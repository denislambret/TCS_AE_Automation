#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Test-ExstreamGenDir.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230120
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
   Count CSV and PDF files on P:\EXSTREAM\PRD166\NIP\OT_output\ECM
   if no fil return True otherwise return False    
#>
#----------------------------------------------------------------------------------------------------------------------------------


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
    $SCRIPT_DATE  = "20230120"

    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

   
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
   

    # Do something here
    # 1 - Read PDF from P:\EXSTREAM\PRD166\NIP\OT_output\ECM
    log -Level 'INFO' -Message ("Search for PDF files...")
    $nbPDF = (Get-ChildItem -path "P:\EXSTREAM\PRD166\NIP\OT_output\ECM" -filter "*.pdf").Count
    log -Level 'INFO' -Message ("Search for CSV files...")
    $nbCSV = (Get-ChildItem -path "P:\EXSTREAM\PRD166\NIP\OT_output\ECM" -filter "*.csv").Count
    
    $total = $nbPDF + $nbCSV


    # 2 - check counters and display info
    log -Level 'INFO' -Message ("PDF documents found : " + $nbPDF + " doc(s)");
    log -Level 'INFO' -Message ("CSV documents found : " + $nbCSV + " doc(s)");
    log -Level 'INFO' -Message ("Total documents found : " + $total + " doc(s)");
    

    # Standard exit and rc return
    Log -Level 'INFO' -message $SEP_L1
    if ($total -gt 0) {
            log -Level 'ERROR' -message ("Some documents where found in P:\EXSTREAM\PRD166\NIP\OT_output\ECM. There should be nothing at this time!")
            log -Level 'ERROR' -message ("Move manaully CSV and PDF file to import directory to solve issue.")
            exit $EXIT_KO
          }
    else { exit EXIT_OK}
    Stop-Log | Out-Null

    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}