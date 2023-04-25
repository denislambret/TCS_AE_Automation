#----------------------------------------------------------------------------------------------------------------------------------
# Script  : removeElderThan.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : Denis Lambret
# Date    : 30.01.2022
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
#  -source
#  -days
#  -hours
#  -months
#  -filter
#----------------------------------------------------------------------------------------------------------------------------------
# Synopsys
#----------------------------------------------------------------------------------------------------------------------------------
# Remove a selection of file from a source directory based on filter param
#----------------------------------------------------------------------------------------------------------------------------------

param(
        [Parameter(Mandatory=$true)][string] $source,
        [switch] $recurse,
        [Parameter(Mandatory=$true)][string] $filter,
        [int] $months,
        [int] $hours,
        [int] $days,
        [int] $minutes,
        [int] $seconds,
        [bool] $help
    )
    
#----------------------------------------------------------------------------------------------------------------------------------
#                                                 I N I T I A L I Z A T I O N
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .DESCRIPTION
        Setup logging facilities by defining log path and default levels.
        Create log instance
#>
BEGIN {
    $Env:PSModulePath = $Env:PSModulePath + ";" + $env:PWSH_SCRIPTS_LIBS
    $log_path = $env:PWSH_SCRIPTS_LOGS
    Import-Module libLog
    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
    $rc = Set-DefaultLogLevel -Level "INFO"
    $rc = Set-MinLogLevel -Level "DEBUG"
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
PROCESS {

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
    Log -Level 'INFO' -Message ($SEP_L1)
    Log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " - ver "+ $VERSION)
    Log -Level 'INFO' -Message ($SEP_L1)
	
    if ((-not $path) -or (-not (Test-Path -path $path))) {
        Log -Level 'ERROR' -Message "Please provide a valid path"
        Stop-Log
        exit 0
    }

    if ((-not $seconds) -and (-not $minutes) -and (-not $hours) -and (-not $days) -and (-not $months)) {
        Log -Level 'ERROR' -Message "Please provide a valid period for search"
        Stop-Log
        exit 0
    }
    
    Log -Level 'INFO' -Message ("Build file list applying " + $filter + " filter pattern for directory " + $source) 
    $list = Get-ChildItem -Path $source -Filter $filter
     
    Log -Level 'INFO' -Message ($SEP_L1)
    if     ($months)  { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMonths(-1 * $months)} }
    elseif ($days)    { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addDays(-1 * $days)} }
    elseif ($hours)   { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addHours(-1 * $hours)} }
    elseif ($minutes) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMinutes(-1 * $minutes)} }
    elseif ($seconds) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addSeconds(-1 * $seconds)} }
    
	Log -Level 'INFO' -Message (" " + (($list).Count) + " file(s) electable for removal found.") 
    
	foreach ($item in $list) {
        
        Log -Level "INFO" -Message ("REMOVE source: " + $item)
        try {
            Remove-Item $item -recurse 
        }
        catch {
            Log -Level 'ERROR' -Message ("REMOVE source: " + $item + " -> Unable to remove file !")
        }
    }
    
    Stop-Log
    exit 0
    #----------------------------------------------------------------------------------------------------------------------------------
}