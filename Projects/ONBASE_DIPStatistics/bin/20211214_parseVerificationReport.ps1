#----------------------------------------------------------------------------------------------------------------------------------
# Script  : 
#----------------------------------------------------------------------------------------------------------------------------------
# Author  :
# Date    :
# Version :
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
# 
#----------------------------------------------------------------------------------------------------------------------------------
# Synopsys
#----------------------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(mandatory=$true)][string] $path,
    [Parameter(mandatory=$true)][string] $dest,
    [Parameter(mandatory=$false)][bool]  $CSV  = $False,
    [Parameter(mandatory=$false)][bool]  $JSON = $True,
    [bool]$help
)

#----------------------------------------------------------------------------------------------------------------------------------
#                                                         I N C L U D E S 
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                                 G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
# We use two PSCustomObject to store information as we deal with complex structures. One store batch information, the other
# document type import statistics. Classes are used as container for data extracted from source reports
# - Generic batches info
class VerifReportObj {
    [string]$date                = ''
    [string]$time                = ''
    [string]$processFormat       = ''
    [string]$storeDocIndex       = ''
    [string]$storeDataFiles      = ''
    [string]$storeImportFile     = ''
    [bool]$testOnly              = $False
    [bool]$isError               = $False
    [bool]$isWarning             = $False
    [string]$defaultDocDate      = ''
    [string]$internalBatchId     = ''
    [string]$indexFileName       = ''
    [int]$entriesFound           = 0
    [int]$unarchivedDoc          = 0
    [int]$fileSize               = 0
    [int]$totalDocFound          = 0
    [int]$totalDocArchived       = 0
    [int]$totalIndexProcessed    = 0
    [string]$unidentifiedDocs    = 0
    [int]$totalDocsImported      = 0
    [int]$totalPagesImported     = 0
    [string]$totalProcessingTime = 0
    [float]$avgDocPerSec         = 0
    [float]$avgPagePerSec        = 0
}

# - docs capture by doctypes and batch
class docTypeStatObj {
    [string]$id                  = ''
    [string]$name                = ''
    [string]$batchId             = ''
    [string]$date                = ''
    [string]$time                = ''
    $countDocs                   = 0
    $countPages                  = 0
}

# Work variables
#..................................................................................................................................
$countRunRecords                = 0  # Count total records found
$countProcessedFiles            = 0  # Count total processed indexes
$countDTStats                   = 0  # Count doctype stat records
#----------------------------------------------------------------------------------------------------------------------------------
#                                                        F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------

#..................................................................................................................................
# Function : helpcmd
#..................................................................................................................................
# Input    : none
# Output   : none
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Give quick command references
#..................................................................................................................................
function helpCmd() {
    Write-Host "-Path   Source report directory"
    Write-Host "-Dest   Destination output for CSV and JSON lists"
    Write-Host "-JSON   Export extracted indexes as JSON"
    Write-Host "-CSV    Export extracted indexes as CSV"
    Write-Host "-help   This help text"

}

#..................................................................................................................................
# Function : parse()
#..................................................................................................................................
# Input    : $inputFile
# Output   : TRUE / FALSE
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Parse a verification report input directories and extract lists enumerating Run/jobs information and document types import stats
#..................................................................................................................................
function fctName() {

}

#..................................................................................................................................
# Function :
#..................................................................................................................................
# Input    :
# Output   :
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
#
#..................................................................................................................................
function fctName() {

}

#----------------------------------------------------------------------------------------------------------------------------------
#                                                             M A I N
#----------------------------------------------------------------------------------------------------------------------------------
# Do some cleaning before initialization
# Remove-Variable * -ErrorAction SilentlyContinue

Write-host "----------------------------------------------------------------------------------------------------------------------------------"
Split-Path ($MyInvocation.InvocationName) -leaf
Write-host "----------------------------------------------------------------------------------------------------------------------------------"
# Create ,master lists for verification and doctype information structure
$listVerifObj = [System.Collections.Generic.List[VerifReportObj]]::new()
$listDocTypesObj = [System.Collections.Generic.List[docTypeStatObj]]::new()

$date = Get-Date -Format "yyyyMMdd"

