#----------------------------------------------------------------------------------------------------------------------------------
# Script  : TPL_Transfert.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : Denis Lambret
# Date    : 29.01.2022
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
# 
#----------------------------------------------------------------------------------------------------------------------------------
# Synopsys
#----------------------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param(
    [bool] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#  Sript setup
#----------------------------------------------------------------------------------------------------------------------------------
BEGIN {

    Import-Module Logging    
    $log_level        = 'INFO'
    $my_script        = $MyInvocation.MyCommand.Name
    $log_file         = $MyInvocation.MyCommand.Name -replace '.ps1','.log'
    $log_path         = split-path $MyInvocation.MyCommand.Path 
    $log_fullname     = $log_path + "\" + (Get-Date -Format "yyyyMMdd") + "_" + $log_file
    
    Add-LoggingTarget -Name Console -Configuration @{
        Level         = $log_level             
        Format        = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}][%{level}] %{message}'
        ColorMapping  = @{
            'DEBUG'   = 'Gray'
            'INFO'    = 'Green'
            'WARNING' = 'Yellow'
            'ERROR'   = 'Red'
        }
    }
    
    Add-LoggingTarget -Name File -Configuration @{
        Path          = $log_fullname
        Level         = $log_level          
        Format        = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}][%{level}] %{message}'
        Append        = $true    
        Encoding      = 'ascii'               
    }
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                         I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    Import-Module Posh-SSH

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    $VERSION = "0.1"
    $AUTHOR  = "Denis Lambret"
    $SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
    $SEP_L2  = '......................................................................................................................'
    
    # Error codes
    #----------------------------------------------------------------------------------------------------------------------------------
    Set-Variable SCRIPT_SUCCESS         -Option Constant -Value 0
    Set-Variable COPY_ERROR             -Option Constant -Value 100
    Set-Variable MOVE_ERROR             -Option Constant -Value 101
    Set-Variable REMOVE_ERROR           -Option Constant -Value 102
    Set-Variable SFTP_CONNECT_ERROR     -Option Constant -Value 100
    Set-Variable SFTP_UPLOAD_ERROR      -Option Constant -Value 111
    Set-Variable SFTP_DOWNLOAD_ERROR    -Option Constant -Value 112
    
    # SFTP session vars
    #----------------------------------------------------------------------------------------------------------------------------------
    $SFTP_host  = "sftppub.tcs.ch"
    $SFTP_port  = "22"
    $SFTP_user  = "sftp_capgemini"
    $SFTP_pwd   = "cAP1sftP0"
    $SFTP_dest  = "/RECINT/Onbase/InputSFDC/DEV"
    $NIP_dest   = "\\fs_AppsData_ge3\Apps_Data$\EXSTREAM\QA166\NIP\Diffusion\archive"
    $SCAN_dest  = "\\fs_AppsData_ge3\Apps_Data$\ONBASE\QA\Diffusion\Scanning"
    $BKP_dest   = "\\fs_AppsData_ge3\Apps_Data$\ONBASE\QA\Diffusion\SAVE"
    $source     = "\\fs_AppsData_ge3\Apps_Data$\ONBASE\QA\Diffusion"

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                             M A I N
    #----------------------------------------------------------------------------------------------------------------------------------
    Write-Log -Level 'INFO' -Message $SEP_L1
    Write-Log -Level 'INFO' -Message "{0} - Ver {1} " -arguments $my_script,$VERSION
    Write-Log -Level 'INFO' -Message $SEP_L1
    
    # 1 - Build CSV list
    Write-Log -Level "INFO" -Message "Build CSV list from {0}" -Arguments $source
    $list_csv = Get-ChildItem -Path $source -Filter "*.csv"
    
    # 2 - Setup connection with SFTP target
    Write-Log -Level "INFO" -Message "Setup connection to SFTP ({0})" -Arguments $SFTP_host
    try {
        $SFTP_pwd = ConvertTo-SecureString $SFTP_pwd -AsPlainText -Force
        $creds = New-Object System.Management.Automation.PSCredential ($SFTP_user, $SFTP_pwd)
        $SFTP_session = New-SFTPSession -Computername $SFTP_host -credential $creds 
    }
    catch {
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error 
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
        exit $SFTP_CONNECT_ERROR
    }
    
    # 3 - Execute SFTP transfert
    Write-Log -Level "DEBUG" -Message "List CSV      : {0}" -Arguments $list_csv
    Write-Log -Level "DEBUG" -Message "SFTP Session #: {0}" -Arguments $SFTP_session.SessionId
    
    foreach ($item_file in $list_csv) {
        Write-Log -Level "INFO" -Message "SFTP UPLOAD - source:{0} dest:{1}" -Arguments ($source+"\"+$item_file), ($SFTP_dest)
        try {
            #Set-SFTPItem -SessionId ($SFTP_session).SessionId -path $source\$item_file -destination $SFTP_dest -Force    
        } 
        catch {
            Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error 
            Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
            exit $SFTP_UPLOAD_ERROR
        }    
    }
    
    # Close SFTPconnection
    Remove-SFTPSession -SessionId ($SFTP_session.SessionId) -ErrorAction SilentlyContinue | Out-Null
    Wait-Logging 

    # 4 - Copy source \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\SDFC.csv to \\fs_AppsData_ge3\Apps_Data$\EXSTREAM\<ENV>\NIP\Diffusion\archive\
    try {
            foreach ($item_file in $list_csv) {
                $item_tmp = $item_file.Name + ".tmp"
                Write-Log -Level "INFO" -Message "COPY ITEM - source:{0} dest:{1}" -Arguments ($source+"\" + $item_file), ($NIP_dest + "\" + $item_tmp)
                Copy-Item -Path $source\$item_file -Destination $NIP_dest\$item_tmp -Force -ErrorAction Continue 
                Write-Log -Level "INFO" -Message "MOVE ITEM - source:{0} dest:{1}" -Arguments ($NIP_dest + "/" + $item_tmp), ($NIP_dest + "\" + $item_file)
                Move-Item -Path $NIP_dest\$item_tmp -Destination $NIP_dest\$item_file -Force -ErrorAction Continue 
            }
    } 
    catch {
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error 
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
        exit $COPY_ERROR
    }
    
    # 5 - move source \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\*.csv to \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\SAVE\SFDC_%DATE%.CSV
    try {
        Write-Log -Level "INFO" -Message "COPY ITEM - source:{0} dest:{1}" -Arguments $source, $BKP_dest
        # TODO - Integrer la date dans le nom du fichier destination
        Copy-Item -Path $source\*.csv -Destination $BKP_dest -Force -ErrorAction Continue 
    } 
    catch {
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error 
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
        exit $MOVE_ERROR
    }

    # echo %date% - %time% -------------------------------------- 2-Transfert lot2 (xxx.CSV vers /InputCapture ----- >>%LOG%
    # %EXEC%\psftp sftp_capgemini@sftppub.tcs.ch -pw cAP1sftP0 -b %PARAM%\PSFTP_02.bat
    
    # 6 - Create a backup copy of CSV file(s) for scanning CSV
    try {
        Write-Log -Level "INFO" -Message "COPY ITEM - source:{0}\*.csv dest:{1}" -Arguments $SCAN_dest, ($SCAN_dest + "\SAVE")
        Copy-Item -Path $SCAN_dest\*.csv -Destination $SCAN_dest\SAVE -ErrorAction Continue
    }    
    catch {
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error 
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
        exit $COPY_ERROR
    }

    # 7 - Remove source CSV
    # Redudant code
    # del \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\Scanning\*.csv   >>%LOG%
    try {
        
        foreach ($item_csv in $(Get-ChildItem -path $SCAN_dest\*.csv))
        {
            Write-Log -Level "INFO" -Message "REMOVE ITEM - source:{0}\$item_csv" -Arguments $SCAN_dest
            Remove-Item $SCAN_dest\$item_csv -force -ErrorAction Continue
        }
        # SOURCE csv cleaning
        foreach ($item_csv in $list_csv) {
            Write-Log -Level "INFO" -Message "REMOVE ITEM - source:{0}\$item_csv" -Arguments $SCAN_dest
            Remove-Item $source\$item_csv
        } 
    } 
    catch {
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error 
        Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
        exit $REMOVE_ERROR
    }

    # 8 - Close SFTP connection and do cleaning
    Wait-Logging
    Remove-Variable *. -ErrorAction SilentlyContinue
    exit $SCRIPT_SUCCESS
    #----------------------------------------------------------------------------------------------------------------------------------
}