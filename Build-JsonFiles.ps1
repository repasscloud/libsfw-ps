function Build-JsonFiles {
    [CmdletBinding()]
    param (
        [System.String]$JsonMapDir
    )
    
    # declare error action
    $ErrorActionPreference = "Stop"

    [System.Array]$PS1SrcFiles = Get-ChildItem -Path $JsonMapDir -Filter "*.ps1" -Recurse
    
    foreach ($ps1 in $PS1SrcFiles)
    {
        # execute the generation of the JSON library file
        try
        {
            # build the file
            & $ps1.FullName

            # advise the file has been built
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) BUILT JSON FILE FOR INGEST: $($ps1.Name)"
        }
        catch
        {
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) UNABLE TO PROCESS: $($ps1.Name)"
        }
    }
}