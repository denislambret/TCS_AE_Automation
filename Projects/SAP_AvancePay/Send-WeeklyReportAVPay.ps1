
#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Send-WeeklyReportAVPay.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220217
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Select report created for avance pay according week number
        Send CSV report to distribution list
   
    .PARAMETER FirstParameter
        '-conf' as configuration file for script parameters

    
    .OUTPUTS
        RC OK/KO

    .EXAMPLE
        Send-WeeklyReportAVPay.ps1 -conf ./prd.conf

#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # Configuration file path
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 1)
    ] 
    [Alias('conf')]
    $conf_filename,
    
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

    $script_path      = $global:ScriptRoot + "\Projects\SAP_AvancePay"
    if (-not $config_path) {$config_path = $script_path + "\" + ($MyInvocation.MyCommand.Name -replace 'ps1','')+ 'conf'}
    
    # Log initialization
    if (-not (Start-Log -path $global:LogRoot -Script $MyInvocation.MyCommand.Name)) { 
        "FATAL : Log initialization failed!"
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
 
    #..................................................................................................................................
    # Function : Send-Message
    #..................................................................................................................................
    # Send email message to TCS SMTP server
    #..................................................................................................................................
    function Send-Message {
        param(
            [string] $subject,
            [string] $body,
            [string] $attachment
        )

        $from = $conf.conf.mail.from
        $recipients = $conf.conf.mail.to
        $secStr = New-Object System.Security.SecureString
        $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NTAUTHORITY\ANONYMOUSLOGON",$secStr
   
        Log -Level 'DEBUG' -Message ("Send email to mail list")
        Log -Level 'DEBUG' -Message ("Subject : " + $subject)
        Log -Level 'DEBUG' -Message ("Attachment : " + $attachment)
                
        try {
			send-mailmessage -to $recipients -from $from -subject $subject -body $body -attachment $attachment -smtpServer $conf.conf.mail.smtp_srv -credential $creds
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
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function Get-WeekNumber([datetime]$DateTime = (Get-Date)) {
        $cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
        return $cultureInfo.Calendar.GetWeekOfYear($DateTime,$cultureInfo.DateTimeFormat.CalendarWeekRule,$cultureInfo.DateTimeFormat.FirstDayOfWeek)
    }

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .DESCRIPTION
            Select report created for avance pay according week number
            Send CSV report to distribution list
    #>
    
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
    

    # 1 - Get report for this weeek as attachement
    $year  = (get-Date).Year
    $week  = ([string](Get-WeekNumber)).padleft(2,"0");
    $outCSVFile =  $conf.conf.pathes.csv_path + '_' + $year + $week + '.csv' 
    Log -Level 'DEBUG' -Message ('CSV Output file is  : ' + $outCSVFile)
    
    # 2- Prepare mail info
    $mySubject = "Avance Pay report - Week #"+ $week + "-" + $year;
    $myBody = "Please find attached to this message AVANCE PAY report list for week #" + $week + "-" + $year;

    # 3 - Send email
    if (Send-Message -Subject $mySubject -body $myBody -attachment $outCSVFile) {
        Log -Level 'INFO' -Message ("Report sent to distribution list...")
    } else {
        Log -Level 'ERROR' -Message ("Error while sending e-mail...")
        Log -Level 'INFO' -message $SEP_L1
        Stop-Log | Out-Null
        exit $EXIT_KO
    }
    
    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}

