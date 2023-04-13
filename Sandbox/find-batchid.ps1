param(
    [string][Parameter(Mandatory)]$path,
    [string][Parameter(Mandatory=$false)]$pattern,
    [string]$ref
)

$count         = 0
$count_error   = 0
$count_ok      = 0

"----------------------------------------------------------------------------------------------------------------------------"
"find-BatchId"
"----------------------------------------------------------------------------------------------------------------------------"
if (-not (Test-Path $path)) {
    "Invalid source path!"
    exit 1
}

if ($ref) {
   $ref_list = Get-Content $ref
} else {
    $ref_list = $pattern
}

$dir_list      = get-childitem $path -Directory
$match_pattern = @()
$total_dir     = ($dir_list).Count
$count_ok = 0
$count_error = 0
$count_docs = 0

foreach ($item in $dir_list) {
    $count += 1
    "(" + $count + "/" + $total_dir + ") - Scanning source : " + $item
    foreach ($ref_item in $ref_list) {
        $rc = Select-String $item\*.csv -pattern "(.*)$ref_item(.*)" -AllMatches
        if ($rc) {
            $match_pattern += $rc.Matches[0].Groups[0].Value
        }
    }
}

"----------------------------------------------------------------------------------------------------------------------------"
#$match_pattern = Convertto-csv -inputobject $match_pattern -Delimiter ";" -NoTypeInformation
$tmp = ".\lst.tmp"
$headers = @('filename','origin','direction','source','seq','seqNum','type','field1','field2','langue','ref','date')
Set-Content $tmp -Value $match_pattern
$match_pattern = Import-CSV $tmp -Delimiter ';' -Header $headers
$count_docs = ($match_pattern).Count

"Now checking matching index file reference(s)..."
"----------------------------------------------------------------------------------------------------------------------------"
foreach ($item in $match_pattern) {
    "test existence for -> " + $item.filename
    if (-not (test-path $item.filename)) {
        "File not found " + $item.filename
        $count_error += 1
    } else {
        $count_ok += 1
    }
}

# Do stats
"----------------------------------------------------------------------------------------------------------------------------"
"Total docs   : " + $count_docs + " doc(s)"
"Total copied : " + $count_ok + " doc(s)"
"Total error  : " + $count_error + " doc(s)"
"----------------------------------------------------------------------------------------------------------------------------"
