#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Start-ServicesList.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220610
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Start all services in sequence

    .DESCRIPTION
        Start all services in sequence - OTDS / TomEE / Stream srv Mgt Gateway / NGINX / doc scenarii

   

    .INPUTS
        -Services Services list in CSV format (name;description;retry;delay)

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
    
    # force switch
    [switch]
    $force,
    
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
    Set-MinLogLevel -Level "DEBUG"
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
    $VERSION = "0.2"
    $AUTHOR  = "Denis Lambret"
    $SCRIPT_DATE  = "18.11.2022"
    $EXIT_OK = 0
    $EXIT_KO = 1
    

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
     
    # Script infp
    Log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION)
    Log -Level 'INFO' -Message $SEP_L1
    
    # 1 - Test and load services CSV list
    if (-not (Test-Path $services)) { 
        $services + " source CSV file does not exist... Abort."
        exit $EXIT_KO
    }

    $errorScript = $False
    $headers = ("rank", "name", "description", "defaultStatus", "retry", "delay")
    $services_list = Import-CSV -Path $services -Header $headers -Delimiter ";" | Select-Object -Skip 1 | Sort-Object -Property rank -Desc

    # 2 - Foreach service, launch Stop sequence
    foreach ($service in $services_list) {
    Log -Level 'DEBUG' -Message $SEP_L2
    Log -Level 'INFO' -Message ("Stopping service #" + $service.rank +" - "+ $service.name + " (" + $service.description + ")")
    $attempts = 0
      $countSrv = (Get-Service $service.name | ? {$_.status -match "Stopped"}).count  
      if ($countSrv -gt 0) {
        Log -Level 'DEBUG' -Message ("Service already stopped...")
        continue
      }
      
      while (($attempts -le $service.retry) -and ($countSrv -eq 0)) {
            if (($service.defaultStatus -eq "Stopped") -or ($force))   {
                Log -Level 'DEBUG' -Message ("Stop Service attempt # " + $attempts)   
                Stop-Service -Name $service.name -ErrorAction Continue
				(Get-Service $service.name).WaitForStatus('Stopped', $service.delay)
                do 
                {
                $countSrv = (Get-Service $service.name | ? {$_.status -match "Stopped"}).count
                $attempts++
                Log -Level 'DEBUG' -Message("Service : " + (Get-Service $service.name).status + " - " + $countSrv)
                Start-Sleep -Second $service.delay
                } until (($countSrv -ge 1))

                if ($attempts -ge $service.retry) { 
                    log -Level 'ERROR' -message "Maximum attempts reached... abort for this service"
                    break
                }      
            } else {
                Log -Level 'WARN' -Message ("Service default constraint (" + $service.defaultStatus + ") prevents stop action.")
                break
            }

            if ($attempts -ge $service.retry -and $service.status -eq "Stopped") {
                $errorScript = $True
                Log -Level "ERROR" -Message ("Unable to stop service " + $service.name)
            } 
        }
    }

    # 3 - check if everything went well
    Log -Level 'INFO' -Message $SEP_L1
    if (-not $errorScript) {
        Log -Level "INFO" -Message "Script ended successfully."
    } else  {
        Log -Level "WARNING" -Message "Script eneded with error condition"
    }

    # Standard exit
    Stop-Log
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}