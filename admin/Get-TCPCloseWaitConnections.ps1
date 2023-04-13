#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Get-TCPCloseWaitConnections.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20221121
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Control number of connection with Exstream Gateway.
        Return error if oover a predefined limit
        Retorn OK if below.

#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (  
    # Server IP + port to check
	[string]$conf,
	
	# Connection limits
	[int]$Limit,
	
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
    
	$Env:PSModulePath = $Env:PSModulePath+";d:\Scripts\libs"
	#$Env:PSModulePath = $Env:PSModulePath+";Y:\03_DEV\06_GITHUB\tcs-1\libs"
	
	Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog

    # Log initialization
    if (-not (Start-Log -path $global:LogRoot -Script $MyInvocation.MyCommand.Name)) { 
        "FATAL : Log initialization failed!"
        exit $EXIT_KO
    }
    
    # Set log default and minum level for logging (ideally DEBUG when having trouble)
    Set-DefaultLogLevel -Level "INFO"
    Set-MinLogLevel -Level "DEBUG"
}


PROCESS {

   
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                          G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    $VERSION      = "0.1"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = "20221121"
    $conf_path    = "../conf/ACP_WGE1AS056T_CTRExstreamGWConnection.conf"
    $LimitConnections = 50
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : Get_TCPCloseWaitConnections
    #..................................................................................................................................
    # Retrieve all CLOSE_WAIT TCP connections on host provide
    #..................................................................................................................................
    function Get-TCPCloseWaitConnections {
        param (
            [string]$hostAddress,
            [int]$port,
            [int]$limit
        )
        
        $connections = get-nettcpconnection -LocalAddress $hostAddress -Port $port| Where-Object {$_.state -eq "closewait"} | Select-Object LocalAddress, RemoteAddress, OwningProcess

        if (($connections).Count -gt $limit) {
            Log -Level 'ERROR' -Message('Number of connections countent on ' + $conf_string + ' over limits defined (max. ' + $LimitConnections + ' < Count : ' + ($list).Count + ')')     
        } else {
            Log -Level 'INFO' -Message('Number of connections countent on ' + $conf_string + ' below limits defined (max. ' + $LimitConnections + ' > Count : ' + ($list).Count + ')')
        }

        return $connections
    }

    #..................................................................................................................................
    # Function : Kill_TCPCloseWaitConnections
    #..................................................................................................................................
    # Retrieve all CLOSE_WAIT TCP connections on host provide
    #..................................................................................................................................
    function Kill-TCPCloseWaitConnections {
        param (
            $connections
        )

        foreach ($item in $connections) {
            try {
                Stop-Process -id $item.OwningProcess
            }
            catch {
                Log -Level 'ERROR' -Message('Unable to stop process '+$_.name + "(" + $_. + ")")
            }
        }
    }
    
    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        $MyInvocation.MyCommand.Name
        " "
        "Options : "
		"-conf		Configuration file with server string including IP address + port to check"
		"-Limits    Threshold connection limit to send OK or KO return code"
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
    if ($conf -and (Test-Path $conf)) {
		$conf_path = $conf
	} else {
		Log -Level 'ERRROR' -Message('Configuration file not found!')
		Exit-KO
	}
	
	if ($limit) {
		$LimitConnections = $limit
	}
	
	if ($help) { helper }
    
    # 0 - Load config file
    $conf_string = Get-Content ($conf)

    # 1 - Get netstat connections list on server
    $list = &netstat -a| Select-String -pattern 'CLOSE_WAIT'

    # 2 -  Test list size and define if we are over or below connection limits.
    if (($list).Count -gt $LimitConnections) {
        # Error Case
        Log -Level 'ERROR' -Message('Number of connections countent on ' + $conf_string + ' over limits defined (max. ' + $LimitConnections + ' - Count : ' + ($list).Count + ')')
        $list | foreach-object {Log -Level 'DEBUG' -Message($_)}
		Log -Level 'ERROR' -Message($SEP_L1)
        Exit-KO
    }
    
    
    # Standard exit
    Log -Level 'INFO' -Message('Number of connections on ' + $conf_string + ' below limits defined (max. ' + $LimitConnections + ' - Count : ' + ($list).Count + ')')
	$list | foreach-object {Log -Level 'DEBUG' -Message($_)}
    Exit-OK
    #----------------------------------------------------------------------------------------------------------------------------------
}