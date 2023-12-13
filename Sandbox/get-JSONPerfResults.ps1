$inputFile = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\data\input\DIRMOEX_results.json"
$listRoot =  (Get-Content $inputFile | convertFrom-Json)
$list = ($listRoot).results
#$list | Select -ExpandProperty results  | select id, name, time, responseCode
$startedAt = $listRoot.startedAt;
Write-Host "id;name;t1;t2;t3;t4;t5;t6;t7;t8;t9;t moyen"

foreach ($item in $list) {
    Write-Host $startedAt";"$item.id';'$item.name';' -noNewLine
    $str = ""
    $totalTime = 0
    $countItem = 0
    Write-host $item.times
    foreach ($result in $item.times) {
        $str = $str + $result.toString()+';'
        $totalTime = $totalTime+ $result
        $countItem++
    }
    Write-host $str -NoNewline
    Write-Host  ($totalTime / $countItem)
}