function Export-JsonManifest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
            [ValidateSet("Productivity","Microsoft","Utility","Developer Tools",
            "Games","Photo & Design","Entertainment","Security","Education",
            "Internet","Lifestyles")]
        [System.String]$Category,                                                               #^ select from categories
        [Parameter(Mandatory=$true)][System.String]$Publisher,                                  #^ publisher name
        [Parameter(Mandatory=$true)][System.String]$Name,                                       #^ application name
        [Parameter(Mandatory=$true)][System.String]$Version,                                    #^ application version
        [System.String]$Copyright=[System.String]::Empty,                                       # copyright notice
        [System.Boolean]$LicenseAcceptRequired=$false,                                          # should default to true only if is required
        [System.Boolean]$RebootRequired=$false,                                                 # is a reboot required
        [Parameter(Mandatory=$true)][System.String]$Lcid,                                       #^ language being supported here  <~ too many languages to isolate here https://github.com/repasscloud/libsfw-ps/issues/5#issuecomment-1086025038
        [Parameter(Mandatory=$true)]
            [ValidateSet("x64","x86","aarch32","arm64")]
            [System.String]$Arch,                                                               #^ architecture of cpu
        [System.String]$FileName=[System.String]::Empty,                                        #% file name
        [System.String]$SHA256=[System.String]::Empty,                                          #% sha256 hash
        [Parameter(Mandatory=$true)][System.String]$FollowUri,                                  #^ uri provided to search for
        [System.String]$AbsoluteUri,                                                            #% the follow_on uri found
        [Parameter(Mandatory=$true)]
        [ValidateSet("msi","msix","exe","bat","ps1","zip","script","cab")]
            [System.String]$ExecType,                                                           #^ executable type
        [System.String]$InstallCmd=[System.String]::Empty,                                      # which install cmd
        [System.String]$InstallArgs=[System.String]::Empty,                                     # which install arguments
        [System.String]$InstallScript=[System.String]::Empty,                                   # which install script, must be a full script, used for LoB apps
        [System.String]$DisplayName=[System.String]::Empty,                                     #% registry display name (should be provided to identify)
        [System.String]$DisplayPublisher=[System.String]::Empty,                                #% registry display publisher
        [System.String]$DisplayVersion=[System.String]::Empty,                                  #% registry display version
        [ValidateSet("Registry","FileVersion","File","Script","Void")]
            [System.String]$DetectMethod,                                                       # how is app detected (registry, fileversion, filematched, script)
        [System.String]$DetectValue=[System.String]::Empty,                                     # the value for the DetectMethod, not compatible with DetectScript
        [System.String]$DetectScript=[System.String]::Empty,                                    # script to detect application, used for LoB apps
        [Parameter(Mandatory=$true)]
            [ValidateSet("void_uninstall","msi","exe","exe2","inno","script")]
            [System.String]$UninstallProcess=[System.String]::Empty,                            #% exe, exe2, msi, etc
        [System.String]$UninstallCmd=[System.String]::Empty,                                    # how is the uninstall proceessed (used with -UninstallProcess)
        [System.String]$UninstallArgs=[System.String]::Empty,                                   # any arguments to be provided to uninstaller (not for MSI usually)
        [System.String]$UninstallScript=[System.String]::Empty,                                 # uninstall script, used for LoB apps
        [System.String]$Homepage=[System.String]::Empty,                                        # URL of application
        [System.String]$IconUri=[System.String]::Empty,                                         # icon for optechx portal
        [System.String]$Docs=[System.String]::Empty,                                            # documentation link
        [System.String]$License=[System.String]::Empty,                                         # link to license or type of license
        [System.String[]]$Tags,                                                                 # list of tags
        [System.String]$Summary=[System.String]::Empty,                                         # summary of application 
        [Parameter(Mandatory=$true)]
            [ValidateSet("mc","ftp","sftp","ftpes","http","https","s3","other")]
            [System.String]$XFT,                                                                #^ transfer protocol (mc, ftp, http, etc)
        [System.String]$Locale="upcloud_au_syd_07",                                             # 
        [System.String]$UriPath=[System.String]::Empty,                                        # 
        [System.Boolean]$Enabled=$true,                                                         # 
        [System.String[]]$DependsOn=[System.String]::Empty,                                     # 
        [System.String]$NuspecUri=[System.String]::Empty,                                       # 
        [System.Version]$SysInfo="4.6.0.0",                                                     # JSON Specification
        [Parameter(Mandatory=$true)][System.String]$OutPath                                     #^ 

    )
    
    begin
    {
        <# PRELOAD - DO NOT EDIT #>
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
    }
    
    process
    {
        <# AUTO GENERATE UUID/GUID #>
        [System.Guid]$Guid = [System.Guid]::NewGuid().Guid

        <# ESTABLISH UID AND KEY #>
        [System.String]$UID  # UID ISO:1006 <publisher>::<app_name>::<version>::<arch>::<exe_type>::<lcid> (ie - google::chrome::94.33.110.22::x64::msi::en-US)
        [System.String]$Key  # auto-generated further down
        $UID = "$($Publisher.ToLower().Replace(' ',''))::$($Name.ToLower().Replace(' ',''))::${Version}::${Arch}::${ExecType}::${Lcid}"
        $Key = "$($Publisher.ToLower().Replace(' ',''))::$($Name.ToLower().Replace(' ',''))"

        <# VERIFY UID AGAINST API #>
        $CHeaders = @{accept = 'text/json'}
        try
        {
            Invoke-RestMethod -Uri "${env:API_BASE_URI}/api/Application/uid/${UID}" -Method Get -Headers $CHeaders -ErrorAction Stop | Out-Null
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) APPLICATION MATCHED: [ ${UID} ]"
            # go to end, nothing left to do
        }
        catch
        {
            <# START MAIN PROCESS AS CATCH STATEMENT #>
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) BUILDING JSON MANIFEST: [ ${Publisher} ${Name} ${Arch} ${ExecType} ]"

            <# JSON DATA STRUCTURE - DO NOT EDIT #>
            $JsonDict = [System.Collections.Specialized.OrderedDictionary]@{}
            $JsonDict.id = [System.Collections.Specialized.OrderedDictionary]@{}
            $JsonDict.meta = [System.Collections.Specialized.OrderedDictionary]@{}
            $JsonDict.install = [System.Collections.Specialized.OrderedDictionary]@{}
            $JsonDict.uninstall = [System.Collections.Specialized.OrderedDictionary]@{}
            $JsonDict.security = [System.Collections.Specialized.OrderedDictionary]@{}
            $JsonDict.sysinfo = [System.Collections.Specialized.OrderedDictionary]@{}

            <# NUSPEC FILE INGEST #>
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
                    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) NUSPEC COULD NOT BE READ OR DID NOT DOWNLOAD"
                }
            }
            else
            {
                Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E0")) NUSPEC NOT PROVIDED"
            }
            
            <# ABSOLUTE URI AND FOLLOW URI #>
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) FOLLOW URI: [ ${FollowUri} ]"
            if (-not($AbsoluteUri))
            {
                try
                {
                    $AbsoluteUri = Get-AbsoluteUri -Uri $FollowUri -ErrorAction Stop
                    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) ABSOLUTE URI MATCH"
                }
                catch
                {
                    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E0")) FOLLOW URI NOT FOUND: [ ${FollowUri} ]"
                    [System.String]$GHIssueNumber = New-GitHubIssue -Title "FollowUri Not Found: ${UID}" -Body "FollowUri Not Found: $FollowUri`r`n`r`nUID: ${UID}" -Labels @("ci-followuri-not-found") -Repository 'libsfw2' -Token $env:GH_TOKEN
                    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) GH Issue: ${GHIssueNumber}"
                    return
                }
            }

            <# DECLARE FILENAME #>
            if ($FileName -ne [System.String]::Empty)
            {
                $FileName = [System.Web.HttpUtility]::UrlDecode($(Split-Path -Path $AbsoluteUri -Leaf))
            }
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) FILENAME: [ ${FileName} ]"

            <# DOWNLOAD FILE FROM PUBLIC URI #>
            $WebRequestQuery = [System.Net.HttpWebRequest]::Create($AbsoluteUri)
            $WebRequest = $WebRequestQuery.GetResponse()
            $DLFileBytesSize = $WebRequest.ContentLength
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) DOWNLOAD FILE: [ ${FileName} ]"
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) TO DIRECTORY:  [ $env:TMP ]"
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) DL SIZE:       [ ${DLFileBytesSize} ]"

            <# SET DOWNLOAD FILE PATH #>
            [System.String]$DownloadFilePath = "$env:TMP\$FileName"

            <# DOWNLOAD FILE LOCALLY TO $ENV:TMP DIRECTORY #>
            try
            {
                <# We know the $env:PATH variable contains ';C:\odf' we just can't use it as ODF is a .Net Core 2.1 DLL and not an EXE file to call #>
                & dotnet "C:\odf\optechx.DownloadFile.dll" $AbsoluteUri $DownloadFilePath
                Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) DOWNLOAD VERIFIED"
            }
            catch
            {
                "$([System.Char]::ConvertFromUTF32("0x1F534")) UNABLE TO DOWNLOAD FILE"
                [System.String]$GHIssueNumber = New-GitHubIssue -Title "Unable to download file: ${UID}" -Body "File not downloaded using odf: $FileName`r`n`r`nUID: ${UID}" -Labels @("ci-file-not-downloaded") -Repository 'libsfw-ps' -Token $env:GH_TOKEN
                return
            }
            
            <# SET SHA256 #>
            $SHA256 = Get-FileHash -Path "$env:TMP\$FileName" -Algorithm SHA256 | Select-Object -ExpandProperty Hash

            <# URI PATH AND UPLOAD (IF REQUIRED) #>
            switch ($XFT)
            {
                "mc" {
                    $UriPath = "apps/${Publisher}/${Name}/${Version}/${Arch}/${FileName}"
                    try {
                        (mc cp "${DownloadFilePath}" $Locale/$UriPath) 2>&1>$null
                        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) PACKAGE UPLOADED VIA: [ mc ]"
                        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) UPLOAD PATH: [ ${UriPath} ]"
                    }
                    catch {
                        Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) UNABLE TO UPLOAD VIA [ mc ]"
                        return
                    }
                }
                default {
                    $UriPath = "FILE NOT UPLOADED"
                }
            }

            #region Security Scans
            #$VTScanResultsId = New-VirusTotalScan -ApiKey $env:VT_API_KEY -FilePath "$env:TMP\$FileName" -BaseUri $env:API_BASE_URI
            $VTScanResultsId = 1
            #endregion Security Scans


            # does the application already have the required fields populated? If so, do not install and skip to the end
            if (-not([System.String]::Empty -notlike $DisplayName -and `
            [System.String]::Empty -notlike $DisplayVersion -and `
            [System.String]::Empty -notlike $DisplayPublisher -and `
            [System.String]::Empty -notlike $UninstallCmd))
            {
                #region INSTALL/UNINSTALL
                <# INSTALL APPLICATION #>
                Install-ApplicationPackage -InstallerType exe -PackageName $UID -FileName $FileName -InstallSwitches $InstallArgs -DLPath $env:TMP

                <# VERIFY APPLICATION UNINSTALL #>
                [System.String]$CsvInstallDump = "$env:TMP\CSV_INSTALL_DUMP.csv"
                [System.String]$CsvPreDump = "$env:TMP\CSV_PRE-INSTALL_DUMP.csv"
                if (Test-Path -Path $CsvInstallDump){ Remove-Item -Path $CsvInstallDump -Confirm:$false -Force }
                Get-ChildItem -Path $hklmPaths | Get-ItemProperty | Where-Object -FilterScript {$null -notlike $_.DisplayName} | Export-Csv -Path $CsvInstallDump -NoTypeInformation
                switch ($DetectMethod)
                {
                    'Registry'
                    {
                        $Count = 0

                        <# VERIFY FROM REGISTRY #>
                        $InstalledBefore = Import-Csv -Path $CsvPreDump | Select-Object -ExpandProperty DisplayName
                        $InstalledAfter = Import-Csv -Path $CsvInstallDump | Select-Object -ExpandProperty DisplayName
                        foreach ($Install in $InstalledAfter)
                        {
                            if ($InstalledBefore -notcontains $Install)
                            {
                                "FOUND INSTALL: ${Install}"
                                $Count += 1
                                <# READ DATA FROM REGISTRY #>
                                $Mapped = Import-Csv -Path $CsvInstallDump | Where-Object -FilterScript {$_.DisplayName -like $Install}
                                [System.String]$DisplayName = $Mapped.DisplayName
                                [System.String]$DisplayVersion = $Mapped.DisplayVersion
                                [System.String]$DisplayPublisher = $Mapped.Publisher
                                [System.String]$UninstallCmd = $Mapped.UninstallString
                                $DisplayName
                                $DisplayVersion
                                $DisplayPublisher
                                $UninstallCmd

                                # <# UNINSTALL APPLICATION #>
                                # Uninstall-ApplicationPackage -UninstallClass $JsonData.uninstall.process -UninstallString $UninstallCmd -UninstallArgs $JsonData.uninstall.args -DisplayName $DisplayName -RebootRequired "N"
                            }
                            else
                            {
                            }
                        }
                    }
                    Default
                    {
                        "Did not match 'Registry'"
                    }
                }
                $Count
                #endregion INSTALL/UNINSTALL
            }
            

            <# DEFAULT EXPLOIT REPORT ID #>
            $ExploitReportId = 1

            #region BUILD JSON
            $JsonDict.guid = $Guid.ToString()

            $JsonDict.id.publisher = $Publisher
            $JsonDict.id.name = $Name
            $JsonDict.id.version = $Version
            $JsonDict.id.arch = $Arch
            $JsonDict.id.lcid = $Lcid
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
            $JsonDict.meta.uripath = $UriPath
            $JsonDict.meta.enabled = $Enabled
            $JsonDict.meta.dependson = $DependsOn
            $JsonDict.meta.nuspecuri = $NuspecUri

            $JsonDict.install.exectype = $ExecType
            $JsonDict.install.installswitches = $InstallArgs
            $JsonDict.install.rebootrequired = $RebootRequired
            $JsonDict.install.displayname = $DisplayName
            $JsonDict.install.displaypublisher = $DisplayPublisher
            $JsonDict.install.displayversion = $DisplayVersion
            $JsonDict.install.detectmethod = $DetectMethod
            $JsonDict.install.detectvalue = $DetectValue
            
            $JsonDict.uninstall.process = $UninstallProcess
            $JsonDict.uninstall.cmd = $UninstallCmd
            $JsonDict.uninstall.args = $UninstallArgs

            $JsonDict.security.virustotalscanresultsid = $VTScanResultsId
            $JsonDict.security.exploitreportid = $ExploitReportId

            $JsonDict.sysinfo = $SysInfo

            $OutFilePath = Join-Path -Path $OutPath -ChildPath "${UID}.json".Replace('::','_')
            $JsonDict | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutFilePath -Encoding utf8 -Force -Confirm:$false #Set-Content -Path $OutFilePath -Encoding utf8 -Confirm:$false -Force
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) JSON MANIFEST OUTPUT: [ ${OutFilePath} ]"
            #endregion BUILD JSON

            return $OutFilePath
        }
    }
    
    end
    {
        [System.GC]::Collect()
    }
}