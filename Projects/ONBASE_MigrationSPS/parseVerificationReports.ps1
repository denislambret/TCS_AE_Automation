#--------------------------------------------------------------------------------------------------------------
# Name        : parseVerificationReports.ps1
#--------------------------------------------------------------------------------------------------------------
# Author      : D.Lambret
# Date        : 15.11.2021
# Status      : PROD
# Version     : 0.1
#--------------------------------------------------------------------------------------------------------------
# Description :
# Extracteur d'information provenant des Verifications Reports OnBase.
# Ce script génère un CSV de sortie regroupant l'ensemble des informations d'import d'un ou plusieurs lot.
# La structure d'enregistrement CSV est la suivante :
# lotId;batchId;reportFile;sourceFile;importDate;nbDocFound;nbDocProceeded;avgCapture;startTime;totalTime
# Les informations sont ensuite intégré dans le document de suivi XLS d'import (imports SPS.xls)
#--------------------------------------------------------------------------------------------------------------

param( 
    [parameter(Mandatory=$false)][string]$path, 
    [parameter(Mandatory=$false)][string]$output
)

#--------------------------------------------------------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------------------------------------------------------
# Pathes
$root_dir = "Y:\03_DEV\01_Powershell\projects\checkImports\data"

# CSV table header
$csv_table = "lotId;batchId;repotFile;sourceFile;importDate;nbDocFound;nbDocProceeded;avgCapture;startTime;totalTime`n"

# Counters
$count_csv_records = 0

#--------------------------------------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------------------------------------
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "Gen Verifications Summmary Report v.1"
$reports_list = Get-ChildItem -path $path -Filter "*.txt" | Sort-object -Property Name

if (-not $path) { $path = $root_dir }
if (-not $output) { $output = $root_dir + "/summary.txt"}
foreach ($item in $reports_list) {
    $content = Get-Content -Path $path\$item
    $count_csv_records += 1
    
    # Match patterns and build CSV records
    $matches = $content | Select-String '^Total Number of Documents Found    = (.*) during process'
    if ($matches) { $nb_docs_found = $matches[0].Matches.Groups[1].Value} 
    
    $matches = $content | Select-String '^Total Number of Documents Archived = (.*) during process'
    if ($matches) { $nb_docs_archived = $matches[0].Matches.Groups[1].Value} 

    $matches = $content | Select-String '^Total Processing Time                  : (.*) Hours, (.*) Minutes, (.*) Seconds'
    if ($matches) { $processing_time = ($matches[0].Matches.Groups[1].Value + ":" + $matches[0].Matches.Groups[2].Value + ":" + $matches[0].Matches.Groups[3].Value) -replace " ",""}

    $matches = $content | Select-String '^Average Processing per Document        : (.*) Seconds'
    if ($matches) { $processing_per_doc = $matches[0].Matches.Groups[1].Value}

    $matches = $content | Select-String '^File                  : (.*)'
    if ($matches) { $file_name = $matches[0].Matches.Groups[1].Value}

    $matches = $content | Select-String '^Internal Batch Number     : (.*)'
    if ($matches) { $OB_batch_number = $matches[0].Matches.Groups[1].Value}

    $matches = $content | Select-String '^(\d{2}\.\d{2}\.\d{4}) (\d{2}\:\d{2}\:\d{2})'
    if ($matches) { 
        $process_date = $matches[0].Matches.Groups[1].Value 
        $process_time = $matches[0].Matches.Groups[2].Value 
    }

    $matches = $content | Select-String '(\d{1,5})\.csv$'
    if ($matches) {
        $idx = $Matches[0].Groups[1].Value
    }
    
    # Write CSV records to output
    $csv_record = $idx + ";" + $OB_batch_number + ";" +$item.Name + ";" + $file_name + ";" + $process_date + ";" + $nb_docs_found + ";" + $nb_docs_archived + ";" + $processing_per_doc + ";" +  $process_time + ";" + $processing_time + "`n"
    $csv_table += $csv_record
}


$date = Get-Date -Format "yyyy-MM-dd"
$csv_output_file = $date +"_Import_Summary.txt"

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "Create output CSV file $output ($count_csv_records records)"
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------------------"
Set-Content -Path  $output -Value $csv_table
Write-Host "--- File Sample :"
Get-Content -Path  $output
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------------------"