<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer

<# APP SPECIFIC CODE - DO NOT EDIT #>
$adr_regex = [System.String]::Empty
$adr_uri = [System.String]::Empty
$adr_version = ([System.Net.HttpWebRequest]::Create('https://www.mozilla.org/en-US/firefox/notes/').GetResponse().ResponseUri.AbsoluteUri).Split('/')[5]
$adr_publisher = "Mozilla"
$adr_name = "Firefox"
$adr_copyright = "Copyright © 1998-$((Get-Date).ToString('yyyy')) Mozilla Foundation"
$adr_nuspec = "https://raw.githubusercontent.com/chocolatey-community/chocolatey-coreteampackages/master/automatic/firefox/firefox.nuspec"
$adr_licenseacceptrequired = $false
$adr_rebootrequired = $false
$adr_category = "Internet"
$adr_xft = "mc"
$adr_locale = "au-syd1-07"
$adr_arch = "x86"
$adr_lcid = "en-US"
$adr_exectype = "msi"
$adr_followuri = 'https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win&lang=en-US'
$adr_absoluteuri = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${adr_version}/win32/en-US/Firefox Setup ${adr_version}.msi"  # $null if not known
$adr_installswitches = "/qn"  # used for backwards compatability
$adr_displayname = "Mozilla Firefox (x86 en-US)"  # OPTIONAL
$adr_geo = "au-syd1-07"
$adr_uninstallargs = "msi-void"
