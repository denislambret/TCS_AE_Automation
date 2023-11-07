#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Get-TransactionLogs.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230208
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Retrieve records from transaction table on a daily base on ONBASE db

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

    $script_path      = $global:ScriptRoot + "\Projects\ONBASE_ExtractTransLog"
    $config_path      = $script_path + "\PRD.conf"

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
    $SCRIPT_DATE  = "20230217"

    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------
    #..................................................................................................................................
    # Function : GenericSqlQuery
    #..................................................................................................................................
    # Execute query to retrieve list of payments from IDIT
    #..................................................................................................................................
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
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Do something usefull for you..."
        " "
        "Options : "
        "-Help      Display command help"
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
    Log -Level 'INFO' -Message ("Executing exctract SQL query....")
    $date      = (get-date -format "yyyyMMdd")
    $startDate = (get-date -format "yyyy-dd-MM")
    $endDate   = (get-date).AddDays(1)
    $endDate   = '{0:yyyyMMdd}' -f $endDate
    
    $outputFileName = $conf.conf.output_path + "\" + $date + "_transactionLog.csv" 
    $query = "SELECT *  FROM [ONBASE_DEV].[hsi].[transactionxlog] WHERE [ONBASE_DEV].[hsi].[transactionxlog].logdate >= '" + $startDate + "' AND [ONBASE_DEV].[hsi].[transactionxlog].logdate < '" + $endDate + "';"
    Log -Level 'DEBUG' -Message ("Query : " + $query)
    $response = GenericSQLQuery -sql $query
    $response | ConvertTo-Csv | Set-Content -path $outputFileName | 
    
    # Compress-Archive -Path $outputFileName -DestinationPath ($outputFileName + '.zip')
    log -Level 'INFO' -Message("Total record(s) extracted : " + $response.Count + " item(s)")
    log -Level 'INFO' -Message("Output file               : " + $outputFileName)

    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}