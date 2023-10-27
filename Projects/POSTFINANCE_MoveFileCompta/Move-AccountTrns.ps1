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
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ] $path,
    
    # path for the result generated during process
    [Parameter(
        Mandatory = $false,
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
    # Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog
    Import-Module Posh-SSH

    Set-EnvRoot
    $script_path      = $global:ScriptRoot + "\Projects\POSTFINANCE_MoveFileCompta"
    $config_path      = $script_path + "\" + ($MyInvocation.MyCommand.Name -replace 'ps1','')+ 'conf'
    
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
   
#     #..................................................................................................................................
# # Function : Get-SFTPPrivKey()
# #..................................................................................................................................
# #  - Connect to SFTP 
# #  - Retrieve Saferpay files for a given date
# #..................................................................................................................................
# function Connect-SFTPPrivKey {
#     param(
#         [Parameter( 
#             Mandatory = $false,
#             Position = 1
#         )][string]
#         $server,
        
#         [Parameter( 
#             Mandatory = $false,
#             Position = 2
#         )][string]
#         $user,

#         [Parameter( 
#             Mandatory = $false,
#             Position = 3
#         )][string]
#         $privKey
#     )

#     $nopasswd     = New-Object System.Security.SecureString # defines empty sec string to not popup dialog requesting for a password
#     $credential   = New-Object System.Management.Automation.PSCredential($user,$nopasswd) #Set Credetials to connect to server

#     # Establish the SFTP connection
#     Log -Level 'DEBUG' -Message ('Credential : ' + ($credential | Format-Table -AutoSize))
#     Log -Level 'DEBUG' -Message ('New-SFTPSession -ComputerName ' +  $server + ' -Credential ' + $credential + ' -KeyFile ' + $privKey + ' -AcceptKey')
#     $sftpSession = New-SFTPSession -ComputerName $server -Credential $credential -KeyFile $privKey -AcceptKey -ErrorVariable $err
    
#     if ($null -ne $sftpSession) {
#         Log -Level 'DEBUG' -Message ('session    : ' + ($sftpSession | Format-List))
#         Log -Level 'DEBUG' -Message ('session ID : ' + $sftpSession.sessionID)
#         Log -Level 'DEBUG' -Message("isConnected :"+$sftpSession.isConnected)
    
#     } else {
#         Log -Level 'DEBUG' -Message ('Error var  : ' + $err)
#         return -1;
#     }
#     return $sftpSession
# }

# #..................................................................................................................................
# # Function : Get-SFTPDefault()
# #..................................................................................................................................
# #  - Connect to SFTP 
# #  - Retrieve Saferpay files for a given date
# #..................................................................................................................................
# function Connect-SFTPDefault {
#     param(
#         [Parameter( 
#             Mandatory = $false,
#             Position = 1
#         )]
#         $server,
#         [Parameter( 
#             Mandatory = $false,
#             Position = 2
#         )] $user,

#         [Parameter( 
#             Mandatory = $false,
#             Position = 3
#         )] [String] $password
#     )

#     # Reprendre le secure string a l'appel de léafonction
#     #$password       = ConvertTo-SecureString $password -AsPlainText -Force
#     $sec_pwd        = $password | ConvertTo-SecureString -AsPlainText -Force
#     $credential     = New-Object System.Management.Automation.PSCredential($user, $sec_pwd) 
#     Log -Level 'DEBUG' -Message ('Credential : ' + $credential | Format-Table -AutoSize)

#     # Establish the SFTP connection
#     $sftpSession = New-SFTPSession -ComputerName $server -Credential $credential -ErrorVariable $err 
#     if ($null -ne $sftpSession) {
#         Log -Level 'DEBUG' -Message ('session    : ' + ($sftpSession | Format-List))
#         Log -Level 'DEBUG' -Message ('session ID : ' + $sftpSession.sessionID)
#         Log -Level 'DEBUG' -Message("isConnected :"+$sftpSession.isConnected)
#     } else {
#         Log -Level 'ERROR' -Message ('Error var  : ' + $err)
#         return -1;
#     }
#     return $sftpSession

# }

# #..................................................................................................................................
# # Function : Get-SFTPFiles($remotePath, $localPath, $filter,$date)
# #..................................................................................................................................
# # Retrieve files from SFTP according a date
# #..................................................................................................................................
# function Get-SFTPFileList() {
#     param(
#         [string] $remotePath,
#         [string] $localPath,
#         [string] $filter,
#         [dateTime] $date
#     );

            
#     # Get remote location
            
#     try {
#         Set-SFTPLocation -SessionId $sftpSession.SessionId -Path $remotePath
#     }
#     catch {
#         Log -Level 'ERROR' -Message($remotePath + ' does not seem to exist.')
#         Log -Level 'ERROR' -Message($Error)
#         return $null
#     }
    
    
    
#     $location = Get-SFTPLocation -SessionId $sftpSession.SessionId 
#     Log -Level 'INFO' -message('Get SFTP location                     : ' + $remotePath)
#     Log -Level 'INFO' -message('Filtered on date equal or lesser than : ' + $date.date)

#     # Lists directory files into variable
#     Log -Level 'DEBUG' -Message('Get-SFTPChildItem -sessionID '+$sftpSession.SessionID+' -path '+$remotePath)
#     $fileList = Get-SFTPChildItem -sessionID $sftpSession.SessionID ` -path $remotePath | where-object {$_.LastWriteTime.date -lt $date.date} | Sort-Object -Property LastWriteTime -Descending 
#     return $fileList
# }

# #..................................................................................................................................
# # Function : Close-SFTP
# #..................................................................................................................................
# # Close SFTP connection
# #..................................................................................................................................
# function Close-SFTP() {
#     # Close session
#     Log -Level 'INFO' -message ('Close SFTP session #' + $sftpSession.SessionId)
#     Remove-SFTPSession -SessionId $sftpSession.SessionID | Out-Null
    
#     # End normally SFTP routine.
#     return $OK;
# }

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
    
   
     # Do something here
    # 1 - 
    $confRoot = $conf.conf
    $sec_pwd        = $confRoot.sftp_servers.sftp_server_tcs.userpwd | ConvertTo-SecureString -AsPlainText -Force
    $credential     = New-Object System.Management.Automation.PSCredential($confRoot.sftp_servers.sftp_server_tcs.username, $sec_pwd ) 
    $sftpSession    = New-SFTPSession -ComputerName $confRoot.sftp_servers.sftp_server_tcs.computername -Credential $credential -Verbose
    
    
    # 1 - Get file source list
    $srcFileList = Get-SFTPChildItem  -SFTPSession $sftpSession -path $confRoot.sftp_servers.sftp_server_tcs.sftp_input_path
    
    $srcFileList | ?{
        $_.LastWriteTime -gt '01.01.2023' -and (-not($_.name -match ".treated$"))
    } | Select-Object -Property name,LastWriteTime,Length|  ft -autosize
    
    
    $srcFileList | Select-Object -Property name,LastWriteTime,Length|  ft -autosize

    # 5 - Close connexion
    Remove-SFTPSession -SessionId $sftpSession.SessionID | Out-Null
    
    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}






