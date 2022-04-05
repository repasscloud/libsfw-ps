function Complete-UrlVTScan {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   Position=0,
                   HelpMessage="Absolute URL to run security scans.")]
        [Alias("URI")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $URL,

        [Parameter(Mandatory=$true,
                   Position=1,
                   HelpMessage="VirusTotal API Key to action scans.")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ApiKey
    )
    
    begin {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    }
    
    process {
        <# SUBMIT URL TO BE SCANNED #>
        $headers=@{}
        $headers.Add("Accept", "application/json")
        $headers.Add("x-apikey", "${ApiKey}")
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")
        $response = Invoke-WebRequest -Uri 'https://www.virustotal.com/api/v3/urls' -Method POST -Headers $headers -ContentType 'application/x-www-form-urlencoded' -Body "url=${URL}"
        $output = $response.Content | ConvertFrom-Json
        $analysisId = $output.data.id   # return data captured

        <# ENCODE URL TO SCAN TO BASE64 #>
        $readableText = "${URL}"
        $encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($readableText)
        $encodedText = [System.Convert]::ToBase64String($encodedBytes)

        <# SUBMIT URL FOR REPORT OF URL #>
        $headers=@{}
        $headers.Add("Accept", "application/json")
        $headers.Add("x-apikey", "${ApiKey}")
        $response = Invoke-WebRequest -Uri "https://www.virustotal.com/api/v3/urls/${encodedText}" -Method GET -Headers $headers
        $output = $response.Content | ConvertFrom-Json
        $harmlessCount = $output.data.attributes.last_analysis_stats.harmless       # return data captured
        $maliciousCount = $output.data.attributes.last_analysis_stats.malicious     # return data captured
        $suspiciousCount = $output.data.attributes.last_analysis_stats.suspicious   # return data captured
        $undetectedCount = $output.data.attributes.last_analysis_stats.undetected   # return data captured
        $timeoutCount = $output.data.attributes.last_analysis_stats.timeout         # return data captured

        <# RETURN DATA #>
        return $analysisId,$harmlessCount,$maliciousCount,$suspiciousCount,$undetectedCount,$timeoutCount
    }
    
    end {
        [System.GC]::Collect()
    }
}
