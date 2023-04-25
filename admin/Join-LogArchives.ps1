#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Join-LogArchives.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220401
# Version : 0.5
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Create and organize archive of logs file in a dedicated directory structure

    .DESCRIPTION
        Create and organize archive of logs file in a dedicated directory structure

    .PARAMETER Path
        Path where to find log to archive

    .PARAMETER Recurse
        Proceed recursively on root log's directory

    .PARAMETER
		Remove source log's file once archived.

    .OUTPUTS
        standard proces log

    .EXAMPLE
        Join-LogArchives.ps1 -path d:\scripts\logs\*.log -remove

#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                             C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
Param(
    [Parameter(Mandatory)][string] $path,
    [switch] $recurse,
    [switch] $remove
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
    #.............................................................................................................................
    # Update vars depending of environment used
    # $Env:PSModulePath = $Env:PSModulePath + ";D:\dev\40_PowerShell\tcs\libs"
    # $log_path = "D:\dev\40_PowerShell\tcs\logs"

    # $Env:PSModulePath = $Env:PSModulePath+";G:\dev\20_GitHub\tcs\libs"
    # $log_path = "G:\dev\20_GitHub\tcs\logs"
    $Env:PSModulePath = $Env:PSModulePath + ";" + $env:PWSH_SCRIPTS_LIBS
    $log_path = $env:PWSH_SCRIPTS_LOGS
    
    Import-Module libLog
    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
    $rc = Set-DefaultLogLevel -Level "INFO"
    $rc = Set-MinLogLevel -Level "DEBUG"
}



PROCESS { 
#----------------------------------------------------------------------------------------------------------------------------------
#                                            G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Global variables
    
    .DESCRIPTION
        Set script's global variables 
#>    
$VERSION = "1.0"
$AUTHOR  = "DLA"
$SCRIPT_DATE = "2022-04-02"
$SEP_L1  = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'
$SEP_L2  = '...................................................................................................................................................................'
$EXIT_OK = 0
$EXIT_KO = 1

#----------------------------------------------------------------------------------------------------------------------------------
#                                             _______ _______ _____ __   _
#                                             |  |  | |_____|   |   | \  |
#                                             |  |  | |     | __|__ |  \_|
#----------------------------------------------------------------------------------------------------------------------------------
log -Level "INFO" -Message $SEP_L1 
log -Level "INFO" -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION + (" (" + $SCRIPT_DATE + "/" + $AUTHOR + ")").PadLeft(138," "))
log -Level "INFO" -Message $SEP_L1 
#$path = "D:\dev\40_PowerShell\tcs\data\input\Logs"

if (-not (Test-Path $path)) {
    log -Level "FATAL" -Message ("GET - Input directory " + $path + " not found! Abort...")
} 

# Create log list, group by date et log process name
log -Level "INFO" -Message "GET - Build log files list from $path using filter *.log"
$fullList = New-Object -TypeName 'System.Collections.ArrayList'

if ($recurse) {
    $list = Get-ChildItem -Path $path -Filter *.log -Exclude $log_name
} else {
    $list = Get-ChildItem -Path $path -Filter *.log -Recurse -Exclude $log_name
}

ForEach ($item in $list)
{
    $rc = $item.name | select-string -Pattern '^(\d{8})_(\d+)_(.*).log$' -AllMatches
    
    if ($rc) {
        $date_stamp            = $rc.Matches[0].Groups[1].Value
        if ($rc.Matches[0].Groups[2].Value-match "\d{2}") {
            $time_stamp        = $rc.Matches[0].Groups[2].Value
            $application_name  = $rc.Matches[0].Groups[3].Value
        } else {
            $time_stamp        = $null
            $application_name  = $rc.Matches[0].Groups[2].Value
        }
        
        $date_real             = [Datetime]::ParseExact($date_stamp, 'yyyyMMdd', $null)
        $year                  = Get-Date $date_real -Format "yyyy"
        $month                 = Get-Date $date_real -Format "MM"
        $day                   = Get-Date $date_real -Format "dd"
        $archive_path          = $path + "\archives\" + $year + "\" + $month 

        if (-not (Test-path $archive_path)) {
            log -Level "INFO" -Message ("SET - Create target archive directory : " + $archive_path)
            New-item -Path $archive_path -ItemType Directory | Out-Null
        }
    }       
    $item | Add-Member -Name "archive_path" -Type NoteProperty -value $archive_path
    $item | Add-Member -Name "application_name" -Type NoteProperty -value $application_name
    $item | Add-Member -Name "year" -Type NoteProperty -value $year
    $item | Add-Member -Name "month" -Type NoteProperty -value $month
    $item | Add-Member -Name "day" -Type NoteProperty -value $day
    $rc = $fullList.add($item)
}

# Grouplist items by application an date
$fulllist = $fulllist | Group-Object -Property year, month, application_name | Sort-Object -Property year,month, application_name

# Create the archive
Push-Location
Set-Location $path
foreach ($item in $fullList) { 
    $dest = $item.Group[0].archive_path + "\" + ( $item.Group[0].year + $item.Group[0].month + "_" + $item.Group[0].application_name + ".zip") 
    if (-not (Test-Path $dest)) {
        log -Level "INFO" -Message ("SET - Create archive " + $dest + " and adding " + ($item.Group.Name).Count + " file(s) ")
    } else {
        log -Level "INFO" -Message ("PATCH - Update archive " + $dest + " by adding " + ($item.Group.Name).Count + " file(s) ")
    }
    $rc = Compress-Archive -Path ($item.Group.Name) -DestinationPath ($dest) -Update -CompressionLevel Optimal -ErrorAction Inquire
    if ($remove) {
            foreach ($file in $item.Group.Name) { Remove-Item $file -ErrorAction SilentlyContinue }
        }
}
Pop-Location

# End script gently
log -Level "INFO" -Message ($SEP_L1)
Stop-Log
exit $EXIT_OK
}



