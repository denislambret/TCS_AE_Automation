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

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
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
#  Script setup
#----------------------------------------------------------------------------------------------------------------------------------
BEGIN {
    Import-Module Logging    
    $my_script        = $MyInvocation.MyCommand.Name
    $log_file         = $MyInvocation.MyCommand.Name -replace '.ps1','.log'
    $log_path         = split-path $MyInvocation.MyCommand.Path 
    $log_fullname     = $log_path + "\" + (Get-Date -Format "yyyyMMdd") + "_" + $log_file
    Write-Host $log_path
    Add-LoggingTarget -Name Console -Configuration @{
        Level         = 'DEBUG'             
        Format        = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}][%{level}] %{message}'
        ColorMapping  = @{
            'DEBUG'   = 'Blue'
            'INFO'    = 'Green'
            'WARNING' = 'Yellow'
            'ERROR'   = 'Red'
        }
    }
    
    Add-LoggingTarget -Name File -Configuration @{
        Path          = $log_fullname
        Level         = 'DEBUG'             
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
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                        F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : func1
    #..................................................................................................................................
    # Input    : input
    # Output   : true
    #..................................................................................................................................
    # Synopsis
    #..................................................................................................................................
    #
    #..................................................................................................................................
    function func1 {
        param( 
                [string] $input
            )

        return $true
    }

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                             M A I N
    #----------------------------------------------------------------------------------------------------------------------------------
    Write-Log -Level 'INFO' -Message $SEP_L1
    Write-Log -Level 'INFO' -Message "{0} - Ver {1} " -arguments $my_script,$VERSION
    Write-Log -Level 'INFO' -Message $SEP_L1
    
    if ((-not $seconds) -and (-not $minutes) -and (-not $hours) -and (-not $days) -and (-not $months)) {
        Write-Log -Level 'ERROR' -Message "Please provide a valid period for search"
        Wait-Logging
        exit 0
    }
    
    Write-Log -Level 'INFO' -Message "Build file list applying {0} filter pattern for directory {1}" -Arguments $filter, $source
    $list = Get-ChildItem -Path $source -Filter $filter
    
    Write-Log -Level 'INFO' -Message $SEP_L1
    if     ($months)  { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMonths(-1 * $months)} }
    elseif ($days)    { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addDays(-1 * $days)} }
    elseif ($hours)   { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addHours(-1 * $hours)} }
    elseif ($minutes) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMinutes(-1 * $minutes)} }
    elseif ($seconds) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addSeconds(-1 * $seconds)} }
    Write-Log -Level 'INFO' -Message "{0} file(s) electible for removal found." -Arguments ($list).Count
    foreach ($item in $list) {
        
        Write-Log -Level "INFO" -Message "REMOVE source:{0}" -Arguments $item
        try {
            Remove-Item $item 
        }
        catch {
            Write-Log -Level 'ERROR' -Message "REMOVE source:{0} -> Unable to remove file !" -Arguments $item
        }
    }
    
    Wait-Logging
    exit 0
    #----------------------------------------------------------------------------------------------------------------------------------
}