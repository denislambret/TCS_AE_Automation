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
#                                             C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
                Position = 0)]
    $path,
    
    # path for the result generated during process
    [Parameter(Mandatory = $true,
    ValueFromPipelineByPropertyName = $true,
    Position = 0)]
    $dest,
    
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
    # Please keep this order, define path first then import modules.
    $script_path        = "D:\dev\40_PowerShell\tcs\Sandbox"
    $log_path           = "D:\dev\40_PowerShell\tcs\logs"
    $lib_path           = "D:\dev\40_PowerShell\tcs\libs"
    $Env:PSModulePath   = $Env:PSModulePat + ";" + $lib_path
    Import-Module libLog
    
    # Initialize log
    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
    $rc = Set-DefaultLogLevel -Level "INFO"
    $rc = Set-MinLogLevel -Level "DEBUG"
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                   I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Includes
        
        .DESCRIPTION
            Include necessary libraries
    #>
   
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                            G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables 
    #>
    $VERSION      = "0.1"
    $AUTHOR       = ""
    $SCRIPT_DATE  = ""
    $LineSize     = 132
    $SEP_L1       = '-' * $LineSize
    $SEP_L2       = '.' * $LineSize
    $EXIT_OK      = 0
    $EXIT_KO      = 1
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                  F U N C T I O N S 
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
        "-Help       Display command help"
    }
   
    #..................................................................................................................................
    # Function : func1
    #..................................................................................................................................
    # <Please describe function here>
    #..................................................................................................................................
   function Verb-Name {
    <#
        .SYNOPSIS
            An example function to display how help should be written.

        .EXAMPLE
            Verb-Name -Name Test-Help

            This shows the help for the example function.
    #>

        [CmdletBinding()]
        param (
            # This parameter doesn't do anything.
            # Aliases: MP
            [Parameter(Mandatory = $true)]
            [Alias("MP")]
            [String]$MandatoryParameter
        )
    
        <# code here ... #>
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
    
    # Do something here
    # 1 -
    # 2 - 
    # 3 -
    
    # Standard exit
    Stop-Log
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}