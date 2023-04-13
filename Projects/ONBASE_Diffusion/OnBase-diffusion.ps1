#----------------------------------------------------------------------------------------------------------------------------------
# Script  : OnBase_Diffusion.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220413
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        A brief description of the function or script.

    .DESCRIPTION
        A longer description.

    .INPUTS
        Description of objects that can be piped to the script.

    .OUTPUTS
        Description of objects that are output by the script.

    .EXAMPLE
        Example of how to run the script.

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.
#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                             C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
                Position = 0)]
    $path,
    
    # path for the result generated during process
    [Parameter(Mandatory = $true,
    ValueFromPipelineByPropertyName = $true,
    Position = 0)]
    $conf,
    
    # help switch
    [switch]
    $help
)



#----------------------------------------------------------------------------------------------------------------------------------
#                                                 I N I T I A L I Z A T I O N
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .DESCRIPTION
        Setup logging facilities by defining log path and default levels.
        Create log instance
#>
BEGIN {
    $Env:PSModulePath = $Env:PSModulePath + ";Y:\03_DEV\06_GITHUB\tcs-1\libs"
    $log_path = "Y:\03_DEV\06_GITHUB\tcs-1\logs"
    Import-Module libLog
    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
    $rc = Set-DefaultLogLevel -Level "INFO"
    $rc = Set-MinLogLevel -Level "DEBUG"
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                   I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Includes
        
        .DESCRIPTION
            Include necessary libraries
    #>
    Import-Module Posh-SSH

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                            G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    $VERSION = "0.1"
    $AUTHOR  = "DLA"
    $SCRIPT_DATE  = "13.04.2022"
    $SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
    $SEP_L2  = '......................................................................................................................'
    $EXIT_OK = 0
    $EXIT_KO = 1
    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                  F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : func1
    #..................................................................................................................................
    function Get-ConfigFile {
    <#
        .SYNOPSIS
            Load config variables from text file formated as 
            [section]
            varname1 = varvalue1

        .EXAMPLE
            Get-ConfigFile -path "myconf.conf"
    #>
    
    [CmdletBinding()]
    param (
            # This parameter doesn't do anything.
            # Aliases: MP
            [Parameter(Mandatory = $true)]
            [Alias("Source")]
            [String]$Path
    )
    
    # Get config routine
    if (-not (Test-Path $Path)) { return $false }
    $h=@{}
    Get-Content -Path $Path |
    foreach-object {
           # Retrieve line with '=' and split them
           $k = [regex]::split($_,'=')
           if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True))
           {
                # Add the Key, Value into the Hashtable
                $k[0] = $k[0] -replace " ",""
                $k[1] = $k[1] -replace " ",""
                $h[$k[0]] = $k[1]
            }
        } 
        return $h
    }

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
   
    # Script info
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION + (" (" + $SCRIPT_DATE + " / " + $AUTHOR + ")").PadLeft(140," "))
    Log -Level 'INFO' -Message $SEP_L1
    
    # 1- Load configuration
    $config = @{}
    if (-not (Test-Path $conf)) {
        Log -Level "Error" -Message("Config file " + $conf + " does not exist.")
            "User : " + $config['SFTP_User']        
    }
    $config = Get-ConfigFile -path $conf
    
    # 2- Open SFTP connection
    # First create credential with no pwd
    # Defines to not popup requesting for a password
    $nopasswd     = New-Object System.Security.SecureString 
    $Credential   = New-Object System.Management.Automation.PSCredential($config['SFTP_User'], $nopasswd) #Set Credetials to connect to server
    $SFTP_Session =  New-SFTPSession -ComputerName $config['SFTP_Server'] -Credential $Credential -KeyFile $config['SFTP_PrivKey']
    if (-not $SFTP_Session) {
        Log -Level "Error" -Message("SFTP connection to " + $config['SFTP_Server'] + " failed")
        exit $EXIT_KO
    }
    Log -Level "Error" -Message("SFTP connection - SessionID #" + $SFTP_Session.SessionID)             
    
    # 3- Do transfert 1 : Transfert lot1 (SFDC.CSV vers /InputSFDC)
    Log -Level 'INFO' -Message ("Transfert lot1 (SFDC.CSV vers /InputSFDC)")
    Log -Level 'INFO' -Message("Put files from " + $config['Local_CCM_links'] + " to SFTP " + $config['SFTP_CCM_links'])
    $csvList = Get-ChildItem -Path ($config['Local_CCM_links'] + "\*.csv")
    foreach ($item in $csvList) {
       Log -Level 'INFO' -Message("Put " +  $item.fullname + " to SFTP " + ($config['SFTP_CCM_links'] + "/" + $item.name))
       Get-SFTPFile -SessionId $SFTPSession.SessionID -LocalPath $item.fullname -RemoteFile ($config['SFTP_CCM_links'] + "/" + $item.name) -Overwrite
    }

    Log -Level 'INFO' -Message("Copy file "+ $config['Local_CCM_linksFile'] + " to " + $config['Local_NIP_Archive'])
    Copy-Item -path $config['Local_CCM_linksFile'] -Destination  $config['Local_NIP_Archive'] -Force -ErrorAction Continue
      
    Log -Level 'INFO' -Message("Move file "+$config['Local_NIP_Archive']+"\SDFC.TMP to " + $config['Local_Extsream_data'])
    Move-Item -path $config['Local_NIP_Archive']\SDFC.TMP -Destination $config['Local_Extsream_data'] -Force -ErrorAction Continue
      
    Log -Level 'INFO' -Message("Move file "+ $config['Local_CCM_linksFile'] +" to " + $config[''] )
    Move-Item -path $config['Local_CCM_linksFile'] -Destination ($config[''] + "\" + (Get-Date -Format "yyyyMMdd_hhmm") + "_SDFC.CSV") -Force -ErrorAction Continue
      
    
    # 4- Do transfert 2 : Transfert lot2 (xxx.CSV vers /InputCapture)
    Log -Level 'INFO' -Message ("Transfert lot2 (xxx.CSV vers /InputCapture)")
    $csvList = Get-ChildItem -Path ($config['Local_SCAN_links'] + "\*.csv")
    foreach ($item in $csvList) {
       Log -Level 'INFO' -Message("Put " +  $item.fullname + " to SFTP " + ($config['SFTP_SCAN_links'] + "/" + $item.name))
       Get-SFTPFile -SessionId $SFTPSession.SessionID -LocalPath $item.fullname -RemoteFile ($config['SFTP_SCAN_links'] + "/" + $item.name) -Overwrite
    }

    Log -Level 'INFO' -Message("Copy file "+ ($config['Local_SCAN_links']+"\*.csv") + " to " + $config['Local_NIP_Archive'])
    Copy-Item -path ($config['Local_SCAN_links']+"\*.csv") -Destination  $config['Local_SCAN_links_backup'] -Force -ErrorAction Continue
    Remove-Item -path ($config['Local_SCAN_links']+"\*.csv")

    # 5- Standard exit
    # Close SFTP session
    Log -Level "INFO" -message ("Close SFTP session #" + $SFTPSession.SessionId)
    Remove-SFTPSession -SessionId $SFTP_Session.SessionID | Out-Null
    Log -Level 'INFO' -Message $SEP_L1

    Stop-Log
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}