# Remove previous stats files
if (Test-Path $dest/$date"_reportByDocTypes.json")  { Remove-Item -Path $dest/$date"_reportByDocTypes.json"}
if (Test-Path $dest/$date"_reportByDocTypes.csv")   { Remove-Item -Path $dest/$date"_reportByDocTypes.csv"}
if (Test-Path $dest/$date"_reportBatchesInfo.json") { Remove-Item -Path $dest/$date"_reportBatchesInfo.json"}
if (Test-Path $dest/$date"_reportBatchesInfo.csv")  { Remove-Item -Path $dest/$date"_reportBatchesInfo.csv"}

# Create batch verification report list
$listReportFiles = Get-ChildItem -Path $path | Where-Object { $_.Name -match "^[a-zA-Z0-9]+.txt$"}

foreach ($inputReport in $listReportFiles) {
    $countRunRecords += 1
    $report = New-Object VerifReportObj
    Write-Host "Processing verification report : $inputReport"
    
    # Extract single occurence values 
    $rc = select-string -Path $inputReport -Pattern '^(\d{2}\.\d{2}\.\d{4})' -AllMatches
    if ($rc) {
        $report.date = $rc.Matches[0].Groups[1].Value
        $dateTmp     = [Datetime]::ParseExact($report.date, 'dd.MM.yyyy', $null)
        $report.date = $dateTmp.toString("yyyyMMdd")
    }
    
    $rc = select-string -Path $inputReport -Pattern '(\d{2}:\d{2}:\d{2})$' -AllMatches
    if ($rc) {
        $report.time = $rc.Matches[0].Groups[1].Value
    }
    
    $rc = select-string -Path $inputReport -Pattern 'Process Format            : (.*)' -AllMatches
    if ($rc) {
        $report.processFormat = $rc.Matches[0].Groups[1].Value
    }
       
    $rc = select-string -Path $inputReport -Pattern 'Store Documents Indices   : (.*)' -AllMatches
    if ($rc) {
        $report.storeDocIndex = $rc.Matches[0].Groups[1].Value
    }
    
    $rc = select-string -Path $inputReport -Pattern 'Store Document Data Files : (.*)' -AllMatches
    if ($rc) {
        $report.storeDataFiles = $rc.Matches[0].Groups[1].Value
    }
   
    $rc = select-string -Path $inputReport -Pattern 'Store Import File         : (.*)' -AllMatches
    if ($rc) {
        $report.storeImportFile = $rc.Matches[0].Groups[1].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Test Only                 : (.*)' -AllMatches
    if ($rc) {
        if ($rc.Matches[0].Groups[1].Value -Match 'Yes') {
            $report.testOnly = $True
        }
    }

    $rc = select-string -Path $inputReport -Pattern 'warning' -AllMatches
    if ($rc) {
        $report.isWarning = $True
    }

    $rc = select-string -Path $inputReport -Pattern 'error' -AllMatches
    if ($rc) {
        $report.isError = $True
    }

    $rc = select-string -Path $inputReport -Pattern 'Default Document Date     : (.*)' -AllMatches
    if ($rc) {
        $report.defaultDocDate = $rc.Matches[0].Groups[1].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Internal Batch Number     : (.*)' -AllMatches
    if ($rc) {
        $report.internalBatchId = $rc.Matches[0].Groups[1].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'TOTALS\s+(\d{1,9})\s+(\d{1,9})' -AllMatches
    if ($rc) {
        $report.totalDocsImported = [int]$rc.Matches[0].Groups[1].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'TOTALS\s+(\d{1,9})\s+(\d{1,9})' -AllMatches
    if ($rc) {
        $report.totalPagesImported = [int]$rc.Matches[0].Groups[2].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Total Number of Documents Found    = (.*) during process' -AllMatches
    if ($rc) {
        $report.totalDocFound = [int]$rc.Matches[0].Groups[2].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Total Number of Documents Archived = (.*) during process' -AllMatches
    if ($rc) {
        $report.totalDocArchived = [int]$rc.Matches[0].Groups[2].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Total Number of Files Processed    = (.*) during process' -AllMatches
    if ($rc) {
        $report.totalProcessingTime  = [int]$rc.Matches[0].Groups[2].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Average Processing per Document        : (.*) Seconds' -AllMatches
    if ($rc) {
        $report.totalProcessingTime  = $rc.Matches[0].Groups[2].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Average Processing per Page            : (.*) Seconds' -AllMatches
    if ($rc) {
        $report.avgPagePerSec = $rc.Matches[0].Groups[2].Value
    }
    
    ##$report.indexFileName       = (select-string -Path $inputReport -Pattern 'File\s+: (.*)\s+' -AllMatches).Matches[0].Groups[1].Value
    ##$report.unarchivedDoc       = [int](select-string -Path $inputReport -Pattern 'Unarchived Documents  : (.*)' -AllMatches).Matches[0].Groups[1].Value
    ##$report.fileSize            = [int](select-string -Path $inputReport -Pattern 'File Size : (\d*)\s+' -AllMatches).Matches[0].Groups[1].Value
    ##$report.entriesFound        = [int](select-string -Path $inputReport -Pattern 'Entries Found         : (.*)' -AllMatches).Matches[0].Groups[1].Value
    #$report.totalDocsImported   = [int](select-string -Path $inputReport -Pattern 'TOTALS\s+(\d{1,9})\s+(\d{1,9})' -AllMatches).Matches[0].Groups[1].Value
    #$report.totalPagesImported  = [int](select-string -Path $inputReport -Pattern 'TOTALS\s+(\d{1,9})\s+(\d{1,9})' -AllMatches).Matches[0].Groups[2].Value

    # Convert time for total processing time
    if ($report.totalProcessingTime -Match '(\d{1,2}) Hours, (\d{1,2}) Minutes, (\d{1,2}) Seconds') {
        $hour = $Matches[1].PadLeft(2,'0')
        $min  = $Matches[2].PadLeft(2,'0')
        $sec  = $Matches[3].PadLeft(2,'0')    
    }
    $report.totalProcessingTime = $hour + ":" + $min + ":" + $sec
    
    # Extract multiple occurences fields
    $rawDocTypes = (select-string -Path $inputReport -pattern '\s+(\d{1,3})(.+)(\.|\*)+\s+(\d{1,8})\s+(\d{1,8})' -AllMatches).Matches
   
    foreach ($item in $rawDocTypes) {
        $docType = [docTypeStatObj]::new()
        $docType.id = $item.Groups[1].Value
        $docType.name = (($item.Groups[2].Value) -replace "\.|\*","").Trim()
        $docType.batchId = $report.internalBatchId
        $docType.date = $report.date
        $docType.time = $report.time
        $docType.countDocs = $item.Groups[4].Value
        $docType.countPages =$item.Groups[5].Value
        $listDocTypesObj.add($docType)
        $countDTStats += 1 
    }
   
    # Add this report to the verif object list
    $listVerifObj += $report
    $report = $null
    $countProcessedFiles += 1
}

Write-host "----------------------------------------------------------------------------------------------------------------------------------"

if ($CSV) {
    # Create CSV output
    Write-Host "Create CSV output lists as" $dest/$date"_reportBatchesInfo.csv"
    $listVerifObj = $listVerifObj | Sort-Object -Property date,time
    $listVerifObj | Export-Csv -path $dest/$date"_reportBatchesInfo.csv"

    # $listVerifCSV | Export-Csv -path "./reportBatchesInfo.csv"
    Write-Host "Create CSV output lists as" $dest/$date"_reportByDocTypes.csv"
    $listDocTypesObj = $listDocTypesObj | Sort-Object -Property date,time
    $listDocTypesObj | Export-Csv -path $dest/$date"_reportByDocTypes.csv"
}

# Create JSON output
if ($JSON) {
    Write-Host "Create JSON output list as" $dest/$date"_reportBatchesInfo.json"
    $listVerifObj_JSON = $listVerifObj | ConvertTo-Json -Depth 2
    $listVerifObj_JSON | Add-Content -path $dest/$date"_reportBatchesInfo.json"

    Write-Host "Create JSON output list as" $dest/$date"_reportByDocTypes.json" 
    $listDocTypes_JSON = ConvertTo-Json $listDocTypesObj 
    $listDocTypes_JSON | Add-Content -path $dest/$date"_reportByDocTypes.json" 
}

Write-host "----------------------------------------------------------------------------------------------------------------------------------"
Write-Host "Statistics : "
Write-host "----------------------------------------------------------------------------------------------------------------------------------"
Write-host "Total processed index :" $countProcessedFiles "file(s)"
Write-host "Total records         :" $countRunRecords "record(s)"
Write-Host "Total doctype stats   :" $countDTStats "record(s)"
$listDocTypes_JSON | ConvertFrom-Json -Depth 2 | Sort-Object -Property id |  Group-Object -Property "name" | Select-Object -Property Count, Name | ft
Write-host "----------------------------------------------------------------------------------------------------------------------------------"



exit 0
#----------------------------------------------------------------------------------------------------------------------------------
