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
# Function : Get-IDITJobsList
#..................................................................................................................................
# Synopsis : Retrieve last 10k job entries from IDIT and load $jobList.
#            Also support basic filter options on status and desc (job description).
#            Note : $jobList is exported variable from the module and should be accessible through script invoking this library.
# Input    : *config_path,status,desc
# Output   : null, joblist
#..................................................................................................................................
function Get-IDITJobsList {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [String]
        [Alias('config','conf')] $config_path,
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $status,
        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [string] $desc
    )

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
        
    # 2 - Prepare WebSrv call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("userName", $conf.wsi.query[0].userName)
    $headers.Add("password", $conf.wsi.query[0].password)
    $headers.Add("Cookie", $conf.wsi.query[0].Cookie)
    $body = $conf.wsi.query[0].body

    # 3 - Invoke Web service
  
    $IDITJobsList = Invoke-RestMethod $conf.wsi.query[0].url -Method  $conf.wsi.query[0].method -Headers $headers -Body $body -StatusCodeVariable $response_code
    Write-Debug  ("response code " + $response_code)
    if ($response_code -ge 300) {
        "Error invoking web service"
        "Return HTTP : " + $response_code
        return $null 
    }
    $IDITJobsList = $IDITJobsList | ConvertTo-Json | ConvertFrom-Json

    # 4 - Apply list filter
    if ($status) {
        $IDITJobsList = $IDITJobsList  | Where-Object { 
            $_.batchStatusVO.desc -match $status
        }     
    }

    If ($desc) {
            $IDITJobsList = $IDITJobsList  | Where-Object { 
            $_.batchJobVO.desc -match $desc
        }
    } 

    # 5 - Return batch jobs filtered list
    return $IDITJobsList
}

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
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )

     # Apply list filter
     if ($id) {
        $job = $IDITJobsList  | Where-Object { 
            $_.id -eq $id
        }     
    }  
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
# Function : isPendingIDITJob
#..................................................................................................................................
# Synopsis : Return true if job is running
# Input    : jobid
# Output   : true/false
#..................................................................................................................................

function isPendingIDITJob {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )
    
    $IDITjobsList = Get-IDITJobStatus -id $id
    if ([int]$job.batchStatusVO.id -in @(8,4,20,17)) {
        return $true
    } else {
        return $false
    }
}

#..................................................................................................................................
# Function : isSuccessIDITJob
#..................................................................................................................................
# Synopsis : Return true if job is marked as success
# Input    : jobid
# Output   : true/false
#..................................................................................................................................

function isSuccessIDITJob {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )
    
    $status = Get-IDITJobStatus -id $id

    if ($status -match 'SUCCESS') {
        return $true
    } else {
        return $false
    }
}

#..................................................................................................................................
# Function : isFailedIDITJob
#..................................................................................................................................
# Synopsis : Return true if job is marked as failed
# Input    : jobid
# Output   : true/false
#..................................................................................................................................
function isFailedIDITJob {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )
    
    $status = Get-IDITJobStatus -id $id
    if ($status -match 'FAIL') {
        return $true
    } else {
        return $false
    }
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
"Establishing jobs list..."
if ($desc) {
    $IDITJobsList = Get-IDITJobsList -config_path $config_path -Desc $desc
} else {
    $IDITJobsList = Get-IDITJobsList -config_path $config_path
}

if (-not $IDITJobsList) {
    "Abnormal termination !"
    exit 1
}

"Total batch enumerated - " + ($jobs).Count + " job(s)"
"-" * 142
if (-not $id) {
    $IDITJobsList | Format-table -autosize
} else {
    "job name   : " + ((Get-IDITJobById -id $id).batchJobVO.desc)
    "Status     : " + (Get-IDITJobStatus -id $id)
    "Is running : " + (isPendingIDITJob -id $id)
    "Is success : " + (isSuccessIDITJob -id $id)
    "Is failure : " + (isFailedIDITJob -id $id)
}

"-" * 142
$IDITJobsList | Format-table -autosize