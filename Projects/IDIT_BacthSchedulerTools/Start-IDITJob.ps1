

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
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $false,
        Position = 1
        )
    ]  
    [Alias('job','jobid')] $id,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 3
        )
    ] 
    [Alias('w')] 
    [switch]$wait,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 2
        )
    ] [switch] $help
)

Import-Module libConstants

#----------------------------------------------------------------------------------------------------------------------------------
#                                            G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
$VERSION      = "0.2"
$AUTHOR       = "DLA"
$SCRIPT_DATE  = "20230123"

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
$retryTimer = 60

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
function Start-IDITJob {
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
        [string] $id
    )

    # 1 - Load script config file
    try {
        [XML]$conf_raw = Get-Content $config_path
        $conf = $conf_raw.conf
    }
    catch {
        Write-Error ("Configuration file not found " + $config_path)
        Write-Error ("Process aborted! " + $config_path)
        exit $EXIT_KO
    }

    # 2 - Prepare WebSrv call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("userName", $conf.wsi.query[1].userName)
    $headers.Add("password", $conf.wsi.query[1].password)
    $headers.Add("Cookie", $conf.wsi.query[1].Cookie)
    $headers.Add("Content-Type", "application/json")
    $body = @{}
    $body.jobId = $id
    $body.checkPreviousExecution = "true"
    $body.updateVersion = "0"
    $body.priority = "3"
    $body = $body | ConvertTo-Json
    
    # 3 - Invoke Web service
    $response = $null

    Write-Host ("Call WS -> " + $conf.wsi.query[1].url + " - " +$conf.wsi.query[1].method)
    try {
            $response = Invoke-RestMethod $conf.wsi.query[1].url -Method  $conf.wsi.query[1].method -Headers $headers -Body $body 
            
      } catch {
        # Dig into the exception to get the Response details.
        # Note that value__ is not a typo.
        Write-Host $("-" * 142)
        Write-Host "StatusCode        :"$_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription :"$_.Exception.Response.ReasonPhrase
        if ($_.ErrorDetails.Message ) {Write-Host "Error Details     :" ($_.ErrorDetails.Message | Convertfrom-json).title}
        Write-Host $("-" * 142)
        exit $EXIT_KO
      }
    


    Write-Debug  ("response code " + $response_code)
    if ($response_code -ge 300) {
        "Error invoking web service"
        "Return HTTP : " + $response_code
        return $null 
    }
    
    # 4 - Return batch jobs filtered list
    return $response.logId
}

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
            Position = 2
        )]
        [string] $id
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
    #$headers.Add("Cookie", $conf.wsi.query[0].Cookie)
    $body = $conf.wsi.query[0].body

    # 3 - Invoke Web service
  
    if ($id) {
        #$url = $conf.wsi.query[0].url + "/" + $id
        $url = $conf.wsi.query[0].url 
        try {
                $IDITJobsList = Invoke-RestMethod $url -Method  $conf.wsi.query[0].method -Headers $headers -Body $body -StatusCodeVariable $response_code
            } 
        catch {
            # Dig into the exception to get the Response details.
            # Note that value__ is not a typo.
            Write-Host $("-" * 142)
            Write-Host "StatusCode        :"$_.Exception.Response.StatusCode.value__
            Write-Host "StatusDescription :"$_.Exception.Response.ReasonPhrase
            if ($_.ErrorDetails.Message ) {Write-Host "Error Details     :" ($_.ErrorDetails.Message | Convertfrom-json).title}
            Write-Host $("-" * 142)
            exit $EXIT_KO
        }    
    } 
    else {
        $IDITJobsList = Invoke-RestMethod $conf.wsi.query[0].url -Method  $conf.wsi.query[0].method -Headers $headers -Body $body -StatusCodeVariable $response_code
    }
    Write-Debug  ("response code " + $response_code)
    if ($response_code -ge 300) {
        "Error invoking web service"
        "Return HTTP : " + $response_code
        return $null 
    }
    $IDITJobsList = $IDITJobsList | ConvertTo-Json -Depth 4| ConvertFrom-Json

    # 4 - Apply list filter
    If ($id) {
        $job = $IDITJobsList  | Where-Object { 
           $_.id -match $id
        }
        return $job
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
    $body = $conf.wsi.query[0].body

    # 3 - Invoke Web service
    $url = $conf.wsi.query[0].url + "/" + $id
    Write-debug "Web service URL -> $url"
    $IDITJobsList = Invoke-RestMethod $url -Method  $conf.wsi.query[0].method -Headers $headers -Body $body -StatusCodeVariable $response_code
     
    if ($response_code -ge 300) {
        "Error invoking web service"
        "Return HTTP : " + $response_code
        return $null 
    }
    $job = $IDITJobsList | ConvertTo-Json -Depth 20| ConvertFrom-Json #| Where-object {$_.}

    # 5 - Return batch jobs filtered list
    return $job
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                             _______ _______ _____ __   _
#                                             |  |  | |_____|   |   | \  |
#                                             |  |  | |     | __|__ |  \_|
#----------------------------------------------------------------------------------------------------------------------------------
if (-not $config_path) {
    $config_path = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects\IDIT_BacthSchedulerTools\ACP.conf"
}

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

$startTime = (Get-Date)
"-" * 142
($MyInvocation.MyCommand.Name + " v" + $VERSION)
"-" * 142

"Creating new job on IDIT server..."
$responseId = Start-IDITJob -config_path $config_path -id $id
if (-not $responseId) {
    "Abnormal termination !"
    exit $EXIT_KO
}

"-" * 142
Write-Host "SUCCESS - Job created with id # $responseId"
"-" * 142

if ($wait) {
    Write-Host "Wait end of job... "
    Write-Host "Start time - " $startTime
    $job = Get-IDITJobById -config $config_path -id $responseId
    $item = $job.batchLogIVOs | Where-object {$_.id -eq $responseId}
    
    Write-Host $currentTime " - Current job status -> " $item.batchStatusVO.id
    while ([int]$item.batchStatusVO.id -in @(8,4,20,17)) {
        Start-Sleep -seconds $retryTimer
        $job = Get-IDITJobById -config $config_path -id $responseId
        $item = $job.batchLogIVOs | Where-object {$_.id -eq $responseId}
        $currentTime = (Get-Date -f "yyyy.MM.dd HH:mm:ss")
        Write-Host $currentTime " - Current status id -> " $item.batchStatusVO.id
    }  
    $endTime = (Get-Date)
    Write-Host "End time - " $endTime
    $item = $job.batchLogIVOs 
    "-" * 142
    Write-Host ("Job # " + $responseId + " ended - " + $item.batchStatusVO.desc + ' - Duration {0:mm} min {0:ss} sec' -f ($endTime-$startTime))
    "-" * 142
}

exit $EXIT_OK