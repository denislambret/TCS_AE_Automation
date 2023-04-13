#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Create-ExstreamUser.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20221109
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Create users(s) into Exstream for Empower usage

    .DESCRIPTION
       Create user(s) profile ba sed on XLS source file including : userID, first name, last name and mail address.
       Generate a tracking log for operations
    
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
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                          G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
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
   
    #..................................................................................................................................
    # Function : Get-ExstreamBearerToken()
    #..................................................................................................................................
    # Generate a bearer token for further WSI calls to Exstream
    #..................................................................................................................................
    function Get-ExstreamBearerToken { 
        # Variables
        $client_id        = "69a868d444215b5b56888e8e56f6672c"
        $client_secret    = "eb685ee7ab4f93a76e4e6c293fc19557"
        $exstream_WSI_URL = "https://eapi.tcsgroup.ch/tcs/partner-catalog/oauth-tcs-native-3600/oauth2/token"


        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

        # Create specific headers for query
        $headers.Add("Accept-Language", "fr")
        $headers.Add("Cache-Control", "no-cache, no-store")
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")

        # Create request body parameters
        $body = "grant_type=client_credentials&client_id=$client_id&client_secret=$client_secret&scope=all"

        # Post query and get response
        $response = Invoke-RestMethod $exstream_WSI_URL -Method 'POST' -Headers $headers -Body $body
        
        return $OK;
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



"Token Type   : " + $response.token_type
"Access Token : " + $response.access_token
"Expire in    : " + $response.expires_in