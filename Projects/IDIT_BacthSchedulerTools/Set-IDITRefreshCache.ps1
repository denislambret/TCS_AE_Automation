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
    
    # help switch
    [switch] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#                                            G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
$VERSION      = "0.1"
$AUTHOR       = "DLA"
$SCRIPT_DATE  = ""

#----------------------------------------------------------------------------------------------------------------------------------
#                                                  F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------
#..................................................................................................................................
# Function : Refresh-Cache
#..................................................................................................................................
# Synopsis : Refresh IDIT Cache
# Input    : none
# Output   : OKO
#..................................................................................................................................

function Set-RefreshCache {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [String]
        [Alias('config','conf')] $config_path
    )
    
    # 2 - Prepare WebSrv call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("userName", $conf.wsi.query[2].userName)
    $headers.Add("password", $conf.wsi.query[2].password)
    $headers.Add("Cookie", $conf.wsi.query[2].Cookie)
    $body = $conf.wsi.query[2].body

    # 3 - Invoke Web service
    $current_hour = (get-date  -Format "HH")
    $url = $conf.wsi.query[2].url + $current_hour
    Write-host "Web service URL -> $url"
    $IDITJobsList = Invoke-RestMethod $url -Method  $conf.wsi.query[2].method -Headers $headers -Body $body -StatusCodeVariable $response_code -ErrorAction Ignore
     
    if ($response_code -ge 300) {
        "Error invoking web service"
        "Return HTTP : " + $response_code
        return $null 
    }
 
    # 5 - Return batch jobs filtered list
    return $response_code
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

# 2 - Instantiate WS Refresh Cache
Set-RefreshCache -conf $config_path