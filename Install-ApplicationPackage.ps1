function Install-ApplicationPackage {
    [CmdletBinding()]
    param (
        [System.String]$PackageName,
        [System.String]$InstallerType,
        [System.String]$FileName,
        [System.String]$InstallSwitches,
        [System.String]$DLPath
    )
    
    [System.String]$download_path = Join-Path -Path $DLPath -ChildPath $FileName

    switch ($InstallerType)
    {
        "exe"
        {
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) INSTALLER TYPE: ${InstallerType}"
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) INSTALLING APPLICATION: ${PackageName}"
            try
            {
                Start-Process -FilePath "${download_path}" -ArgumentList "${InstallSwitches}" -Wait -ErrorAction Stop
                Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) INSTALL SUCCESSFULL: ${PackageName}"
                Start-Sleep -Seconds 3
            }
            catch
            {
                Write-Output "$([char]::ConvertFromUTF32("0x1F534")) ${PackageName} NOT INSTALLED"
                exit 1
            }
        }
        "msi"
        {
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) INSTALLER TYPE: ${InstallerType}"
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) INSTALLING APPLICATION: ${PackageName}"
            try
            {
                Start-Process -FilePath msiexec -ArgumentList "/i `"${download_path}`" ${InstallSwitches}" -Wait -ErrorAction Stop
                Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) INSTALL SUCCESSFULL: ${PackageName}"
                Start-Sleep -Seconds 3
            }
            catch
            {
                Write-Output "$([char]::ConvertFromUTF32("0x1F534")) NOT INSTALLED: ${PackageName} "
                exit 1
            }
        }
        Default
        {
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E0")) INSTALLER TYPE: ${InstallerType}"
            Write-Output "$([char]::ConvertFromUTF32("0x1F534")) NOT INSTALLED: ${PackageName} "
            exit 1
        }
    }
}