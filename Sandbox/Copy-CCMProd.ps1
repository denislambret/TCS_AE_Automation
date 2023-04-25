#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Copy_CCMProd.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220411
# Version : 0.1
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Copy PDF and CSV file from PROD import directory

    .DESCRIPTION
        Enable copy of PROD environment data associated to CCM Plis import process to multiple tests environment inclduing
              - DEV
              - QA
              - ACP

    .EXAMPLE
        Copy_CCMProd.ps1

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

    #>
#----------------------------------------------------------------------------------------------------------------------------------

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
    $rc = Set-MinLogLevel -Level "INFO"
}



PROCESS {
    function Set-CSVSample {
        param(
            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)] $path,
            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)] $nbExtract
        )
        # List all CSV
        $sources_csv  = Get-ChildItem -Path "$path\*.csv"

        # Foreach csv file, extract only the first x lines (x is defined by nbExtract parameters)
        foreach ($item in $sources_csv) {
            Log -Level 'INFO' -Message ('Sampling CSV index : ' + $item)
            $raw_csv = Get-Content -path $item.fullname
            $nb_records_csv = ($raw_csv).Count
            Log -Level 'DEBUG' -Message ('Total records found : ' + $nb_records_csv)
            $records_csv = $raw_csv | Select-Object -First $nbExtract
            $item_dest = ($item).BaseName + "_sample.csv"
            $item_dest = (Split-Path $item) + "\" + $item_dest 
            $records_csv | Out-File $item_Dest | Out-Null
            Log -Level 'DEBUG' -Message ('Create sample file : ' + $item_dest)      
        }
    }

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                            G L O B A L   V A R I A B L E S
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables 
    #>
    $VERSION = "0.1"
    $AUTHOR  = "DLA"
    $SCRIPT_DATE  = "2022.04.10"
    $SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
    $SEP_L2  = '......................................................................................................................'
    $EXIT_OK = 0
    $EXIT_KO = 1

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
    # Script infp
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION + (" (" + $SCRIPT_DATE + " / " + $AUTHOR + ")").PadLeft(95," "))
    Log -Level 'INFO' -Message $SEP_L1

    #----------------------------------------------------------------------------------------------------------------------------------
    # Copy Prod to DEV / QA / ACP
    # Start-Process powershell.exe -Credential $Credential -Verb RunAs -ArgumentList ("-file $args")
    $source    =  "Y:\03_DEV\02_OnBase\data"
    $zipRoot   =  "Y:\03_DEV\02_OnBase\data\zip"
    #$source    =  "\\fs_Appsdata_ge3\Apps_data$\EXSTREAM\PRD\Diffusion\ONBASE"
    #$zipRoot   =  "\\fs_Appsdata_ge3\Apps_data$\EXSTREAM\PRD\Diffusion\ONBASE\BACKUP"
    #$source    =  "\\fs_Appsdata_ge3\Apps_data$\EXSTREAM\DEV\Diffusion\ONBASE"
    #$zipRoot   =  "\\fs_Appsdata_ge3\Apps_data$\EXSTREAM\DEV\Diffusion\ONBASE\BACKUP"
    
    $zipName   = (Get-Date -Format "yyyy-MM-dd_hhmmss") + "_CCM_PLIS.ZIP"
    
    $destinationsList = @{
                "DEV" = "\\fs_Appsdata_ge3\Apps_data$\EXSTREAM\DEV\Diffusion\ONBASE"
                "QA"  = "\\fs_Appsdata_ge3\Apps_data$\EXSTREAM\QA\Diffusion\ONBASE"
                "ACP" = "\\fs_Appsdata_ge3\Apps_data$\EXSTREAM\ACP\Diffusion\ONBASE"
    }

    $header = @('filename','origin','direction','source','seq','seqNum','type','field1','field2','langue','ref','date')
    
    # Build transport archive file
    log -Level "INFO" -Message ("Building archive for source files found in " + $source)
    if (-not (Test-Path $zipRoot)) {
        New-Item $zipRoot -Type directory | Out-Null
    }
    
    # Build sample files
    Set-CSVSample -path $source -nbExtract 100
    

    # Build file list to archive 
    foreach ($item in (Get-ChildItem -Path ($source+"\*_sample.csv"))) {
        $content = Import-CSV -path $item -Delimiter ";" -header $header
        $pdfFileList = $content | Select-Object -Property Filename
        $sourceFileList =  @($sourceFileList;$pdfFileList)
    }
    $sourceFileList  = @($sourceFileList; @((Get-ChildItem -Path ($source+"\*_sample.csv")).Fullname))
    
    #$sourceFileList  = Get-ChildItem -Path ($source+"\*_sample.csv"), ($source + "\*.pdf")

    log -Level "INFO" -Message ("Create archive transport file " + ($zipRoot + "\" + $zipName))
    try {
        Compress-Archive $sourceFileList -DestinationPath ($zipRoot + "\" + $zipName) -CompressionLevel Optimal -Update   
    }
    catch {
        log -Level "ERROR" -Message ("Error while creating archive " + ($zipRoot + "\" + $zipName))
        log -Level "ERROR" -Message ($error)
        exit $EXIT_KO
    }
    

    # Dispatch a copy of archive file on each destinations
    foreach ($itemDestKey in $destinationsList.Keys) {
        log -Level "INFO" -Message ("Copy archive to " + $destinationsList[$itemDestKey])
        Copy-Item -path ($zipRoot + "\" + $zipName) -dest ($destinationsList[$itemDestKey] + "\" + $zipName)  -ErrorAction Continue

        # Expand archive on destination
        log -Level "INFO" -Message ("Expand archive to " + $destinationsList[$itemDestKey])
        Expand-Archive -path ($destinationsList[$itemDestKey] + "\" + $zipName)  -DestinationPath $destinationsList[$itemDestKey] -Force
        
        # Remove dest ZIP
        log -Level "INFO" -Message ("Remove destination ZIP " + ($destinationsList[$itemDestKey] + "\" + $zipName))
        Remove-Item -path ($destinationsList[$itemDestKey] + "\" + $zipName)
        # Transform file ref path in index files
        (Get-ChildItem -Path ($destinationsList[$itemDestKey] + "\*.csv")) | ForEach-Object {
            log -Level "INFO" -Message ("Replace references in indexes " + $_.fullname)
                (Get-Content  $_.fullname) -replace [RegEx]::Escape("\PRD\"),[RegEx]::Escape(("\" + $itemDestKey + "\")) | Set-Content $_.fullname
        }
    
    }

    # Remove source ZIP
    log -Level "INFO" -Message ("Remove source ZIP " + ($zipRoot + "\" + $zipName))
    Remove-Item -path ($zipRoot + "\" + $zipName)
    
    # Remove CSV Samples 
    Remove-Item -path ($source + "\*_sample.csv") 
    # Standard exit
    log -Level "INFO" -Message $SEP_L1
    log -Level "INFO" -Message("Total file processed : " + ($sourceFileList).Count + " file(s)")
    Stop-Log 
    exit $EXIT_OK
}
