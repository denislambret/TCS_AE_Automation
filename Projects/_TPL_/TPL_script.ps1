#----------------------------------------------------------------------------------------------------------------------------------
# Script  : script_name
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : author trigram
# Date    : YYYYMMDD
# Version : X.X
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        A brief description of the function or script.

    .DESCRIPTION
        A longer description.

    .PARAMETER FirstParameter
        Description of each of the parameters.
        Note:
        To make it easier to keep the comments synchronized with changes to the parameters,
        the preferred location for parameter documentation comments is not here,
        but within the param block, directly above each parameter.

    .PARAMETER SecondParameter
        Description of each of the parameters.

    .INPUTS
        Description of objects that can be piped to the script.

    .OUTPUTS
        Description of objects that are output by the script.

    .EXAMPLE
        Example of how to run the script.

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

    #>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ] $path,
    
    # path for the result generated during process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)
    ] $dest,
    
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
    $Env:PSModulePath = $Env:PSModulePath + ";C:\Program Files\WindowsPowerShell\Modules"
    Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog
        
    $script_path      = $global:ScriptRoot + "\Projects\ONBASE_ExtractTransLog"
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
    $VERSION      = "0.1"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = ""

    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Do something usefull for you..."
        " "
        "Options : "
        "-path      Source directory / file"
        "-dest      Destination directory / file"
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
    
    # 1 - Load script config file
    try {
        [XML]$conf = Get-Content $config_path
    }
    catch [System.IO.FileNotFoundException] {
        Log -Level "ERROR" -Message ("Configuration file not found " + $config_path)
        Log -Level "ERROR" -Message ("Process aborted! " + $config_path)
        Clean-TemporaryDirectory
        Stop-Log | Out-Null
        exit $EXIT_KO
    }
    
    
    Log -Level 'WARNING' -Message "Do something !!!"
    # Do something here
    # 1 - 
    # 2 - 
    # 3 -
    
    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}