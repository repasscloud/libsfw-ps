function Read-XmlMetaFile {
    [CmdletBinding()]
    param (
        [System.String]$XmlURI
    )
    
    begin {
        [System.String]$XmlDLPath = "$env:TEMP\nuspec.xml"
        [System.String]$AgentString = ' Mozilla/5.0 (compatible; MSIE 9.0; Windows NT; Windows NT 10.0; en-US)'
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
            if ($null -ne $x.package.metadata.projectUrl) { [System.String]$homepage = $x.package.metadata.projectUrl } else { [System.String]$homepage = '' }
            if ($null -ne $x.package.metadata.iconUrl) { [System.String]$icon = $x.package.metadata.iconUrl } else { [System.String]$icon = '' }
            if ($null -ne $x.package.metadata.copyright) { [System.String]$copyright = $x.package.metadata.copyright } else { [System.String]$copyright = '' }
            if ($null -ne $x.package.metadata.licenseUrl) { [System.String]$license = $x.package.metadata.licenseUrl } else { [System.String]$license = '' }
            if ($null -ne $x.package.metadata.docsUrl) { [System.String]$docs = $x.package.metadata.docsUrl } else { [System.String]$docs = '' }
            if ($null -ne $x.package.metadata.tags) { [System.String]$tags = $x.package.metadata.tags } else { [System.String]$tags = '' }
            if ($null -ne $x.package.metadata.summary) { [System.String]$summary = $x.package.metadata.summary } else { [System.String]$summary = '' }

            if (Test-Path -Path $XmlDLPath) { Remove-Item -Path $XmlDLPath -Confirm:$false -Force }
        }
        catch
        {
            $wc.Dispose()

            # meta data
            [System.String]$homepage =  [System.String]::Empty
            [System.String]$icon = [System.String]::Empty
            [System.String]$copyright = [System.String]::Empty
            [System.String]$license = [System.String]::Empty
            [System.String]$docs = [System.String]::Empty
            [System.String]$tags = [System.String]::Empty
            [System.String]$summary = [System.String]::Empty
        }

        # bundle the data into an array to be returned
        [System.Array]$returnArray = @($homepage, $icon, $copyright, $license, $docs, $tags, $summary)

        return $returnArray
    }
    
    end {
        [System.GC]::Collect()
    }
}
