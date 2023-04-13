#----------------------------------------------------------------------------------------------------------------------------------
# Module  : libSFTP
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230323
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Implements POSH-SSH abstraction layer for SFTP communication

    .DESCRIPTION
        Implements all basic function to manage SFTP transfert with a remote server.
        
        Windows Powershell module that leverages a custom version of the SSH.NET Library to provide basic SSH functionality 
        in Powershell. The main purpose of the module is to facilitate automating actions against one or multiple SSH enabled 
        Linux servers from a Windows Host. As of version 3.x the module can be used in Linux and Mac OS using .Net Standard. 

    .FUNCTIONALITY
        Functions description list
   
    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

#>
#----------------------------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------------------------
#                                                   I N C L U D E S 
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Inlude POSH-SSH as master library.
#>
Import-Module libEnvRoot
Import-Module libConstants
Import-Module libLog
Import-Module Posh-SSH

#----------------------------------------------------------------------------------------------------------------------------------
#                                            G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Global variables
    
    .DESCRIPTION
        
#>

#----------------------------------------------------------------------------------------------------------------------------------
#                                                  F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------

#..................................................................................................................................
# Function : Get-SFTPSaferPayFiles()
#..................................................................................................................................
#  - Connect to SFTP 
#  - Retrieve Saferpay files for a given date
#..................................................................................................................................
function Get-SFTPConfig {
    param(
        [Alias('path')][string] $config_path
    );

    try {
        [XML]$conf = Get-Content $config_path
        $conf = $conf.conf.sftp_server;
        return OK
    }
    catch [System.IO.FileNotFoundException] {
        return KO
    }
}

#..................................................................................................................................
# Function : Get-SFTPDefault()
#..................................................................................................................................
#  - Connect to SFTP 
#..................................................................................................................................
function Connect-SFTPDefault {
    
    # Initialize SFTP parameters for connection
    $passwd       = ConvertTo-SecureString $conf.conf.userpwd -AsPlainText -Force
    $credential   = New-Object System.Management.Automation.PSCredential($conf.conf.username,  $conf.conf.userpwd) 

    # Establish the SFTP connection
    $SFTPSession = New-SFTPSession -ComputerName $conf.computerName -Credential $credential 
    
    if ($err) {
        Write-Error -Message("Error creating SFTP session.")
        return -1;
    } else {
        return $SFTPSession
    }

}

#..................................................................................................................................
# Function : Connect-SFTPPrivKey()
#..................................................................................................................................
#  - Connect to SFTP 
#  - Retrieve Saferpay files for a given date
#..................................................................................................................................
function Connect-SFTPPrivKey {
    $nopasswd     = New-Object System.Security.SecureString # defines empty sec string to not popup dialog requesting for a password
    $credential   = New-Object System.Management.Automation.PSCredential($conf.conf.sftp_server.username,$nopasswd) #Set Credetials to connect to server

    # Establish the SFTP connection
   $SFTPSession = New-SFTPSession -ComputerName $conf.conf.sftp_server.computername -Credential $credential -KeyFile 'D:\Scripts\Projects\SAP_AvancePay\sftp_avance_pay_prod.openssh.ppk' -Debug

    if ($session.sessionID -lt 0) {
        Write-Error -Message("Error creating SFTP session.")
        return -1;
    } else {
        return $SFTPSession
    }
}

#..................................................................................................................................
# Function : Close-SFTP
#..................................................................................................................................
# Count total number of transaction in source XML camt file
#..................................................................................................................................
function Close-SFTP() {
    # Close session
    Remove-SFTPSession -SessionId$SFTPSession.SessionID | Out-Null
    
    # End normally SFTP routine.
    return $OK;
}

#..................................................................................................................................
# Function : Get-SFTPFiles($filter,$date)
#..................................................................................................................................
# Retrieve files from SFTP according a date
#..................................................................................................................................
function Test-SFTPFiles() {
    param(
        [Alias('path')][string] $source
    );

    # Get remote location
    $location = Get-SFTPLocation -SessionId $SFTPSession.SessionId 
    
    
    # lists directory files into variable
    $fileList = Get-SFTPChildItem -sessionID$SFTPSession.SessionID -path $source | where-object {$_.name -match '.csv$'}
    return $fileList
}

#..................................................................................................................................
# Function : Get-SFTPFiles($filter,$date)
#..................................................................................................................................
# Retrieve files from SFTP according a date
#..................................................................................................................................
function Get-SFTPFiles() {
    param(
        [string] $filter,
        [dateTime] $date
    );

    $sftp_source = '/advancePay/Success'
    
    
    # Get remote location
    $location = Get-SFTPLocation -SessionId$SFTPSession.SessionId 
    Write-Debug -message('SFTP current location : ' + $location)
    Write-Debug -message('Get SFTP location     : ' + $conf.conf.sftp_server.sftp_success_path)
    Write-Debug -message('Filtered on           : ' + $date.date)
    
    # Lists directory files into variable
    $fileList = Get-SFTPChildItem -sessionID$SFTPSession.SessionID -path $conf.conf.sftp_server.sftp_success_path `
                | where-object {$_.LastWriteTime.date -eq $date.date} `
                | Sort-Object -Property LastWriteTime -Descending

    # Download content(s) for counting
    if ($fileList) {
        $fileList | ForEach-Object {
            try {
                Get-SFTPFile -SessionId$SFTPSession.SessionID -RemoteFile ($conf.conf.sftp_server.sftp_success_path + '/' + $_.name) -localPath $conf.conf.pathes.local_path -overwrite
                #Get-SFTPItem -SessionId$SFTPSession.SessionID -path ($conf.conf.sftp_server.sftp_success_path + '/' + $_.name) -destination $conf.conf.pathes.local_path -Force
            }
            catch {
                Write-Error -Message('Error while downloading : ' + $error )
            }
        }
    }
    return $fileList
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                                E X P O R T E R S
#----------------------------------------------------------------------------------------------------------------------------------
Export-ModuleMember -Function  Test-SFTPFiles, Close-SFTP, Connect-SFTPPrivKey, Connect-SFTPDefault, Get-SFTPFiles, Get-SFTPConfig