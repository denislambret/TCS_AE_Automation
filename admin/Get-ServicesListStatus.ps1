#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Get-ServicesListStatus
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220610
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Return all services status in sequence

    .DESCRIPTION
        Return all services statu in sequence - OTDS / TomEE / Stream srv Mgt Gateway / NGINX / doc scenarii

   

    .INPUTS
        - Services Services list in CSV format (name;retry;delay)

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
    
    # Load services list in CSV Format - headers list gives columns name 
    # Note : Rank values should be encoded on 2 or more position to avoid sort issues (01,02,03... until 09) 
    $headers = ("rank", "name", "description", "defaultStatus", "retry", "delay")
    $services_list = Import-CSV -Path $services -Header $headers -Delimiter ";" | Select-Object -skip 1 | Sort-Object -Property rank 
    
    # Create an array list of services status by parsing service names one by one
    $services = [System.Collections.ArrayList]@()
    foreach ($service in $services_list) {
      $item = Get-Service $service.name  -ErrorAction Continue 
      $item | Add-Member -NotePropertyName "expected" -NotePropertyValue $service.defaultStatus   
      $item | Add-Member -NotePropertyName "rank" -NotePropertyValue $service.rank
      $services.add($item) | Out-Null
    }
    
    # Display ou array list of services with a nice table
    $services | Select-Object rank, name, DisplayName, Status, expected | Format-Table -AutoSize
    
    # And quit
    exit $EXIT_OK
}
