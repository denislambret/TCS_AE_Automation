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
            )] [String] $password
        )

        # Reprendre le secure string a l'appel de léafonction
        #$password       = ConvertTo-SecureString $password -AsPlainText -Force
        $sec_pwd        = $password | ConvertTo-SecureString -AsPlainText -Force
        $credential     = New-Object System.Management.Automation.PSCredential($user, $sec_pwd) 
        Log -Level 'DEBUG' -Message ('credentials : ' + $credential | Format-Table -AutoSize)
        Log -Level 'DEBUG' -Message ('Password    : ' + $password | Format-Table -AutoSize)
        Log -Level 'DEBUG' -Message ('User        : ' + $user | Format-Table -AutoSize)

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
    function Get-SFTPFileList() {
        param(
            [SftpSession] $session,
            [string] $remotePath
        );

                
        # Get remote location
               
        try {
            Set-SFTPLocation -SessionId $Session.SessionId -Path $remotePath
        }
        catch {
            Log -Level 'ERROR' -Message($remotePath + ' does not exist.')
            Log -Level 'ERROR' -Message($Error)
            return $null
        }
        
        
        
        $location = Get-SFTPLocation -SessionId $session.SessionId 
        Log -Level 'INFO' -message('Get SFTP location                     : ' + $remotePath)
        Log -Level 'INFO' -message('Filtered on date equal or lesser than : ' + $date.date)

        # Lists directory files into variable
        Log -Level 'DEBUG' -Message('Get-SFTPChildItem -sessionID ' + $session.SessionID + ' -path ' + $remotePath)
        $fileList = Get-SFTPChildItem -sessionID $session.SessionID ` -path $remotePath | where-object {$_.LastWriteTime.date -lt $date.date} | Sort-Object -Property LastWriteTime -Descending 
       return $fileList
    }

    #..................................................................................................................................
    # Function : Close-SFTP
    #..................................................................................................................................
    # Close SFTP connection
    #..................................................................................................................................
    function Close-SFTP() {

        param(
            [SftpSession]$session
        )

        # Close session
        Log -Level 'INFO' -message ('Close SFTP session #' + $session.SessionId)
        Remove-SFTPSession -SessionId $session.SessionID | Out-Null
        
        # End normally SFTP routine.
        return $OK;
    }

    Export-ModuleMember -Function Connect-SFTPPrivKey, Connect-SFTPDefault, Get-SFTPFileList, Close-SFTP