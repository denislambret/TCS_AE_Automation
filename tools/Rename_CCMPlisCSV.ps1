Param(
        [Parameter(Mandatory)][string] $path,
        [Parameter(Mandatory)][string] $filter,
        [switch] $recurse,
        [switch] $remove
)

PROCESS { 
    function Rename-Log {
        Param(
            [Parameter(Mandatory)][string] $path,
            [Parameter(Mandatory)][string] $filter
        )

        $files_list = Get-ChildItem -Path $path -Filter $filter | Sort-Object -Property LastWriteTime -Descending
        $count_copy = 0
        $count_total = 0
        foreach ($item in $files_list) {
            $count_total += 1
            $rc = $item.name | select-string -Pattern "SFDC_(\d{2}).(\d{2}).(\d{4})(_\w*)?.CSV" -AllMatches
            if ($rc) {
                $year = $rc.Matches[0].Groups[3].Value
                $month = $rc.Matches[0].Groups[2].Value
                $day = $rc.Matches[0].Groups[1].Value
                $last = "_" + $rc.Matches[0].Groups[4].Value
                
                $new_file_name = $item.directoryname + "\" + $year + $month + $day + "_SFDC_CCMPLIS" + $last + ".CSV" 
                "Move item " + $item.FullName + " to " + $new_file_name
                Move-Item -path $item.FullName -Destination $new_file_name 
                $count_copy += 1
            }
        }
        "Total filed scanned : " + $count_total + " file(s)"
        "Total filed moved   : " + $count_copy + " file(s)"
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
    if (-not $path) { $path = "\\fs_AppsData_ge3\Apps_Data$\ONBASE\PRD\DIFFUSION\Scanning\SAVE" }
    if (-not $filter) { $filter = "*.csv"}
    Rename-Log -path $path -Filter $filter
}