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
# Zip all PDF files from a source directory and copy archive to destination according filter and period elder than
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(Mandatory)][string] $source,
    [Parameter(Mandatory)][string] $dest,
    [Parameter(Mandatory)][string] $filter,
    [switch] $recurse,
    [switch] $remove,
    [int] $months,
    [int] $hours,
    [int] $days,
    [int] $minutes,
    [int] $seconds,
    [bool] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#  Sript setup
#----------------------------------------------------------------------------------------------------------------------------------
BEGIN {

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

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                         I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    $VERSION = "0.1"
    # AUTHOR  = "Denis Lambret"
    $SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
    # SEP_L2  = '......................................................................................................................'
  
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

    Write-Log -Level 'DEBUG' -Message 'Test source and dest path....'
    if (-not (Test-Path $source)) {
        Write-Log -Level 'WARNING' -Message 'Source : {0} not found !' -Arguments $source
        exit $true
    }
    if (-not (Test-Path (Split-Path $dest))) {
        Write-Log -Level 'WARNING' -Message 'Dest   : {0} not found !' -Arguments $dest
        exit $true
    }

    $list = Get-ChildItem $source -Filter $filter 
    if     ($months)  { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMonths(-1 * $months)} }
    elseif ($days)    { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addDays(-1 * $days)} }
    elseif ($hours)   { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addHours(-1 * $hours)} }
    elseif ($minutes) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMinutes(-1 * $minutes)} }
    elseif ($seconds) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addSeconds(-1 * $seconds)} }
    Write-Log -Level 'INFO' -Message "{0} file(s) electible for archiving found." -Arguments ($list).Count

    if (-not $list) {
        Write-Log -Level 'INFO' -Message "No file to process... Bye!"
        Write-Log -Level 'INFO' -Message $SEP_L1
        exit $false
    }
    
    if ((-not (Test-Path -Path $dest -PathType Leaf))) { $zip_file = $dest + "\" + (Get-Date -Format "yyyyMMdd_") + ($my_script -replace ".ps1",".zip")}
    else {$zip_file = $dest}
    
    Write-Log -Level 'DEBUG' -Message "Run Compress cmdlet... -Path {0} -DestinationPath {1}" -Arguments $list, $zip_file
    $error.clear()
    try {
            Write-Log -Level 'DEBUG' -Message "Compress-Archive -Path {0} -DestinationPath {1} -ErrorAction Continue -Force | Out-Null" -Arguments $list, $zip_file
            Compress-Archive -Path $list -DestinationPath $zip_file -ErrorAction Continue -Force | Out-Null
        }
        catch {
            Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
            Wait-Logging
            exit 
        }
    Write-Log -Level 'INFO' -Message "Archive created -> {0} created" -Arguments  $zip_file
    
    if ($remove) {
        try {
            foreach ($source_file in $list) {
                Remove-Item -Path $source_file -ErrorAction Continue                                                                                 
                Write-Log -Level 'DEBUG' -Message "{0} file removed" -Arguments $source_file
            }
        }
        catch {
            Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
            Wait-Logging
            exit 
        }
        Write-Log -Level 'INFO' -Message "{0} source file(s) removed successfully." -Arguments ($list).Count
    }

    Wait-Logging
    exit 0
    #----------------------------------------------------------------------------------------------------------------------------------
}