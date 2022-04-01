<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer

<# APP SPECIFIC CODE - DO NOT EDIT #>
$adr_regex = [System.String]::Empty
$adr_uri = 'http://omahaproxy.appspot.com/all?os=win&amp;channel=stable'
$adr_version = Invoke-WebRequest -Uri $releases -UseBasicParsing | Select-Object Content | ConvertFrom-Csv | Select-Object -ExpandProperty current_version
$adr_publisher = "Google"
$adr_name = "Chrome"
$adr_copyright = "Copyright $((Get-Date).ToString('yyyy')) Google LLC. All rights reserved."
$adr_nuspec = "https://github.com/chocolatey-community/chocolatey-packages/raw/master/automatic/googlechrome/googlechrome.nuspec"
$adr_licenseacceptrequired = $false
$adr_rebootrequired = $false
$adr_category = "Internet"
$adr_xft = "mc"
$adr_locale = "au-syd1-07"
$adr_arch = "x86"
$adr_lcid = "en-US"
$adr_exectype = "msi"
$adr_followuri = 'https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise.msi'
$adr_absoluteuri = 'https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise.msi'  # $null if not known
$adr_installswitches = "/qn"  # used for backwards compatability
$adr_displayname = ""  # OPTIONAL
$adr_geo = "au-syd1-07"
$adr_uninstallargs = "msi-void"
