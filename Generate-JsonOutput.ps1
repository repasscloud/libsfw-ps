function Export-JsonOutput {
    [CmdletBinding()]
    param (
        [System.Guid]$Guid=[System.Guid]::NewGuid().Guid,           # automatically generate a new guid each and every time
        [System.String]$UID=[System.String]::Empty,                 # unique identifier for app <publisher>.<app_name>_<version>_<arch>_<exe_type>_<lcid> (ie - google-chrome-94.33.110.22-x64-msi_en-US)
        [System.String]$Key=[System.String]::Empty,                 # non-unique identifier <publisher>.<app_name>
        [Required]
        [ValidateSet("Productivity")]
        [System.String]$Category,                                   #^ select from categories
        [Required]
        [System.String]$Publisher,                                  #^ publisher name
        [Required]
        [System.String]$Name,                                       #^ application name
        [Required]
        [System.String]$Version,                                    #^ application version
        [System.String]$Copyright=[System.String]::Empty,           # copyright notice
        [System.Boolean]$LicenseAcceptRequired=$false,              # should default to true only if is required
        [Required]
        [ValidateSet("x64","x86")]
        [System.String]$Arch,                                       #^ architecture of cpu
        [Required]
        [ValidateSet("Exe","Msi")]
        [System.String]$ExecType,                                   #^ executable type
        [System.String]$FileName=[System.String]::Empty,            # file name
        [System.String]$SHA256=[System.String]::Empty,              # sha256 hash
        [Required]                         
        [System.String]$FollowUri,                                  #^ uri provided to search for
        [System.String]$AbsoluteUri=[System.String]::Empty,         # the follow_on uri found
        [System.String]$InstallSwitches=[System.String]::Empty,     # which install switches
        [System.String]$DisplayName=[System.String]::Empty,         # registry display name (should be provided to identify)
        [System.String]$DisplayPublisher=[System.String]::Empty,    # registry display publisher
        [System.String]$DisplayVersion=[System.String]::Empty,      # registry display version
        [System.String]$DetectMethod=[System.String]::Empty,        # how is app detected (registry, fileversion, filematched)
        [System.String]$DetectValue=[System.String]::Empty,         # the value for the type
        [System.String]$UninstallProcess=[System.String]::Empty,    # exe, exe2, msi, etc
        [System.String]$UninstallString=[System.String]::Empty,     # how is the uninstall proceessed (used in conjunction with above)
        [System.String]$UninstallArgs=[System.String]::Empty,       # any arguments to be provided to uninstaller (not for MSI usually)
        [System.String]$Homepage=[System.String]::Empty,            # URL of application
        [System.String]$IconUri=[System.String]::Empty,             # icon for optechx portal
        [System.String]$Docs=[System.String]::Empty,                # documentation link
        [System.String]$License=[System.String]::Empty,             # link to license or type of license
        [System.String[]]$Tags=[System.String]::Empty,              # list of tags
        [System.String]$Summary=[System.String]::Empty,             # summary of application 
        [System.Boolean]$RebootRequired=$false,                     # is a reboot required
        [Required]
        [System.String]$LCID,                                       #^ language being supported here
        [ValidateSet("mc","ftp","http","other")]
        [System.String]$XFT,                                        # transfer protocol (mc, ftp, http, etc)
        [ValidateSet("au-syd1-07")]
        [System.String]$Locale,                                     #
        [System.String]$RepoGeo=[System.String]::Empty,             #
        [System.String]$Uri_Path=[System.String]::Empty,            # 
        [System.Boolean]$Enabled=$true,                             # 
        [System.String[]]$DependsOn=[System.String]::Empty,         # 
        [System.String]$NuspecUri=[System.String]::Empty,           # 
        [System.Version]$SysInfo="4.5.0.0",                         # JSON Specification
        [Required]
        [System.String]$OutPath
    )
    
    BEGIN {
        <# PRELOAD - DO NOT EDIT #>
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer

        function Get-RedirectedUri {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [System.String]$Uri
            )
            process {
                do {
                    try {
                        $request = Invoke-WebRequest -Method Head -Uri $Uri
                        if ($request.BaseResponse.ResponseUri -ne $null) {
                            # This is for Powershell 5
                            $redirectUri = $request.BaseResponse.ResponseUri.AbsoluteUri
                        }
                        elseif ($request.BaseResponse.RequestMessage.RequestUri -ne $null) {
                            # This is for Powershell core
                            $redirectUri = $request.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
                        }
                        $retry = $false
                    }
                    catch {
                        if (($_.Exception.GetType() -match "HttpResponseException") -and ($_.Exception -match "302")) {
                            $Uri = $_.Exception.Response.Headers.Location.AbsoluteUri
                            $retry = $true
                        }
                        else {
                            throw $_
                        }
                    }
                } while ($retry)
                return $redirectUri
            }
        }
        function Get-RedirectedUrl {
            Param (
                [Parameter(Mandatory=$true)]
                [System.String]$url
            )
            $request = [System.Net.WebRequest]::Create($url)
            $request.AllowAutoRedirect = $true
            $request.UserAgent = 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) AppleWebKit/534.6 (KHTML, like Gecko) Chrome/7.0.500.0 Safari/534.6'
            try
            {
                $response = $request.GetResponse()
                $returnValue = $response.ResponseUri.AbsoluteUri
                $response.Close()
            }
            catch
            {
                "Error: $_"
            }
            return $returnValue
        }
    }
    
    PROCESS {
        <# JSON DATA STRUCTURE - DO NOT EDIT #>
        $JsonDict = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.id = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.meta = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.installer = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.uninstaller = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.sysinfo = [System.Collections.Specialized.OrderedDictionary]@{}

        #region NUSPEC
        # download Nuspec file and check for particulars
        if ($null -notlike $NuspecUri)
        {
            if (Test-Path -Path "$($env:TMP)\nuspec.xml") { Remove-Item -Path "$($env:TMP)\nuspec.xml" -Confirm:$false -Force }
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("user-agent", $userAgent)
            $wc.DownloadFile($NuspecUri, "$($env:TMP)\nuspec.xml")
            $wc.Dispose()
            try
            {
                # now that Nuspec is downloaded and verified, try to get data out of it
                [xml]$XmlNuspec = Get-Content -Path "$($env:TMP)\nuspec.xml" -ErrorAction Stop
                # if ($XmlNuspec.package.metadata.version) { if(-not($Version)){$Version=$XmlNuspec.package.metadata.version} }
                # if ($XmlNuspec.package.metadata.authors) { if(-not($Publisher)){$Publisher=$XmlNuspec.package.metadata.authors} }
                if ($XmlNuspec.package.metadata.projectUrl) { if(-not($Homepage)){$Homepage=$XmlNuspec.package.metadata.projectUrl} }
                if ($XmlNuspec.package.metadata.docsUrl) { if(-not($Docs)){$Docs=$XmlNuspec.package.metadata.docsUrl} }
                if ($XmlNuspec.package.metadata.iconUrl) { if(-not($IconUri)){$IconUri=$XmlNuspec.package.metadata.iconUrl} }
                if ($XmlNuspec.package.metadata.copyright) { if(-not($Copyright)){$Copyright=$XmlNuspec.package.metadata.copyright} }
                if ($XmlNuspec.package.metadata.licenseUrl) { if(-not($License)){$License=$XmlNuspec.package.metadata.licenseUrl} }
                if ($XmlNuspec.package.metadata.requireLicenseAcceptance) { if('true' -like $XmlNuspec.package.metadata.requireLicenseAcceptance){$LicenseAcceptRequired=$true}else{$LicenseAcceptRequired=$false} }
                # if ($XmlNuspec.package.metadata.id) { if(-not($Name)){$Name=$XmlNuspec.package.metadata.id} }
                if ($XmlNuspec.package.metadata.summary) { if(-not($Summary)){$Summary=$XmlNuspec.package.metadata.summary} }
                if ($XmlNuspec.package.metadata.tags) { if(-not($Tags)){$Tags=($XmlNuspec.package.metadata.tags).Split(' ')} }
                # if ($XmlNuspec.package.metadata.dependencies) { $DependsOn }
            }
            catch
            {
                Write-Output "Nuspec file could not be read or did not download"
            }
        }
        else
        {
            Write-Output "Nuspec URI not provided"    
        }
        #endregion NUSPEC
        
        #region ABSOLUTE URI & FILENAME & HASH & LOCALE
        if (-not($AbsoluteUri))
        {
            try { [System.String]$Url01 = Get-RedirectedUri -Uri $FollowUri -ErrorAction Stop } catch { $Url01 = $null }
            try { [System.String]$Url02 = Get-RedirectedUrl -url $FollowUri -ErrorAction Stop } catch { $Url02 = $null }

            if (-not($Url01 -like $Url02))
            {
                if ($null -notlike $Url01) { $AbsoluteUri=$Url01}
                elseif ($null -notlike $Url02) { $AbsoluteUri=$Url02}
                else { exit 1 }
            }
        }
        $FileName = [System.Web.HttpUtility]::UrlDecode($(Split-Path -Path $AbsoluteUri -Leaf))
        Invoke-WebRequest -Uri "$AbsoluteUri" -OutFile "$env:TMP\$FileName" -UseBasicParsing
        $SHA256 = Get-FileHash -Path "$env:TMP\$FileName" -Algorithm SHA256 | Select-Object -ExpandProperty Hash
        $Locale = "apps/${Publisher}/${Name}/${Version}/${Arch}/${FileName}"
        #endregion ABSOLUTE URI & FILENAME & HASH & LOCALE

        #region UID_KEY
        $UID = "$($Publisher.ToLower().Replace(' ','')).$($Name.ToLower().Replace(' ',''))_${Version}_${Arch}_${ExecType}_${LCID}"
        $Key = "$($Publisher.ToLower().Replace(' ','')).$($Name.ToLower().Replace(' ',''))"
        #endregion UID_KEY

        #region BUILD JSON
        $JsonDict.guid = $Guid.ToString()
        $JsonDict.id.publisher = $Publisher
        $JsonDict.id.name = $Name
        $JsonDict.id.version = $Version
        $JsonDict.id.arch = $Arch
        $JsonDict.id.lcid = $LCID
        $JsonDict.id.uid = $UID
        $JsonDict.id.key = $Key
        $JsonDict.id.category = $Category

        $JsonDict.meta.sha256 = $SHA256
        $JsonDict.meta.filename = $FileName
        $JsonDict.meta.followuri = $FollowUri
        $JsonDict.meta.absoluteuri = $AbsoluteUri
        $JsonDict.meta.copyright = $Copyright
        $JsonDict.meta.license = $License
        $JsonDict.meta.licenseacceptrequired = $LicenseAcceptRequired
        $JsonDict.meta.homepage = $Homepage
        $JsonDict.meta.iconuri = $IconUri
        $JsonDict.meta.docs = $Docs
        $JsonDict.meta.summary = $Summary
        $JsonDict.meta.tags = $Tags
        $JsonDict.meta.summary = $Summary
        $JsonDict.meta.xft = $XFT
        $JsonDict.meta.locale = $Locale
        $JsonDict.meta.repogeo = $RepoGeo
        $JsonDict.meta.uripath = $Uri_Path
        $JsonDict.meta.enabled = $Enabled
        $JsonDict.meta.dependson = $DependsOn
        $JsonDict.meta.nuspecuri = $NuspecUri

        $JsonDict.installer.exectype = $ExecType
        $JsonDict.installer.installswitches = $InstallSwitches
        $JsonDict.installer.rebootrequired = $RebootRequired
        $JsonDict.installer.displayname = $DisplayName
        $JsonDict.installer.displaypublisher = $DisplayPublisher
        $JsonDict.installer.displayversion = $DisplayVersion
        $JsonDict.installer.detectmethod = $DetectMethod
        $JsonDict.installer.detectvalue = $DetectValue
        
        $JsonDict.uninstall.process = $UninstallProcess
        $JsonDict.uninstall.string = $UninstallString
        $JsonDict.uninstall.args = $UninstallArgs

        $OutFilePath = JoinPath -Path $OutPath -ChildPath "${UID}.json"
        $JsonDict | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutFilePath -Encoding utf8 -Force -Confirm:$false
        #endregion BUILD JSON
    }
    
    END {
        [System.GC]::Collect()
    }
}