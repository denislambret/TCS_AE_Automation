#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Kill-IDITJob.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20240123
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
      Mark a batch as failed on IDIT. Kill a batch job.
    

    .DESCRIPTION
    
    .PARAMETER FirstParameter
     conf       configuration file
     id         job id to kill
     

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

#>

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $false,
        Position = 0
        )
    ]  
    [Alias('config','conf')] $config_path,
    
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 1
        )
    ]  
    [Alias('job','jobid')] $id,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 2
        )
    ]  
    # help switch
    [switch] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#                                            G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
$status = @{
    4 = "IN PROGRESS"
    5 = "SUCCESS"
    6 = "FAIL"
    7 = "FAIL"
    8 = "IN PROGRESS"
    10 = "FAIL"
    17 = "IN PROGRESS"
    20 = "IN PROGRESS"
}

$HTTP_CODES = @{ 
    200 = "HTTP_SUCCESS"
    401 = "HTTP_SECURITY_ERROR"
    422 = "HTTP_FUNCTIONAL_ERROR"
    500 = "HTTP_SERVER_ERROR"
}

$IDITjobsList = $null
$VERSION      = "0.1"
$AUTHOR       = "DLA"
$SCRIPT_DATE  = ""

#----------------------------------------------------------------------------------------------------------------------------------
#                                                  F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------
#..................................................................................................................................
# Function : Get-IDITJobById
#..................................................................................................................................
# Synopsis : Get job by id
# Input    : jobid
# Output   : job 
#..................................................................................................................................
function Get-IDITJobById {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [String]
        [Alias('config','conf')] $config_path,
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $id
    )
    
    # 2 - Prepare WebSrv call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("userName", $conf.wsi.query[0].userName)
    $headers.Add("password", $conf.wsi.query[0].password)
    $headers.Add("Cookie", $conf.wsi.query[0].Cookie)
    $body = $conf.wsi.query[0].body

    # 3 - Invoke Web service
    $url = $conf.wsi.query[0].url + "/" + $id
    Write-host "Web service URL -> $url"
    $IDITJobsList = Invoke-RestMethod $url -Method  $conf.wsi.query[0].method -Headers $headers -Body $body -StatusCodeVariable $response_code -ErrorAction Ignore
     
    if ($response_code -ge 300) {
        "Error invoking web service"
        "Return HTTP : " + $response_code
        return $null 
    }
    $job = $IDITJobsList | ConvertTo-Json -Depth 20| ConvertFrom-Json 

    # 5 - Return batch jobs filtered list
    return $job
}

#..................................................................................................................................
# Function : Get-IDITJobStatus
#..................................................................................................................................
# Synopsis : get job status by id
# Input    : jobid
# Output   : IDIT's job status code
#..................................................................................................................................

function Get-IDITJobStatus {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )

    # 4 - Apply list filter
    if ($id) {
        $job = $IDITJobsList  | Where-Object { 
            $_.id -eq $id
        }     
    }

    # 5 - Return batch jobs filtered list
    return $status[[int]$job.batchStatusVO.id]
}

#..................................................................................................................................
# Function : GenericSqlQuery
#..................................................................................................................................
# Execute query to retrieve list of payments from IDIT
#..................................................................................................................................function doSQL
function GenericSQLQuery {
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
function GetSqlConnection {
    $ConnectionString = "Server=" + $conf.db.sqlServerInstance + "; database=" + $conf.db.database + "; Integrated Security=False;" + "User ID=" + $conf.db.userName + "; Password="+$conf.db.password + ";"
    try
    {
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
    }
    catch
    {
        Write-Host $PSItem
        return $null
    }
    return $sqlConnection
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                             _______ _______ _____ __   _
#                                             |  |  | |_____|   |   | \  |
#                                             |  |  | |     | __|__ |  \_|
#----------------------------------------------------------------------------------------------------------------------------------
if (-not $config_path) {
    $config_path = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects\IDIT_BacthSchedulerTools\ACP.conf"
}

"-" * 142
($MyInvocation.MyCommand.Name + " v" + $VERSION)
"-" * 142

# 1 - Load script config file
try {
        [XML]$conf_raw = Get-Content $config_path
        $conf = $conf_raw.conf
}
catch [System.IO.FileNotFoundException] {
        Write-Error ("Configuration file not found " + $config_path)
        Write-Error ("Process aborted! " + $config_path)
        exit $EXIT_KO
}

# 2 - Download job information
"Download job information..."
$job = Get-IDITJobById -config_path $config_path -id $id
"-" * 142
if (($job).Count -gt 0) {
    Write-Host $("job #" + $id +" found"+$(" " * 123)) -ForegroundColor DarkGreen 
} else {
    Write-Host $("job not found..."+$(" " * 126)) -ForegroundColor White -BackgroundColor Red
    "-" * 142
    exit $EXIT_KO
}

# 3 - Display job details (see json response structure to understand variables used)
"-" * 142
"Connect to DB and execute kill job query..."
$query = "UPDATE sh_batch_log SET status = 6 WHERE id=" + $id
$response = GenericSQLQuery -sql $query
If ($null -eq $response) {
    "-" * 142
    "job #$id hase been killed..."
    "-" * 142
     exit $EXIT_OK
} else {
    "-" * 142
    "Error killing job #$id..."
    "-" * 142
    exit $EXIT_KO
}

# Script end
"-" * 142

