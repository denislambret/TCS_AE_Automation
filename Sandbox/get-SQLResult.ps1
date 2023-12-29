#..................................................................................................................................
# Function : GenericSqlQuery
#..................................................................................................................................
# Execute query to retrieve list of payments from IDIT
#..................................................................................................................................
function GenericSQLQuery {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [System.Data.SqlClient.SqlConnection]
        [Alias('server')] $sqlConnection,
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $query
    )
    # https://cmatskas.com/execute-sql-query-with-powershell/

    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    
    # Connect IDIT db
    $SqlCmd.CommandText = $query
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
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]    $server,
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string]    $database,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string]    $user,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string]    $password
    )

    $ConnectionString = "Server=" + $server + "; database=" + $database + "; Integrated Security=False;" + "User ID=" + $user + "; Password=" + $password + ";"

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


#------------------------------------------------------------------------------------------------------------
'Start SQL connection...'
$sql_connection = GetSqlConnection -server 'prd-idit' -database 'IDIT_PRD' -user 'iditPRD' -password 'emkj4Dw1sOpc7AxfBWO6'
if ($null -eq $sql_connection) {
    Write-Error ('Error connecting to DB server (' + $server + ')')
    Stop-Log | Out-Null
    exit 1
}

'Execute query...'
$query = 'SELECT * FROM T_BATCH_JOB';
$response = GenericSQLQuery -server $sql_connection -query $query
$response | Format-table -autosize


'End SQL connection...'
$sql_connection.close()


