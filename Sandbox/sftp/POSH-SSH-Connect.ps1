

#----------------------------------------------------------------------------------------------------------------------------------
#                                                 I N I T I A L I Z A T I O N
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .DESCRIPTION
        Setup logging facilities by defining log path and default levels.
        Create log instance
#>
BEGIN {
              $Env:PSModulePath = $Env:PSModulePath+";Y:\03_DEV\06_GITHUB\tcs-1\libs"
              $log_path = "Y:\03_DEV\06_GITHUB\tcs-1\logs"
              Import-Module libLog
              if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
              $rc = Set-DefaultLogLevel -Level "INFO"
              $rc = Set-MinLogLevel -Level "DEBUG"
}

PROCESS {     
              Import-Module Posh-SSH
              $root_dir = "Y:\03_DEV\06_GITHUB\tcs-1\Sandbox\sftp\keys"
              $ComputerName = "sftppub.tcs.ch" # Define Server Name
              $UserName     = "sftp_exstream" # Define UserName
              $KeyFile      =  $root_dir + "\sftp_exstream.priv.openssh.ppk" # Define the Private Key file path
              $nopasswd     = New-Object System.Security.SecureString # efines to not popup requesting for a password
              $Credential   = New-Object System.Management.Automation.PSCredential ($UserName, $nopasswd) #Set Credetials to connect to server

              # Set local file path and SFTP path
              $LocalPath = "Y:\03_DEV\06_GITHUB\tcs-1\data\output"
              $SftpPath = '/'

              # Establish the SFTP connection
              Log -Level "INFO" -message ("Connect to SFTP remote " + $ComputerName)
              $SFTPSession = New-SFTPSession -ComputerName $ComputerName -Credential $Credential -KeyFile $KeyFile
              Log -Level "INFO" -message ("Session ID " + $SFTPSessionom.SessionId)
              # Get remote location
              $location = Get-SFTPLocation -SessionId $SFTPSession.SessionId 
              Log -Level "INFO" -message ("Get SFTP location " + $location)
              
              # lists directory files into variable
              $FilePath = Get-SFTPChildItem -sessionID $SFTPSession.SessionID -path $SftpPath
              $FilePath

              # Close session
              Log -Level "INFO" -message ("Close SFTP session #" + $SFTPSession.SessionId)
              Remove-SFTPSession -SessionId $SFTPSession.SessionID | Out-Null
}
