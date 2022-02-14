function Build-JsonFiles {
    [CmdletBinding()]
    param (
        [System.String]$JsonMapDir
    )
    
    # declare error action
    $ErrorActionPreference = "Stop"

    [System.Array]$PS1SrcFiles = Get-ChildItem -Path $JsonMapDir -Filter "*.ps1" | Select-Object FullName,Name
    
    foreach ($ps1 in $PS1SrcFiles)
    {
        # set name and full name
        [System.String]$jsonFileSrc = $ps1.Name
        [System.String]$jsonPathSrc = $ps1.FullName

        # execute the generation of the JSON library file
        try
        {
            # build the file
            & $jsonPathSrc

            # advise the file has been built
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) BUILT JSON FILE FOR INGEST: ${jsonFileSrc}"
        }
        catch
        {
            Write-Output "$([System.Char]::ConvertFromUTF32("0x1F534")) UNABLE TO PROCESS: ${jsonFileSrc}"
        }
    }
}