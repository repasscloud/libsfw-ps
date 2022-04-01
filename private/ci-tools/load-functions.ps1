Get-ChildItem -Path $env:APPVEYOR_BUILD_FOLDER\libsfw-ps -Filter "*.ps1" -File | ForEach-Object {
    . $_.FullName
    Write-Output "$([System.Char]::ConvertFromUTF32("0x1F7E1")) IMPORTED FUNCTION: $($_.FullName)"
}