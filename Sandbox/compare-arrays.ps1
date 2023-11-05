
# $a =  Get-Random  -Count 15000 -InputObject (1..999999)
# $b =  Get-Random  -Count 12000 -InputObject (1..999999)

# $na = ($a | Where-Object {$b -NotContains $_} | Sort ).Count
# $nb = ($b | Where-Object {$a -NotContains $_} | Sort ).Count
# $nc = ($a | Where-Object {$b -Contains $_} | Sort ).Count

# #$a
# "a size - " + ($a).Count

# #$b
# "b size - " + ($b).Count



# Write-Host $na "items are in a but not in b"
# Write-Host $nb "items are in b but not in a"
# Write-Host $nc "items in common between a and b"
$source_a = "D:\dev\40_PowerShell\tcs\data\input\testfolder\"
$source_b = "D:\dev\40_PowerShell\tcs\data\input\testfolder2\"
$sep = "........................................................................................................."

# Push-Location
# Set-Location $source_a
# 1..100 | ForEach-Object { $n = [System.IO.Path]::GetRandomFileName() | Set-Content }

# Set-Location $source_b
# 1..100 | ForEach-Object { $n = [System.IO.Path]::GetRandomFileName(); Set-Content -path $n}
# Pop-Location

$files_a = gci ($source_a + "*.*")
$files_b = gci ($source_b + "*.*")

$la = $files_a | Where-Object {$files_b.name -NotContains $_.name} | Sort 
$lb = $files_b | Where-Object {$files_a.name -NotContains $_.name} | Sort
$lc = $files_a | Where-Object {$files_b.name -Contains $_.name} | Sort 
$na = ($la).Count
$nb = ($lb).Count
$nc = ($lc).Count

#$files_a | ft -AutoSize -Property Name
$sep
"a size - " + ($files_a).Count + " items"

#$files_b | ft -AutoSize -Property Name
"b size - " + ($files_b).Count + " items"

$sep
Write-Host $na "items are in a but not in b"
$sep
$la | ft -AutoSize -Property Name

$sep
Write-Host $nb "items are in b but not in a"
$sep
$lb | ft -AutoSize -Property Name
" "
$sep

Write-Host $nc "items in common between a and b"
$sep
$lc | ft -AutoSize -Property Name
