#--------------------------------------------------------------------------------------------------------------
# Name        : refactorIndex.ps1
#--------------------------------------------------------------------------------------------------------------
# Author      : D.Lambret
# Date        : 09.12.2021
# Status      : DEV
# Version     : 0.1
#--------------------------------------------------------------------------------------------------------------
# Description : Parse et corrige les index CSV fournis par SPS
# Les noms de fichiers PDF sources sont modifiés en supprimant la valeur numérique placée en fin de chaine.
# Les enregistrements sont ensuite sauvés dans une nouvelle version du fichier CSV
#--------------------------------------------------------------------------------------------------------------

Param( 
    [parameter(Mandatory=$true)][string]$path,
    [parameter(Mandatory=$true)][string]$dest
)

#--------------------------------------------------------------------------------------------------------------
# Global variables
#--------------------------------------------------------------------------------------------------------------
# Script description
#--------------------------------------------------------------------------------------------------------------
$version     = "0.1"
$author      = "D.Lambret"
$versionDate = "09.12.2021"

# Work variables
#--------------------------------------------------------------------------------------------------------------
$errorDefaultAction             = "Inquire"
$countOriginalRecords           = 0
$countUpdatedRecords            = 0
$countMatchingRecords           = 0
$countUnmatchingRecords         = 0
$countCSVFiles                  = 0
$countTotalOriginalRecords      = 0
$countTotalUpdatedRecords       = 0
$countTotalMatchingRecords      = 0
$countTotalUnmatchingRecords    = 0
$countFileLinkOK                = 0
$countFileLinkKO                = 0
$srcFilter                      = "*.csv"
$csvDelim                       = "~"
$maxFileNameLength              = 26
$csvHeaders = @(
                 "documentId", "contentDate","CustomerFirstName","CustomerLastName","DocumentClass",
                 "DocumentDate","DocumentIdString","DocumentSize","DocumentType","InsurancePolicyNumber",
                 "InvPropNumber","Locality","PostalCode","ProposalNumber","Read","ReferenceNumber","TCSDocumentId"
                 "FullPath","ImportJobId","ZipName"
               )
#--------------------------------------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------------------------------------
# 1 - Splash info
Write-Host "--------------------------------------------------------------------------------------------------------------"
Write-Host $MyInvocation.MyCommand.Name "v $version"
Write-Host "--------------------------------------------------------------------------------------------------------------"

# 2 - Script initialization
# Test output path and create it if necessary
if (-not (Test-Path -path $dest)) {
    Write-Host "Destination directory $dest does not exist."
    Write-Host "Create destination directory $dest."
    New-Item $dest -ItemType Directory -ErrorAction $errorDefaultAction
}

# Test source directory, exit if not exists
if (-not (Test-Path -path $path)) {
    Write-Host "Source path $path does not exist!"
    Write-Host "Exit script with error code..."
    exit 1
}

# 3 - Read all CSV files in source directory
$csvList = Get-ChildItem -path $path -filter $srcFilter
$countCSVFiles = ($csvList).Count
foreach ($csvFileItem in $csvList) {
    write-Host "Processing file $csvFileItem"
    write-Host ".............................................................................................................."
    $csvContent = Import-CSV $path/$csvFileItem -Delimiter $csvDelim -Header $csvHeaders 
    $countOriginalRecords = ($csvContent).Count
    # For every records found
    foreach ($csvRecord in $csvContent) {
       # Test if fill name includes extra field we want to remove
       $fullPath = ($csvRecord | select-object -ExpandProperty "FullPath")
       if ( $fullPath -match "(.*).pdf$") {
            # Extract record info and update fullpath member by adding document_id at the very end     
            $filename =  Split-Path $fullPath -Leaf
            $newFullPath = ($fullPath -replace '.pdf$','') + "_" + ($csvRecord | Select-Object -ExpandProperty 'documentId') + ".pdf"
            if ($filename.Length -gt $maxFileNameLength) {
                Write-Host "Warning : file name found has a length bigger than expected. It could means the CSV has allready been transformed."
                Write-Host "Warning : " $fullPath " is bypassed but kept in the index with original value."
                continue
            }
            $csvRecord.FullPath = $newFullPath
           
            # Test if file exists?
            if (-not (Test-Path -Path $csvRecord.FullPath))
            {
            Write-Host "Warning: Source file " $csvRecord.FullPath " does not exist!!!"
            $countFileLinkKO +=1
            } else {
                #Write-Host "File" $csvRecord.FullPath "link is OK"
                $countFileLinkOK +=1
            }
            $countMatchingRecords += 1
       } else {
             $countUnmatchingRecords += 1
             Write-Host "Did not find a correct fullpath for " $csvRecord.FullPath
       }  
    }
    
    # Update CSV file creating a new copy
    $csvFileItemUpdated = ($csvFileItem -replace '.csv$','') + '_refactored' + '.csv'
    Write-Host "Save new CSV copy as $dest/$csvFileItemUpdated"
    $csvContent |  Export-CSV -path "$dest/$csvFileItemUpdated" -Delimiter $csvDelim -Append -NoTypeInformation 
    (gc $dest\$csvFileItemUpdated) | Select -skip 1 | foreach-object {$_ -replace '"',''} | set-content  $dest\$csvFileItemUpdated
    
    write-Host ".............................................................................................................."
    Write-Host "Original records found  : " $countOriginalRecords " record(s)"
    Write-Host "Matching records update : " $countMatchingRecords " record(s)"
    Write-Host "Unmatching records      : " $countUnmatchingRecords " record(s)"
    Write-Host "File links OK           : " $countFileLinkOK " link(s)"
    Write-Host "File links KO           : " $countFileLinkKO " link(s)"
    Write-Host ".............................................................................................................."
    $countTotalOriginalRecords      += $countOriginalRecords
    $countTotalMatchingRecords      += $countMatchingRecords
    $countTotalUnmatchingRecords    += $countUnmatchingRecords
    $countMatchingRecords           = 0
    $countUnmatchingRecords         = 0
}

Write-Host "--------------------------------------------------------------------------------------------------------------"
Write-Host "Process Summary "
Write-Host "--------------------------------------------------------------------------------------------------------------"
Write-Host "Total CSV files processed        :" $countCSVFiles " file(s)"
Write-Host "Total CSV records found          :" $countTotalOriginalRecords " record(s)"
Write-Host "Total matching records processed :" $countTotalMatchingRecords " record(s)"
Write-Host "Total unmatching records found   :" $countTotalUnmatchingRecords " record(s)"
Write-Host "--------------------------------------------------------------------------------------------------------------"

