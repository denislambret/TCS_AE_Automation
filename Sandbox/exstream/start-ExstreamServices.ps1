#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Start-ExstreamServices.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220610
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Start all Exstream services in sequence

    .DESCRIPTION
        Start all Exstream services in sequence - OTDS / TomEE / Stream srv Mgt Gateway / NGINX / doc scenarii

   

    .INPUTS
        -Services Services list in CSV format (name;retry;delay)

    .OUTPUTS
        Script log
        =  0 - Succesfful
        <> 0 - Error
#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                             C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path for services list CSV File
    [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
                Position = 0)]
    $services,
    
    # help switch
    [switch]
    $help
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
    $script_Root = "D:\scripts\tools"
    $log_path = "D:\scripts\logs"
    $lib_path = "D:\scripts\libs"
    $Env:PSModulePath = $Env:PSModulePat + ";" + $lib_path
    
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
    $VERSION = "0.1"
    $AUTHOR  = "Denis Lambret"
    $SCRIPT_DATE  = ""
    $SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
    $SEP_L2  = '......................................................................................................................'
    $EXIT_OK = 0
    $EXIT_KO = 1
    

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .DESCRIPTION
            Particularly when the comment must be frequently edited,
            as with the help and documentation for a function or script.
    #>
    
    # Script infp
    Log -Level 'INFO' -Message $SEP_L1
    Log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION + " (" + $SCRIPT_DATE + " / " + $AUTHOR + ")")
    Log -Level 'INFO' -Message $SEP_L1
    
    # 1 - Test and load services CSV list
    if (-not (Test-Path $services)) { 
        $services + " source CSV file does not exist... Abort."
        exit $EXIT_KO
    }

    $errorScript = $False
    $headers = ("name", "retry", "delay")
    $services_list = Import-CSV -Path $services -Header $headers -Delimiter ";"

    # 2 - Foreach service, launch start sequence
    foreach ($service in $services_list) {
      Log -Level 'INFO' -Message $SEP_L2
      Log -Level 'INFO' -Message ("Starting service " + $service.name + " - " + $service.description)
      Log -Level 'INFO' -Message $SEP_L2
      $attempts = 0
      $countSrv = (Get-Service $service.name | ? {$_.status -match "Running"}).count  
      if ($countSrv -gt 0) {
        Log -Level 'INFO' -Message ("Service already running...")
        continue
      }
      
      while (($attempts -le $service.retry) -and ($countSrv -eq 0)) {
            Start-Service -Name $service.name -ErrorAction SilentlyContinue
            (Get-Service $service.name).WaitForStatus('Running', $service.delay)
            do 
            {
              Log -Level 'DEBUG' -Message ("Attempt # " + $attempts)   
              $countSrv = (Get-Service $service.name | ? {$_.status -match "Running"}).count
              $attempts++
              Start-Sleep -Second $service.delay
            } until (($countSrv -ge 1))
                
            
          if ($attempts -ge $service.retry) { 
            log -Level 'ERROR' -message "Maximum attempts reached... abort for this service"
            break
          }      
        }

        if ($attempts -ge $service.retry -and $service.status -eq "Stopped") {
            $errorScript = $True
            Log -Level "ERROR" -Message ("Unable to start service " + $service.name)
        }
    }

    # 3 - check if everything went well
    if (-not $errorScript) {
        Log -Level "INFO" -Message "Script ended successfully."
    } else  {
        Log -Level "ERROR" -Message "Script eneded with error condition"
    }

    # Standard exit
    Stop-Log
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}