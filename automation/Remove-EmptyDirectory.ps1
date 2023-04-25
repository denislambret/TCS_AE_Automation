# Remove empty directories
#---------------------------------------------------------------------------------------------------------------
[XML]$confFile = (get-Content -path ./sample.conf.xml)
$confFile.conf.cleaner.directory | foreach-object { 
    if ($_.removeEmptyDirectory -match "true")
    {
        D:\scripts\automation\Get-EmptyDirectory.ps1 -path $_.path | Where-Object {$_.EmptyDirectory} | Remove-Item -Force -WhatIf}
    }
    

