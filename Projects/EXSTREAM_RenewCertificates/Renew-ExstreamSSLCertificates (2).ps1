#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Renew-ExstreamSSLCertificates.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20221024
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Automate SSL certificates renewal process

    .NOTES
#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 0
        )] 
    [Alias("path")]
    $template,

    [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 1
        )] 
    [Alias("restore")]
    $rollback,

    
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
    Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog

    # Reset error var
    $error.Clear()

    # Log initialization
    if (-not (Start-Log -path $global:LogRoot -Script $MyInvocation.MyCommand.Name -noTranscript)) { 
        "FATAL : Log initializzation failed!"
        exit $EXIT_KO
    }
    Set-DefaultLogLevel -Level "INFO"
    Set-MinLogLevel -Level "DEBUG"
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                          G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables 
    #>
    $VERSION      = "1.0"
    $AUTHOR       = "DLA"
    $SCRIPT_DATE  = "20201024"

    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Renew-ExstreamSSLCertificates.ps1"
        $SEP1
        " "
        "Options : "
        "-Template  Template XML configuration file that will execute the renewal"
        "-Rollback  Rollback of a backup configuration set"
        "-Help      Display command help"
    }
   
    #..................................................................................................................................
    # Function : Create-FileBackup
    #..................................................................................................................................
    # Backup a configuration file from orugunal directory
    #..................................................................................................................................
   function Create-FileBackup {
        [CmdletBinding()]
        param (
            # Source file path to backup
            # Aliases: source
            [Parameter(Mandatory = $true)]
            [Alias("path")]
            [String]$source
        )

        # Run copy process of original file source
        try {
            
        }
        catch {
            {1:<#Do this if a terminating exception happens#>}
            return $KO
        }

        # Everything went well
        return $OK
    }

    #..................................................................................................................................
    # Function : Restore-FileBackup
    #..................................................................................................................................
    # Restore a backup configuration on original directory
    #..................................................................................................................................
   function Restore-FileBackup {
        [CmdletBinding()]
        param (
            # Restore a source file to a Destinationm path 
            # Aliases: dest
            [Parameter(Mandatory = $true)]
            [Alias("path")]
            [String]$source,

            [Parameter(Mandatory = $true)]
            [Alias("dest")]
            [String]$destination
        )        

        # Run copy process
        try {
            
        }
        catch {
            {1:<#Do this if a terminating exception happens#>}
            return $KO
        }
        
        # Everything went well
        return $OK
    }

    #..................................................................................................................................
    # Function : Renew-JCS
    #..................................................................................................................................
    # Renew Java Store Certificate
    #..................................................................................................................................
   function Renew-JCS {
    [CmdletBinding()]
    param (
        # Restore a source file to a Destinationm path 
        # Aliases: dest
        [Parameter(Mandatory = $true)]
        [Alias("name")]
        [String]$certName,
        # Certificate file CER path 
        # Aliases: dest
        [Parameter(Mandatory = $true)]
        [Alias("path")]
        [String]$certSource,
    )        

    # 1 - List certificates in Java Certificate Store
    try {
        # keytool.exe -list -keystore "C:\Program Files\Java\jdk-11.0.2\lib\security\cacerts"    
    }
    catch {
        {1:<#Do this if a terminating exception happens#>}
        return $KO
    }
    
    # 2 - Delete certificate
	try {
        # keytool.exe -delete -alias "exstream2.tcsgroup.ch" -keystore "C:\Program Files\Java\jdk-11.0.2\lib\security\cacerts"    
    }
    catch {
        {1:<#Do this if a terminating exception happens#>}
        return $KO
    }

    # 3 - Add new certificate

    try {
        # keytool.exe -import -trustcacerts -keystore "C:\Program Files\Java\jdk-11.0.2\lib\security\cacerts" -file "D:\Install Exstream Empower\Certificat\exstream2.tcsgroup.ch.cer"     
    }
    catch {
        {1:<#Do this if a terminating exception happens#>}
        return $KO
    }

    # Everything went well
    return $OK
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
    if ($help) { helper }
    
    # If Do something here
    # 1 - Read template file (xml configuration)
    if (-not (Test-Path $template)) {
        Log -Level 'FATAL' -Message($template + ' does not exists !!!')
        Log -Level 'FATAL' -Message('Script aborted by fatal error. Please check your template file name')
        Stop-Log | Out-Null
        exit $EXIT_KO    
    }
    
    try {
        [XML]$conf = Get-Content -Path $template    
    }
    catch {
        Log -Level 'FATAL' -Message($error)
        Log -Level 'FATAL' -Message('Script aborted by fatal error. Please check your XML template file structure')
        Stop-Log | Out-Null
        exit $EXIT_KO    
    }
 
    # 2 - foreach configuration item, we process as follow 
    foreach ($item in $conf.root.configItem) {
        Log -Level 'INFO' -message $SEP_L2
        # 3 - Test if the item file exits and also associated certificate
        if (-not (Test-Path $item.path)) {
            Log -Level 'ERROR' -Message($item.path + ' file does not exist')
            Log -Level 'WARNING' -Message($item.name + ' is bypassed...')
            $error.clear()
            continue
        }

        if (-not (Test-Path $item.certificate.path)) {
            Log -Level 'ERROR' -Message($item.certificate.path + ' file does not exist')
            Log -Level 'WARNING' -Message($item.name + ' is bypassed...')
            $error.clear()
            continue
        }
        
        # 4 - Test if we deal with pfx or a jcs action
        
        # Copy certificate to destination path
    
        # 5 - Read source file and replace string
    }
    
    # 6- Update java certificate
    

    # Standard exit
    Log -Level 'INFO' -Message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}