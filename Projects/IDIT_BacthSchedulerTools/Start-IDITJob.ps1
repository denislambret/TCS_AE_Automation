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
    catch [System.IO.FileNotFoundException] {
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

    Write-Host ("Call " + $conf.wsi.query[1].url + " - " +$conf.wsi.query[1].method)
    try {
            $response = Invoke-RestMethod $conf.wsi.query[1].url -Method  $conf.wsi.query[1].method -Headers $headers -Body $body 
            
      } catch {
        # Dig into the exception to get the Response details.
        # Note that value__ is not a typo.
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.ReasonPhrase
        if ($_.ErrorDetails.Message ) {Write-Host "Error Details :" ($_.ErrorDetails.Message | Convertfrom-json).title}
        exit 1
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
"Creating new job on IDIT server..."
$response = Start-IDITJob -config_path $config_path -id $id
if (-not $response) {
    "Abnormal termination !"
    exit 1
}

"-" * 142
Write-Host "SUCCESS - Job created with id # $response"
"-" * 142