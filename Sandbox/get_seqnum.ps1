# Get list of seq number from PDF list
$elected = get-childitem "P:\EXSTREAM\QA\Diffusion\OnBase\*.pdf" | foreach {$rc = $_.toString() | Select-string -pattern "(.?\d)_(\d{4,6})" -AllMatches; if ($rc) {$seq += $rc.Matches[0].Groups[2].Value+"`n"}}
$seq | set-content "Y:\03_DEV\06_GITHUB\tcs-1\Sandbox\tmplist.txt"
get-content P:\EXSTREAM\QA\Diffusion\OnBase\tmplist.txt  | sort | get-unique

