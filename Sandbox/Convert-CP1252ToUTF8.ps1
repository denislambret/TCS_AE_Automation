Param (
    [Parameter(Mandatory=$True)][String]$Path
)



#$Utf8Encoding = New-Object System.Text.UTF16Encoding($False)
$Utf8Encoding = New-Object System.Text.UTF8Encoding($False)
$content = get-content $Path
if ( $content -ne $null ) {
        [System.IO.File]::WriteAllLines($Path, $content, $Utf8Encoding)
    } else {
        Write-Host "No content found in $Path"   
}

