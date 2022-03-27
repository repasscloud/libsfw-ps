function Read-XmlMetaFile {
    [CmdletBinding()]
    param (
        [System.String]$XmlURI
    )
    
    begin {
        [System.String]$XmlDLPath = "$env:TEMP\nuspec.xml"
        [System.String]$AgentString = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT; Windows NT 10.0; en-US)'
    }
    
    process {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("user-agent", $AgentString)
        if (Test-Path -Path $XmlDLPath) { Remove-Item -Path $XmlDLPath -Confirm:$false -Force }

        try
        {
            $wc.DownloadFile($XmlURI, $XmlDLPath)
            $wc.Dispose()

            [xml]$x = Get-Content -Path $XmlDLPath

            # meta data
            if ($null -ne $x.package.metadata.projectUrl) { [System.String]$Homepage = $x.package.metadata.projectUrl } else { [System.String]$Homepage = '' }
            if ($null -ne $x.package.metadata.iconUrl) { [System.String]$Icon = $x.package.metadata.iconUrl } else { [System.String]$Icon = '' }
            if ($null -ne $x.package.metadata.copyright) { [System.String]$Copyright = $x.package.metadata.copyright } else { [System.String]$Copyright = '' }
            if ($null -ne $x.package.metadata.licenseUrl) { [System.String]$License = $x.package.metadata.licenseUrl } else { [System.String]$License = '' }
            if ($null -ne $x.package.metadata.docsUrl) { [System.String]$Docs = $x.package.metadata.docsUrl } else { [System.String]$Docs = '' }
            if ($null -ne $x.package.metadata.tags) { [System.String]$Tags = $x.package.metadata.tags } else { [System.String]$Tags = '' }
            if ($null -ne $x.package.metadata.summary) { [System.String]$Summary = $x.package.metadata.summary } else { [System.String]$Summary = '' }

            if (Test-Path -Path $XmlDLPath) { Remove-Item -Path $XmlDLPath -Confirm:$false -Force }
        }
        catch
        {
            $wc.Dispose()

            # meta data
            [System.String]$Homepage =  [System.String]::Empty
            [System.String]$Icon = [System.String]::Empty
            [System.String]$Copyright = [System.String]::Empty
            [System.String]$License = [System.String]::Empty
            [System.String]$Docs = [System.String]::Empty
            [System.String]$Tags = [System.String]::Empty
            [System.String]$Summary = [System.String]::Empty
        }

        # bundle the data into an array to be returned
        [System.Array]$ReturnArray = @($Homepage, $Icon, $Copyright, $License, $Docs, $Tags, $Summary)

        return $ReturnArray
    }
    
    end {
        [System.GC]::Collect()
    }
}
