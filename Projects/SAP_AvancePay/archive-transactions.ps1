# Archive transaction
# List files matching a specific filter
# Create MD5 hashes signature for source files
# Create archive in dated sub-dir structure

$source = "Y:\03_DEV\06_GITHUB\tcs-1\data\input"
$filter = "*.txt"

if (test-path $source) {
    $lstFile = Get-ChildItem -path $source -Filter $filter
    $lstFile | %{
         $sigFile = $_.fullname -replace ".txt",".sig"
         $_ | Get-FileHash | out-file $sigFile
         $_.fullname + " - " + $sigFile
    }
}