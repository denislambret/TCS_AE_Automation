#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Count-ScanLinks.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20221107
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Count links sent to Onbase to reference SCAN CLUB DOCUMENTS
#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $true,
        Position = 0
        )
    ] 
    [Alias('source')]
    $path,
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

    # Log initialization
    if (-not (Start-Log -path $global:LogRoot -Script $MyInvocation.MyCommand.Name -noTranscript)) { 
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
    $VERSION            = "1.0"
    $AUTHOR             = "DLA"
    $SCRIPT_DATE        = "20221107"
    $source_scanfile    = "P:\ONBASE\PRD\DIFFUSION\Scanning\SAVE"

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        ($MyInvocation.MyCommand.Name + " v" + $VERSION)
        "Check and count SCANNING CLUB links file..."
        " "
        "Options : "
        "-path      Source directory / file (alias -source)"
        "-Help      Display command help"
    }
   
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
    # Script infp
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION)
    Log -Level 'INFO' -Message $SEP_L1
    
    # Display inline help if required
    if ($help) { helper }
    if (-not $path) {
        $source_scanfile    = "P:\ONBASE\PRD\DIFFUSION\Scanning\SAVE"
    } else {
        $source_scanfile    = $path
    }

    # 1 - Check directory
    if (-not (Test-Path $source_scanfile)) {
        log -Level 'ERROR' -Message($source_file + " does not exist!")
        log -Level 'ERROR' -Message("Abort script...")
        log -Level 'INFO' -Message $SEP1
        Stop-Log | Out-Null
        exit $EXIT_OK    
    }
    
    # 2 - Get last file generated and count items
    $countFiles = (Get-ChildItem -path *.csv | Where-Object {$_.LastWriteTime -eq (get-date).date}).Count
    $countLinks = (Get-ChildItem -path *.csv | Where-Object {$_.LastWriteTime -eq (get-date).date} | Get-Content).Count
    
    # 3 - Display stats
    if (($countFiles -lt 1) -or ($countLinks -lt 1)) {
        log -Level 'ERROR' -Message("CSV links file not found !")
        log -Level 'ERROR' -Message("CSV links records not found !")
    } else {
        log -Level 'INFO' -Message("CSV links file found    : " + $countFiles + " file")
        log -Level 'INFO' -Message("CSV links records found : " + $countLinks + " record(s)")
    }


    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}