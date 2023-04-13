#----------------------------------------------------------------------------------------------------------------------------------
# Script  : preprocessorCCM.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : Denis Lambret
# Date    : 
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
# -path    Source CSV index file
# -Dest    Destination index CSV file
# -Lookup  Link to Lookup table used to compute doc type
#----------------------------------------------------------------------------------------------------------------------------------
# Synopsys
#----------------------------------------------------------------------------------------------------------------------------------
# Process one CCM CSV index file before import in OnBase
#  - Convert source to UTF8
#  - Compute DocType value for import and complete CSV
#----------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
Param (
    [Parameter(Mandatory=$True)][String]$Path,
    [Parameter(Mandatory=$False)][String]$Dest,
    [Parameter(Mandatory=$True)][String]$Lookup
)

#----------------------------------------------------------------------------------------------------------------------------------
#                                                  I N I T I A L I Z A T I O N
#----------------------------------------------------------------------------------------------------------------------------------
BEGIN {
    # Update vars depending of environment used
    $Env:PSModulePath = $Env:PSModulePath+";Y:\03_DEV\06_GITHUB\tcs-1\libs"
    $log_path = "Y:\03_DEV\06_GITHUB\tcs-1\logs"
    #.............................................................................................................................

    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
    $rc = Set-DefaultLogLevel -Level "INFO"
    $rc = Set-MinLogLevel -Level "DEBUG"
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                                       L  I   B   S
#----------------------------------------------------------------------------------------------------------------------------------
PROCESS {
Import-Module libEncoding
Import-Module libLog

#----------------------------------------------------------------------------------------------------------------------------------
#                                                 G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
$VERSION = "0.1"
$AUTHOR  = "Denis Lambret"
$SEP_L1  = '---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
$SEP_L2  = '...................................................................................................................................................................................................'
$EXIT_OK = 0
$EXIT_KO = 1


#----------------------------------------------------------------------------------------------------------------------------------
#                                                             M A I N
#----------------------------------------------------------------------------------------------------------------------------------


$headers_csv    = ("fullpath","CCM_Business","CCM_Direction ","CCM_Origin","CCM_Environnement","CCM_Sequence","CCM_EventType","CCM_forPrintshop","CCM_forEmail","CCM_Langue","CCM_idPli","CCM_refNumber","CCM_lastName","CCM_firstName","CCM_creationDate")
$headers_lookup = ("EventType","DocumentType")

# 1- Check command line parameters
if (-not (Test-Path $Path)) {
    log -level "WARNING" -message "Please define a correct file input path ! Aborting"
    Stop-Log
    exit $EXIT_KO
}

if (-not $Dest) {
    $Dest = $Path
}

if (-not (Test-Path $Lookup)) {
    log -level "WARNING" -message "Please define a correct lookup table ! Aborting"
    Stop-Log
    exit $EXIT_KO
}

log -Level "INFO" -message $SEP_L1
log -Level "INFO" -message "preprocessorCCM.ps1"
log -Level "INFO" -message $SEP_L2
log -Level "INFO" -message "Input : $Path"
log -Level "INFO" -message "Output: $Dest"
log -Level "INFO" -message "Lookup: $lookup"
log -Level "INFO" -message $SEP_L1

# 2 - Read source file and add extra column based on lookup table
$keyIndex = "CCM_EventType"

log -Level "DEBUG" -message ("Read source index $Path as encoded with " + (Get-Encoding -path $Path).Encoding)
if (-not (is_UTF8($Path))) {
    log -Level "DEBUG" -message ("Convert $Path to UTF8 encoding...")
    ConvertTo-UTF8 -path $Path 
}
log -Level "INFO" -message ("Add extra column based on Lootkup table $lookup with key set to $keyIndex")

# 3 - Change file adding last column based on lookup table match on CCM_EVENTID
$count = 0
$bypassed = 0

$lt = Import-csv $lookup  -Header $headers_lookup -Delimiter ";" | Group-Object -AsHashTable -Property EventType
$list = Import-CSV  $Path -Delimiter ";" -Header $headers_csv
$countInputRecords = (Measure-Object -InputObject $list).Count
$new_list = [System.Collections.ArrayList]@()

foreach ($item in $list) {
    $count += 1
    log -Level "INFO" -message ("READ record - " + $item)
    if (($item.$keyIndex) -and ($lt.ContainsKey($item.$keyIndex))) { 
        $item | Add-Member -Name DocType -Type NoteProperty -value $lt[$item.$keyIndex].DocumentType
        $new_list += $item
        log -Level "INFO" -message ("UPDATE record to - " + $item)
    } else {
    log -Level "ERROR" -message ("no key found for key " + $item.col1 + " on row " + $count + " -> Bypass this record ")
    $bypassed += 1
  }
}

log -Level "INFO" -message ("Total input record(s))   : " + $countInputRecords + " record(s))")
log -Level "INFO" -message ("Total record(s) read     : " + $count + " record(s))")
log -Level "INFO" -message ("Total record(s) bypassed : " + $bypassed + " record(s))")
log -Level "INFO" -message ("EXPORT file to - $Dest") 

$new_list | ConvertTo-Csv -Delimiter ";" -NoTypeInformation  | ForEach-Object { $_ -replace '"',''} | Select-Object -Skip 1 | Set-Content -path $Dest -Encoding UTF8 -Force
log -Level "DEBUG" -message ("Total exported records - " + ($new_list).Count + " record(s))")
log -Level "DEBUG" -message ("Read source $Dest encoding -> " + (Get-Encoding -path $Dest).Encoding)   
log -message $SEP_L1   

Stop-Log

if ($bypassed) {
    log -level "ERROR" -Message "EXIT - Process ended with partial success code."
    exit $EXIT_KO
} else {
    exit $EXIT_OK
}


}