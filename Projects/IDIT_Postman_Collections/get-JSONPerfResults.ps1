param(
    [Parameter(Mandatory=$true, 
    ValueFromPipeline=$false, 
    Position=1)]         
    [Alias("input", "i", "path")]
    [ValidateNotNullOrEmpty()]
    [string]$inputFile
)

if (-not (Test-Path $inputFile)) {
    "Error - source file path "+ $inputFile +" does not exist" 
}

#$inputFile = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects\IDIT_Postman_Collections\IDIT - DIRECT VS MOEX Performances.postman_test_run.json"
$listRoot =  (Get-Content $inputFile | convertFrom-Json)

# Get Postman Run generic information
$list = ($listRoot).results
$startedAt = $listRoot.startedAt;

# Header CSV
Write-Host "id;name;t1;t2;t3;t4;t5;t6;t7;t8;t9;t10;t moyen"

# Data CSV
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
    Write-Host  $record 
}