#----------------------------------------------------------------------------------------------------------------------------------
# Script  : check-IDITPayments.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20221029
# Version : 1.1
#----------------------------------------------------------------------------------------------------------------------------------
# 20221029 - Add sendMail parameter to enable / disable email diffusion
# 20230418 - Correct different display bugs and counting logic.
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                             C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter( 
                Mandatory = $false,
                Position = 0
            )]
    $path,
    
	# sendMail diffusion toggle
	[Parameter( 
                Mandatory = $false,
                Position = 1
            )]
    $sendMail,
	
    # Date 
    [Parameter( 
                Mandatory = $false,
                Position = 1
            )]
    $date,
	
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
    $VERSION      = "0.1"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = "20221029"
    $LineSize     = 112
    $SEP_L1       = '-' * $LineSize
    $SEP_L2       = '.' * $LineSize
    $EXIT_OK      = 0
    $EXIT_KO      = 1
    $dateShift    = -1
    
    $recipients = @("denis.lambret@tcs.ch")
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
        "-path       CAMT source directory"
        "-date       yyyyMMdd"
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
    # Function : GenericSqlQuery
    #..................................................................................................................................
    # Execute query to retrieve list of payments from IDIT
    #..................................................................................................................................function doSQL
    function GenericSQLQuery
    {
        param(
            [string] $sql
        )
        # https://cmatskas.com/execute-sql-query-with-powershell/
    
        $SqlConnection = GetSqlConnection
    
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        
        # Connect IDIT db
        $SqlCmd.CommandText = $sql
        $SqlCmd.Connection = $SqlConnection
        
        # Then execute query
        $Reader= $SqlCmd.ExecuteReader()
        $DataTable = New-Object System.Data.DataTable
        $DataTable.Load($Reader)
         
        # close db
        $SqlConnection.Close()
        
        return $DataTable
    }

    #..................................................................................................................................
    # Function : GetSqlConnection
    #..................................................................................................................................
    # Get a SQL connection
    #..................................................................................................................................
    function GetSqlConnection
    {
        $ConnectionString = "Server=" + $conf.conf.db.sqlServerInstance + "; database=" + $conf.conf.db.database + "; Integrated Security=False;" + "User ID=" + $conf.conf.db.userName + "; Password="+$conf.conf.db.password + ";"
    
        try
        {
            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
            $sqlConnection.Open()
            return $sqlConnection
        }
        catch
        {
            return $null
        }
    
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
    
    if (-not $date) {$date = Get-Date } else { $date = [datetime]::parseexact($date, 'yyyyMMdd', $null)}

    # 1 - Do cleaning of tmp directory
    Clean-TemporaryDirectory

    # 2 - Load script config file
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
    
    # 3 - Get CAMT from Share
    $source_path = $conf.conf.pathes.camt_source_path
    Log -Level 'DEBUG' -Message "Build source CAMT files list from $source_path..."
    if (-not $date) {$date = (get-Date)};
    #$listCamtFiles= get-ChildItem ($source_path + '\*.treated') | Where-Object {$_.LastWriteTime -ge ((get-Date).AddDays($dateShift)).Date}
    #Log -Level 'DEBUG' -Message("get-ChildItem ("+$source_path +" '\*.treated') | Where-Object {$_.LastWriteTime -ge "+((get-Date).AddDays($dateShift)).Date+"}")
	$listCamtFiles= get-ChildItem ($source_path + '\*.treated') | Where-Object {$_.LastWriteTime -ge ($date.AddDays($dateShift)).Date}
    
	$countXMLFile = ($listCamtFiles).Count
    
    if ($countXMLFile -eq 0) {
        Log -Level "ERROR" -Message "No XML camt file found !!!"
        Log -Level "ERROR" -Message "Aborting Payments control."
        $subject = "-- CTR - IDIT Payments received - " + (get-date -f "dd.MM.yyyy") + " - Control KO --"
        $body = "No XML files to process`n Please review log attached for details."
        
        $rc = Send-Message -Subject $subject -body $body
        Log -Level 'INFO' -Message $SEP_L2
		Clean-TemporaryDirectory
		Stop-Log | Out-Null
        exit $EXIT_KO
    }

    Log -Level 'DEBUG' -Message("List CAMT files : ")
	Log -Level 'DEBUG' -Message $SEP_L2
    $listCamtFiles | foreach-object {Log -Level 'DEBUG' -Message($_.name)}
	Log -Level 'DEBUG' -Message "Count records from source XML..."
    $countRecords = ($listCamtFiles | Get-Content | Select-String -pattern '<Ref>').Count
    Log -Level 'DEBUG' -Message $SEP_L2
	
    Log -Level 'DEBUG' -Message("Copy CAMT to work directory "+($script_path + "\tmp\"))
    $listCamtFiles | foreach-object {Copy-Item -path ($source_path + "\" + $_.name) -Destination ($script_path + "\tmp\" + $_.name)}
    $listCamtFiles = get-ChildItem ($script_path + '\tmp\camt*.*') | Where-Object {$_.LastWriteTime -ge ($date.AddDays($dateShift)).Date}


    # 4 - List number of payment in file
    Push-Location  
    cd $script_path
    Invoke-Command -ScriptBlock {& .\incpayment.exe read -i .\tmp 2>&1> .\output_cmd.txt}
    #$output_cmd = & .\incpayment.exe read -i .\tmp 2>&1> .\output_cmd.txt | Out-Null
    if (-not (Test-Path '.\incoming-payments.csv')) { 
        Log -Level 'ERROR' -Message ("Unable to find CSV -> './incoming-payments.csv'")
        Log -Level 'ERROR' -Message ("This file must exist to end processing! Abort...")
		Clean-TemporaryDirectory
        Stop-Log | Out-Null
		exit $EXIT_KO
    }
    $listCamtCSVData    = Import-Csv -Delimiter ',' -path './incoming-payments.csv'
    Pop-Location
    
    $listCamtCSVData | foreach-object {
       $split_records = $_.'File Name' -split "_"
       $_ | Add-Member -NotePropertyName Bqe -NotePropertyValue $split_records[3]
    } | out-Null
    
    $CountByBank        = $listCamtCSVData | select-object -ExpandProperty Bqe | group | Select Name, Count
    $CountTotalPayments = ($listCamtCSVData).Count
    
    Log -Level 'INFO' -Message "CAMT files statistics "
    Log -Level 'INFO' -Message $SEP_L2
    
    $CountByBank | Select-Object Name, Count | Foreach-object {
        Log -Level 'INFO' -Message("Found for " + $_.Name + "            : " + $_.Count + " record(s)" )
    } 

    Log -Level 'INFO' -Message $SEP_L2
    Log -Level 'INFO' -Message("Total XML files found for today : " + $countXMLFile + " file(s)")
    Log -Level 'INFO' -Message("Total records found   for today : " + $CountTotalPayments + " record(s)")
    
    # 5 - Query DB and list number of payments received
    Log -Level 'INFO' -Message $SEP_L2
    Log -Level 'INFO' -Message "Query IDIT DB"
    Log -Level 'INFO' -Message $SEP_L2
    
    $sql_connection = GetSqlConnection
    $listCamtFiles = get-ChildItem ($script_path + '\tmp\camt*.*') | Where-Object {$_.LastWriteTime -ge ($date.AddDays($dateShift)).Date}
    $listCamtDBCounter = @()
    $listCamtDBData   = @()
    
    $listCamtFiles | foreach-object {
        Log -Level 'INFO' -Message ("Build query for file " + $_.name)
        
        # Count results foreach XML
        $query = "select count(*) as Counter from AC_PMNT_INTERFACE_IN where PAYMENT_REMARKS like '" + ($_.name -replace '.treated','') + "%'"
        $response = GenericSQLQuery -sql $query
        $response | Add-Member -NotePropertyName name -NotePropertyValue ($_.name -replace '.treated','') 
        Log -Level 'INFO' -Message ("Found : " + $response.Counter + " record(s)")
        $listCamtDBCounter += $response

        # List entries per XML
        $query = "select OUT_PAYMENT_ID from AC_PMNT_INTERFACE_IN where PAYMENT_REMARKS like '" + ($_.name -replace '.treated','') + "%'"
        $response = GenericSQLQuery -sql $query
        $listCamtDBData += $response
    }
    
    #$listCamtDBCounter | foreach-object { $_.Counter = [int]$_.Counter }
    $CountTotalPayments_DB = ($listCamtDBCounter | measure-object -Sum -Property Counter).Sum
    Log -Level 'INFO' -Message $SEP_L2
    Log -Level 'INFO' -Message ("Total records found from DB      : " + $CountTotalPayments_DB + " record(s)")

    # 6 - Check if we are fine or not comparing DB and files record counters
    Log -Level 'INFO' -Message $SEP_L2
    if ($CountTotalPayments_DB -eq $CountTotalPayments) {
        Log -Level 'INFO' -Message "Payments control OK !"
        $subject = "-- Control - IDIT Payments received - " + (get-date -f "dd.MM.yyyy") + " - Control OK --"
        $body = "Control payments ended with success code.`nAll transactions extracted from XML found a counterpart in IDIT DB !"
        if ($sendMail) {Send-Message -Subject $subject -body $body}
    }
    else {
        # We have a problem with matching and counters
        Log -Level 'INFO' -Message "Payments control KO !"
        Log -Level 'INFO' -Message $SEP_L1
        
        # Identify missing records 
        $l = $lcsv | select-object -expandProperty "QR Reference" | foreach-object { $_ -replace "'",""}
        $diff = $l | Where-Object { $listCamtDBData -notcontains ($_) }
        
        #$diff = $listCamtCSVData | Where-Object { $listCamtDBData -notcontains ($_."QR Reference") }
        $diff | foreach-object {
            Log -Level 'INFO' -Message ($_)
        }
        Log -Level 'INFO' -Message $SEP_L1
        Log -Level 'WARNING' -Message 'Payments control KO !'
        Log -Level 'WARNING' -Message 'Reference mismatch. Please correct'
        
        $subject = "-- Control - IDIT Payments received - " + (get-date -f "dd.MM.yyyy") + " - Control KO --"
        $body = "Control payments received failed !`n Reference found in XML : $CountTotalPayments`nReferences found in DB : $CountTotalPayments_DB`nPlease review log attached for details.`n`nPlease check references or open support tickect on SSC Portal`n"
				
        if ($sendMail) {$rc = Send-Message -Subject $subject -body $body}
        
		Log -Level 'INFO' -Message $SEP_L2
		Clean-TemporaryDirectory
        
		Stop-Log | Out-Null
        exit $EXIT_KO
    }
    
	# 7 - Do post cleaning of tmp directory
    Log -Level 'INFO' -Message $SEP_L2
    Clean-TemporaryDirectory
    
    # 8 - Standard exit
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}