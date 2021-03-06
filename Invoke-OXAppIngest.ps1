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
            installScript = [System.String]::Empty  # reserved for LoB applications
            displayName = $JsonData.install.displayname
            displayPublisher = $JsonData.install.displaypublisher
            displayVersion = $JsonData.install.displayversion
            packageDetection = $JsonData.install.detectmethod
            detectScript = [System.String]::Empty  # reserved for LoB applications
            detectValue = $JsonData.install.detectvalue
            uninstallProcess = $JsonData.uninstall.process
            uninstallCmd = $JsonData.uninstall.cmd
            uninstallArgs = $JsonData.uninstall.args
            uninstallScript = [System.String]::Empty  # reserved for LoB applications
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
            virusTotalScanResultsId = $JsonData.security.virustotalscanresultsid
            exploitReportId = 1
        } | ConvertTo-Json

        $Body
        Invoke-RestMethod -Uri "${BaseUri}/api/Application" -Method Post -UseBasicParsing -Body $Body -ContentType "application/json" -ErrorAction Stop
    }
    
    end {
        [System.GC]::Collect()
    }
}