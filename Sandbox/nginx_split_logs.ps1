# Work variables including calendar to convert text month in int month
$cal = @{ 
	"Jan" = 1;
	"Feb" = 2;
	"Mar" = 3;
	"Apr" = 4;
	"May" = 5;
	"Jun" = 6;
	"Jul" = 7;
	"Aug" = 8;
	"Sep" = 9;
	"Oct" = 10;
	"Nov" = 11;
	"Dec" = 12
}

# Error log split process
$log_path =  "D:\ManagementGateway\16.6\root\revproxy\logs"
$log_file = $log_path + "\error.log"
$bkp_log_file = $log_file + ".old"

# Backup current log. We are working on backup content. The file is reset to 0 just after copy
Copy-Item -Path $log_file -Destination $bkp_log_file
Remove-Item $log_file
New-Item $logFile

# Read file line by line 
# Foreach line search for date pattern in order to name children logs
# Tehn add content to children
get-Content $log_file -ReadCount 1| foreach-object {
    $rc = $_ | select-string -Pattern '^(\d{4})/(\d+)/(\d+)' -AllMatches
    if ($rc) {
        $output_log_file =  ".\" + ($rc.Matches[0].Groups[1].Value) + ($rc.Matches[0].Groups[2].Value) + ($rc.Matches[0].Groups[3].Value) + "_nginx_access.log"
    } 
    
    if (test-path $output_log_file) { 
        Add-Content -path $output_log_file -value $_ 
    } else {
        "Create new log file " + $output_log_file
        Set-Content -path $output_log_file -value $_
    }
}
# Access log split process
$log_file = $log_path + "\access.log"
$bkp_log_file = $log_file + ".old"

# Backup current log. We are working on backup content. The file is reset to 0 just after copy
Copy-Item -Path $log_file -Destination $bkp_log_file
Remove-Item $log_file
New-Item $logFile

# Read file line by line 
# Foreach line search for date pattern in order to name children logs
# Tehn add content to children
get-Content $bkp_log_file -ReadCount 1| foreach-object {
    $rc = $_ | select-string -Pattern '\[(\d{2})/(.+)/(\d+)\:' -AllMatches
    if ($rc) {
	    $rc.Matches[0].Groups[2].Value
	    $month = $cal[$rc.Matches[0].Groups[2].Value]
		$month = $month.toString().PadLeft(2,"0")
		$date = ($rc.Matches[0].Groups[3].Value) +  $month + ($rc.Matches[0].Groups[1].Value)
        $output_log_file =  ".\" + $date + "_nginx_access.log"
    } 
    
    if (test-path $output_log_file) { 
        "Add content to " + $output_log_file
		Add-Content -path $output_log_file -value $_ 
    } else {
        "Create new log file " + $output_log_file
        Set-Content -path $output_log_file -value $_
    }
}