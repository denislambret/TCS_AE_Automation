
$obj = @{}
$p = "D:\dev\40_PowerShell\PowerShell\data\input"

$pdfList = gci -filter "*.pdf" -path $p

foreach ($item in $pdfList) {
    $fields = $item -split "_"
    $obj.add('name',$fields[0])
    $obj.add('index',$fields[1])
    $list.add($obj)
    $obj = ""
}
