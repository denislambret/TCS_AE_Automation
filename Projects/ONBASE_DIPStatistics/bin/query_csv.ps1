Import-Module JoinModule

function Get_MergedCSVReport
{
    Param (
        [Parameter(mandatory=$true)][string] $primaryTable,
        [Parameter(mandatory=$true)][string] $secondaryTable,
        [Parameter(mandatory=$true)][string] $jointParam
    )
    
    if ((-not (Test-Path $primaryTable)) -or (-not (Test-Path $secondaryTable)) ) {
        return $False
    }

    $MergedReport = Import-CSV $primaryTable `
    | InnerJoin (Import-CSV  $secondaryTable) -On $jointParam  #`
    
    if ($Filter) {
        $MergedReport = $MergedReport| Where-Object {$Filter}
    }
    return $MergedReport
}

function Get-QueryResult
{
    Param (
        [Parameter(mandatory=$true)][string] $MergedReport,
        [Parameter(mandatory=$false)][string] $Filter
    )
}


# Build a jointure on both batch and doctypes CSV files
# A filter is set to select only records with no error
$stats = $null
$stats = Import-CSV G:\dev\20_GitHub\tcs\data\output\20220319_reportBatchesInfo.csv `
| InnerJoin (Import-CSV  G:\dev\20_GitHub\tcs\data\output\20220319_reportByDocTypes.csv) -On date, time  #`
#| Where-Object {$_.isError -eq $False}

# List selected fields
$query1 = $stats |  Group-Object Date, time `
| Select -ExpandProperty Group `
| Select-object -property date, time, batchId, processFormat, name, indexFileName, fileSize, sourceReportPath, totalPagesImported, totalDocsImported -Last 2 `
| Sort-Object -Property batchId 
#$query1 | fl

# List last two records with all fields - Group by date time and sorted by batch id
$query2 = $stats |  Group-Object Date, time `
| Select -ExpandProperty Group `
| Select-object -property date, time, batchId, processFormat, indexFileName, indexFileSize, indexEntriesFound, defaultDocDate `
| Sort-Object -Property batchId 
$query2 | ft

# List all batch ids in error
$query3 = $stats | Group-Object Date, time `
| Select -ExpandProperty Group `
| Select-Object -Property date, time, batchId, processFormat, indexFileName, indexFileSize, indexEntriesFound, defaultDocDate `
| Select-Object -Unique 
| Where-Object {$_.isError -eq $True}
| Sort-Object -Property batchId 
$query3 | Select-Object -Unique -Property batchId | ft