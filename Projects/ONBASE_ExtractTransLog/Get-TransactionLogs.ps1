#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Get-TransactionLogs.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230311
# Version : 0.2
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Retrieve records from transaction table on a daily base on ONBASE db. Apply transcoding to complete action code message.
        Also offer flexibility to create ONBASE DIP index file, and zip audit log before archiving to gain storage space

    .INPUTS
        Configuration file 

    .OUTPUTS
        CSV log file
        CSV Dip index file
        Audit logs in text or zip format

    .EXAMPLE
        .\Get-TransactionLogs.ps1 -conf .\dev.conf -dip -zip

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

    Configuration file template

    <conf>
        <db>
            <sqlServerInstance>CLUSQL01TSTBASE</sqlServerInstance>
            <database>ONBASE_DEV</database>
            <userName>obdev_admin</userName>
            <password>&lt;?lM`xS$&amp;e*y$mAf5&amp;G&gt;</password>
        </db>
        <msgtbl_path>C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects\ONBASE_ExtractTransLog\msg_catalog.csv</msgtbl_path>
        <output_path>C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects\ONBASE_ExtractTransLog\data\</output_path>
        <targetDocType>158</targetDocType>
    </conf>    

    Message table format is four columns CSV file and based on official Hyland documentation Onbase v22.3 :
    - Log Message	
    - Table	
    - actionnum	
    - subactionnum

    #>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $false,
        Position = 0
        )
    ] 
    [Alias('config','conf')] [string]$config_path,
    
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 1
        )
    ] 
    [Alias('sd')] [datetime]$startDate,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 2
        )
    ]
    [Alias('ed')] [datetime]$endDate, 
    
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 3
        )
    ] 
    [Alias('d')] [switch]$dip,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 4
        )
    ] 
    [Alias('noTranscoding','noTransco','nt')] [switch]$raw,
 
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 5
        )
    ] 
    [Alias('z')] [switch]$zip,
 
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

    $log_path ="C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\logs"
    # Log initialization
    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { 
        "FATAL : Log initialization failed!"
        exit $EXIT_KO
    }
    
    # Set log default and minum level for logging (ideally DEBUG when having trouble)
    Set-DefaultLogLevel -Level "INFO"
    Set-MinLogLevel -Level "DEBUG"

    $DebugPreference = "SilentlyContinue"
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
    $SCRIPT_DATE  = "20230217"
        
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------
    #..................................................................................................................................
    # Function : GenericSqlQuery
    #..................................................................................................................................
    # Execute query to retrieve list of payments from IDIT
    #..................................................................................................................................
    function GenericSQLQuery {
        param(
            [string] $sql
        )
        # https://cmatskas.com/execute-sql-query-with-powershell/
    
        $SqlConnection = GetSqlConnection
        if (-not $SqlConnection) {
            Log -level 'ERROR' -message ("Error connecting to db!")
            return $false
        }
    
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
    function GetSqlConnection {
        $ConnectionString = "Server=" + $conf.conf.db.sqlServerInstance + "; database=" + $conf.conf.db.database + "; Integrated Security=False;" + "User ID=" + $conf.conf.db.userName + "; Password="+'?lM`xS$&e*y$mAf5&G';
    
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
    # Function : Get-FingerPrint
    #..................................................................................................................................
    # Compute a finger print for a file or a PSObject
    #..................................................................................................................................
    function Get-FingerPrint {
        param (
            [Parameter(
                Mandatory = $false,
                Position = 0
                )
            ] [string] $path,
            [Parameter(
                Mandatory = $false,
                Position = 1
                )
            ] [PSObject] $str
        )
        
        
        if (-not $str) {
            if (($path) -and (Test-Path $path)) {
                $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $stream = [System.IO.File]::Open($path, [System.IO.Filemode]::Open, [System.IO.FileAccess]::Read)
                $fingerPrint= [System.BitConverter]::ToString($md5.ComputeHash($stream))
                $stream.Close()
                return $fingerPrint
            }
        } elseif ($str) {
            $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
            $utf8 = New-Object -TypeName System.Text.UTF8Encoding
            $fingerprint = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($str)))
            return $fingerPrint
        } else {
            return $null
        }
    }

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Extract and prepare ONBASE transaction logs for archiving."
        " "
        "Options : "
        "-Config            Configuration file name"
        "-startDate         Start extraction date"
        "-endDate           End extraction date"
        "-DIP               Generate DIP index file"
        "-noTranscoding     No message transcoding / completion"
        "-zip               Create output zip archive"
        "-Help              Display command help"
        Write-Host $SEP_L1
        exit 0;
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
    
    # Script infp
    Write-Host $SEP_L1
    Write-Host ($MyInvocation.MyCommand.Name + " v" + $VERSION)
    Write-Host $SEP_L1

    # Display inline help if required
    if ($help) { 
        helper 
        exit 0;
    }
    
    # 1 - Load script config file
    try {
        [XML]$conf = Get-Content $config_path
    }
    catch [System.IO.FileNotFoundException] {
        Log -Level "ERROR" -Message ("Configuration file not found " + $conf.config_path)
        Log -Level "ERROR" -Message ("Process aborted! " + $conf.config_path)
        Clean-TemporaryDirectory
        Stop-Log | Out-Null
        exit $EXIT_KO
    }

    # 2 -  Send SQL query to extract transaction logs
    Write-Host ("Build and execute Onbase audit trails extraction query...")
    $date      = (get-date -format "yyyyMMdd_HHmmss")
    if (-not $startDate) { 
        $startDate = (get-date)
        $endDate   = (get-date)
    }
    
    $strStartDate = '{0:yyyy-dd-MM 00:00:00}' -f $startDate
    $strEndDate   = '{0:yyyy-dd-MM 23:59:59}' -f $endDate

    $outputFileName = $conf.conf.output_path + "\" + $date + "_transactionLog.txt" 
    $query = "SELECT TMaster.transactionnum `
        ,TMaster.tmessage`
        ,TMaster.action`
        ,TMaster.logdate`
        ,TMaster.num`
        ,TMaster.usernum`
        ,TUser.username`
        ,TMaster.itemnum`
        ,TMaster.docrevnum`
        ,TMaster.registernum`
        ,TMaster.actionnum`
        ,TMaster.subactionnum`
        ,TMaster.severityflag`
        ,TMaster.tracelvl`
        ,TMaster.extrainfo1`
        ,TMaster.extrainfo2`
    FROM hsi.transactionxlog AS TMaster`
    INNER JOIN hsi.useraccount AS TUser ON TUser.usernum = TMaster.usernum`
    WHERE TMaster.logdate >= '" + $strStartDate + "' AND TMaster.logdate < '" + $strEndDate + "';"

    Write-Debug ("Query : " + $query)
    $response = GenericSQLQuery -sql $query
    Write-Host("Total record(s) extracted    : " + $response.Count + " item(s)")

    # 3 - Trancode / complete log record message
    if (-not $raw) { 
        $trCount = 0
        Write-Host "Apply transcoding on action/subaction message codes..."
        $msgList = Import-Csv -path $conf.conf.msgtbl_path -Delimiter ";" -Header @('message','table','actionnum','subactionnum')
        $response | ForEach-Object { 
            $actionnum = $_.actionnum
            $subactionnum = $_.subactionnum
            $message = $msgList | Where-Object { (($_.actionnum -eq $actionnum) -and ($_.subactionnum -eq $subactionnum))} | Select-Object -ExpandProperty message  
            $actionMessage = ($_.tmessage.Trim() -replace '\s{2,}|\"{2,}', '') + " - " + $message
            Write-Debug ("Transcoding message action/subaction code (" + $_.actionnum + "-" + $_.subactionnum + ") as string message => '" + $actionMessage +"'" )
            $_ | Add-Member -NotePropertyName tfullmessage -NotePropertyValue $actionMessage
            $trCount++
        }
        Write-Host("Total record(s) transcoded   : " + $trCount + " item(s)") 
    }
    $response | ConvertTo-Csv -Delimiter ";" | ForEach-Object {$_.Trim() -replace '\s{2,}|\"{2,}', ''} | Set-Content -path $outputFileName 
    
    # 4 - Create zip archive file
    if ($zip) {
        Write-Host "Create archive file..."
        Compress-Archive -Path $outputFileName -DestinationPath ($outputFileName + '.zip')
    }

    # 5 - If DIP is set, then we generate an CSV index for further import
    if ($dip) {
        $idxFileName =  $conf.conf.output_path + "\" + $date + "_DIP_Indexes.csv"
        "Generate index file for DIP  : " + $idxFileName
        if ($zip) { 
            $zipExt ='.zip'
        }
        $idx = "ONBASE;ONBASE;INTERNE;AUD - Import Onbase transactions logs file;" + (get-date -format "yyyy-MM-dd") + ";" + (get-date -format "yyyy-MM-dd") + ";IT;;;CONFIDENTIAL;" + $conf.conf.targetDocType + ";" + $outputFileName + $zipExt
        $idx | Set-Content -path $idxFileName
        if ($zip) {
            Remove-Item -path $outputFileName
        }
    }
    Write-Host("Output file                  : " + $outputFileName)
    
    # Standard exit
    Write-Host $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}