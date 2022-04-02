function Invoke-OXAppIngest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.String]$JsonPayload,
        [Parameter(Mandatory=$false)][System.String]$BaseUri='https://engine.api.dev.optechx-data.com'
    )
    
    begin {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
    
    process {

        $JsonData = Get-Content -Path $JsonPayload | ConvertFrom-Json

        $Body = @{
            id = 0
            uuid = $JsonData.guid
            uid = $JsonData.id.uid
            lastUpdate = (Get-Date).ToString('yyyyMMdd')
            applicationCategory = $JsonData.id.category
            publisher = $JsonData.id.publisher
            name = $JsonData.id.name
            version = $JsonData.id.version
            copyright = $JsonData.meta.copyright
            licenseAcceptRequired = $JsonData.meta.licenseacceptrequired
            rebootRequired = $JsonData.install.rebootrequired
            lcid = $JsonData.id.lcid
            cpuArch = $JsonData.id.arch
            filename = $JsonData.meta.filename
            sha256 = $JsonData.meta.sha256
            followUri = $JsonData.meta.followuri
            absoluteUri = $JsonData.meta.absoluteuri
            executable = $JsonData.install.exectype
            installCmd = $JsonData.meta.filename
            installArgs = $JsonData.install.installswitches
            installScript = [System.Stringt]::Empty  # reserved for LoB applications
            displayName = [System.Stringt]::Empty
            displayPublisher = [System.Stringt]::Empty
            displayVersion = [System.Stringt]::Empty
            packageDetection = $JsonDict.install.detectmethod
            detectScript = [System.Stringt]::Empty  # reserved for LoB applications
            detectValue = $JsonData.install.detectvalue
            uninstallProcess = $JsonData.uninstall.process
            uninstallCmd = $JsonData.uninstall.string
            uninstallArgs = $JsonData.uninstall.args
            uninstallScript = [System.Stringt]::Empty  # reserved for LoB applications
            homepage = $JsonData.meta.homepage
            icon = $JsonData.meta.iconuri
            docs = $JsonData.meta.docs
            license = $JsonData.meta.license
            tags = $JsonData.meta.tags
            summary = $JsonData.meta.summary
            transferMethod = $JsonData.meta.xft
            locale = $JsonData.meta.locale
            uriPath = $JsonData.meta.uripath
            enabled = $JsonData.meta.enabled
            dependsOn = $JsonData.meta.dependson
            virusTotalScanResultsId = $JsonData.security.virustotalscanresultsid.id
            exploitReportId = 1
        } | ConvertTo-Json

        Invoke-RestMethod -Uri "${BaseUri}/api/Application" -Method Post -UseBasicParsing -Body $Body -ContentType "application/json" -ErrorAction Stop
    }
    
    end {
        [System.GC]::Collect()
    }
}