#--------------------------------------------------------------------------------------------------------------
# Name        : FTP_TC_SDFC_PRINT_STATUS_FILE.ps1
#--------------------------------------------------------------------------------------------------------------
# Author      : D.Lambret
# Date        : 05.11.2021
# Status      : DEV
# Version     : 1.0
#--------------------------------------------------------------------------------------------------------------
# Description : Move print status file from TC site to SDFC input directory
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Includes
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------------------------------------------------------
# Script variables
# $root_dir = "\\\\fs_UsersData_GE3\Users_Data_GE3$\LD06974\03_DEV\01_Powershell"
$root_dir = "C:\PSFTP\TC_TCS_PRD"
$bin_dir  = $root_dir + ""
$today    = get-date -format "yyyy_MM_dd"
$log_dir  = "\\fs_AppsData_ge3\Apps_Data$\EXSTREAM\PRD\Reception\PrintingStatus\Logs\"
#\\fs_AppsData_ge3\Apps_Data$\EXSTREAM\PRD\Reception\PrintingStatus\Logs\transfertTC_TCS_PRD.log

# FTP transfert variables
# -- FTP TC
$ftp_user = "TCST"
$ftp_password = "LZY-F?WcQ+r2"
$src_srv  = "ftp.tcgroup.ch"
$src_dir  = "/prod/out/"

# -- EXSTREAM Server
$dst_dir  = "\\fs_AppsData_ge3\Apps_Data$\EXSTREAM\PRD\Reception\PrintingStatus"
$dst_dir_NIS  = "\\fs_AppsData_ge3\Apps_Data$\EXSTREAM\PRD166\NIP\Diffusion\StatusPrintshop"
$pattern  = "*.xml"


# Counters
$countGetFiles       = 0
$countRemovedFiles   = 0
$countErrorTransfert = 0
$countErrorRemove    = 0

#--------------------------------------------------------------------------------------------------------------------------------------------
# Library    : liblog.ps1
#--------------------------------------------------------------------------------------------------------------------------------------------
# Description : Offer file log facilities for scripts
#--------------------------------------------------------------------------------------------------------------------------------------------
# Global variables
#--------------------------------------------------------------------------------------------------------------------------------------------
$default_level = ""
$default_path  = ""

function set_LogDefaultLevel {
    param([String]$dfLevel)
    $global:default_level = $dfLevel
}

function set_LogDefaultPath {   
    param([String]$dfPath)
    $global:default_path = $dfPath
}

function write_LogStatus {
    Write-Host "default path set to $default_path"
    Write-Host "default level set to $default_level"
}

