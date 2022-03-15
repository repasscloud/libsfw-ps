function Build-JsonFiles {
    [CmdletBinding()]
    param (
        [System.String]$JsonMapDir
    )
    
    # declare error action
    $ErrorActionPreference = "Stop"

    [System.Array]$PS1SrcFiles = Get-ChildItem -Path $JsonMapDir -Filter "*.ps1" -Recurse | Select-Object -ExpandProperty FullName
    
    foreach ($PS1File in $PS1SrcFiles)
    {
        # execute the generation of the JSON library file
        try
        {
            # build the file
            . $PS1File

            # advise the file has been built
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) BUILT JSON FILE FOR INGEST: $($PS1File.Name)"
        }
        catch
        {
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) UNABLE TO PROCESS: $($pPS1File.Name)"
        }
    }
}