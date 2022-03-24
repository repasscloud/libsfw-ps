function Build-JsonFiles {
    [CmdletBinding()]
    param (
        [System.String]$JsonMapDir
    )
    
    # error action preference
    $ErrorActionPreference = "Stop"

    [System.String[]]$PS1Files = Get-ChildItem -Path $JsonMapDir -Filter "*.ps1" -Recurse -File | Select-Object -ExpandProperty FullName
    
    foreach ($PS1File in $PS1Files)
    {
        # execute the generation of the JSON library file
        try
        {
            # build the file
            powershell -File $PS1File -ErrorAction Stop

            # advise the file has been built
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) BUILT JSON FILE FOR INGEST: $($PS1File)"
        }
        catch
        {
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) UNABLE TO PROCESS: $($PS1File.Name)"
        }
    }
}
