function Uninstall-ApplicationPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.String]$UninstallClass,

        [Parameter(Mandatory=$true)]
        [System.String]$UninstallString,

        [Parameter(Mandatory=$true)]
        [System.String]$UninstallArgs,

        [Parameter(Mandatory=$true)]
        [System.String]$DisplayName,

        [Parameter(Mandatory=$false)]
        [ValidateSet("N","n","Y","y")]
        [System.Char]$RebootRequired = "N"
    )
    
    begin {
        [System.Array]$hklmPaths = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        )
    }

    process {

        switch ($RebootRequired)
        {
            {$_ -eq 'n' -or $_ -eq 'N'}
            {
                # process like normal
                switch ($UninstallClass)
                {
                    'msi' {
                        [System.String]$uarg = ($UninstallString -replace "/I","/X" -replace "MsiExec.exe ","") + " /qn"
                        try {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) START UNINSTALL: ${DisplayName}"
                            Start-Process -FilePath "C:\Windows\System32\MsiExec.exe" -ArgumentList "$($uarg)" -Wait -ErrorAction Stop
                        }
                        catch {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) DID NOT UNINSTALL: ${DisplayName}"
                        }
                    }
                    'exe' {
                        try {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) START UNINSTALL: ${DisplayName}"
                            Start-Process -FilePath "`"$uninstallstring`"" -ArgumentList "${UninstallArgs}" -Wait -ErrorAction Stop
                        }
                        catch {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) DID NOT UNINSTALL: ${DisplayName}"
                        }
                    }
                    'exe2' {
                        try {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) START UNINSTALL: ${DisplayName}"
                            Start-Process -FilePath $uninstallstring -ArgumentList "${UninstallArgs}" -Wait -ErrorAction Stop
                        }
                        catch {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) DID NOT UNINSTALL: ${DisplayName}"
                        }
                    }
                }
            }
            Default
            {
                # process without reboot (ie - do not uninstall actual item)
                switch ($UninstallClass)
                {
                    'msi' {
                        [System.String]$uarg = ($UninstallString -replace "/I","/X" -replace "MsiExec.exe ","") + " /qn"
                        try {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) NO UNINSTALL (REBOOT REQUIRED): ${DisplayName}"
                            Write-Output "Start-Process -FilePath `"C:\Windows\System32\MsiExec.exe`" -ArgumentList `"$($uarg)`" -Wait -ErrorAction Stop"
                        }
                        catch {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) DID NOT UNINSTALL: ${DisplayName}"
                        }
                    }
                    'exe' {
                        try {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) NO UNINSTALL (REBOOT REQUIRED): ${DisplayName}"
                            Write-Output "Start-Process -FilePath `"${uninstallstring}`" -ArgumentList `"${switches}`" -Wait -ErrorAction Stop"
                        }
                        catch {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) DID NOT UNINSTALL: ${DisplayName}"
                        }
                    }
                    'exe2' {
                        try {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) NO UNINSTALL (REBOOT REQUIRED): ${DisplayName}"
                            Write-Output "Start-Process -FilePath `"${uninstallstring}`" -ArgumentList `"${switches}`" -Wait -ErrorAction Stop"
                        }
                        catch {
                            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) DID NOT UNINSTALL: ${DisplayName}"
                        }
                    }
                }
            }
        }
    
        # verify app uninstalled
        if ($null -notlike (Get-ChildItem -Path $hklmPaths | Get-ItemProperty | Where-Object -FilterScript {$_.DisplayName -like $DisplayName}))
        {
            Get-ChildItem -Path $hklmPaths | Get-ItemProperty | Where-Object -FilterScript {$_.DisplayName -like $DisplayName}
            exit 1
        }
        else
        {
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E2")) UNINSTALLED: ${DisplayName}"
        }
    }
    
    end {
        [System.GC]::Collect()
    }
}
