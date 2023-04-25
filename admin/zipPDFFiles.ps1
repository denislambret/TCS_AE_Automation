#----------------------------------------------------------------------------------------------------------------------------------
# Script  : zipAllPdf.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : Denis Lambret
# Date    : 29.01.2022
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
# Command parameters
#----------------------------------------------------------------------------------------------------------------------------------
# Zip all PDF files from a source directory and copy archive to destination
#----------------------------------------------------------------------------------------------------------------------------------
# Synopsys
#----------------------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                               C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(Mandatory)][string] $source,
    [Parameter(Mandatory)][string] $dest,
    [switch] $recurse,
    [switch] $remove,
    [bool] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#  Sript setup
#----------------------------------------------------------------------------------------------------------------------------------
BEGIN {
    Import-Module Logging    
    $my_script        = $MyInvocation.MyCommand.Name
    $log_file         = $MyInvocation.MyCommand.Name -replace '.ps1','.log'
    $log_path         = split-path $MyInvocation.MyCommand.Path 
    $log_fullname     = $log_path + "\" + (Get-Date -Format "yyyyMMdd_") + "_" + $log_file
    
    Add-LoggingTarget -Name Console -Configuration @{
        Level         = 'INFO'             
        Format        = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}][%{level}] %{message}'
        ColorMapping  = @{
            'DEBUG'   = 'Blue'
            'INFO'    = 'Green'
            'WARNING' = 'Yellow'
            'ERROR'   = 'Red'
        }
    }
    
    Add-LoggingTarget -Name File -Configuration @{
        Path          = $log_fullname
        Level         = 'DEBUG'             
        Format        = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}][%{level}] %{message}'
        Append        = $true    
        Encoding      = 'ascii'               
    }
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                         I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    $VERSION = "0.1"
    # AUTHOR  = "Denis Lambret"
    $SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
    # SEP_L2  = '......................................................................................................................'
  
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                             M A I N
    #----------------------------------------------------------------------------------------------------------------------------------
    Write-Log -Level 'INFO' -Message $SEP_L1
    Write-Log -Level 'INFO' -Message "{0} - Ver {1} " -arguments $my_script,$VERSION
    Write-Log -Level 'INFO' -Message $SEP_L1
    
    Write-Log -Level 'DEBUG' -Message 'Test source and dest path....'
    if (-not (Test-Path $source)) {
        Write-Log -Level 'WARNING' -Message 'Source : {0} not found !' -Arguments $source
        exit $true
    }
    if (-not (Test-Path (Split-Path $dest))) {
        Write-Log -Level 'WARNING' -Message 'Dest   : {0} not found !' -Arguments $dest
        exit $true
    }

    $list = Get-ChildItem $source -Filter "*.pdf"
    if (-not $list) {
        Write-Log -Level 'INFO' -Message "No file to process... Bye!"
        Write-Log -Level 'INFO' -Message $SEP_L1
        exit $false
    }
    
    Write-Log -Level 'INFO' -Message "{0} file(s) identified for archiving" -arguments $list.Count
    $zip_file = $dest + "\" + (Get-Date -Format "yyyyMMdd_") + ($my_script -replace ".ps1",".zip")

    Write-Log -Level 'DEBUG' -Message "Run Compress cmdlet... -Path {0} -DestinationPath {1}" -Arguments $list, $zipFile
    $error.clear()
    try {
            Compress-Archive -Path $list -DestinationPath  $zip_file -ErrorAction Continue -Force | Out-Null
        }
        catch {
            Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
            exit 
        }
    Write-Log -Level 'INFO' -Message "Archive created -> {0} created" -Arguments  $zip_file
    
    if ($remove) {
        try {
            foreach ($source_file in $list) {
                Remove-Item -Path $source_file -ErrorAction Continue                                                                                 
                Write-Log -Level 'DEBUG' -Message "{0} file removed" -Arguments $source_file
            }
        }
        catch {
            Write-Log -Level 'ERROR' -Message "{0}" -Arguments $error[0].exception.gettype().fullname 
            exit 
        }
        Write-Log -Level 'INFO' -Message "{0} source file(s) removed successfully." -Arguments ($list).Count
    }
    Write-Log -Level 'INFO' -Message $SEP_L1
    exit 
    #----------------------------------------------------------------------------------------------------------------------------------
}