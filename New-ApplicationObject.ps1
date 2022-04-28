function New-ApplicationObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Productivity","Microsoft","Utility","Developer Tools","Games","Photo & Design","Entertainment","Security","Education","Internet","Lifestyles")]
        [System.String]$ApplicationCategory,

        [Parameter(Mandatory=$true)]
        [System.String]$Publisher,

        [Parameter(Mandatory=$true)]
        [System.String]$Name,

        [Parameter(Mandatory=$true)]
        [System.String]$Version,

        [Parameter(Mandatory=$false)]
        [System.String]$Copyright=[System.String]::Empty,

        [Parameter(Mandatory=$false)]
        [System.Boolean]$RebootRequired=$false,

        [Parameter(Mandatory=$true)]
        [System.String[]]$Lcid,

        [Parameter(Mandatory=$true)]
        [ValidateSet("x64","x86","aarch32","arm64")]
        [System.String[]]$CpuArch,

        [Parameter(Mandatory=$false)]
        [System.String]$Homepage=[System.String]::Empty,

        [Parameter(Mandatory=$false)]
        [System.String]$IconUri=[System.String]::Empty,

        [Parameter(Mandatory=$false)]
        [System.String]$Docs=[System.String]::Empty,

        [Parameter(Mandatory=$false)]
        [System.String]$License=[System.String]::Empty,

        [Parameter(Mandatory=$false)]
        [System.String[]]$Tags=[System.String]::Empty,

        [Parameter(Mandatory=$false)]
        [System.String]$Summary=[System.String]::Empty,

        [Parameter(Mandatory=$false)]
        [System.String]$NuspecURI=[System.String]::Empty,
        
        [Parameter(Mandatory=$false)]
        [System.Boolean]$Enabled=$true,

        [Parameter(Mandatory=$false)]
        [System.String]$API_URI="https://engine.api.dev.optechx-data.com",

        [Parameter(Mandatory=$false)]
        [System.String]$APP_ROUTE="v1/Application",

        [Parameter(Mandatory=$false)]
        [System.String]$APP_UID_ROUTE="v1/Application/uid"
    )
    
    begin {
        <# PRELOAD - DO NOT EDIT #>
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
    }
    
    process {
        <# ESTABLISH UID AND KEY #>
        [System.String]$UID = "$($Publisher.ToLower().Replace(' ',''))::$($Name.ToLower().Replace(' ',''))::${Version}"
        [System.Guid]$UUID = [System.Guid]::NewGuid()

        <# VERIFY UID AGAINST API PARENT OBJECT ELSE CREATE #>
        $CHeaders = @{accept = 'text/json'}
        try
        {
            Invoke-RestMethod -Uri "${API_URI}/${APP_UID_ROUTE}/${UID}" -Method Get -Headers $CHeaders -ErrorAction Stop | Out-Null
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) APPLICATION MATCHED: [ ${UID} ]"
            # go to end, nothing left to do, well, there is ~> have to create the child object now
        }
        catch
        {
            <# START MAIN PROCESS AS CATCH STATEMENT #>
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) NEW APPLICATION: [ ${UID} ]"

            <# NUSPEC FILE INGEST #>
            if ($null -notlike $NuspecURI)
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
                    if ($XmlNuspec.package.metadata.projectUrl) { if(-not($Homepage)){$Homepage=$XmlNuspec.package.metadata.projectUrl} }
                    if ($XmlNuspec.package.metadata.docsUrl) { if(-not($Docs)){$Docs=$XmlNuspec.package.metadata.docsUrl} }
                    if ($XmlNuspec.package.metadata.iconUrl) { if(-not($IconUri)){$IconUri=$XmlNuspec.package.metadata.iconUrl} }
                    if ($XmlNuspec.package.metadata.copyright) { if(-not($Copyright)){$Copyright=$XmlNuspec.package.metadata.copyright} }
                    if ($XmlNuspec.package.metadata.licenseUrl) { if(-not($License)){$License=$XmlNuspec.package.metadata.licenseUrl} }
                    if ($XmlNuspec.package.metadata.requireLicenseAcceptance) { if('true' -like $XmlNuspec.package.metadata.requireLicenseAcceptance){$LicenseAcceptRequired=$true}else{$LicenseAcceptRequired=$false} }
                    if ($XmlNuspec.package.metadata.summary) { if(-not($Summary)){$Summary=$XmlNuspec.package.metadata.summary} }
                    if ($XmlNuspec.package.metadata.tags) { if(-not($Tags)){$Tags=($XmlNuspec.package.metadata.tags).Split(' ')} }
                }
                catch
                {
                    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) NUSPEC COULD NOT BE READ OR DID NOT DOWNLOAD"
                }
            }
            else
            {
                Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E0")) NUSPEC NOT PROVIDED"
            }<# END NUSPEC FILE INGEST #>

            $ApiDataObj = [System.Collections.Specialized.OrderedDictionary]@{}

            <# GH JSON OBJECT ADD DATA #>
            $ApiDataObj.id = 0
            $ApiDataObj.uuid = $UUID
            $ApiDataObj.uid = $UID
            $ApiDataObj.lastUpdate = $((Get-Date).ToString('yyyyMMdd'))
            $ApiDataObj.applicationCategory = $Category
            $ApiDataObj.publisher = $Publisher
            $ApiDataObj.name = $Name
            $ApiDataObj.version = $Version
            $ApiDataObj.copyright = $Copyright
            $ApiDataObj.licenseAcceptRequired = $LicenseAcceptRequired
            $ApiDataObj.lcid = $Lcid
            $ApiDataObj.cpuArch = $CpuArch
            $ApiDataObj.homepage = $Homepage
            $ApiDataObj.icon = $IconUri
            $ApiDataObj.docs = $Docs
            $ApiDataObj.license = $License
            $ApiDataObj.tags = $Tags
            $ApiDataObj.summary = $Summary
            $ApiDataObj.enabled = $true
            
            <# CONVERT DICTIONARY TO JSON OBJECT #>
            $ApiDataObj | ConvertTo-Json

            <# POST OBJECT INTO API DB #>
            try
            {
                #Invoke-RestMethod -Uri "${API_URI}/${APP_ROUTE}" -Method Post -UseBasicParsing -Body $ApiDataObj -ContentType "application/json" -ErrorAction Stop
                return 0
            }
            catch
            {
                $_.Exception.Message
                return 1
            }
        }
    }
    
    end {
        [System.GC]::Collect()
    }
}