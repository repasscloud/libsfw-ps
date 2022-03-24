function Export-JsonManifest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][ValidateSet("Productivity")][System.String]$Category,      #^ select from categories
        [Parameter(Mandatory=$true)][System.String]$Publisher,                                  #^ publisher name
        [Parameter(Mandatory=$true)][System.String]$Name,                                       #^ application name
        [Parameter(Mandatory=$true)][System.String]$Version,                                    #^ application version
        [System.String]$Copyright=[System.String]::Empty,                                       # copyright notice
        [System.Boolean]$LicenseAcceptRequired=$false,                                          # should default to true only if is required
        [Parameter(Mandatory=$true)][ValidateSet("x64","x86")][System.String]$Arch,             #^ architecture of cpu
        [Parameter(Mandatory=$true)][ValidateSet("Exe","Msi")][System.String]$ExecType,         #^ executable type
        [System.String]$FileName=[System.String]::Empty,                                        #% file name
        [System.String]$SHA256=[System.String]::Empty,                                          #% sha256 hash
        [Parameter(Mandatory=$true)][System.String]$FollowUri,                                  #^ uri provided to search for
        [System.String]$AbsoluteUri,                                                            #% the follow_on uri found
        [System.String]$InstallSwitches=[System.String]::Empty,                                 # which install switches
        [System.String]$DisplayName=[System.String]::Empty,                                     #% registry display name (should be provided to identify)
        [System.String]$DisplayPublisher=[System.String]::Empty,                                #% registry display publisher
        [System.String]$DisplayVersion=[System.String]::Empty,                                  #% registry display version
        [ValidateSet("Registry","FileVersion","File")][System.String]$DetectMethod="Registry",  # how is app detected (registry, fileversion, filematched)
        [System.String]$DetectValue=[System.String]::Empty,                                     # the value for the type
        [System.String]$UninstallProcess=[System.String]::Empty,                                #% exe, exe2, msi, etc
        [System.String]$UninstallString=[System.String]::Empty,                                 #% how is the uninstall proceessed (used in conjunction with above)
        [System.String]$UninstallArgs=[System.String]::Empty,                                   #% any arguments to be provided to uninstaller (not for MSI usually)
        [System.String]$Homepage=[System.String]::Empty,                                        # URL of application
        [System.String]$IconUri=[System.String]::Empty,                                         # icon for optechx portal
        [System.String]$Docs=[System.String]::Empty,                                            # documentation link
        [System.String]$License=[System.String]::Empty,                                         # link to license or type of license
        [System.String[]]$Tags,                                                                 # list of tags
        [System.String]$Summary=[System.String]::Empty,                                         # summary of application 
        [System.Boolean]$RebootRequired=$false,                                                 # is a reboot required
        [Parameter(Mandatory=$true)][System.String]$LCID,                                       #^ language being supported here
        [ValidateSet("mc","ftp","http","other")][System.String]$XFT,                            # transfer protocol (mc, ftp, http, etc)
        [ValidateSet("au-syd1-07")][System.String]$Locale="au-syd1-07",                         # 
        [System.String]$RepoGeo=[System.String]::Empty,                                         # 
        [System.String]$Uri_Path=[System.String]::Empty,                                        # 
        [System.Boolean]$Enabled=$true,                                                         # 
        [System.String[]]$DependsOn=[System.String]::Empty,                                     # 
        [System.String]$NuspecUri=[System.String]::Empty,                                       # 
        [System.Version]$SysInfo="4.5.0.0",                                                     # JSON Specification
        [Parameter(Mandatory=$true)][System.String]$OutPath                                     #^ 
    )
    
    begin {
        <# PRELOAD - DO NOT EDIT #>
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
    }
    
    process {
        [System.Guid]$Guid = [System.Guid]::NewGuid().Guid  # auto-generated
        [System.String]$UID                                 # UID ISO:1005 <publisher>.<app_name>_<version>_<arch>_<exe_type>_<lcid> (ie - google-chrome-94.33.110.22-x64-msi_en-US)
        [System.String]$Key                                 # auto-generated

        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) BUILD JSON MANIFEST: [ ${Publisher} ${Name} ${Arch} ]"

        <# JSON DATA STRUCTURE - DO NOT EDIT #>
        $JsonDict = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.id = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.meta = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.install = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.uninstall = [System.Collections.Specialized.OrderedDictionary]@{}
        $JsonDict.sysinfo = [System.Collections.Specialized.OrderedDictionary]@{}

        #region NUSPEC
        # download Nuspec file and check for particulars
        if ($null -notlike $NuspecUri)
        {
            "$([System.Char]::ConvertFromUTF32("0x1F7E2")) NUSPEC XML PROVIDED"
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

        #region UID_KEY
        $UID = "$($Publisher.ToLower().Replace(' ','')).$($Name.ToLower().Replace(' ',''))_${Version}_${Arch}_${ExecType}_${LCID}"
        $Key = "$($Publisher.ToLower().Replace(' ','')).$($Name.ToLower().Replace(' ',''))"
        #endregion UID_KEY
        
        #region ABSOLUTE URI & FILENAME & HASH & LOCALE & REPOGEO
        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) FOLLOW URI: [ ${FollowUri} ]"
        if (-not($AbsoluteUri))
        {
            try {
                $AbsoluteUri = Get-AbsoluteUri -Uri $FollowUri -ErrorAction Stop
                Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) ABSOLUTE URI MATCH"
            }
            catch {
                Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E0")) FOLLOW URI NOT FOUND: [ ${FollowUri} ]"
                $Body = @{
                    title  = "FollowUri Not Found: ${Key}"
                    body   = "FollowUri not found: $FollowUri`r`n`r`n${UID}"
                    labels = @("ci-followuri-not-found")
                } | ConvertTo-Json
                $Headers = @{Authorization = 'token ' + $env:GH_TOKEN}
                $owner = "repasscloud"
                $repository = "libsfw2"
                $NewIssue = Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$owner/$repository/issues" -Body $Body -Headers $Headers -ContentType "application/json"
                $NewIssue.html_url
                exit 1
            }
        }
        $FileName = [System.Web.HttpUtility]::UrlDecode($(Split-Path -Path $AbsoluteUri -Leaf))
        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) FILENAME: [ ${FileName} ]"
        $WebRequestQuery = [System.Net.HttpWebRequest]::Create($AbsoluteUri)
        $WebRequestQuery.Method = "HEAD"
        $WebRequest = $WebRequestQuery.GetResponse()
        $DLFileBytesSize = $WebRequest.ContentLength
        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) DOWNLOAD FILE: [ ${FileName} ]"
        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) TO DIRECTORY:  [ $env:TMP ]"
        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) DL SIZE:       [ ${DLFileBytesSize} ]"
        [System.String]$DownloadFilePath = "$env:TMP\$FileName"

        try
        {
            & dotnet "C:\odf\optechx.DownloadFile.dll" $AbsoluteUri $DownloadFilePath
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) COMPLETE"
        }
        catch
        {
            "$([System.Char]::ConvertFromUTF32("0x1F534")) UNABLE TO DOWNLOAD FILE"
            exit 1
        }

        # Write-Output "Env Path is: $($env:PATH)"
        <# we know the $env:PATH variable contains ';C:\odf' we just can't execute it as the code is .Net Core 2.1 and not an executable file :-( #>
        
        #Invoke-WebRequest -Uri "$AbsoluteUri" -OutFile "$env:TMP\$FileName" -UseBasicParsing
        $SHA256 = Get-FileHash -Path "$env:TMP\$FileName" -Algorithm SHA256 | Select-Object -ExpandProperty Hash
        $Locale = "au-syd1-07"
        $Uri_Path = "apps/${Publisher}/${Name}/${Version}/${Arch}/${FileName}"
        #region ABSOLUTE URI & FILENAME & HASH & LOCALE & REPOGEO

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

        $JsonDict.install.exectype = $ExecType
        $JsonDict.install.installswitches = $InstallSwitches
        $JsonDict.install.rebootrequired = $RebootRequired
        $JsonDict.install.displayname = $DisplayName
        $JsonDict.install.displaypublisher = $DisplayPublisher
        $JsonDict.install.displayversion = $DisplayVersion
        $JsonDict.install.detectmethod = $DetectMethod
        $JsonDict.install.detectvalue = $DetectValue
        
        $JsonDict.uninstall.process = $UninstallProcess
        $JsonDict.uninstall.string = $UninstallString
        $JsonDict.uninstall.args = $UninstallArgs

        $JsonDict.sysinfo = $SysInfo

        $OutFilePath = Join-Path -Path $OutPath -ChildPath "${UID}.json"
        $JsonDict | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutFilePath -Encoding utf8 -Force -Confirm:$false
        #endregion BUILD JSON
    }
    
    end {
        [System.GC]::Collect()
    }
}