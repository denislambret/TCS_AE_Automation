#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Get-IDITJobsList.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20240123
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
     Return status information related to IDIT Job list.
    

    .DESCRIPTION
    
    .PARAMETER FirstParameter
     conf       configuration file
     id         filter on job id
     desc       List jobs filtered by description
     status     List filtered by status
     first      Limit number item in list
     log        Dump batch log (work only with id selection)
     childOnly  Display only job with a parentid (children)

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
    [Alias('first', 'top')] $limit = 10000,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $false,
        Position = 3
        )
    ]  
    [Alias('log','l')]
    [switch]$fLog = $false,
    
    [Alias('childOnly','p')]
    [switch]$fParent = $false,

    # help switch
    [switch] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#                                            G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
$IDITjobsList = $null
$VERSION      = "0.1"
$AUTHOR       = "DLA"
$SCRIPT_DATE  = ""

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
    $headers.Add("Content-type", "text/plain")
    #$headers.Add("Cookie", $conf.wsi.query[0].Cookie)
    $body = $conf.wsi.query[0].body

    # 3 - Invoke Web service
  
    if ($id) {
        #$url = $conf.wsi.query[0].url + "/" + $id
        $url = $conf.wsi.query[0].url 
        Write-host "Web service URL -> $url"
        $IDITJobsList = Invoke-RestMethod $url -Method  $conf.wsi.query[0].method -Headers $headers -Body $body -StatusCodeVariable $response_code
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
    $job = $IDITJobsList | ConvertTo-Json -Depth 20| ConvertFrom-Json #| Where-object {$_.}

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
# Function : Get-IDITJobParent
#..................................................................................................................................
# Synopsis : get job parentLogId by jobid
# Input    : jobid
# Output   : IDIT's job status code
#..................................................................................................................................

function Get-IDITJobParent {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $id
    )
    
    $IDITJobsList = Get-IDITJobsList -config_path $config_path 
    
    # 4 - Apply list filter
    $jobs = $IDITJobsList  | Where-Object { 
            $_.parentLogId -eq $id    
    }

    # 5 - Return parentLogId
    return $jobs
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

"Download job list from IDIT..."
if ($desc) {
     $IDITJobsList = Get-IDITJobsList -config_path $config_path -Desc $desc
     "Total matches                 -> " + ($IDITJobsList).Count + " job(s)"
} elseif ($id) {
    
    $job = Get-IDITJobById -config_path $config_path -id $id
    "-" * 142
    if (($job).Count -gt 0) {
        Write-Host $("job #" + $id +" found"+$(" " * 123)) -ForegroundColor DarkGreen 
    } else {
        Write-Host $("job not found..."+$(" " * 126)) -ForegroundColor White -BackgroundColor Red
        "-" * 142
        exit $EXIT_KO
    }
} else {
    $IDITJobsList = Get-IDITJobsList -config_path $config_path
    "Total matches after query     -> " + ($IDITJobsList).Count + " job(s)"
    if (($IDITJobsList).Count -ge $limit) {
        "Limit matches display        -> " + $limit + " job(s)"
    }
}

if ((-not $IDITJobsList) -and (-not $job)) {
    "Abnormal termination or no matched job !"
    "-" * 142
    exit $EXIT_KO
}

if (-not $id) {
        $itemJobList = $IDITJobsList | Select-Object id, parentLogId, batchJobVO, createDate, updateStatusDate, batchStatusVO  
        if ($fStatus) {
            $itemJobList = $itemJobList | Where-Object {$_.batchStatusVO.desc -match $fStatus}   
        }
        
        if ($fParent) {$itemJobList = $itemJobList | Where-Object {$_.parentLogId}   }

        "Total matches after filtering -> " + ($itemJobList).Count + " job(s)"
        if (($IDITJobsList).Count -ge $limit) {
            "Limit matches display         -> " + $limit + " job(s)"
        }
        "." * 142
        $itemJobs = @()
        $itemJobList | ForEach-Object {
            $hItemJobList = @{}
            $hItemJobList.id = $_.id
            $hItemJobList.parentLogId = $_.parentLogId
            $hItemJobList.createDate = $_.createDate
            $hItemJobList.updateStatusDate = $_.updateStatusDate
            $hItemJobList.status = $_.batchStatusVO.desc
            $hItemJobList.desc = $_.batchJobVO.desc
            $itemJobs += $hItemJobList 
        }
        $itemJobs = $itemJobs |  ConvertTo-Json | Convertfrom-json 
        $itemJobs | Select-Object id, parentLogId, status, desc, createDate, updateStatusDate `
        | Sort-Object -property createDate `
        | Select-Object -First $limit `
        | Format-Table @{n='id';e={$_.id};align='center'},@{n='parentId';e={$_.parentLogId};align='center'},@{n='status';e={$_.status};align='center'}, desc, createDate, updateStatusDate -AutoSize
        
    } else {
        # Display job details (see json response structure to understand variables used)
        "." * 142
        $item = $job.batchLogIVOs | ?{$_.id -eq $id}
        "Parent      : " + $item.parentLogId
        "Job name    : " + $item.batchJobVO.id + " - " + $item.batchJobVO.desc
        "Status      : " + $item.batchStatusVO.id + " - " + $item.batchStatusVO.desc
        "Created at  : " + $item.createDate
        "Last update : " + $item.updateDate
        $startTime = [DateTime]::ParseExact($item.createDate, 'MM/dd/yyyy HH:mm:ss',$null)
        $endTime   = [DateTime]::ParseExact($item.updateDate, 'MM/dd/yyyy HH:mm:ss',$null)
        'Duration    : {0:mm} min {0:ss} s' -f ($endTime-$startTime)
        
        
        # If display log switch is true, display job logs
        if ($fLog) {
            "-" * 142
            "JOB LOG"
            "-" * 142
            $item.systemTaskLogIVOs | ForEach-Object {
                $str = $_.updateDate.toString() + ' ' + $_.logType.desc + ' ' + $_.message 
                $str | Out-String -Width 142 -Stream | ForEach-Object { Write-Host $_ }
            }
        } 
    }

"-" * 142
