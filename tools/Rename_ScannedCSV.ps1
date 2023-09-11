Param(
        $path,
        $filter,
        [switch] $recurse,
        [switch] $remove
)

PROCESS { 
    function Rename-Log {
        Param(
            [Parameter(Mandatory=$false)][string] $path,
            [Parameter(Mandatory=$false)][string] $filter
        )

        $files_list = Get-ChildItem -Path $path -Filter $filter | Sort-Object -Property LastWriteTime -Descending
        $count_copy = 0
        foreach ($item in $files_list) {
            $rc = $item.name | select-string -Pattern "(\d{2})_(\d{2})_(\d{4})__(\d{2})_(\d{2})_(\d{2})" -AllMatches
            if ($rc) {
                $year = $rc.Matches[0].Groups[3].Value
                $month = $rc.Matches[0].Groups[2].Value
                $day = $rc.Matches[0].Groups[1].Value 
                $hour = $rc.Matches[0].Groups[4].Value
                $min = $rc.Matches[0].Groups[5].Value
                $sec = $rc.Matches[0].Groups[6].Value

                $new_file_name = $item.directoryname + "\" + $year + $month + $day + "_" + $hour + $min + $sec + "_Scanning.csv"
                "Move item " + $item.FullName + " to " + $new_file_name
                Move-Item -path $item.FullName -Destination $new_file_name 
                $count_copy += 1
            }
        }
        "Total filed moved :" + $count_copy + " file(s)"
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