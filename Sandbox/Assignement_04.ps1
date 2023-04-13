$source = "D:\dev\40_PowerShell\tcs\data\input\Random.txt"
$target =  "D:\dev\40_PowerShell\tcs\data\input\Random_sorted.txt"
# Get a key to search
$key = [string](Read-Host "Enter key to search ")

# Search it and count occurences - Display counter or leave a key not found message
$occurence = Select-String -path $source -AllMatches -Pattern $key
$count = ($occurence).Count
if ($count-gt 0) {"number of occurence(s) found : " + $count} else {"Key not found in input file !"}

# Display all lines from source file
$line_counter = 0
Get-Content $source | foreach-object { 
    $line_counter += 1
    "Line " + $line_counter + " : " + $_
}


# Display only even lines
$line_counter = 0
Get-Content $source | foreach-object { 
    $line_counter += 1
    if (($line_counter % 2) -ne 1) {"Line " + $line_counter + " : " + $_}
}

# Sort all the lines and write into another file using a single PowerShell statement
Get-Content $source | Sort-Object | out-file $target