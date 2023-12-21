param(
    [Parameter(Mandatory=$true, 
    ValueFromPipeline=$false, 
    Position=1)]         
    [Alias("input", "i", "path")]
    [ValidateNotNullOrEmpty()]
    [string]$inputFile,

    [Parameter(Mandatory=$false, 
    ValueFromPipeline=$false, 
    Position=2)]         
    [Alias("output", "o", "destination")]
    [ValidateNotNullOrEmpty()]
    [string]$outputFile
)

# Splash scr
$SEP = "-" * 142
$SEP
"Get-JsonPerfResults "
$SEP

# Test parameteres
if (-not (Test-Path $inputFile)) { "Error - source file path "+ $inputFile +" does not exist"}
if (-not $outputFile) { $outputFile = $inputFile -replace '\.json$', '.csv'}

# Build content list from JSON
$listRoot =  (Get-Content $inputFile | convertFrom-Json)

# Get Postman Run generic information
$list = ($listRoot).results
$startedAt = $listRoot.startedAt;

# Header CSV
Write-Host "id;name;t1;t2;t3;t4;t5;t6;t7;t8;t9;t10;t moyen"

# Data CSV
$outList = @()
foreach ($item in $list) {
    #Write-Host $startedAt';'$item.id';'$item.name';' -noNewLine
    $str = ""
    $totalTime = 0
    $countItem = 0
    $record = $startedAt.toString()+';'+$item.id+';'+$item.name+';'

    foreach ($result in $item.times) {
        $str = $str + $result.toString()+';'
        $totalTime = $totalTime+ $result
        $countItem++
    }
    $record = $record + ';' + $str +  ($totalTime / $countItem)
    $outList = $outlist + $record
}
$outList = $outList | ConvertTo-Csv -UseCulture -NoTypeInformation -Delimiter ";"
$outList | format-table -AutoSize

# Export CSV
$SEP
"Export to "+$outputFile
$outList | Export-Csv -path $outputFile
$SEP