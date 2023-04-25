#--------------------------------------------------------------------------------------------------------------
# Name        : count4period.ps1
#--------------------------------------------------------------------------------------------------------------
# Author      : D.Lambret
# Date        : 08.11.2021
# Status      : PROD
# Version     : 0.1
#--------------------------------------------------------------------------------------------------------------
# Description : Compte les documents PDF présent dans la structure de repertoire source proposée
# Le comptage permet le rapprochement avec les chiffres de livraisons communiqué par SPS et permet de 
# valider l'envois des documents/index pourreprise OnBase.
# Paramètre d'appel :
# -period mmYY
# -DocType xxx 
#--------------------------------------------------------------------------------------------------------------
Param(
    [Parameter(Mandatory=$true)] $period,
    [Parameter(Mandatory=$true)] $doctype
)

#--------------------------------------------------------------------------------------------------------------
# Includes
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------------------------------------------------------
$pattern = $docType + "_" + $period + "*"
$import_path = "\\fs_EcmUnZipData_ge3\ecm_unzip_data$\SPSMigUnzip\PRD\INV"
$total = 0

#--------------------------------------------------------------------------------------------------------------
# procedures & functions
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------------------------------------
Write-Host "-----------------------------------------------------------------------------------------------------"

Write-Host "Search for $pattern on $import_path"

Push-Location
Set-Location  $import_path
# Build directories liste according pattern provided
$listdir = Get-ChildItem -Filter $pattern -directory | Sort-object -property Name

# foreach directory, count number of PDF
foreach ($item in $listdir) 
{ 
    Push-Location
    cd $item
    $count = (Get-ChildItem -filter "*.pdf").count
    write-host "$item;$count"
    $total += $count
    Pop-Location
}
Pop-Location

Write-Host "-----------------------------------------------------------------------------------------------------"
Write-Host "Grand total : $total PDF file(s)"