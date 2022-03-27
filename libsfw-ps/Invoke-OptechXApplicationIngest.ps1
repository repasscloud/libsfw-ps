function Invoke-OXAppIngest {
    [CmdletBinding()]
    param (
        [System.String]$JsonPayload
    )
    
    begin {
        
    }
    
    process {

        $JsonData = Get-Content -Path $JsonPayload | ConvertFrom-Json

        <# SET $CATID #>
        switch($JsonData.id.category)
        {
            'Productivity' { $catID = 1 }
            'Microsoft' { $catID = 2 }
            'Utility' { $catID = 3 }
            'Developer Tools' { $catID = 4 }
            'Games' { $catID = 5 }
            'Photo & Design' { $catID = 6 }
            'Entertainment' { $catID = 7 }
            'Secuirty' { $catID = 8 }
            'Education' { $catID = 9 }
            'Internet' { $catID = 10 }
            'Lifestyle' { $catID = 11 }
        }
        <# SET LANGID #>
        switch($JsonData.id.lcid)
        {
            'MUI' { $langID = 1 }
            'en-US' { $langID = 2 }
        }
        <# SET CPUARCHID #>
        switch($data.id.arch)
        {
            'x86' { $cpuarchID = 1 }
            'x64' { $cpuarchID = 2 }
            'arm86' { $cpuarchID = 3 }
            'arm64' { $cpuarchID = 4 }
        }
        <# SET EXECID #>
        switch($data.install.exectype)
        {
            'msi' { $execID = 1 }
            'msix' { $execID = 2 }
            'exe' { $execID = 3 }
            'bat' { $execID = 4 }
            'ps1' { $execID = 5 }
            'cmd' { $execID = 6 }
        }
        <# GET VIRUS RESPONSE #>
        $VTScanResults = New-VirusTotalScan -SHA256 $JsonData.meta.sha256 -FileName $JsonData.meta.filename

        $ApiPayload = @{
            id = 0
            uuid = $JsonData.guid
            uid = $JsonData.id.uid
            lastUpdate = (Get-Date).ToString('yyyyMMdd')
            applicationCategoryId = $catID
            publisher = $JsonData.id.publisher
            name = $JsonData.id.name
            version = $JsonData.id.version
            copyright = $JsonData.meta.copyright
            licenseAcceptRequired = $JsonData.meta.licenseacceptrequired
            rebootRequired = $JsonData.install.rebootrequired
            languageId = $langID
            cpuArchId = $cpuarchID
            filename = $JsonData.meta.filename
            sha256 = $JsonData.meta.sha256
            followUri = $JsonData.meta.followuri
            absoluteUri = $JsonData.meta.absoluteuri
            executableId = $execID
            installCmd = $JsonData.meta.filename
            installArgs = $JsonData.install.installswitches
            installScript = $null
            displayName = $null
            displayPublisher = $null
            displayVersion = $null
            packageDetectionId = $data 
            detectScript = $null
            detectValue = $JsonData.install.detectvalue
            uninstallProcessId = $JsonData.uninstall.process #needs ID
            uninstallCmd = $JsonData.uninstall.string
            uninstallArgs = $JsonData.uninstall.args
            uninstallScript = $null
            homepage = $JsonData.meta.homepage
            icon = $JsonData.meta.iconuri
            docs = $JsonData.meta.docs
            license = $JsonData.meta.license
            tags = $JsonData.meta.tags
            summary = $JsonData.meta.summary
            transferMethodId = $JsonData.meta.xft
            localeId = $JsonData.meta.locale  # needs ID
            uriPath = $JsonData.meta.uripath
            enabled = $JsonData.meta.enabled
            dependsOn = $JsonData.meta.dependson
            virusTotalScanResults = 0
            exploitReportId = 0
        }
    }
    
    end {
        [System.Gc]::Collect()
    }
}