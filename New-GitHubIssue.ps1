function New-GitHubIssue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.String]$Title,
        [Parameter(Mandatory=$true)][System.String]$Body,
        [Parameter(Mandatory=$true)][System.String[]]$Labels,
        [Parameter(Mandatory=$true)][System.String]$Repository,
        [Parameter(Mandatory=$false)][System.String]$Owner='repasscloud',
        [Parameter(Mandatory=$false)][System.String]$Token=$env:GH_TOKEN
    )
    
    begin {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
    
    process {
        $Headers = @{Authorization = 'token ' + $env:GH_TOKEN}
        $Body = @{
            title  = "${Title}"
            body   = "${Body}"
            labels = $Labels
        } | ConvertTo-Json
        $NewIssue = Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$owner/$repository/issues" -Body $Body -Headers $Headers -ContentType "application/json"
        return $NewIssue.html_url
    }
    
    end {
        [System.GC]::Collect()
    }
}
