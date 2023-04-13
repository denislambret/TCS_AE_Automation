#----------------------------------------------------------------------------------------------------------------------------------
# Script  : parseVerificationReport.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DEnis Lambret
# Date    : 19/03/2022
# Version : 1.1
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
#  Path - Source directory where reprots reside
#  Dest - Output directory for aggregated data output 
#  CSV - Generate CSV output switch 
#  JSON - Generate JSON output switch 
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
    [Parameter(mandatory=$false)][switch]  $CSV  = $True,
    [Parameter(mandatory=$false)][switch]  $JSON = $False,
    [bool]$help
)

#----------------------------------------------------------------------------------------------------------------------------------
#                                                         I N C L U D E S 
#----------------------------------------------------------------------------------------------------------------------------------
Import-Module libEnvRoot
Import-Module libLog

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
    [int]$indexEntriesFound           = 0
    [int]$indexFileSize          = 0
    [int]$unarchivedDoc          = 0
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

# Setup Environment root variables
Set-EnvRoot

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
    log -Level "INFO" -Message "-Path   Source report directory"
    log -Level "INFO" -Message "-Dest   Destination output for CSV and JSON lists"
    log -Level "INFO" -Message "-JSON   Export extracted indexes as JSON"
    log -Level "INFO" -Message "-CSV    Export extracted indexes as CSV"
    log -Level "INFO" -Message "-help   This help text"
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                                             M A I N
#----------------------------------------------------------------------------------------------------------------------------------
# Setup Log facility
Start-Log -path $global:LogRoot -Script $MyInvocation.MyCommand.Name
Set-DefaultLogLevel -Level "INFO"
Set-MinLogLevel -Level "INFO"

log -Level "INFO" -Message "----------------------------------------------------------------------------------------------------------------------------------"
log -Level "INFO" -Message (Split-Path ($MyInvocation.InvocationName) -leaf)
log -Level "INFO" -Message "----------------------------------------------------------------------------------------------------------------------------------"

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
log -Level "INFO" -Message "Processing verification reports..."
$listReportFiles = Get-ChildItem -Path $path | Where-Object { $_.Name -match "^[a-zA-Z0-9]+.txt$"}

