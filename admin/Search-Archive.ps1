#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Search-Archive.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220402
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Search a text pattern in text files ZIP archives

    .DESCRIPTION
        Search a text pattern in text files ZIP archives. This tools intends to help search
        in archived log files. The search is a simple select-string on text pattern and fits
        only text files.

    .INPUTS
        Command line :
        -path       source ZIP files path
        -pattern    text pattern to find
        -filter     extension selection filter

    .OUTPUTS
        File name and lines list of where hits found

    .EXAMPLE
        Search-Archive -path ./Logs/Archives/2022/04 -pattern "Error"

    .LINK
        Links to further documentation.

    .NOTES
        None
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
    
    # Search files globber
    [Parameter(Mandatory = $true,
    ValueFromPipelineByPropertyName = $true,
    Position = 0)]
    $filter,

    # Search files globber
    [Parameter(Mandatory = $true,
    ValueFromPipelineByPropertyName = $true,
    Position = 0)]
    $pattern,
    
    # help switch
    [switch]
    $help
)



#--------------------------------------------------------------------------------------------------------------------------------------
#                                                 I N I T I A L I Z A T I O N
#--------------------------------------------------------------------------------------------------------------------------------------
<#
    .DESCRIPTION
        Setup logging facilities by defining log path and default levels.
        Create log instance
#>
BEGIN {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                   I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Includes
        
        .DESCRIPTION
            Include necessary libraries
    #>
    $Env:PSModulePath = $Env:PSModulePath+";G:\dev\20_GitHub\tcs\libs"
    $Env:PSModulePath = $Env:PSModulePath + ";" + $env:PWSH_SCRIPTS_LIBS
    $log_path = $env:PWSH_SCRIPTS_LOGS
    $tmp_path = $env:PWSH_SCRIPTS_TMP
    Import-Module libLog

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                     S E T U P  
    #----------------------------------------------------------------------------------------------------------------------------------
    if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
    $rc = Set-DefaultLogLevel -Level "INFO"
    $rc = Set-MinLogLevel -Level "DEBUG"
}

PROCESS {
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
    $SCRIPT_DATE = "2022-04-02"
    $SEP_L1  = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'
    $SEP_L2  = '...................................................................................................................................................................'
    $EXIT_OK = 0
    $EXIT_KO = 1
    
   
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
    
    # Script info
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION + (" (" + $SCRIPT_DATE + " / " + $AUTHOR + ")").PadLeft(140," "))
    Log -Level 'INFO' -Message $SEP_L1
    
    # 1 - create ZIP list from source path
    Log -Level "INFO" -Message ("Build zip list from " + $path)
    if (-not (Test-Path $path)) {
        log -Level "FATAL" -Message ("Source " + $Path + " directory does not exist. Abort!")
        Stop-Log
        exit $EXIT_KO
    }

    if (-not (Test-Path $tmp_path)) {
        New-item -Path $tmp_path -Type Directory -ErrorAction Break
    }
    
    $zip_list = Get-ChildItem -Path $path -Filter "*.zip" -Recurse 

    # 2 - Foreach item of zip list, extract all files
    $result_list = New-Object -TypeName 'System.Collections.ArrayList'
    Foreach ($item in $zip_list) {
        # 3 - Foreach files, search the request pattern with select string
        Log -Level "Info" -Message ("Searching in archive file " + $item.FullName)
        $rc = Expand-Archive -path $item.FullName -ErrorAction Inquire -DestinationPath $tmp_path
        $result = select-string $tmp_path\$filter -pattern $pattern
        $idx = $result_list.add($result)

        # 4 - Remove unzipped logs
        Remove-Item $tmp_path\*.* -Force
    }  

    # 5 - Display results
    log -Level Info -Message $SEP_L1 
    $result_list | Select-Object * | ConvertTo-Csv -Delimiter ":" | Out-Null
    #$result_list | Select-Object -ExpandProperty SyncRoot | Select-object -Property Path, LineNumber, Line | Format-Table

    Log -Level "INFO" -Message("Save hitlist as " + $MyInvocation.MyCommand.Name + ".csv")
    $CSV =  $result_list | Select-Object -ExpandProperty SyncRoot | Select-object -Property Path, LineNumber, Line | ConvertTo-Csv -Delimiter ";"
    Log -Level "INFO" -Message ("Matched items " + ($CSV).Count + " record(s)")
    $CSV | Out-File -path ($MyInvocation.MyCommand.Name + ".csv")
     
    # Standard exit
    log -Level "INFO" -Message $SEP_L1 
    Stop-Log
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}