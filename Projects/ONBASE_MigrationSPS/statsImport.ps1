
#--------------------------------------------------------------------------------------------------------------
# Name        : statsImport.ps1
#--------------------------------------------------------------------------------------------------------------
# Author      : D.Lambret
# Date        : 08.11.2021
# Status      : PROD
# Version     : 0.1
#--------------------------------------------------------------------------------------------------------------
# Description : Compte les documents PDF importés en fonction d'une liste de Verification Reports fournie 
# par OnBase. Fournies une sortie au format CSV pour analyse et comptage.
#--------------------------------------------------------------------------------------------------------------

$path = "Y:\03_DEV\01_Powershell\projects\checkImports\data"
$fileList = get-childitem -path $path -Filter "*.txt"

foreach ($item in $fileList) {
    Get-Content $path/$item | Select-String -Pattern "(.*)(\d{,3})(.*)\.{2,}\s*\d{1,}\s*\d{1,}" -AllMatches
    $dtCode = $matches[0].Matches.Groups[1].Value
    $dtDesc = $matches[0].Matches.Groups[2].Value 
    $dtDesc = $dtDesc -replace ".",""
    $pages  = $matches[0].Matches.Groups[3].Value 
    $docs   = $matches[0].Matches.Groups[4].Value
    Write-Host "Records - dt : $dtCode ddesc: $dtDesc pages: $pages docs: $docs"
 }



 


