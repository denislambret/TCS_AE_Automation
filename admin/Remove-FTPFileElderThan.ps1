#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Remove_FTPFileElderThan.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : Denis Lambret
# Date    : 17.08.2023
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
#  -source
#  -days
#  -hours
#  -months
#  -filter
#----------------------------------------------------------------------------------------------------------------------------------
# Synopsys
#----------------------------------------------------------------------------------------------------------------------------------
# Remove a selection of file from a source FTP directory based on filter param
#----------------------------------------------------------------------------------------------------------------------------------

param(
        [Parameter(Mandatory=$true)][string] $source,
        [switch] $recurse,
        [Parameter(Mandatory = $true,Position = 1)] $conf,
        [Parameter(Mandatory=$true)][string] $filter,
        [int] $months,
        [int] $hours,
        [int] $days,
        [int] $minutes,
        [int] $seconds,
        [bool] $help
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
    Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module Posh-SSH
    $script_path      = $global:ScriptRoot + "\admin"
    $config_path      = $script_path + "\PRD.conf"
    $log_path         = $global:LogRoot
    $lib_path         = $env:PWSH_SCRIPTS_LIBS
    $Env:PSModulePath = $Env:PSModulePath + ";" + $lib_path
    $Env:PSModulePath = $Env:PSModulePath + ";" + $env:PWSH_SCRIPTS_LIBS
    $log_path = $env:PWSH_SCRIPTS_LOGS
    Import-Module libLog
    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
    $rc = Set-DefaultLogLevel -Level "INFO"
    $rc = Set-MinLogLevel -Level "DEBUG"
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
PROCESS {

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                  F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

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
        $credential   = New-Object System.Management.Automation.PSCredential($user,$nopasswd) #Set Credetials to connect to server

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
        $password       = ConvertTo-SecureString $password -AsPlainText -Force
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
    # Function : Close-SFTP
    #..................................................................................................................................
    # Close SFTP connection
    #..................................................................................................................................
    function Close-SFTP() {
        # Close session
        Log -Level 'DEBUG' -message ('Close SFTP session #' + $session.SessionId)
        Remove-SFTPSession -SessionId $session.SessionID | Out-Null
        
        # End normally SFTP routine.
        return $OK;
    }
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    $VERSION = "0.1"
    $AUTHOR  = "Denis Lambret"
    $SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
    $SEP_L2  = '......................................................................................................................'
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                             M A I N
    #----------------------------------------------------------------------------------------------------------------------------------
    Log -Level 'INFO' -Message ($SEP_L1)
    Log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " - ver "+ $VERSION)
    Log -Level 'INFO' -Message ($SEP_L1)
	
    if ((-not $path) -or (-not (Test-Path -path $path))) {
        Log -Level 'ERROR' -Message "Please provide a valid path"
        Stop-Log
        exit 0
    }

    if ((-not $seconds) -and (-not $minutes) -and (-not $hours) -and (-not $days) -and (-not $months)) {
        Log -Level 'ERROR' -Message "Please provide a valid period for search"
        Stop-Log
        exit 0
    }
    
    # 1 - Load script config file
    if ($conf -and (Test-Path $conf)) {
        $config_path = $conf
    }
    
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
    
    # 2- Build file candidates list
    Log -Level 'INFO' -message ('Connect to SFTP server ' + $conf.conf.sftp_servers.sftp_server_poste.computername )
    $session = Connect-SFTPPrivKey -server $conf.conf.sftp_servers.sftp_server_poste.computername -user $conf.conf.sftp_servers.sftp_server_poste.username -privKey $conf.conf.sftp_servers.sftp_server_poste.privkey
    
    if (($null -eq $session) -or ($session.SessionId -eq -1)) {
        log -Level 'ERROR' -Message('Unable to connect to SFTP. Please check server avaibility and credentials.')
        log -Level 'ERROR' -Message('Aborting control with KO code.')
        Exit-KO
    }

    log -Level 'INFO' -Message ('Connection ID associated #' + $session.SessionId)
    Log -Level 'INFO' -Message ("Build file list applying " + $filter + " filter pattern for directory " + $source) 
    $list = Get-SFTPFiles -RemotePath $source -Filter $filter -Date (Get-Date -f 'YYYY-MM-DD')
     
    Log -Level 'INFO' -Message ($SEP_L1)
    if     ($months)  { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMonths(-1 * $months)} }
    elseif ($days)    { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addDays(-1 * $days)} }
    elseif ($hours)   { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addHours(-1 * $hours)} }
    elseif ($minutes) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addMinutes(-1 * $minutes)} }
    elseif ($seconds) { $list = $list | Where-Object {$_.LastWriteTime -lt (Get-Date).addSeconds(-1 * $seconds)} }
    
	Log -Level 'INFO' -Message (" " + (($list).Count) + " file(s) electable for removal found.") 
    
    # 3 - Process candidates list
	foreach ($item in $list) {
        
        Log -Level "INFO" -Message ("REMOVE source: " + $item)
        try {
            Remove-Item $item -recurse -WhatIf
        }
        catch {
            Log -Level 'ERROR' -Message ("REMOVE source: " + $item + " -> Unable to remove file !")
        }
    }
    
    # 4 - End processing here
    close-SFTP
    Stop-Log
    exit EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}