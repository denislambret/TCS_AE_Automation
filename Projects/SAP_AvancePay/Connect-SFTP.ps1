    
	$Env:PSModulePath = $Env:PSModulePath + ";C:\Program Files\WindowsPowerShell\Modules"
	Import-Module Posh-SSH
	
	# Initialize SFTP parameters for connection
    $root_script  = 'D:\Scripts\Projects\SAP_AvancePay'
    $session      = 0;
    $config_path = $root_script+"\ACP.conf"
	
	#..................................................................................................................................
    # Function : Get-SFTPSaferPayFiles()
    #..................................................................................................................................
    #  - Connect to SFTP 
    #  - Retrieve Saferpay files for a given date
    #..................................................................................................................................
    function Connect-SFTPPrivKey {
        $nopasswd     = New-Object System.Security.SecureString # defines empty sec string to not popup dialog requesting for a password
        $credential   = New-Object System.Management.Automation.PSCredential($conf.conf.sftp_server.username,$nopasswd) #Set Credetials to connect to server

        # Establish the SFTP connection
        $session = New-SFTPSession -ComputerName $conf.conf.sftp_server.computername -Credential $credential -KeyFile 'D:\Scripts\Projects\SAP_AvancePay\sftp_avance_pay_prod.openssh.ppk' -Debug
        Write-Host $session   

        if ($session.sessionID -lt 0) {
            Write-Host ('Error seting up SFTP connection - ' + $err) 
            return -1;
        } else {
			Write-Host ('session    : ' + ($session | fl))
			Write-Host ('session ID : ' + $session.sessionID)
			Write-Host ('Error var  : ' + $err)
            return $session
        }
    }
	
	#..................................................................................................................................
    # Function : Close-SFTP
    #..................................................................................................................................
    # Count total number of transaction in source XML camt file
    #..................................................................................................................................
    function Close-SFTP() {
        # Close session
        Write-Host ('Close SFTP session #' + $session.SessionId)
        Remove-SFTPSession -SessionId $session.SessionID | Out-Null
        
        # End normally SFTP routine.
        return $OK;
    }
	
	#..................................................................................................................................
    # Function : Get-SFTPFiles($filter,$date)
    #..................................................................................................................................
    # Retrieve files from SFTP according a date
    #..................................................................................................................................
    function Test-SFTPFiles() {
        param(
            [Alias('path')][string] $source
        );

        # Get remote location
        $location = Get-SFTPLocation -SessionId $session.SessionId 
        Write-host ('Scanned source directory : ' + $source)
        
        # lists directory files into variable
        $fileList = Get-SFTPChildItem -sessionID $session.SessionID -path $source | where-object {$_.name -match '.csv$'}
        if ($fileList) { 
            Write-host ('File list returned : ' + ($fileList).Count + " file(s)")
        } else {
            Write-host ('File list returned : null')
        }
        return $fileList
    }
	
	#--MAIN ---------------------------------------------------------------------------------------------------------------------------
	# 1 - Load script config file
    try {
        [XML]$conf = Get-Content $config_path
    }
    catch [System.IO.FileNotFoundException] {
        Write-Host ("Configuration file not found " + $config_path)
        Write-Host ("Process aborted! " + $config_path)
        Clean-TemporaryDirectory
        Stop-Log | Out-Null
        exit $EXIT_KO
    }
	
	$session = Connect-SFTPPrivKey
    if ($session.SessionId -lt 0) {
        Write-Host ('Unable to connect to SFTP. Please check server avaibility and credentials.')
        Write-Host ('Aborting control with KO code.')
        Exit-KO
    }
    Write-Host ('Connection ID associated #' + $session.SessionId)
	
	(Test-SFTPFiles -path /advancePay/Success).Count | Out-Null
	
	    # 5 - End process as OK
    Write-Host ('Close connection to SFTP ')
    if (-not (Close-SFTP)) {
        log -Level 'WARNING' -Message('Unable to close SFTP connection.')
        log -Level 'WARNING' -Message('Continue control anyway...')
        Write-Host $SEP_L1
    }
	
exit EXIT_OK