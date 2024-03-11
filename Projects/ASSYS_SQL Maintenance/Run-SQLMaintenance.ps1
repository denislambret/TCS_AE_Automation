#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Run_SQLMaintenance.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20240304
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
    On a regular basis some SQL script must be run on ASSYS DB in order to clean deprecated records.
    This script run SQL script on command line in order to be automated in VTOM
    A successfull call return EXIT_OK, call in error returns EXIT_KO

    .LINK
        Links to further documentation.

#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ] 
    [Alias("conf","c")]
    $config_path,
    
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $false,
        Position = 1
        )
    ] 
    [Alias("sqlscript","sql")]
    [string] $sqlScriptKey,

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
    $lib_path         = $env:PWSH_SCRIPTS_LIBS
    $Env:PSModulePath = $Env:PSModulePath + ";" + $lib_path

    Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog

    $script_path      = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects\IDIT_UpdateCGA"
    if ($null -eq $config_path) { $config_path = $script_path + "\" + ($MyInvocation.MyCommand.Name -replace 'ps1','')+ '.conf'}
    
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
    $VERSION      = "1.0"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = "2023.12.19"

    $sqlScripts = @{
        "CLOSE_FINISHED_TEMPORARY_CASE" = "CALL CLOSE_FINISHED_TEMPORARY_CASE;";
        "PROCESS_OPEN_FINISHED_CASE_AFTER_TIME_LIMIT" = "CALL PROCESS_OPEN_FINISHED_CASE_AFTER_TIME_LIMIT";
        "PROCESS_UNCLOSED_CASE_1" = "CALL PROCESS_UNCLOSED_CASE_1";
        "PROCESS_UNCLOSED_CASE_2" = "CALL PROCESS_UNCLOSED_CASE_2";
        "PROCESS_UNCLOSED_CASE_3" = "CALL PROCESS_UNCLOSED_CASE_3";
        "PROCESS_UNCLOSED_CASE_4" = "CALL PROCESS_UNCLOSED_CASE_4";
        "PROCESS_UNCLOSED_CASE_5" = "CALL PROCESS_UNCLOSED_CASE_5";
        "PROCESS_UNCLOSED_CASE_6" = "CALL PROCESS_UNCLOSED_CASE_6";
        "PROCESS_UNCLOSED_CASE_7" = "CALL PROCESS_UNCLOSED_CASE_7";
        "PROCESS_UNCLOSED_CASE_8" = "CALL PROCESS_UNCLOSED_CASE_8";
    }
    
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
        $ConnectionString = "Server=" + $conf.conf.db.sqlServerInstance + "; database=" + $conf.conf.db.database + "; Integrated Security=False;" + "User ID=" + $conf.conf.db.userName + "; Password="+$conf.conf.db.password + ";"
    
        try
        {
            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
            $sqlConnection.Open()
            return $sqlConnection
        }
        catch
        {
            Write-Error $error
            return $null
        }
    }

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Options : "
        "-conf      Source directory / file"
        "-sqlscript Reference key to instantiate maintenance SQL script"
        "           CLOSE_FINISHED_TEMPORARY_CASE"
        "           PROCESS_OPEN_FINISHED_CASE_AFTER_TIME_LIMIT"
        "           PROCESS_UNCLOSED_CASE_1"
        "           PROCESS_UNCLOSED_CASE_2"
        "           PROCESS_UNCLOSED_CASE_3"
        "           PROCESS_UNCLOSED_CASE_4"
        "           PROCESS_UNCLOSED_CASE_5"
        "           PROCESS_UNCLOSED_CASE_6"
        "           PROCESS_UNCLOSED_CASE_7"
        "           PROCESS_UNCLOSED_CASE_8"
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
        Log -Level "ERROR" -Message ("Configuration file not found " + $config_path)
        Log -Level "ERROR" -Message ("Process aborted! " + $config_path)
        Clean-TemporaryDirectory
        Stop-Log | Out-Null
        exit $EXIT_KO
    }
    
    
    # 2 - Play SQL queries on ASSYS DB
    # 2.1 Get SQL DB connection
    Log -Level 'INFO' -Message('Get connection to DB Server ('+$conf.conf.db.sqlServerInstance+')')
    $sql_connection = GetSqlConnection
    if ($null -eq $sql_connection) {
        Log -Level 'ERROR' -Message('Error connecting to DB server ('+$conf.conf.db.sqlServerInstance+')')
        Log -Level 'INFO' -message $SEP_L1
        Stop-Log | Out-Null
        exit $EXIT_KO
    }

    # 2.2 Run Query 1
    Log -Level 'INFO' -Message $SEP_L2
    Log -Level 'INFO' -Message('preparing query : '+ $sqlScriptKey)    
    Log -Level 'DEBUG' -Message('SQL cmd : ' + $sqlScripts[$sqlScriptKey])
    $response = GenericSQLQuery -sql $query
  
    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}