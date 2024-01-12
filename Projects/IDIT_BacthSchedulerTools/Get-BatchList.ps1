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

$config_path = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects\IDIT_BacthSchedulerTools\ACP.conf"
$jobsList = $null

function Get-BatchList {
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
        Log -Level "ERROR" -Message ("Configuration file not found " + $config_path)
        Log -Level "ERROR" -Message ("Process aborted! " + $config_path)
        Clean-TemporaryDirectory
        Stop-Log | Out-Null
        exit $EXIT_KO
    }
        
    # 2 - Prepare WebSrv call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("userName", $conf.wsi.query[0].userName)
    $headers.Add("password", $conf.wsi.query[0].password)
    $headers.Add("Cookie", $conf.wsi.query[0].Cookie)
    $body = $conf.wsi.query[0].body

    # 3 - Invoke Web service
    $jobsList = Invoke-RestMethod $conf.wsi.query[0].url -Method  $conf.wsi.query[0].method -Headers $headers -Body $body
    $jobsList = $jobsList | ConvertTo-Json | ConvertFrom-Json

    # 4 - Apply list filter
    if ($status) {
        $jobsList = $jobsList  | Where-Object { 
            $_.batchStatusVO.desc -match $status
        }     
    }

    If ($desc) {
            $jobsList = $jobsList  | Where-Object { 
            $_.batchJobVO.desc -match $desc
        }
    } 

    # 5 - Return batch jobs filtered list
    return $jobsList
}

function Get-jobById {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )
     # Apply list filter
     if ($id) {
        $job = $jobsList  | Where-Object { 
            $_.id -eq $id
        }     
    }  
    return $job
}

function Get-JobStatus {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )

    # 4 - Apply list filter
    if ($id) {
        $job = $jobsList  | Where-Object { 
            $_.id -eq $id
        }     
    }

    # 5 - Return batch jobs filtered list
    #$jobsList.batchStatusVO.id
    return $status[[int]$job.batchStatusVO.id]
}

function isPendingJob {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )
    
    $job = Get-JobStatus -id $id
    if ([int]$job.batchStatusVO.id -in @(8,4,20,17)) {
        return $true
    } else {
        return $false
    }
}

function isSuccessJob {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )
    
    $job = Get-JobStatus -id $id

    if ($job -match 'SUCCESS') {
        return $true
    } else {
        return $false
    }
}

function isFailedJob {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $id
    )
    
    $job = Get-JobStatus -id $id
    if ($job -match 'FAIL') {
        return $true
    } else {
        return $false
    }
}


"-" * 80
"Establishing jobs list..."
$jobsList = Get-BatchList -config_path $config_path 
"-" * 80

#$jobsList = Get-BatchList -config_path $config_path -desc 'GL export' -status 'success'
"Total batch enumerated - " + ($jobsList).Count + " job(s)"
"-" * 80
$jobsList | Select-Object -First 1
"-" * 80
$id = 20815548

"job name   : " + ((Get-jobById -id $id).batchJobVO.desc)
"Status     : " + (Get-JobStatus -id $id)
"Is running : " + (isPendingJob -id $id)
"Is success : " + (isSuccessJob -id $id)
"Is failure : " + (isFailedJob -id $id)




