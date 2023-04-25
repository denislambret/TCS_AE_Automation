#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Copy-IDITPaymentsCamt.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230414
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
# 20230414 - Initial version
#
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                             C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # configuration file
	[Parameter( 
        Mandatory = $false,
        Position = 1
    )]
    $conf,
    
    # sendMail diffusion toggle
	[Parameter( 
                Mandatory = $false,
                Position = 1
            )]
    [switch]
    $sendMail,
	
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
    # Import root paths and constants
    Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module Posh-SSH

    $script_path      = $global:ScriptRoot + "\Projects\IDIT_CheckPayments"
    $config_path      = $script_path + "\PRD.conf"
    $log_path         = $global:LogRoot
    $lib_path         = $env:PWSH_SCRIPTS_LIBS
    $Env:PSModulePath = $Env:PSModulePath + ";" + $lib_path
     
    # Import external libs
    Import-Module libLog
    Import-Module libSendMail
    
    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
    $rc = Set-DefaultLogLevel -Level 'INFO'
    $rc = Set-MinLogLevel -Level 'DEBUG'
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                   I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
   
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                            G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables as AUTHOR, VERSION, and Last modif date
			Also define output separator line size for nice formating
			Define standart script exit codes
    #>
    $VERSION      = "1.0"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = "20230413"
    $LineSize     = 112
    $SEP_L1       = '-' * $LineSize
    $SEP_L2       = '.' * $LineSize
    $EXIT_OK      = 0
    $EXIT_KO      = 1
    $dateShift    = 0
    
    $recipients = @(" ")

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
        "-conf       Config file - Default is PROD.conf"
        "-sendmail   Send info email to distribution list"
        "-Help       Display command help"
    }
    
    #..................................................................................................................................
    # Function : Clean-TemporaryDirectory
    #..................................................................................................................................
    # Execute query to retrieve list of payments from IDIT
    #..................................................................................................................................
    function Clean-TemporaryDirectory {
        Log -Level 'DEBUG' -Message  "Clean temporary directory...."
        Remove-Item ($script_path + "\tmp\*.*")
        if (test-path ($script_path + "\incoming-payments.csv")) { Remove-Item ($script_path + "\incoming-payments.csv")}
    }
  
    #..................................................................................................................................
    # Function : Send-Message
    #..................................................................................................................................
    # Send email message to TCS SMTP server
    #..................................................................................................................................
    function Send-Message {
        param(
            [string] $subject,
            [string] $body
        )

        $from = $conf.conf.mail.from
        $recipients = $conf.conf.mail.to
        $secStr = New-Object System.Security.SecureString
        $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NTAUTHORITY\ANONYMOUSLOGON",$secStr
        $myAttachment = ($script_path + "/tmp/" +  $global:log_name)
        Log -Level 'DEBUG' -Message ("Send email to mail list")
        Copy-Item ($global:log_path + "\" +  $global:log_name)  ($script_path + "/tmp")
        
        try {
			send-mailmessage -to $recipients -from $from -subject $subject -body $body -attachment $myAttachment -smtpServer $conf.conf.mail.smtp_srv -credential $creds
		}
		catch {
			Log -Level 'ERROR' -Message('Error While sending mail to distribution list')
			Log -Level 'ERROR' -Message($error)
			
			# Return KO
			return $false
		}
		
		# Return OK
		return $true
    }
    
    #..................................................................................................................................
    # Function : Get-SFTPPrivKey()
    #..................................................................................................................................
    #  - Connect to SFTP 
    #  - Retrieve Saferpay files for a given date
    #..................................................................................................................................
    function Connect-SFTPPrivKey {
        param(
            [Parameter( 
                Mandatory = $false,
                Position = 1
            )][string]
            $server,
            
            [Parameter( 
                Mandatory = $false,
                Position = 2
            )][string]
            $user,

            [Parameter( 
                Mandatory = $false,
                Position = 3
            )][string]
            $privKey
        )

        $nopasswd     = New-Object System.Security.SecureString # defines empty sec string to not popup dialog requesting for a password
        $credential   = New-Object System.Management.Automation.PSCredential ($user,$nopasswd) #Set Credetials to connect to server

        # Establish the SFTP connection
        Log -Level 'DEBUG' -Message ('Credential : ' + ($credential | Format-Table -AutoSize))
        Log -Level 'DEBUG' -Message ('New-SFTPSession -ComputerName ' +  $server + ' -Credential ' + $credential + ' -KeyFile ' + $privKey + ' -AcceptKey')
		$session = New-SFTPSession -ComputerName $server -Credential $credential -KeyFile $privKey -AcceptKey -ErrorVariable $err
        
        if ($null -ne $session) {
            Log -Level 'DEBUG' -Message ('session    : ' + ($session | Format-List))
		    Log -Level 'DEBUG' -Message ('session ID : ' + $session.sessionID)
            Log -Level 'DEBUG' -Message("isConnected :"+$session.isConnected)
        
        } else {
            Log -Level 'DEBUG' -Message ('Error var  : ' + $err)
            return -1;
        }
		return $session
    }

    #..................................................................................................................................
    # Function : Get-SFTPDefault()
    #..................................................................................................................................
    #  - Connect to SFTP 
    #  - Retrieve Saferpay files for a given date
    #..................................................................................................................................
    function Connect-SFTPDefault {
        param(
            [Parameter( 
                Mandatory = $false,
                Position = 1
            )]
            $server,
            [Parameter( 
                Mandatory = $false,
                Position = 2
            )] $user,

            [Parameter( 
                Mandatory = $false,
                Position = 3
            )] [SecureString]$password
        )

        # Reprendre le secure string a l'appel de léafonction
        $password       = ConvertTo-SecureString $passwordd -AsPlainText -Force
        $credential   = New-Object System.Management.Automation.PSCredential($user, $password) 
        Log -Level 'DEBUG' -Message ('Credential : ' + $credential | Format-Table -AutoSize)

        # Establish the SFTP connection
        $session = New-SFTPSession -ComputerName $server -Credential $credential -ErrorVariable $err 
        if ($null -ne $session) {
            Log -Level 'DEBUG' -Message ('session    : ' + ($session | Format-List))
		    Log -Level 'DEBUG' -Message ('session ID : ' + $session.sessionID)
            Log -Level 'DEBUG' -Message("isConnected :"+$session.isConnected)
        } else {
            Log -Level 'ERROR' -Message ('Error var  : ' + $err)
            return -1;
        }
		return $session

    }
    
    #..................................................................................................................................
    # Function : Get-SFTPFiles($remotePath, $localPath, $filter,$date)
    #..................................................................................................................................
    # Retrieve files from SFTP according a date
    #..................................................................................................................................
    function Get-SFTPFiles() {
        param(
            [string] $remotePath,
            [string] $localPath,
            [string] $filter,
            [dateTime] $date
        );

        $sftp_source = '/advancePay/Success'
        
        
        # Get remote location
        $location = Get-SFTPLocation -SessionId $session.SessionId 
        Log -Level 'DEBUG' -message('SFTP current location                  : ' + $location)
        Log -Level 'DEBUG' -message('Get SFTP location                      : ' + $remotePath)
        Log -Level 'DEBUG' -message('Get local location                     : ' + $localPath)
        Log -Level 'DEBUG' -message('Filtered on date equal or greater than : ' + $date.date)

        # Lists directory files into variable
        $fileList = Get-SFTPChildItem -sessionID $session.SessionID -path $remotePath`
                  | where-object {$_.LastWriteTime.date -gt $date.date} `
                  | Sort-Object -Property LastWriteTime -Descending

        # Download content(s) for counting
        if ($fileList) {
            $fileList | ForEach-Object {
                try {
                    Log -Level 'INFO' -Message("Downloading -> " + $_.name + " to " + $localPath + '\' + $_.name )
                    Get-SFTPFile -SessionId $session.SessionID -RemoteFile ($remotePath + '/' + $_.name) -localPath $localPath -overwrite
                }
                catch {
                    log -Level 'ERROR' -Message('Error while downloading ' + $_.name + ': ' + $error )
                }
            }
        }
        return $fileList
    }

    #..................................................................................................................................
    # Function : Count-Transaction
    #..................................................................................................................................
    # Count total number of transaction in source XML camt file
    #..................................................................................................................................
    function Close-SFTP() {
        # Close session
        Log -Level 'DEBUG' -message ('Close SFTP session #' + $session.SessionId)
        Remove-SFTPSession -SessionId $session.SessionID | Out-Null
        
        # End normally SFTP routine.
        return $OK;
    }
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .DESCRIPTION
    #>
    
    # Script info 
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION)
    Log -Level 'INFO' -Message $SEP_L1
    
    # Display inline help if required
    if ($help) { helper }
    if ($conf -and (Test-Path $conf)) {
        $config_path = $conf
    }
    
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
    
    # 2 - Get CAMT from Share
    # 2.1 - Check input parameters & initialize work variables
    if (-not $date) {
        $selectDate = (get-date).AddDays(-1) 
    } else {
        $selectDate = [Datetime]::ParseExact($date, 'yyyyMMdd 00:00:00', $null)
        $selectDate = $selectDate.AddHours(-24);
    }
    log -Level 'DEBUG' -Message('Selected date : ' + $selectDate)

    # 2.2 - Open SFTP connection and retrieve file based on date given on invokation
    #       Close SFTP connection when finished
    Log -Level 'INFO' -message ('Connect to SFTP server ' + $conf.conf.sftp_servers.sftp_server_poste.computername )

    $session = Connect-SFTPPrivKey -server $conf.conf.sftp_servers.sftp_server_poste.computername -user $conf.conf.sftp_servers.sftp_server_poste.computername -privKey $conf.conf.sftp_servers.sftp_server_poste.privkey
    
    if (($null -eq $session) -or ($session.SessionId -eq -1)) {
        log -Level 'ERROR' -Message('Unable to connect to SFTP. Please check server avaibility and credentials.')
        log -Level 'ERROR' -Message('Aborting control with KO code.')
        Exit-KO
    }
    log -Level 'INFO' -Message ('Connection ID associated #' + $session.SessionId)


    # 2.3- Check if we have file(s) in $sftp_input_path
    # Note : this directory should be empty at control execution
    log -Level 'INFO' -Message $SEP_L2
    $countInputFiles = 0
    $listRemoteFiles = Get-SFTPFiles -remotePath $conf.conf.sftp_servers.sftp_server_poste.sftp_input_path -localPath $conf.conf.pathes.backup_path -filter '*camt*' -date $selectDate
    $countInputFiles = ($listRemoteFiles).Count
    Log -Level 'INFO' -message ($countInputFiles + ' file(s) copied')

    # 3 - Do post cleaning of tmp directory and end sftp connection
    Log -Level 'INFO' -Message $SEP_L2
    Close-SFTP;
    
    # 4 - Standard exit
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}