# Parse file fileds the old way... Not necessary fast but does the job.
# At least we cover the task in one pass
foreach ($inputReport in $listReportFiles) {
    $countRunRecords += 1
    $report = New-Object VerifReportObj
    
    log -Level "DEBUG" -Message ("Analyzing report : $inputReport")
    
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

    $rc = select-string -Path $inputReport -Pattern 'Unarchived Documents  : (\d{1,10})' -AllMatches
    if ($rc) {
        $report.unarchivedDoc = $rc.Matches[0].Groups[1].Value
    }
    
    $rc = select-string -Path $inputReport -Pattern 'Entries Found         : (\d{1,10})' -AllMatches
    if ($rc) {
        $report.indexEntriesFound = $rc.Matches[0].Groups[1].Value
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

    $rc = select-string -Path $inputReport -Pattern 'Total Number of Documents Found    = (\d{1,10}) during process' -AllMatches
    if ($rc) {
        $report.totalDocFound = [int]$rc.Matches[0].Groups[1].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Total Number of Documents Archived = (\d{1,10}) during process' -AllMatches
    if ($rc) {
        $report.totalDocArchived = [int]$rc.Matches[0].Groups[1].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Total Number of Files Processed    = (\d{1,10}) during process' -AllMatches
    if ($rc) {
        $report.totalIndexProcessed = [int]$rc.Matches[0].Groups[1].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Average Processing per Document        : (.*) Seconds' -AllMatches
    if ($rc) {
        $report.avgDocPerSec  = $rc.Matches[0].Groups[1].Value
    }

    $rc = select-string -Path $inputReport -Pattern 'Average Processing per Page            : (.*) Seconds' -AllMatches
    if ($rc) {
        $report.avgPagePerSec = $rc.Matches[0].Groups[1].Value
    }
    
    # Convert time for total processing time
    $rc = select-string -Path $inputReport -Pattern 'Total Processing Time                  :   (\d{1,2}) Hours, (\d{1,2}) Minutes, (\d{1,2}) Seconds' -AllMatches
    if ($rc) {
        $hour = $rc.Matches[0].Groups[1].Value.PadLeft(2,"0")
        $min  = $rc.Matches[0].Groups[2].Value.PadLeft(2,"0")
        $sec  = $rc.Matches[0].Groups[3].Value.PadLeft(2,"0")
    }
    $report.totalProcessingTime = $hour + ":" + $min + ":" + $sec
    
    # Extract multiple occurence fields
    # Extract docTypes info
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
   
    # Extract index file list if possible
    $rawFilesInfo = (select-string -Path $inputReport -Pattern "^File\s+: (.*.csv)" -Context 1,2 -AllMatches)
    if ($rawFilesInfo) {
       foreach ($rawFile in $rawFilesInfo.Matches)  {
            $report.indexFileName = $rawFile.Groups[1].Value
       }
    }

    $rawFilesInfo = (select-string -Path $inputReport -Pattern "File Size : (\d*)" -Context 1,2 -AllMatches)
    if ($rawFilesInfo) {
       foreach ($rawFile in $rawFilesInfo.Matches)  {
            $report.indexFileSize = $rawFile.Groups[1].Value
       }
    }

    $listVerifObj += $report
    $report = $null
    $countProcessedFiles += 1
}
log -Level "INFO" -Message "----------------------------------------------------------------------------------------------------------------------------------"

# Create CSV output
if ($CSV) {
    log -Level "INFO" -Message ("Create CSV output lists as" + $dest + "/" + $date + "_reportBatchesInfo.csv")
    $listVerifObj = $listVerifObj | Sort-Object -Property date,time
    $listVerifObj | Export-Csv -path $dest\$date"_reportBatchesInfo.csv"

    # $listVerifCSV | Export-Csv -path "./reportBatchesInfo.csv"
    log -Level "INFO" -Message ("Create CSV output lists as" + $dest + "/" + $date + "_reportByDocTypes.csv")
    $listDocTypesObj = $listDocTypesObj | Sort-Object -Property date,time
    $listDocTypesObj | Export-Csv -path $dest\$date"_reportByDocTypes.csv"
}

# Create JSON output
if ($JSON) {
    log -Level "INFO" -Message ("Create JSON output list as" + $dest + "/" + $date + "_reportBatchesInfo.json")
    $listVerifObj_JSON = $listVerifObj | ConvertTo-Json -Depth 2
    $listVerifObj_JSON | Add-Content -path $dest/$date"_reportBatchesInfo.json"

    log -Level "INFO" -Message ("Create JSON output list as" + $dest + "/" + $date + "_reportByDocTypes.json")
    $listDocTypes_JSON = ConvertTo-Json $listDocTypesObj 
    $listDocTypes_JSON | Add-Content -path $dest/$date"_reportByDocTypes.json" 
}

log -Level "INFO" -Message "----------------------------------------------------------------------------------------------------------------------------------"
log -Level "INFO" -Message "Statistics : "
log -Level "INFO" -Message "----------------------------------------------------------------------------------------------------------------------------------"
log -Level "INFO" -Message ("Total processed reports : " + $countProcessedFiles + " file(s)")
log -Level "INFO" -Message ("Total Run records       : " + $countRunRecords + " record(s)")
log -Level "INFO" -Message ("Total doctype stats     : " + $countDTStats + " record(s)")
log -Level "INFO" -Message "----------------------------------------------------------------------------------------------------------------------------------"
$messages = ($listDocTypesObj | Sort-Object -Property id |  Group-Object -Property "name" | Select-Object -Property Count, Name)
$messages | Sort-Object -Property Count -Descending | ForEach-Object {
    log -Level "INFO" -Message (($_.Name).PadLeft(23," ") + " : " + $_.Count + " doc(s)")
}
log -Level "INFO" -Message "----------------------------------------------------------------------------------------------------------------------------------"
Stop-Log
exit 0
#----------------------------------------------------------------------------------------------------------------------------------
