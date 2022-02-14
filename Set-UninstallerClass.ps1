function Set-UninstallerClass {
    [CmdletBinding()]
    param (
        [SYstem.String]$UninstallString
    )
    
    # set installer class (this doesn't represent the file type for installing!)
    switch ($UninstallString)
    {
        # msi/msix
        {$_ -match 'MsiExec.exe /[IX]{[0-9A-Z]{8}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{12}}'}
        {
            [System.String]$UninstallerClass = "msi"
        }
        # inno installer
        {$_ -match '^".*unins[0-9]{3}\.exe"$'}
        {
            [System.String]$UninstallerClass = "inno"
        }
        # inno installer 2
        {$_ -match '^.*unins[0-9]{3}\.exe$'}
        {
            [System.String]$UninstallerClass = "inno"
        }
        # std installer
        {$_ -match '^.*\.exe$'}
        {
            [System.String]$UninstallerClass = "exe"
        }
        # exe installer 2
        {$_ -match '^.*\.exe"$'}
        {
            [System.String]$UninstallerClass = "exe2"
        }
        # unknown installer
        Default
        {
            [System.String]$UninstallerClass = "other"
            # have not found what 'ClickOnce' is represented by yet, may need to move this to the json file
        }
    } 

    return $UninstallerClass
}