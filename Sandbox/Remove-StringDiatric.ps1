Param (
    [Parameter(Mandatory=$True)][String]$str
)


Import-Module libEncoding    
"Remove String Diatric ---------------------------------------------------------------------------"
$str_processed = Remove-StringDiacritic($str)
$str_processed
"-------------------------------------------------------------------------------------------------"

