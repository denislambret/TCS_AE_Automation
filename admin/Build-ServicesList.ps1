# Build Services List
# Skeleton / Demonstrator - to document
[CmdletBinding()]
param (
    [Parameter(Mandatory)][String]$filter,
    [Parameter(Mandatory)][String]$output,
    [Parameter()][Switch]$Append
)

if ($Append) { 
    $count = Get-Content $output | Select-Object -Last 1 | ConvertFrom-Csv | select Rank 
} else { 
    $counter = 1 
}

$list = @()
$headers = ("rank", "name", "description", "defaultStatus", "retry", "delay")
$services_list = Get-Service $filter -ErrorAction SilentlyContinue | Sort-Object Name

$csv_list = $services_list | ForEach-Object {
    if ($PSItem.StartType -in @("Manual", "Disabled")) { $startType = "Stopped" }
    if ($PSItem.StartType -eq "Automatic") { $startType = "Running" }

    $myItem = New-Object -TypeName PSObject 
    $myItem | Add-Member -NotePropertyName "rank" -NotePropertyValue $counter
    $myItem | Add-Member -NotePropertyName "name" -NotePropertyValue $PSItem.Name
    $myItem | Add-Member -NotePropertyName "description" -NotePropertyValue $PSItem.DisplayName
    $myItem | Add-Member -NotePropertyName "defaultStatus" -NotePropertyValue $StartType
    $myItem | Add-Member -NotePropertyName "retry" -NotePropertyValue 3
    $myItem | Add-Member -NotePropertyName "delay" -NotePropertyValue 1
    $counter = $counter + 1
    $myItem | Select-Object rank, name, description, defaultStatus, retry, delay
    $PSItem = $myItem
}


if ($Append) {
    $csv_list | ConvertTo-Csv -Delimiter ';' -NoTypeInformation -QuoteFields name, description, defaultstatus | Select-Object -Skip 1 | Out-File $output -Append
} else {
    $csv_list | ConvertTo-Csv -Delimiter ';' -NoTypeInformation -QuoteFields name, description, defaultstatus | Out-File $output
}

$csv_list | Format-Table -AutoSize
"Services dumped in csv -> " + ($csv_list).Count + " records"
"Total services actually in csv -> " + ((Get-Content -Path $output).Count-1) + " records"

