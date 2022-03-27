function New-VirusTotalScan {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.String]$FileName,
        [Parameter(Mandatory=$true)][System.String]$FileName,
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}

#/api/VirusTotalScanResults
$headers = [System.Collections.Specialized.OrderedDictionary]@{}
$headers.Authorization = "Basic dXNlck5hbWU6cGFzc3dvcmQ="
[System.String]$FileName = "$env:TMP\AcroRdrDC2101120039_MUI.exe"
$hash = Get-FileHash -Path $FileName -Algorithm SHA256 | Select-Object -ExpandProperty Hash
$headers = [System.Collections.Specialized.OrderedDictionary]@{}
$headers.Add("Accept", "application/json")
$headers.Add("x-apikey", "30f77c3ea3d5f9d5037d17930dee009bd634f8387485655e8901bbfa9fe27bc4")
$response = Invoke-RestMethod -Uri "https://www.virustotal.com/api/v3/files/${hash}" -Headers $headers
$aly_sts = $response.data.attributes.last_analysis_stats
$aly_ttl = $aly_sts.'harmless' + $aly_sts.'type-unsupported' + $aly_sts.'suspicious' + $aly_sts.'confirmed-timeout' + $aly_sts.'timeout' + $aly_sts.'failure' + $aly_sts.'malicious' + $aly_sts.'undetected'
$aly_safety_percentage = [System.Int32]((($aly_sts.'harmless' + $aly_sts.'undetected')/$aly_ttl) * 100)
$payload = [System.Collections.Specialized.OrderedDictionary]@{}
$payload.id = 0
$payload.uuid = [System.Guid]::NewGuid()
$payload.hash_Scanned = $hash
$payload.filename = $FileName
$payload.tlsh = $response.data.attributes.tlsh
$payload.vhash = $response.data.attributes.vhash
$payload.stats_Harmless = $aly_sts.'harmless'
$payload.stats_Type_Unsupported = $aly_sts.'type-unsupported'
$payload.stats_Suspicious = $aly_sts.'suspicious'
$payload.stats_Confirmed_Timeout = $aly_sts.'confirmed-timeout'
$payload.stats_Timeout = $aly_sts.'timeout'
$payload.stats_Failure = $aly_sts.'failure'
$payload.stats_Malicious = $aly_sts.'malicious'
$payload.stats_Undetected = $aly_sts.'undetected'
$payload.stats_Total_Count = $aly_ttl
$payload.stats_Safety_Percentage = [System.Int32]((($aly_sts.'harmless' + $aly_sts.'undetected')/$aly_ttl) * 100)
$payload.is_Safe = if ($aly_safety_percentage -gt 70){ $true } else { $false }
$json = $payload | ConvertTo-Json -Depth 4
$ApiResponse = Invoke-WebRequest -Uri http://localhost:8080/api/VirusTotalScanResults -ContentType 'application/json' -Method Post -Body $json -Headers $headers



~/Projects/optechx/optechx.api [dev-net5.0/refresh4 ≡]> $ApiResponse.Content | ConvertFrom-Json


id                      : 3
uuid                    : d6891fea-8313-4d7d-b8bc-74f5b9cfc0b4
hash_Scanned            : 021C69296F5ABEA1683602F7EDBF98471294543CBA580E8373A9B97FCD4E6742
filename                : /Users/danijel-rpc/tmp\AcroRdrDC2101120039_MUI.exe
tlsh                    : T1BEF83328D6EB677BE10AE875D470A1511B872E949F2063C7E390393F3DA0546EB3C366
vhash                   : 038056655d1d1570c4z19009d7z5055z7040073fz
stats_Harmless          : 0
stats_Type_Unsupported  : 7
stats_Suspicious        : 0
stats_Confirmed_Timeout : 0
stats_Timeout           : 5
stats_Failure           : 3
stats_Malicious         : 0
stats_Undetected        : 57
stats_Total_Count       : 72
stats_Safety_Percentage : 79
is_Safe                 : True