[System.Array]$hklmPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# uninstall Google Update Tool
[System.String]$app_i = "Google Auto Update Tool"
Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) UNINSTALLING ${app_i}"
try {
    Start-Process -FilePath MsiExec.exe -ArgumentList "/X","{60EC980A-BDA2-4CB6-A427-B07A5498B4CA}","/qn" -Wait -ErrorAction Stop
    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) REMOVED: ${app_i}"
}
catch {
    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) NOT REMOVED: ${app_i}"
    [System.Array]$otherApps = @("google")
    foreach ($app in $otherApps)
    {
        foreach ($path in $hklmPaths)
        {
            Get-ChildItem -Path $path | Get-ItemProperty | Where-Object -FilterScript { $null -notlike $_.DisplayName } | Where-Object -FilterScript { $_.DisplayName -like "*${app}*" } | Select-Object -Property *
        }
    }
}

# uninstall Google Chrome
[System.String]$app_i = "Google Chrome"
Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) UNINSTALLING ${app_i}"
try {
    #Start-Process -FilePath "C:\Program Files (x86)\Google\Chrome\Application\77.0.3865.120\Installer\setup.exe" -ArgumentList "--uninstall","--system-level","--verbose-logging","--force-uninstall" -Wait -ErrorAction Stop
    Start-process -FilePath msiexec -ArgumentList '/X','{177B605A-B1E1-3197-B5D4-05F00C0174D1}','/q' -Wait
    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) REMOVED: ${app_i}"
}
catch {
    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) NOT REMOVED: ${app_i}"
    [System.Array]$otherApps = @("google")
    foreach ($app in $otherApps)
    {
        foreach ($path in $hklmPaths)
        {
            Get-ChildItem -Path $path | Get-ItemProperty | Where-Object -FilterScript { $null -notlike $_.DisplayName } | Where-Object -FilterScript { $_.DisplayName -like "*${app}*" } | Select-Object -Property *
        }
    }
}
#ref: https://answers.microsoft.com/en-us/windows/forum/all/uninstall-silently-google-chrome-by-command-line/0b35fde7-3f8a-473d-9a41-ca1946616bbb

# uninstall Mozilla Firefox
[System.String]$app_i = "Mozilla Firefox"
Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) UNINSTALLING ${app_i}"
try {
    Start-Process -FilePath "C:\Program Files (x86)\Mozilla Maintenance Service\uninstall.exe" -ArgumentList '/S' -Wait
    Start-Process -FilePath "C:\Program Files\Mozilla Firefox\uninstall\helper.exe" -ArgumentList "-ms" -Wait -ErrorAction Stop
    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) REMOVED: ${app_i}"
}
catch {
    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) NOT REMOVED: ${app_i}"
    [System.Array]$otherApps = @("firefox")
    foreach ($app in $otherApps)
    {
        foreach ($path in $hklmPaths)
        {
            Get-ChildItem -Path $path | Get-ItemProperty | Where-Object -FilterScript {$null -notlike $_.DisplayName} | Where-Object -FilterScript {$_.DisplayName -like "*${app}*"} | Select-Object -Property *
        }
    }
}