
#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Reset-NGINXLogs.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 2022116
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Copy access and error logs for nginx, then formalize in dated logs 
        Output is same directory as input logs.
        Sources are removed if process is OK

    .DESCRIPTION
        A longer description.

    .PARAMETER FirstParameter
        Path - Source path for NGINX Exstream logs. If no value use default path
    .PARAMETER SecondParameter
        Description of each of the parameters.

 #>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ] $path,
    
    # help switch
    [switch] $help
)



#----------------------------------------------------------------------------------------------------------------------------------
#                                                I N I T I A L I Z A T I O N
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .DESCRIPTION
        Setup logging facilities by defining log path and default levels.
        Create log instance
#>


BEGIN {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                           G L O B A L   I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables as AUTHOR, VERSION, and Last modif date
			Also define output separator line size for nice formating
			Define standart script exit codes
    #>
    $Env:PSModulePath = $Env:PSModulePath+";d:\Scripts\libs"
    Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog
    # Log initialization
    if (-not (Start-Log -path $global:LogRoot -Script $MyInvocation.MyCommand.Name)) { 
        "FATAL : Log initializzation failed!"
        exit $EXIT_KO
    }
    
    # Set log default and minum level for logging (ideally DEBUG when having trouble)
    Set-DefaultLogLevel -Level "INFO"
    Set-MinLogLevel -Level "INFO"
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Includes
        
        .DESCRIPTION
            Include necessary libraries
    #>
   
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                          G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables 
    #>
    $VERSION      = "0.1"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = "20221116"

    # Work variables including calendar to convert text month in int month
    $cal = @{ 
        "Jan" = 1;
        "Feb" = 2;
        "Mar" = 3;
        "Apr" = 4;
        "May" = 5;
        "Jun" = 6;
        "Jul" = 7;
        "Aug" = 8;
        "Sep" = 9;
        "Oct" = 10;
        "Nov" = 11;
        "Dec" = 12
    }

    # Error log split process
    $source_log_file = $source_log_path + "\error.log"
    $bkp_log_file = $source_log_file + ".old"
    
    # Service description
    $service_name = "nginx166"
    $service_delay = 1
    $service_retry = 5

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : Start-ServiceUnit
    #..................................................................................................................................
    # Start a single service and wait until running. Return false after x attempts
    #..................................................................................................................................
    function Start-ServiceUnit {
        param(
            [Parameter(Mandatory = $true)][Alias("name")][string] $service_name,
            [Parameter(Mandatory = $true)][Alias("delay")][int] $service_delay,
            [Parameter(Mandatory = $true)][Alias("retry")][int] $service_retry
        )
        
        # Start service
        Start-Service -Name $service_name -ErrorAction Continue
        
        # Wait until running
        $attempts = 1
        do 
        {
            Log -Level 'DEBUG' -Message ("Start Service attempt # " + $attempts)   
            $countSrv = (Get-Service $service_name | ? {$_.status -match "Running"}).count
            $attempts++
            Start-Sleep -Second $service_delay
            if ($attempts -ge $service_retry) { 
                log -Level 'ERROR' -message "Maximum attempts reached... abort for this service"
                return $false
            }          
        } until (($countSrv -ge 1))

        # Everything is fine
        return $true
    }

    #..................................................................................................................................
    # Function : Stop-SerficeUnit
    #..................................................................................................................................
    # Stop a single service and wait until running. Return false after x attempts
    #..................................................................................................................................
    function Stop-ServiceUnit {
        param(
            [Parameter(Mandatory = $true)][Alias("name")][string] $service_name,
            [Parameter(Mandatory = $true)][Alias("delay")][int] $service_delay,
            [Parameter(Mandatory = $true)][Alias("retry")][int] $service_retry
        )
        
        # Start service
        Stop-Service -Name $service_name -ErrorAction Continue
        
        # Wait until running
        $attempts = 1
        do 
        {
            Log -Level 'DEBUG' -Message ("Stop Service attempt # " + $attempts)   
            $countSrv = (Get-Service $service_name | ? {$_.status -match "Stopped"}).count
            $attempts++
            Start-Sleep -Second $service_delay
            if ($attempts -ge $service_retry) { 
                log -Level 'ERROR' -message "Maximum attempts reached... abort for this service"
                return $false
            }          
        } until (($countSrv -ge 1))
        
        # Everything is fine
        return $true
    }
    
    #..................................................................................................................................
    # Function : Split-LogExt
    #..................................................................................................................................
    # Split-Log in correctly dated logs regrouped by day (yyyymmdd)
    #..................................................................................................................................
    function Split-LogExt 
    {  
        param(
            [Parameter(Mandatory = $true)][string] $name,
            [Parameter(Mandatory = $true)][Alias("Source")][string] $source_log_path
        )

        # Access log split process
        $source_log_file = $source_log_path + "\" + $name + ".log"
        $output_log_file = $source_log_path + "\" + (Get-Date -f "yyyyMMdd") + "_nginx_" + $name + ".log"
        $bkp_log_file = $source_log_path + "\" + (Get-Date -f "yyyyMMdd") + "_nginx_" + $name + ".bkp"
        
        Log -Level 'INFO' -Message("Now splitting " + $source_log_file)
        Log -Level 'DEBUG' -Message('Log split process starting on ' + $source_log_file)
        Log -Level 'DEBUG' -Message('Log backup on ' + $bkp_log_file)
        
        # Read file line by line 
        # Foreach line search for date pattern in order to name children logs
        # Then add content to children
        Log -Level 'DEBUG' -Message('Does ' + $bkp_log_file + ' exist?')
        if (-not (Test-Path $bkp_log_file)) {
            Log -Level 'DEBUG' -Message('No backup file '+ $bkp_log_file + ' found! Abort.') 
            Exit-KO
        }
        
        $buffer = @() 

        $content = get-content $bkp_log_file
        $totalLines = ($content).Count
        
        if ($buffer) {    
            $buffer | Out-File -Append -path $output_log_file
            $buffer = @()
        }
        
        $prevDate = "1980-01-01"
        $lineCount = 0
        foreach ($line in $content) {
            $lineCount += 1
            if ($line -match '(\d{4})/(\d{2})/(\d{2}) (\d{2}):(\d{2}):(\d{2})') {
                    $year = $Matches[1]
                    $month = $Matches[2]
                    $day = $Matches[3]
                    $hour = $Matches[4]
                    $minute = $Matches[5]
                    $second = $Matches[6]
                    
                    $curDate =$year + $month + $day
                    if (($curDate -ne $prevDate) -and ($buffer)) {
                        $buffer | Out-File -Append -path $logName
                        "New file date...Dump buffer in out-file."
                        $buffer = @()
                    }
                    if ($year -and $month -and $day) {
                        $logName = $root + $curDate + "_Nginx_RevProxy.log"
                    }   
                }
                
                # Add line to buffer 
                $buffer += $line
                $prevDate = $year + $month + $day
                if (-not ($lineCount % 1000)) {
                    "Total lines processed so far : " + $lineCount + " / " + $totalLines 
                    $buffer | Out-File -Append -path $output_log_file
                    "Dump buffer in out-file."
                    $buffer = @()
                }
         }   
    }
    
    #..................................................................................................................................
    # Function : Split-Log
    #..................................................................................................................................
    # Split-Log in correctly dated logs regrouped by day (yyyymmdd)
    #..................................................................................................................................
    function Split-Log {
        param(
            [Parameter(Mandatory = $true)][string] $name,
            [Parameter(Mandatory = $true)][Alias("Source")][string] $source_log_path
        )

        # Access log split process
        $source_log_file = $source_log_path + "\" + $name + ".log"
        $output_log_file = $source_log_path + "\" + (Get-Date -f "yyyyMMdd") + "_nginx_" + $name + ".log"
        $bkp_log_file = $source_log_path + "\" + (Get-Date -f "yyyyMMdd") + "_nginx_" + $name + ".bkp"
        Log -Level 'INFO' -Message("Now splitting " + $source_log_file)
        Log -Level 'DEBUG' -Message('Log split process starting on ' + $source_log_file)
        Log -Level 'DEBUG' -Message('Log backup on ' + $bkp_log_file)
        
        # Read file line by line 
        # Foreach line search for date pattern in order to name children logs
        # Then add content to children
        Log -Level 'DEBUG' -Message('Does ' + $bkp_log_file + ' exist?')
        if (-not (Test-Path $bkp_log_file)) {
            Log -Level 'DEBUG' -Message('No backup file '+ $bkp_log_file + ' found! Abort.') 
            Exit-KO
        }
        
        $log_content = get-Content $bkp_log_file
        
        foreach ($item in $log_content) {           
            $rc = $item | select-string -Pattern '(\d{4})/(\d{2})/(\d{2}) (\d{2}):(\d{2}):(\d{2})' -AllMatches
            # prev pattern matching : \[(\d{2})/(.+)/(\d+)\:
            if ($rc) {
                
                #$month = $cal[$rc.Matches[0].Groups[2].Value]
                #$month = $month.toString().PadLeft(2,"0")
                $year = $rc.Matches[0].Groups[1].Value
                $month = $rc.Matches[0].Groups[2].Value
                $day = $rc.Matches[0].Groups[3].Value
                $date = $year + $month + $day
                $output_log_file =  ".\" + $date + "_nginx_" + $name + ".log"
            } 
            
            if (test-path $output_log_file) { 
                Log -Level 'DEBUG' -Message("Add content to " + $output_log_file)
                Add-Content -path $output_log_file -value $item 
            } else {
                Log -Level 'DEBUG' -Message("Create new log file " + $output_log_file)
                Set-Content -path $output_log_file -value $item
            }
        }

        # Remove source log processed
        Remove-Item $bkp_log_file
        Remove-Item $source_log_file 

        # return OK
        return $true
    }

    
    #..................................................................................................................................
    # Function : Backup-Log
    #..................................................................................................................................
    # Create a backup cpy of source log file dated today
    #..................................................................................................................................
    function Backup-Log {
        param(
            [Parameter(Mandatory = $true)][string] $name,
            [Parameter(Mandatory = $true)][Alias("Source")][string] $source_log_path
        )
        
        # Access log split process
        $source_log_file = $source_log_path + "\" + $name + ".log"
        $output_log_file = $source_log_path + "\" + (Get-Date -f "yyyyMMdd") + "_nginx_" + $name + ".log"
        $bkp_log_file = $source_log_path + "\" + (Get-Date -f "yyyyMMdd") + "_nginx_" + $name + ".bkp"
        
        # Backup current log. We are working on backup content. The file is reset to 0 just after copy
        Log -Level 'DEBUG' -Message('Backup current log ' + $source_log_file + ' to destination ' + $bkp_log_file + ' -Force')
        if (-not (Test-Path $source_log_file)) {
            Log -Level 'ERROR' -Message($source_log_file + ' does not exist')
            return $false
        }
        
        try {
            Copy-Item -Path $source_log_file -Destination $bkp_log_file -Force
        }
        catch {
          Log -Level 'ERROR' -Message($error)
          return $false
        }
        
        # return OK
        return $true
    }

    #..................................................................................................................................
    # Function : EXIT_OK
    #..................................................................................................................................    
    function Exit-KO {
        Pop-Location
        Stop-Log
        exit $EXIT_KO
    }
    
    #..................................................................................................................................
    # Function : EXIT_OK
    #..................................................................................................................................
    function Exit-OK {
        Pop-Location
        Log -Level 'INFO' -message $SEP_L1
        Stop-Log | Out-Null
        exit $EXIT_OK
    }

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Reset-NGINXLogs.ps1"
        " "
        "Options : "
        "-path      Source log path"
        "-Help      Display command help"
    }
   
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
    
    # Script info
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION)
    Log -Level 'INFO' -Message $SEP_L1
    
    # Display inline help if required
    if ($help) { helper }
    
    # Test source path
    if (-not $path) { $source_log_path =  "D:\ManagementGateway\16.6\root\revproxy\logs" } 
    elseif (Test-Path $source_log_path) { $source_log_path = $path }
    
    # Switch to log directory 
    Push-Location
    Set-Location $source_log_path

    # 1 - Stop NGINX service
    Log -Level 'INFO' -Message('1 - Stop NGINX service')
    Log -Level 'INFO' -Message $SEP_L2
    if (-not (Stop-ServiceUnit -name $service_name -delay $service_delay -retry $service_retry)) {
        Log -Level 'ERROR' -Message('Unable to stop ' + $service_name)
        Exit-KO
    }
    

    # 2 - Split and process log files
    Log -Level 'INFO' -Message('2 - Process logs for split process')
    Log -Level 'INFO' -Message $SEP_L2
    
    # - Error log split process
    Log -Level 'DEBUG' -Message('Error log split process')
    $error_log_file = $source_log_path + "\error.log"
    $bkp_log_file = (Get-Date -f "yyyyMMdd") + "_nginx_error.bkp"
    
    # Backup current log. We are working on backup content. The file is reset to 0 just after copy
    if (-not (Backup-Log -Name "error" -Source  $source_log_path)) {
         Exit-KO
    }

    # Split it
    if (-not (Split-Log -Name "error" -Source $source_log_path)) {
        Log -Level 'ERROR' -Message('Error while splitting error log file ' + $error_log_file)
        Exit-KO
    }
       
    # - Access log split process
    Log -Level 'DEBUG' -Message('Access log split process')
    $access_log_file = $source_log_path + "\access.log"
    $bkp_log_file = (Get-Date -f "yyyyMMdd") + "_nginx_access.bkp"

    # Backup current log. We are working on backup content. The file is reset to 0 just after copy
    if (-not (Backup-Log -Name "access" -Source  $source_log_path)) {
         Exit-KO
    }

    # Split it 
    if (-not (Split-Log -Name "access" -Source  $source_log_path)) {
        Log -Level 'ERROR' -Message('Error while splitting access log file ' + $access_log_file)
        Exit-KO
    }
        
    # 3 - Restart service
    Log -Level 'INFO' -Message $SEP_L2
    Log -Level 'INFO' -Message('3 - Restart service '+ $service_name)
    if (-not (Start-ServiceUnit -name $service_name -delay $service_delay -retry $service_retry)) {
        Log -Level 'ERROR' -Message('Unable to stop ' + $service_name)
         Exit-KO
    }
    
    # Standard exit
    Exit-OK
    #----------------------------------------------------------------------------------------------------------------------------------
}