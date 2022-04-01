function New-VirusTotalScan {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][System.String]$FilePath,
        [Parameter(Mandatory=$true)][System.String]$ApiKey,
        [Parameter(Mandatory=$false)][System.String]$BaseUri='http://localhost:8080'
    )
    begin {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
    process {
        
        [System.String]$FileName = Split-Path -Path $FilePath -Leaf

        if (Test-Path -Path $FilePath)
        {
            $SHA256 = Get-FileHash -Path $FilePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
            $headers=@{}
            $headers.Add("Accept", "application/json")
            $headers.Add("x-apikey", "${ApiKey}")
            
            try
            {
                $VTResponse = Invoke-WebRequest -Uri "https://www.virustotal.com/api/v3/files/${SHA256}" -Method GET -Headers $headers -ErrorAction Stop
                $StatusCode = $VTResponse.StatusCode
            }
            catch
            {
                $StatusCode = $_.Exception.Response.StatusCode.value__
            }

            if ($StatusCode -eq 200)
            {
                $aly_sts = $VTResponse.data.attributes.last_analysis_stats
                $aly_sts
                $aly_ttl = $aly_sts.'harmless' + $aly_sts.'type-unsupported' + $aly_sts.'suspicious' + $aly_sts.'confirmed-timeout' + $aly_sts.'timeout' + $aly_sts.'failure' + $aly_sts.'malicious' + $aly_sts.'undetected'
                $aly_safety_percentage = if ($aly_ttl -eq 0 -or $nul -eq $aly_ttl){100}else{[System.Int32]((($aly_sts.'harmless' + $aly_sts.'undetected')/$aly_ttl) * 100)}
                $Payload = [System.Collections.Specialized.OrderedDictionary]@{}
                $Payload.id = 0
                $Payload.uuid = [System.Guid]::NewGuid()
                $Payload.hashScanned = $SHA256
                $Payload.filename = $FileName
                $Payload.tlsh = if($null -eq $VTResponse.data.attributes.tlsh){"no_value"}else{$VTResponse.data.attributes.tlsh}
                $Payload.vhash = if($null -eq $VTResponse.data.attributes.vhash){"no_value"}else{$VTResponse.data.attributes.vhash}
                $Payload.statsHarmless = if($null -eq $aly_sts.'harmless'){0}else{$aly_sts.'harmless'}
                $Payload.statsTypeUnsupported = if($null -eq $aly_sts.'type-unsupported'){0}else{$aly_sts.'type-unsupported'}
                $Payload.statsSuspicious = if($null -eq $aly_sts.'suspicious'){0}else{$aly_sts.'suspicious'}
                $Payload.statsConfirmedTimeout = if($null -eq $aly_sts.'confirmed-timeout'){0}else{$aly_sts.'confirmed-timeout'}
                $Payload.statsTimeout = if($null -eq $aly_sts.'timeout'){0}else{$aly_sts.'timeout'}
                $Payload.statsFailure = if($null -eq $aly_sts.'failure'){0}else{$aly_sts.'failure'}
                $Payload.statsMalicious = if($null -eq $aly_sts.'malicious'){0}else{$aly_sts.'malicious'}
                $Payload.statsUndetected = if($null -eq $aly_sts.'undetected'){0}else{$aly_sts.'undetected'}
                $Payload.statsTotalCount = if($null -eq $aly_ttl){0}else{$aly_ttl}
                try
                {
                    $Payload.statsSafetyPercentage = [System.Int32]((($aly_sts.'harmless' + $aly_sts.'undetected')/$aly_ttl) * 100)
                }
                catch
                {
                    $Payload.statsSafetyPercentage = 100
                }
                $Payload.isSafe = if ($aly_safety_percentage -gt 70){ $true } else { $false }
                $Body = $Payload | ConvertTo-Json -Depth 4
                $return = Invoke-RestMethod -Uri "${BaseUri}/api/VirusTotalScan" -Method Post -UseBasicParsing -Body $Body -ContentType "application/json" -ErrorAction Stop
                return $return
                
            }
            else
            {
                return 1
            }
        }

    }
    end {
        [System.Gc]::Collect()
    }
}
