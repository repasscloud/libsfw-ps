function Get-InstallerPackage {
    [CmdletBinding()]
    param (
        [System.String]$DLUri,
        [System.String]$DLFile,
        [System.String]$DLPath
    )
    
    begin {
        [System.String]$AgentString = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT; Windows NT 10.0; en-US)'
    }
    
    process {

        [System.String]$OutputPath = Join-Path -Path $DLPath -ChildPath $DLFile

        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("user-agent", $AgentString)

        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E0")) DOWNLOADING FILE: ${DLFile}"

        try
        {
            $wc.DownloadFile("${DLUri}", "${OutputPath}")
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) FILE DOWNLOADED TO: ${OutputPath}"
            $wc.Dispose()     
        }
        catch
        {
            $wc.Dispose()
            Write-Output "$([char]::ConvertFromUTF32("0x1F534")) DOWNLOAD FAILED FOR FILE: ${DLUri}"
            exit 1
        }     
    }
    
    end {
        [System.GC]::Collect()
    }
}