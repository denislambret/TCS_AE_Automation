#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Restart-IISSrv
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230817
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Script to restart IIS

    .INPUTS
        None

    .OUTPUTS
        RC code 0 = OK - 1 = KO

    .EXAMPLE
        Restart_IISSrv.ps1
#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
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
    Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog

    $script_path      = $global:ScriptRoot + "\admin\"
    $config_path      = $script_path + "\" + ($MyInvocation.MyCommand.Name -replace 'ps1','')+ '.conf'
    
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
    $VERSION      = "1.0"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = "17.08.2023"

    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Restart_IISServer.ps1"
        "Simply restart IIS Server. Can be instantiated by VTOM"
        "Options : "
        "-Help      Display command help"
    }
   
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
    
    # Quick comment
    
    # Script infp
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION)
    Log -Level 'INFO' -Message $SEP_L1
    
    # Display inline help if required
    if ($help) { helper }
    
 
    
    Log -Level 'INFO' -Message "Restarting IIS Server...."
    # Do something here
    # 1 - Restart IIS
    $output = C:\Windows\WinSxS\wow64_microsoft-windows-iis-sharedlibraries_31bf3856ad364e35_10.0.17763.1_none_0c0406fc415c8543\iisreset.exe
    if ($output -match 'Internet services successfully restarted') {
        Log -Level 'Info' -Message 'Restart IIS OK'
        Log -Level 'INFO' -message $SEP_L1
        Stop-Log | Out-Null
        return $EXIT_OK
    } else {
        Log -Level 'ERROR' -Message 'Restart IIS did not ended with success code.'
        Log -Level 'INFO' -message $SEP_L1
        Stop-Log | Out-Null
        return $EXIT_KO
    }
    #----------------------------------------------------------------------------------------------------------------------------------
}