$maxIter = 1024
$iter = 0
$list = $null
$output = "D:\dev\40_PowerShell\PowerShell\data\output\randomLst.txt"

Remove-Item $output -ErrorAction SilentlyContinue
New-Item $output | Out-Null

While ($iter -le $maxIter)
{
    $seed = Get-Random -Minimum 1 -Maximum 9999999
    $list = $list + ($seed.ToString()).padLeft(7,"0") + "," 
    $iter++
}
Add-Content $output -Value $list

$list = $null
$first = $true
foreach ($item in (Get-Content $output | Sort-Object | Get-Unique)) {
    if ($first) {
        $list = $item
        $first =$false
    }   else {
        $list = $list + "," + $item 
    }
}

Remove-Item $output 
New-Item $output | Out-Null
Add-Content $output -Value $list

(Get-Content $output).replace(",","`n") | Add-Content -Path $output -Value $list

$i = 0;Get-Content $output -ReadCount 100 | ForEach-Object {$i++; $outFile = "$output.$i"; $_ | Set-Content -Path $outFile}
