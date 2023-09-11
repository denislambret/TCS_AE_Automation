#----------------------------------------------------------------------------------------------------------------------------------
# Script  : removeElderThan_bulk.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : Denis Lambret
# Date    : 
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
# - playbook    Playbook file in CSV format (filter, path, period)
#----------------------------------------------------------------------------------------------------------------------------------
# Synopsys
#----------------------------------------------------------------------------------------------------------------------------------
# Bulk launch for removeElderPath command. The script run a playbook in CSV format including
# - path
# - period
# - period unit
# - filter
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(Mandatory)][string] $playbook,
    [switch] $sim,
    [bool] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#  Script setup
#----------------------------------------------------------------------------------------------------------------------------------
# Initialize log provider 
BEGIN {
    Import-Module Logging    
    $log_level        = 'DEBUG'
    $my_script        = $MyInvocation.MyCommand.Name
    $my_script_path   = split-path $MyInvocation.MyCommand.Path
    $log_file         = $MyInvocation.MyCommand.Name -replace '.ps1','.log'
    $log_path         = split-path $MyInvocation.MyCommand.Path 
    $log_fullname     = $log_path + "\" + (Get-Date -Format "yyyyMMdd") + "_" + $log_file
    
    Add-LoggingTarget -Name Console -Configuration @{
        Level         = $log_level             
        Format        = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}][%{level}] %{message}'
        ColorMapping  = @{
            'DEBUG'   = 'Gray'
            'INFO'    = 'Green'
            'WARNING' = 'Yellow'
            'ERROR'   = 'Red'
        }
    }
    
    Add-LoggingTarget -Name File -Configuration @{
        Path          = $log_fullname
        Level         = $log_level          
        Format        = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}][%{level}] %{message}'
        Append        = $true    
        Encoding      = 'ascii'               
    }
}

PROCESS {
#----------------------------------------------------------------------------------------------------------------------------------
#                                                         I N C L U D E S 
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                                 G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
$VERSION = "0.1"
$AUTHOR  = "Denis Lambret"
$SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
$SEP_L2  = '......................................................................................................................'

# Error codes
#----------------------------------------------------------------------------------------------------------------------------------
Set-Variable SCRIPT_SUCCESS         -Option Constant -Value 0
Set-Variable PLAYBOOK_ERROR         -Option Constant -Value 101
Set-Variable REMOVE_ERROR           -Option Constant -Value 102

# Work variables
$headers = @('Filter','Path','Period','PeriodUnit')
$units   = @('months','days','hours','minutes','seconds')
#----------------------------------------------------------------------------------------------------------------------------------
#                                                             M A I N
#----------------------------------------------------------------------------------------------------------------------------------
if (-not (Test-Path $playbook)) {
    Write-Log -Level 'WARNING' -Message 'No playbook found! Abort...'
    exit 
}

$playbook_cmd = Import-CSV $playbook -Delimiter ";" -Header $headers | Select-Object -Property Filter,Path,Period,PeriodUnit

foreach ($item in $playbook_cmd) {
    # Build file list matching filter criteria
    $list = Get-ChildItem $item.Path -Filter $item.Filter 
    
    if     ($item.PeriodUnit = "months")  { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMonths(-1 * $months)} }
    elseif ($item.PeriodUnit = "days")    { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addDays(-1 * $days)} }
    elseif ($item.PeriodUnit = "hours")   { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addHours(-1 * $hours)} }
    elseif ($item.PeriodUnit = "minutes") { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMinutes(-1 * $minutes)} }
    elseif ($item.PeriodUnit = "seconds") { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addSeconds(-1 * $seconds)} }
    Write-Log -Level 'INFO' -Message "{0} file(s) electible for removal found." -Arguments ($list).Count
    
    # No file to process? exit gently
    if (-not $list) {
        Write-Log -Level 'INFO' -Message "No file to process... Bye!"
        Write-Log -Level 'INFO' -Message $SEP_L1
        exit $false
    }
    
    # Process file list for removal
    Write-Log -Level 'INFO' -Message $SEP_L2
    try {
            foreach ($item in $list) {
                if ($sim) { 
                        Write-Log -Level 'INFO' -Message "REMOVE source:{0} sim:{1}" -Arguments "$path\$item", $sim 
                        Remove-Item -Path $item.Path\$item -ErrorAction Continue -WhatIf | Out-Null 
                }
                else { 
                        Write-Log -Level 'INFO' -Message "REMOVE source:{0}" -Arguments "$path\$item"
                        Remove-Item -Path $item.Path\$item -ErrorAction Continue
                } 
            }
        }
        catch {
            Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
            Write-Log -Level 'ERROR' -Message "Details : {0}" -Arguments $error
            Wait-Logging
            exit 
        }
   
}

Wait-Logging
exit 0
#----------------------------------------------------------------------------------------------------------------------------------
}