function Write-Log { 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path=$global:default_path, 
        
        [Parameter(Mandatory=$false)] 
        [Alias('out')] 
        [switch]$oe, 

        [Parameter(Mandatory=$false)] 
        [Alias('in')] 
        [switch]$fi, 
        
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info","Debug")] 
        [string]$Level=$default_level, 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 

    Process 
    { 
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-host -Message "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." #-path $logScript
            Return $FALSE
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-host "Creating log path : $Path." #-path $logScript
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            'Debug' { 
                Write-Verbose $Message 
                $LevelText = 'DEBUG:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
    } 
}

#--------------------------------------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------------------------------------
# 1- Log setup + script init
# Build log name based on current date
$Env:PSModulePath = $Env:PSModulePath + ";C:\Program Files\WindowsPowerShell\Modules"
Import-Module Posh-SSH
Import-Module "$root_dir\liblog.ps1"

$log_file = "transfertTC_TCS_PRD_"+$today+".log"
set_LogDefaultLevel "Info"
set_LogDefaultPath "$log_dir\$log_file"

Write-Log -Level 'Info' -Message "-------------------------------------------------------------------------------------------------------"
Write-Log -Level 'Info' -Message "SFTP_TC_SDFC_STATUS_FILE.ps1"
Write-Log -Level 'Info' -Message "-------------------------------------------------------------------------------------------------------"

# 2- Set credentials for connection
Write-log -Level 'Info' -Message "-------------------------------------- 1-Copie des fichiers XML de TrendCommerce vers Reception\PrintingStatus ----------------------"

Write-Log -Level 'Info' -Message "Set credentials for ($ftp_user) to $src_srv"
$Passwd = ConvertTo-SecureString $ftp_password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($ftp_user, $Passwd)

# 3- Establish FTP connection
Write-Log -Level 'Info' -Message "Open FTP connection to $src_srv"
$session = New-SFTPSession -ComputerName $src_srv -Credential $Credential -Verbose -AcceptKey 
Write-Log -Level 'DEBUG' -Message("Session :" + ($session | fl))

if (-not $session) {
   Write-Log -Level 'Error' -Message "Connection refused !"
   exit
}
$sessionId = Get-SFTPSession -SessionId $session.sessionId
 

# 2- List files to move from TC to TCS/SDFC input directory
Write-Log -Level 'Info' -Message "Get remote directory XML files list..."
$list = Get-SFTPChildItem -Path $src_dir -index $sessionId.sessionId

# apply filter for 
if ($fi) {
    $list | Where-Object{(($_.name -match "*.F.Receipt.xml") -or ($_.name -match "*.I.Receipt.xml"))}
}

if ($oe) {
    $list | Where-Object {(($_.name -match "*.O.Receipt.xml") -or ($_.name -match "*.E.Receipt.xml"))}
}

# 3- Process to FTP transfert
foreach ($srcItem in $list) {
    $item_name = $srcItem.Name
    if ($item_name -Match ".xml$")
    {
        Write-Log -Level 'Info' -Message "GET remote item $src_dir/$item_name"
        Get-SFTPFile  -RemoteFile $src_dir/$item_name -LocalPath $dst_dir -SFTPSession $session -ErrorAction SilentlyContinue
		Get-SFTPFile  -RemoteFile $src_dir/$item_name -LocalPath $dst_dir_NIS -SFTPSession $session -ErrorAction SilentlyContinue
        if ($Error.Count -gt 0) {
        
            if ($error -match "File already present on local host")
            {  
               # Case where the file is already on target 
               # In this case, we can removed it directly
               Write-Log -Level 'Info' -Message "RM remote item $src_dir/Input/$item_name"
               Remove-SFTPItem -path $src_dir/$item_name -index $sessionId.sessionId -force -ErrorAction SilentlyContinue 
               $countRemovedFiles += 1
            }
            else {
               Write-Log -Level 'Error' -Message $error
               $countErrorTransfert +=1
               $Error.Clear() 
            }
        }
        else 
        {
            $countGetFiles += 1
            # 4- Remove transfered file
            Write-Log -Level 'Info' -Message "RM remote item $src_dir/Input/$item_name"
            Remove-SFTPItem -path $src_dir/$item_name -index $sessionId.sessionId -force -ErrorAction SilentlyContinue 
            if ($Error.Count -gt 0) {
                Write-Log -Level 'Error' -Message $Error 
                $countErrorRemove +=1
                $Error.Clear() 
            } 
            else {
                $countRemovedFiles += 1
            }
        }
    }
}



# 5- End script
 if (Remove-SFTPSession -sessionid $sessionId.sessionId) {
    Write-Log -Level 'Info' -Message 'Session removed...'
 }

Write-Log -Level 'Info' -Message "-------------------------------------------------------------------------------------------------------"
Write-Log -Level 'Info' -Message "File(s) transferred from TC FTP server : $countGetFiles"
Write-Log -Level 'Info' -Message "File(s) transfert from TC FTP in error : $countErrorTransfert"
Write-Log -Level 'Info' -Message "File(s) removed from TC FTP server     : $countRemovedFiles"
Write-Log -Level 'Info' -Message "File(s) removed from TC FTP in error   : $countErrorRemove"
Write-Log -Level 'Info' -Message "-------------------------------------------------------------------------------------------------------"

# Clean environment
Remove-Module * 
$error.Clear()
