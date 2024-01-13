Import-Module libWSIDITJobs
$config_path = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects\IDIT_BacthSchedulerTools\ACP.conf"
"-" * 80
"Establishing jobs list..."
$jobs = Get-BatchList -config_path $config_path 
if (-not $jobs) {
    "Abnormal termination !"
    exit 1
}
"-" * 80

#$jobsList = Get-BatchList -config_path $config_path -desc 'GL export' -status 'success'
"Total batch enumerated - " + ($jobs).Count + " job(s)"
"-" * 80
$jobs | Select-Object -First 1
"-" * 80
$id = 20815548

"job name   : " + ((Get-jobById -id $id).batchJobVO.desc)
"Status     : " + (Get-JobStatus -id $id)
"Is running : " + (isPendingJob -id $id)
"Is success : " + (isSuccessJob -id $id)
"Is failure : " + (isFailedJob -id $id)