#--------------------------------------------------------------------------------------------------------------
# Name        : parseImportLogsOB.ps1
#--------------------------------------------------------------------------------------------------------------
# Author      : D.Lambret
# Date        : 04.11.2021
# Status      : DEV
# Version     : 0.1
#--------------------------------------------------------------------------------------------------------------
# Description : Parse and provides stats from OnBase index import logs
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Includes
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------------------------------------------------------
$root_dir  = "Y:\03_DEV\01_Powershell\checkImports"
$src_dir   = $root_dir+"\data"
$tmp_dir   = $src_dir+"\tmp"
$stats_dir = "Y:\03_DEV\01_Powershell\checkImports\data\stats"
$separator = ";"
$headers   = @('filename','dest','sens','src','instance','id','tpyedesc','typerep','language','SFid','CustNum','LastName','FirstName','docdate','docType')
$FTCounts  = @()
$grpSummary = @()
#--------------------------------------------------------------------------------------------------------------
# Procedures & functions
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------------------------------------
Write-Host "--------------------------------------------------------------------------------------------------------------"
Write-Host "parseImportLogsOB.ps1"
Write-Host "--------------------------------------------------------------------------------------------------------------"
Write-Host "Scan source on" $src_dir
# Check Zip file available for analysis
$zipList = Get-ChildItem -path $src_dir -Filter *.zip
Write-Host "Zip(s) identified : " ($zipList).Count


# Unzip content
# Foreach log file, open and build stats
foreach ($zipFile in $zipList) {
    # Reset temporary directory
    if (Test-Path $tmp_dir)
    {
        Remove-Item -Path $tmp_dir\*.*
    } else {
        Create-Item -Path $tmp_dir -Type directory
    }
    
    # Extract files from current zip
    Write-Host "Extract from "$zipFile
    Expand-Archive -LiteralPath $src_dir\$zipFile -DestinationPath $tmp_dir

    # Build stats based on content
    $reportsList = Get-ChildItem -path $tmp_dir -Filter *.txt
    $totalDocs = 0
    $dtCount = @{}

    foreach ($report in $reportsList) {
        $csv = Import-Csv -Path $tmp_dir\$report -Delimiter ';' -Header filename,srv,sens,src,instance,idPli,code,Type1,Type2,language,SFid,custId,LastName,FirstName,docDate,docType
        $csv = $csv | Sort-Object docType
        $totalDocs += $csv.count
        $grp = $csv | group-object docType
        
        
        Write-host "--------------------------------------------------------------------------------------------------------------"
        Write-host "Import Batch : $zipFile - $report"
        Write-host "--------------------------------------------------------------------------------------------------------------"
        $grp | ft -Property Name, Count
        $FTCounts[$grpName.Name] += 1
        
    }   
}
Write-host "--------------------------------------------------------------------------------------------------------------"
Write-Host "Total documents imported : " $totalDocs "doc(s)"
foreach ($itemGrp in $grpSummary) {
   $itemGrp | select -Unique Name, @{Name = 'Total'; expression = {(($itemGrp.count) | measure -Property count -sum).sum}}
}

