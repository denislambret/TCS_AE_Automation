#----------------------------------------------------------------------------------------------------------------------------------
# Script  : zipAllPdf.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : Denis Lambret
# Date    : 29.01.2022
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
# Zip all PDF files from a source directory and copy archive to destination according filter and period elder than
#----------------------------------------------------------------------------------------------------------------------------------
# Synopsys
#----------------------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(Mandatory)][string] $path,
    [Parameter(Mandatory)][string] $filter,
    [string] $log,
    [switch] $recurse,
    [int] $months,
    [int] $days,
    [int] $hours,
    [int] $minutes,
    [int] $seconds,
    [switch] $sim,
    [bool] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#  Script setup
#----------------------------------------------------------------------------------------------------------------------------------
# Initialize log provider 
BEGIN 
{
    Import-Module Logging    
    $log_level        = 'DEBUG'
    $my_script        = $MyInvocation.MyCommand.Name
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

PROCESS 
{
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
  
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                             M A I N
    #----------------------------------------------------------------------------------------------------------------------------------
    # Should we redirect log to a specific target file or std configuration?
    if (-not $log) {
        Write-Log -Level 'INFO' -Message $SEP_L1
        Write-Log -Level 'INFO' -Message "{0} - Ver {1} " -arguments $my_script,$VERSION
        Write-Log -Level 'INFO' -Message $SEP_L1
    } else {
        Add-LoggingTarget -Name File -Configuration @{
            Path          = $log
            Level         = $log_level          
            Format        = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}][%{level}] %{message}'
            Append        = $true    
            Encoding      = 'ascii'               
        }
    }

    # Check command line param to manage period criteria 
    if ((-not $seconds) -and (-not $minutes) -and (-not $hours) -and (-not $days) -and (-not $months)) {
        Write-Log -Level 'ERROR' -Message "Please provide a valid period for search"
        Wait-Logging
        exit 0
    }

    # Check source path
    Write-Log -Level 'DEBUG' -Message 'Test source and dest path....'
    if (-not (Test-Path $path)) {
        Write-Log -Level 'WARNING' -Message 'Source : {0} not found !' -Arguments $path
        exit $true
    }


    # Build file list matiching filter criteria
    $list = Get-ChildItem $path -Filter $filter 
    if     ($months)  { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMonths(-1 * $months)} }
    elseif ($days)    { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addDays(-1 * $days)} }
    elseif ($hours)   { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addHours(-1 * $hours)} }
    elseif ($minutes) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMinutes(-1 * $minutes)} }
    elseif ($seconds) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addSeconds(-1 * $seconds)} }
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
                        Remove-Item -Path $path\$item -ErrorAction Continue -WhatIf | Out-Null 
                }
                else { 
                        Write-Log -Level 'INFO' -Message "REMOVE source:{0}" -Arguments "$path\$item"
                        Remove-Item -Path $path\$item -ErrorAction Continue
                } 
            }
        }
        catch {
            Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
            Write-Log -Level 'ERROR' -Message "Details : {0}" -Arguments $error
            Wait-Logging
            exit 
        }
   
    Wait-Logging
    exit 0
    #----------------------------------------------------------------------------------------------------------------------------------
}

