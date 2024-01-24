#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Move-SFTPFile.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20240119
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS

    

    .DESCRIPTION
    
    
    
    .PARAMETER FirstParameter
        

    .PARAMETER SecondParameter
        Description of each of the parameters.

    .INPUTS
        Description of objects that can be piped to the script.

    .OUTPUTS
        Return code 0 - Script successsfully executed
        Return code 1 - Script in error

    .EXAMPLE
        Move-FileCompta.ps1 

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

    #>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ]
    [alias('conf','c')] $config_path,
    
   
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)
    ] $delay,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)
    ]
    [ValidateSet('second', 'minute', 'hour', 'day')]
     $unit,
   
    
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
    
	$lib_path         = $env:PWSH_SCRIPTS_LIBS
    $Env:PSModulePath = $Env:PSModulePath + ";" + $lib_path
	
	# Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog
    Import-Module Posh-SSH -force

    
    #Set-EnvRoot
    $script_path      = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Sandbox\sftp"
    if (-not $config_path) { $config_path      = $script_path + "\" + ($MyInvocation.MyCommand.Name -replace 'ps1','')+ 'conf'}
    
    # Log initialization
    if (-not (Start-Log -path 'C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\logs' -Script $MyInvocation.MyCommand.Name)) { 
        "FATAL : Log initializzation failed!"
        exit $EXIT_KO
    }
    
    # Set log default and minum level for logging (ideally DEBUG when having trouble)
    Set-DefaultLogLevel -Level "INFO"
    Set-MinLogLevel -Level "DEBUG"
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Includes
        
        .DESCRIPTION
            Include necessary libraries
    #>
   
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                          G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables 
    #>
    $VERSION      = "0.1"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = ""

    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Do something usefull for you..."
        " "
        "Options : "
        "-conf     Configuration file"
        "-unit     Filter period unit"
        "-delay    Filter period value"
        "-Help     Display command help"
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
    
   

    #$delay = '01.01.2023'
    
    # 1 - Load script config file
    try {
        [XML]$conf = Get-Content $config_path
        $confRoot = $conf.conf
    }
    catch [System.IO.FileNotFoundException] {
        Log -Level "ERROR" -Message ("Configuration file not found " + $config_path)
        Log -Level "ERROR" -Message ("Process aborted! " + $config_path)
        Clean-TemporaryDirectory
        Stop-Log | Out-Null
        exit $EXIT_KO
    }
    
     # Process command line + Display inline help if required
     if ($help) { helper }
    # 1 - Get connected to SFTP
    $sec_pwd        = $confRoot.sftp_servers.sftp_server.userpwd | ConvertTo-SecureString -AsPlainText -Force
    $credential     = New-Object System.Management.Automation.PSCredential($confRoot.sftp_servers.sftp_server.username, $sec_pwd ) 
    try {
    	$sftpSession = New-SFTPSession -ComputerName $confRoot.sftp_servers.sftp_server.computername -Credential $credential -KeyFile $confRoot.sftp_servers.sftp_server.privKey -AcceptKey
    }
    catch {
        Log -Level 'ERROR' -Message "An error occurred while connecting to SFTP server."
        Log -Level 'ERROR' -Message($_)
        Log -Level 'ERROR' -Message($_.ScriptStackTrace)
        exit $EXIT_KO
    }
    
    # 2 - Get file source list
    $srcFileList = Get-SFTPChildItem -SFTPSession $sftpSession -path $confRoot.sftp_servers.sftp_server.sftp_input_path
    Log -Level 'INFO' -message('Count ' + ($srcFileList).Count + ' item(s) on SFTP source')
    

    # 3 - Filter source list
    # Date and name filtering
    Log -Level 'INFO' -message 'Sorting and filtering SFTP file list'
    $srcFileList = $srcFileList | ?{
        $_.LastWriteTime -gt $delay `
        -and ($_.name -match ".*")
    } 
    Log -Level 'INFO' -message('Count ' + ($srcFileList).Count + ' item(s) electable for copy to ' + $confRoot.pathes.local_path )
    
    if (($srcFileList).Count -eq 0) {
        Log -Level 'INFO' -message 'There nothing left to do...'
        Log -Level 'INFO' -message $SEP_L1
        Stop-Log | Out-Null
        exit $EXIT_OK
    }

    # 4 - Download source file to dest + rename original
    Log -Level 'INFO' -message $SEP_L2
    $srcFileList | %{
        try {
            Log -Level 'INFO' -message ("Copy "+ $_.FullName + " to " + $confRoot.pathes.local_path)
            Get-SFTPItem -SFTPSession $sftpSession -path $_.FullName -destination $confRoot.pathes.local_path -ErrorAction SilentlyContinue
            Log -Level 'INFO' -message ("Rename source to " + ($_.name + '.downloaded'))
            
        } catch {
            Log -Level 'ERROR' -Message "An error occurred while copy/rename files :"
            Log -Level 'ERROR' -Message($_)
            Log -Level 'ERROR' -Message($_.ScriptStackTrace)
            Log -Level 'INFO' -message $SEP_L1
            (get-sftpsession | Select-object SessionId) | remove-sftpsession
            Stop-Log | Out-Null
            exit $EXIT_KO
        }
        
        try {
            Remove-SFTPFile -SFTPSEssion $sftpSession -path $_.FullName -NewName ($_.name + '.downloaded')
        } catch {
            
        }
    }
     

    # 5 - Close connexion
    Remove-SFTPSession -SFTPSEssion $sftpSession | Out-Null
    
    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}






