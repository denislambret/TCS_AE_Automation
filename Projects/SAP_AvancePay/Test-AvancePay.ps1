#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Test-Saferpay.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230207
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        This script is used to check, download, and count number of transaction in files made available by safer pay.
        The control should be done morning after 06:00-
        Also the control take place during the weekend. There is normally one file per day in XML format.
        For every run, a log timestamped is created to gather information about number of records found in XML.

    .INPUTS
        Description of objects that can be piped to the script.

    .OUTPUTS
        Description of objects that are output by the script.

    .EXAMPLE
        ./Test-Saferpay.ps1 -date "20230126"

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
	# sendMail diffusion toggle
	[Parameter( 
                Mandatory = $false,
                Position = 1
            )][string]
    $date,

    [Parameter( 
                Mandatory = $false,
                Position = 2
            )]
            [Alias("conf")]
            [string]
    $conf_filename,
	
    # help switch
    [switch]
    $help
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
    Import-Module Posh-SSH

    # Log initialization
    if (-not (Start-Log -path $global:LogRoot -Script $MyInvocation.MyCommand.Name)) { 
        'FATAL : Log initializzation failed!'
        exit $EXIT_KO
    }
    
    # Set log default and minum level for logging (ideally DEBUG when having trouble)
    Set-DefaultLogLevel -Level 'INFO'
    Set-MinLogLevel -Level 'DEBUG'
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
   
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                          G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables 
    #>

    $VERSION      = '1.1'
    $AUTHOR       = 'DLA'
    $SCRIPT_DATE  = '20230303'

    # Initialize SFTP parameters for connection
	$Env:PSModulePath = $Env:PSModulePath + ";Y:\03_DEV\06_GITHUB\tcs-1\libs;C:\Program Files\WindowsPowerShell\Modules"
    $root_script  = 'D:\Scripts\Projects\SAP_AvancePay'
    $session      = 0;
    $config_path = $root_script+"\ACP.conf"
    $csvRegistry = ""
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : Get-SFTPSaferPayFiles()
    #..................................................................................................................................
    #  - Connect to SFTP 
    #  - Retrieve Saferpay files for a given date
    #..................................................................................................................................
    function Connect-SFTPPrivKey {
        $nopasswd     = New-Object System.Security.SecureString # defines empty sec string to not popup dialog requesting for a password
        $credential   = New-Object System.Management.Automation.PSCredential ($conf.conf.sftp_server.username,$nopasswd) #Set Credetials to connect to server

        # Establish the SFTP connection
        Log -Level 'DEBUG' -Message ('New-SFTPSession -ComputerName ' + $conf.conf.sftp_server.computername + ' -Credential ' + $credential + ' -KeyFile ' + $conf.conf.sftp_server.privkey + ' -AcceptKey')
		$session = New-SFTPSession -ComputerName $conf.conf.sftp_server.computername -Credential $credential -KeyFile $conf.conf.sftp_server.privkey -AcceptKey 
        
		
		Log -Level 'DEBUG' -Message ('session    : ' + ($session | fl))
		Log -Level 'DEBUG' -Message ('session ID : ' + $session.sessionID)
		Log -Level 'DEBUG' -Message ('Error var  : ' + $err)
        if ($err) {
            Log -Level 'ERROR' -Message ('Error seting up SFTP connection- ' + $err) 
            return -1;
        } else {
            return $session
        }
    }

    #..................................................................................................................................
    # Function : Get-SFTPSaferPayFiles()
    #..................................................................................................................................
    #  - Connect to SFTP 
    #  - Retrieve Saferpay files for a given date
    #..................................................................................................................................
    function Connect-SFTPDefault {
        
        # Initialize SFTP parameters for connection
        $userName     = 'sftp_avance_pay_prod' # Define UserName
        $passwd       = 'q21RCB902PDoGMSS'
        $passwd       = ConvertTo-SecureString $passwd -AsPlainText -Force
        $credential   = New-Object System.Management.Automation.PSCredential($conf.conf.username,  $conf.conf.userpwd) 

        # Establish the SFTP connection
        $session = New-SFTPSession -ComputerName $computerName -Credential $credential -ErrorVariable $err 
        
		Log -Level 'DEBUG' -Message("isConnected :"+$session.isConnected)
        if ($err) {
            Log -Level 'ERROR' -Message ('Error seting up SFTP connection- ' + $err) 
            return -1;
        } else {
            return $session
        }

    }
    
    #..................................................................................................................................
    # Function : Test-SFTPFiles
    #..................................................................................................................................
    # Retrieve files from SFTP according a date
    #..................................................................................................................................
    function Test-SFTPFiles() {
        param(
            [Alias('path')][string] $source
        );

        # Get remote location
        $location = Get-SFTPLocation -SessionId $session.SessionId 
        Log -Level 'DEBUG' -message('Scanned source directory : ' + $source)
        
        # lists directory files into variable
        $fileList = Get-SFTPChildItem -sessionID $session.SessionID -path $source | where-object {$_.name -match '.csv$'}
        if ($fileList) { 
            Log -Level 'DEBUG' -message('File list returned : ' + ($fileList | ForEach-Object { $_.name + ","}))
        } else {
            Log -Level 'DEBUG' -message('File list returned : null')
        }
        return $fileList
    }

    #..................................................................................................................................
    # Function : Get-SFTPFiles($filter,$date)
    #..................................................................................................................................
    # Retrieve files from SFTP according a date
    #..................................................................................................................................
    function Get-SFTPFiles() {
        param(
            [string] $filter,
            [dateTime] $date
        );

        $sftp_source = '/advancePay/Success'
        
        
        # Get remote location
        $location = Get-SFTPLocation -SessionId $session.SessionId 
        Log -Level 'DEBUG' -message('SFTP current location : ' + $location)
        Log -Level 'DEBUG' -message('Get SFTP location     : ' + $conf.conf.sftp_server.sftp_success_path)
        Log -Level 'DEBUG' -message('Filtered on           : ' + $date.date)
       
        # Lists directory files into variable
        $fileList = Get-SFTPChildItem -sessionID $session.SessionID -path $conf.conf.sftp_server.sftp_success_path `
                  | where-object {$_.LastWriteTime.date -eq $date.date} `
                  | Sort-Object -Property LastWriteTime -Descending

        # Download content(s) for counting
        if ($fileList) {
            $fileList | ForEach-Object {
                try {
                    Log -Level 'INFO' -Message("Downloading -> " + $_.name)
                    Get-SFTPFile -SessionId $session.SessionID -RemoteFile ($conf.conf.sftp_server.sftp_success_path + '/' + $_.name) -localPath $conf.conf.pathes.local_path -overwrite
					#Get-SFTPItem -SessionId $session.SessionID -path ($conf.conf.sftp_server.sftp_success_path + '/' + $_.name) -destination $conf.conf.pathes.local_path -Force
                }
                catch {
                    log -Level 'ERROR' -Message('Error while downloading : ' + $error )
                    
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

    #..................................................................................................................................
    # Function : Get-TransactionCount
    #..................................................................................................................................
    # Count total number of transaction in source XML camt file
    #..................................................................................................................................
    function Get-TransactionCount {
        param (
            [string]$source
        )
        
        Log -Level 'DEBUG' -message ('Count total number of transaction in source CSV transaction file ' + $source)
        $count = (Get-ChildItem $source).count
        if ($count) {
            return $count;
        } else {
            if (-not (Get-Variable 'counter' -Scope 'Global' -ErrorAction 'Ignore')) {
                Log -Level 'ERROR' -message ('Count total number of transaction in source CSV transaction file ' + $source)
                return KO;
            }
        }
    }

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function Get-WeekNumber([datetime]$DateTime = (Get-Date)) {
        $cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
        return $cultureInfo.Calendar.GetWeekOfYear($DateTime,$cultureInfo.DateTimeFormat.CalendarWeekRule,$cultureInfo.DateTimeFormat.FirstDayOfWeek)
    }

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        ' '
        'Options : '
        '-date      Selection date for control'
        '-conf      Configuration file path'
        '-Help      Display command help'
        Exit-OK
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
    
    # Script info
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + ' v' + $VERSION)
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
    
    
    # 1 - Check input parameters & initialize work variables
    if (-not $date) {
        $selectDate = (get-date).AddDays(-1) 
    } else {
        $selectDate = [Datetime]::ParseExact($date, 'yyyyMMdd 00:00:00', $null);
    }
    log -Level 'DEBUG' -Message('Selected date : ' + $selectDate)
    
    # 2 - Open SFTP connection and retrieve file based on date given on invokation
    #     Close SFTP connection when finished
    Log -Level 'INFO' -message ('Connect to SFTP server ' + $computerName)
    $session = Connect-SFTPPrivKey
    if ($session.SessionId -eq -1) {
        log -Level 'ERROR' -Message('Unable to connect to SFTP. Please check server avaibility and credentials.')
        log -Level 'ERROR' -Message('Aborting control with KO code.')
        Exit-KO
    }
    log -Level 'INFO' -Message ('Connection ID associated #' + $session.SessionId)
    
    
    # 2.1 - Check if we have file(s) in $sftp_input_path
    # Note : this directory should be empty at control execution
    log -Level 'INFO' -Message $SEP_L2
    log -Level 'INFO' -Message ('Check file(s) from ' + $sftp_input_path)
    $countInputFiles = 0;
    $countInputFiles = (Test-SFTPFiles -path $sftp_input_path).Count
    if($countInputFiles) {
        log -level 'WARNING' -Message('-> ' + $countInputFiles +' file(s) found in ' + $sftp_input_path);
        log -level 'WARNING' -Message('There should be no file here at control time ! Please check directory...');
    } else {
        log -Level 'INFO' -Message ('No file found.... Check is OK.');
    }
    
    # 2.2 - Check if we have file(s) in $sftp_failed_path
    # Note : this directory should be empty at control execution
    log -Level 'INFO' -Message $SEP_L2
    log -Level 'INFO' -Message ('Check file(s) from ' + $sftp_failed_path)
    $ListFailedFiles = 0;
    $ListFailedFiles = Test-SFTPFiles -path $sftp_failed_path
    $countFailedFiles = ($ListFailedFiles).Count
    if ($countFailedFiles) {
        log -level 'WARNING' -Message('-> ' + $countFailedFiles + ' file(s) found in ' + $sftp_failed_path);
        $ListFailedFiles | ForEach-Object {
            log -level 'WARNING' -Message('File : ' + $_.Name);
        }
        log -level 'WARNING' -Message('There should be no file here at control time ! Please check directory...');
    } else {
        log -Level 'INFO' -Message('No file found.... Check is OK.');
    }
    
    # 2.3 - Check if we have file(s) in $sftp_success_path
    # Note : this directory should be not empty at control execution. 
    # Here we have to select file(s) according date criteria and count transaction per files.
    log -Level 'INFO' -Message $SEP_L2
    log -Level 'INFO' -Message ('Get file(s) from ' + $sftp_success_path)
    $listSuccessFile = 0;
    $listSuccessFile = Get-SFTPFiles -path $sftp_success_path -date $selectDate -Force
    if (-not $listSuccessFile) {
        log -Level 'ERROR' -Message('No file found on SFTP for the given date. Normally a file should be available for the date even if empty.')
        log -Level 'ERROR' -Message('Aborting control with KO code.')
        Close-SFTP
        Log -Level 'INFO' -Message $SEP_L1
        Exit-KO
    } 
    
    # 3 - Parse and count retrieved transaction file(s)
    $countTransactions = 0;
    $listSuccessFile | ForEach-Object {
        $countTransactions += (Get-Content ($conf.conf.pathes.local_path + "/" + $_.Name)).Count
        log -Level 'INFO' -Message ('Transactions found in ' + $_.Name + ' -> ' + $countTransactions + ' transaction(s).')
    }
    
    # 4- create CSV report
    $year  = (get-Date).Year
    $week  = ([string](Get-WeekNumber)).padleft(2,"0");

    $outCSVFile =  $conf.conf.pathes.csv_path + '_' + $year + $week + '.csv' 
    log -Level 'DEBUG' -Message ('Build statistics to ' + $conf.conf.csv.headers)
    Log -Level 'DEBUG' -Message ('CSV Output file is  : ' + $outCSVFile)
    $statStr = ($selectdate -f "yyyyMMdd") + $conf.conf.csv.separator + $countTransactions + $conf.conf.csv.separator + $countInputFiles `
               + $conf.conf.csv.separator + $countFailedFiles
    
    # Name the CSV with year and week
    if (-not (Test-Path $outCSVFile)) {
        Set-Content -path $outCSVFile -value $conf.conf.csv.headers
        Add-Content -path $outCSVFile -value $statStr
    } else {
        Add-Content -path $outCSVFile -value $statStr
    }
    
    # 5 - Remove work file
    $listSuccessFile | ForEach-Object { 
        Log -Level 'DEBUG' -Message("Remove work file " + ($conf.conf.pathes.local_path + "/" + $_.Name))
        Remove-Item ($conf.conf.pathes.local_path + "/" + $_.Name) -ErrorAction Continue
    } 
  
    # 5 - End process as OK
    log -Level 'INFO' -Message ('Close connection to SFTP ')
    if (-not (Close-SFTP)) {
        log -Level 'WARNING' -Message('Unable to close SFTP connection.')
        log -Level 'WARNING' -Message('Continue control anyway...')
        Log -Level 'INFO' -Message $SEP_L1
        Exit-KO
    }
    
    # Standard success RC 
    Exit-OK
    #----------------------------------------------------------------------------------------------------------------------------------
}