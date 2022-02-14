function Add-ExecToRepo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.String]$XFT,

        [Parameter(Mandatory=$true)]
        [System.String]$Locality,

        [Parameter(Mandatory=$true)]
        [System.String]$Uri,

        [Parameter(Mandatory=$true)]
        [System.String]$Upload,

        [Parameter(Mandatory=$true)]
        [System.String]$DLPath
    )
    
    begin {
        if ($env:PATH.Split(';') -notcontains 'C:\mc\bin') { $env:PATH += ';C:\mc\bin' }
    }
    
    process {
        [System.String]$download_path = Join-Path -Path $DLPath -ChildPath $Upload

        switch ($XFT)
        {
            'mc' {
                
                (mc cp "${download_path}" $Locality/$Uri) 2>&1>$null
                Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) PAVCKAGE UPLOADED VIA: mc"
            }
        }
    }
    
    end {
        try
        {
            Remove-Item -Path $download_path -Confirm:$false -Force -ErrorAction Stop
        }
        catch
        {
            Write-Verbose "UNABLE TO DELETE FILE: ${download_path}"
        }
        [System.GC]::Collect()
    }
}