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
    [Alias('description','jobname')] $desc,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 2
        )
    ]  
    [Alias('status','s')] $fStatus,
    
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 3
        )
    ]  
    [Alias('log','l')]
    [switch]$fLog = $false,
    [Alias('retrieveHierachy','r')]
    [switch]$fHierarchy = $false,

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
$item = $job.batchLogIVOs | ?{$_.id -eq $id}

# Retrieve parent job ib if available
$jobSysTaskLog = $job | Where-object {($_.batchLogIVOs.systemTaskLogIVOs)}
$tmp = $jobSysTaskLog.batchLogIVOs.SystemTaskLogIVOs.message | ?{$_ -match 'parentLogId=(\d{8}),'}
if ($Matches[1]) { $parentJobId = $Matches[1] } else { $parentJobId = $null}

"Parent      : " + $parentJobId
"Job name    : " + $item.batchJobVO.id + " - " + $item.batchJobVO.desc
"Status      : " + $item.batchStatusVO.id + " - " + $item.batchStatusVO.desc
"Created at  : " + $item.createDate
"Last update : " + $item.updateDate
$startTime = [DateTime]::ParseExact($item.createDate, 'MM/dd/yyyy HH:mm:ss',$null)
$endTime   = [DateTime]::ParseExact($item.updateDate, 'MM/dd/yyyy HH:mm:ss',$null)
'Duration    : {0:mm} min {0:ss} s' -f ($endTime-$startTime)

# 4 - If display log switch is true, display job logs
if ($fLog) {
    "-" * 142
    "JOB LOG"
    "-" * 142
    $item.systemTaskLogIVOs | ForEach-Object {
        $str = $_.updateDate.toString() + ' ' + $_.logType.desc + ' ' + $_.message 
        $str | Out-String -Width 142 -Stream | ForEach-Object { Write-Host $_ }
    }
} 

# Script end
"-" * 142

