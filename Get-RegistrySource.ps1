function Get-RegistrySource {
    [CmdletBinding()]
    param (
        [System.String]$RegDisplayName
    )

    begin {
        [System.Array]$hklmPaths = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        )
    }
    
    process {
        if ($RegDisplayName.Length -eq 0)
        {
            # generate installed app comparisons
            $old = Import-Csv -Path $env:TEMP\app_list.csv | Select-Object -ExpandProperty DisplayName
            $current = Get-ChildItem -Path $hklmPaths | Get-ItemProperty | Where-Object -FilterScript {$null -notlike $_.DisplayName -and $_.DisplayName -notmatch 'Microsoft Azure Libraries for \.NET.*'} | Select-Object -ExpandProperty DisplayName
    
            # find newly installed app
            foreach ($i in $current)
            {
                if ($old -notcontains $i)
                {
                    # grab the info
                    $reg_src_lookup = Get-ChildItem -Path $hklmPaths | Get-ItemProperty | Where-Object -FilterScript {$_.DisplayName -like $i} | Select-Object -Property *
                    
                    # output the data for verbosity and manual checking
                    $reg_src_lookup
                }
            }

            exit 1
        }

        $reg_src_data = Get-ChildItem -Path $hklmPaths | Get-ItemProperty | Where-Object -FilterScript {$_.DisplayName -like $RegDisplayName} | Select-Object -Property *

        return $reg_src_data
    }

    end {
        [System.GC]::Collect()
    }
}