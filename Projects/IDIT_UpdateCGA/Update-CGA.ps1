#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Update_CGA.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20231219
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
       As end user modify CGA during business days with no control (which is a issue), this script update DB records and order
       to keep correct versions and configuration of CGA.

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

    $queries = @("update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2024', GENERAL_CONDITIONS_TCS='1000043'`
        where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT`
        inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID`
        inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID`
        inner join P_POLICY as p on p.id=ptcs.id`
        inner join P_POL_HEADER as ph on p.policy_header_id=ph.id`
        where EXTERNAL_POLICY_NUMBER is not null`
        AND p.POLICY_START_DATE>='01-01-2024'`
        AND p.STATUS_ID in ('20','13','10')`
        AND T_PROD_TCSVER_TCS.ID in (1000025)`
        AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2024' )`
        AND ID<=10150698", 
        
        "update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2024', GENERAL_CONDITIONS_TCS='1000043' where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT`
        inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID`
        inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID`
        inner join P_POLICY as p on p.id=ptcs.id`
        inner join P_POL_HEADER as ph on p.policy_header_id=ph.id`
        where EXTERNAL_POLICY_NUMBER is not null`
        AND p.POLICY_START_DATE>='01-01-2024'`
        AND p.STATUS_ID in ('20','13','10')`
        AND T_PROD_TCSVER_TCS.ID in (1000025)`
        AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2024' )`
        AND ID>10150698 AND ID<=10296118",
        
        "update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2024', GENERAL_CONDITIONS_TCS='1000043' where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT`
        inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID`
        inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID`
        inner join P_POLICY as p on p.id=ptcs.id`
        inner join P_POL_HEADER as ph on p.policy_header_id=ph.id`
        where EXTERNAL_POLICY_NUMBER is not null`
        AND p.POLICY_START_DATE>='01-01-2024'`
        AND p.STATUS_ID in ('20','13','10')`
        AND T_PROD_TCSVER_TCS.ID in (1000025)`
        AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2024' )`    
        AND ID>10296118 AND ID<=10368854",
        
        "update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2024', GENERAL_CONDITIONS_TCS='1000044' where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT`
        inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID`
        inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID`
        inner join P_POLICY as p on p.id=ptcs.id`
        inner join P_POL_HEADER as ph on p.policy_header_id=ph.id`
        where EXTERNAL_POLICY_NUMBER is not null`
        AND p.POLICY_START_DATE>='01-01-2024'`
        AND p.STATUS_ID in ('20','13','10')`
        AND T_PROD_TCSVER_TCS.ID in (1000026)`
        AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2024' )`
        AND ID<=10221100",
        
        "update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2024', GENERAL_CONDITIONS_TCS='1000044' where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT`
        inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID`
        inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID`
        inner join P_POLICY as p on p.id=ptcs.id`
        inner join P_POL_HEADER as ph on p.policy_header_id=ph.id`
        where EXTERNAL_POLICY_NUMBER is not null`
        AND p.POLICY_START_DATE>='01-01-2024'`
        AND p.STATUS_ID in ('20','13','10')`
        AND T_PROD_TCSVER_TCS.ID in (1000026)`
        AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2024' )`
        AND ID>10221100 AND ID<=10369015",
        
        "update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2022', GENERAL_CONDITIONS_TCS='1000022' where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT`
        inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID`
        inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID`
        inner join P_POLICY as p on p.id=ptcs.id`
        inner join P_POL_HEADER as ph on p.policy_header_id=ph.id`
        where EXTERNAL_POLICY_NUMBER is not null`
        AND p.POLICY_START_DATE<'01-01-2024'`
        AND p.POLICY_START_DATE>='01-01-2022'`
        AND p.STATUS_ID in ('20','13','10')`
        AND T_PROD_TCSVER_TCS.ID in (1000025)`
        AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2022')",
        
        "update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2022', GENERAL_CONDITIONS_TCS='1000023' where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT`
        inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID`
        inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID`
        inner join P_POLICY as p on p.id=ptcs.id`
        inner join P_POL_HEADER as ph on p.policy_header_id=ph.id`
        where EXTERNAL_POLICY_NUMBER is not null`
        AND p.POLICY_START_DATE<'01-01-2024'`
        AND p.POLICY_START_DATE>='01-01-2022'`
        AND p.STATUS_ID in ('20','13','10')`
        AND T_PROD_TCSVER_TCS.ID in (1000026)`
        AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2022')"

    )
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
    
    
    # 2 - Play update SQL queries on DB
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
    $countQueries = 0;
    foreach ($query in $queries) {
        Log -Level 'INFO' -Message('preparing query #'+ $countQueries)    
        Log -Level 'DEBUG' -Message('SQL cmd : ' + $sql)
        #$response = GenericSQLQuery -sql $query
        Log -Level 'INFO' -Message('query executed #'+ $countQueries + ' - response ' + $response)    
    }
    
   
    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}