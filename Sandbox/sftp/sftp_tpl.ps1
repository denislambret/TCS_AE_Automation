# Define Server Name
$ComputerName = "HOST ADDRESS"

# Define UserName
$UserName = "USERNAME"

#Define the Private Key file path
$KeyFile = "PATH TO KEYFILE\KEYFILE NAME (OPENSSH FORMAT)"

#Defines to not popup requesting for a password
$nopasswd = new-object System.Security.SecureString

#Set Credetials to connect to server
$Credential = New-Object System.Management.Automation.PSCredential ($UserName, $nopasswd)

# Set local file path and SFTP path
$LocalPath = "E:\ftproot\LocalUser\USERNAME\In"
$SftpPath = 'In/'

# Establish the SFTP connection
$SFTPSession = New-SFTPSession -ComputerName $ComputerName -Credential $Credential -KeyFile $KeyFile

# lists directory files into variable
$FilePath = Get-SFTPChildItem -sessionID $SFTPSession.SessionID -path $SftpPath

#For each file listed in the directory below copies the files to the local directory and then deletes them from the SFTP one at a time looped until all files
#have been copied and deleted
ForEach ($LocalFile in $FilePath)
{
    
#Ignores '.' (current directory) and '..' (parent directory) to only look at files within the current directory
    if($LocalFile.name -eq "." -Or $LocalFile.name -eq ".." )
    {
          Write-Host "Files Ignored!"
    }
    else
    {
        Write-Host $LocalFile
        Get-SFTPFile -SessionId $SFTPSession.SessionID -LocalPath $LocalPath -RemoteFile $localfile.fullname -Overwrite


        Remove-SFTPItem -SessionId $SFTPSession.SessionID -Path $localfile.fullname -Force
    }   
    

}

#Terminates the SFTP session on the server
Remove-SFTPSession -SessionId $SFTPSession.SessionID