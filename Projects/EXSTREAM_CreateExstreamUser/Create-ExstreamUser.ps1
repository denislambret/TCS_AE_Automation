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
    $SCRIPT_DATE  = "20221109"

    $config_path = ($script_name -replace 'ps1','conf')
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "$MyInvocation.MyCommand.Name"
        " "
        "Options : "

        "-Help      Display command help"
    }
   
    #..................................................................................................................................
    # Function : Get-ExstreamBearerToken()
    #..................................................................................................................................
    # Generate a bearer token for further WSI calls to Exstream
    #..................................................................................................................................
    function Get-ExstreamBearerToken { 
        # Create dictionnary collection
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

        # Create specific headers for query
        $headers.Add("Accept-Language", "fr")
        $headers.Add("Cache-Control", "no-cache, no-store")
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")

        # Create request body parameters
        $body = "grant_type=client_credentials&client_id=" + $conf.conf.otds.userID + "&client_secret=" + $conf.conf.otds.userPassword

        # Post query and get response
        try {
            $response = Invoke-RestMethod $conf.conf.otds.url -Method 'POST' -Headers $headers -Body $body   
        }
        catch {
            return $KO
        }
        
        return $response.acces_token;
    }
   
    #..................................................................................................................................
    # Function : Set-BackupUsersFile
    #..................................................................................................................................
    # Create a backup for user input xml file
    #..................................................................................................................................
    function Set-BackupUsersFile {
        param (
            $path
        )
        
        $backup = $path + "\" + ((get-date) -f "yyyyMMdd_hhmmss_") + "_users.xlsx"
        try {
            Copy-Item $path -Destination $backup
        } catch {
            return $KO
        }
        return $OK
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
    log -Level 'DEBUG' -Message("Load configuration file...")
    try {
        [XML]$conf = Get-Content $config_path
    }
    catch [System.IO.FileNotFoundException] {
        Log -Level "ERROR" -Message ("Configuration file not found " + $config_path)
        Log -Level "ERROR" -Message ("Process aborted! " + $config_path)
        Stop-Log | Out-Null
		exit $EXIT_KO
    }   
    
    # 2 - Get OTDS Bearer token
    log -Level 'DEBUG' -Message("Get bearer token...")
    $bearer = Get-ExstreamBearerToken
    if (-not $bearer) {
        log -Level 'ERROR' -message("Unable to generate bearer token for Exstream")
        log -Level 'ERROR' -message("No security token set. Abort script")
        Stop-Log | Out-Null
		exit $EXIT_KO
    }
    
    # 3 - Backup user.xls file
    Set-BackupUsersFile($conf.conf.list.path + "\" + $conf.conf.list.file)

    # 4 - Call populate.bat with proper parameters
    log -Level 'DEBUG' -Message("Run populate.bat script with current bearer token...")
    log -Level 'DEBUG' -Message("EXEC : &populate.bat " + $bearer)
    $rc = &populate.bat $bearer
    if (-not (($rc | Select-Object -Last 1) -match "END HTTP")) {
        Log -Level "ERROR" -Message ("Configuration file not found " + $config_path)
        Log -Level "ERROR" -Message ("Process aborted! " + $config_path)
        Stop-Log | Out-Null
		exit $EXIT_KO
    }

    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}



