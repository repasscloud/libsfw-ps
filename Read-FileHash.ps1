function Read-FileHash {
    [CmdletBinding()]
    param (
        [System.String]$DLFile,
        [System.String]$DLPath
    )
    
    [System.String]$OutputPath = Join-Path -Path $DLPath -ChildPath $DLFile
    [System.String]$returned_hash = (Get-FileHash -Path $OutputPath -Algorithm SHA256).Hash

    return $returned_hash
}