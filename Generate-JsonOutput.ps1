function Export-JsonOutput {
    [CmdletBinding()]
    param (
        [System.String]$NuspecUri,
        [System.String]$Homepage,
        [System.String]$IconUri,
        [System.String]$Copyright,
        [System.String]$License,
        [System.Bool]$LicenseAcceptRequired=$false,
        [System.String]$Docs,
        [System.String]$Tags,
        [System.String]$Summary,
        [Required]
        [ValidateSet("True","False")]
        [System.String]$RebootRequired,
        [System.String]$Depends,
        [ValidateSet("Productivity")]
        [System.String]$Category,
        [ValidateSet("mc")]
        [System.String]$XFT,
        [ValidateSet("au-syd1-07")]
        [System.String]$Locale,
        [Required]
        [System.String]$Version,
        [System.String]$Name,
        [System.String]$Publisher,
        [System.String]$Arch,
        [System.String]$LCID,
        [System.String]$UID,
        [ValidateSet("Exe","Msi")]
        [System.String]$Type,
        [System.String]$FileName,
        [System.String]$SHA256,
        [System.String]$FollowUri,
        [System.String]$Switches,
        [System.String]$DisplayName,
        [System.String]$DisplayVersion,
        [System.String]$DisplayPublisher,
        [System.String]$Path,
        [ValidateSet("au-syd1-07")]
        [System.String]$Geo,
        [System.String]$UninstallString,
        [System.String]$UninstallArgs,
        [System.String]$SysInfo="4.4.0.2"  # licenseacceptrequired

    )
    
    begin {
        <# PRELOAD - DO NOT EDIT #>
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer

        <# JSON DATA STRUCTURE - DO NOT EDIT #>
        $JsonDict = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.meta = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.id = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.installer = [System.Collections.Specialized.OrderedDictionary]@{}
        $dJsonDict.uninstaller = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.sysinfo = [System.Collections.Specialized.OrderedDictionary]@{}
    }
    
    process {
        # download Nuspec file
        if ($null -notlike $NuspecUri)
        {
            if (Test-Path -Path "$($env:TMP)\nuspec.xml") { Remove-Item -Path "$($env:TMP)\nuspec.xml" -Confirm:$false -Force }
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("user-agent", $userAgent)
            try
            {
                $wc.DownloadFile($NuspecUri, "$($env:TMP)\nuspec.xml")
                $wc.Dispose()
                [xml]$XmlNuspec = Get-Content -Path "$($env:TMP)\nuspec.xml"
                $AppVersionFromRegex = $XmlNuspec.package.metadata.version
                Remove-Item -Path "$($env:TMP)\nuspec.xml" -Confirm:$false -Force
            }
            catch
            {
                Write-Output "Version info cannot be confirmed"
            }
        }
        else
        {
            Write-Output "Nuspec URI not provided"    
        }

        if ($null -notlike $Version)
        {
            switch ($Version -like $AppVersionFromRegex)
            {
                $True {
                    # Nuspec file match
                    $JsonDict.id.version = $AppVersionFromRegex
                }
                Default {
                    # Nuspec file did not match
                    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) NUSPEC DID NOT MATCH VERSION PROVIDED"
                    $JsonDict.id.version = $Version
                }
            }
        }
    }
    
    end {
        
    }
}