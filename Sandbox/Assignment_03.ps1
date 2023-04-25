$files_list = Get-ChildItem -Path "D:\dev\40_PowerShell\tcs\data\input\testfolder" 

$maxEllectibleDelay = 365 * 5

# Initialize output and set CSV header
"Name, EmployeeID, Eligibility" | Set-Content -Path "./employee_eligibility_status.csv"

# Read files list
$files_list | ForEach-Object { 
    # split each fields
    ($name, $id, [string]($date)) = ($PSItem).Name -split "_"
    
    # format and type values extracted
    $ext = [System.IO.Path]::GetExtension($PSItem)
    $date = $date -replace $ext, ''
    $isEmployee = if ($ext -match '.emp') {$true} else {$false}
    
    $date = [System.datetime]::ParseExact($date, 'yyyy-MM-dd', $null)
    $date
 
    # Compute date difference between today and hire date
    $diff = (New-TimeSpan -Start $date -End (Get-Date)).Days
    $isOldEnough = if ($diff -ge $maxEllectibleDelay) {$true} else {$false}
    
    # Check if electible 
    $electible = if ($isEmployee -and $isOldEnough) {'yes'} else {'no'}
    

    # Create record and append to output
    $record = $name + ',' + $id + ',' + $electible
    $record
    $record | Add-Content -Path "./employee_eligibility_status.csv"
}