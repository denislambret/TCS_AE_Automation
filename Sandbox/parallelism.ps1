$list_file = ".\test.list"
$output_path = "D:\dev\40_PowerShell\tcs\data\output"
$MaxThreads = 4
$split_max_item = 1000
$count_batch = 0


$list_content = Get-Content -Path $list_file
$batch_name = "batch_" + $count_batch.tostring().PadLeft(3,"0") + ".dat"


function Compute-Batch {
    param(
        $path
    )
    
    $content = Import-CSV -Path $path -Delimiter ";" -header @("id","filename")
    foreach ($item in $content) {
        Add-Content -path $content.filename -value $content
    }
    return $True
}

"Generating content..."
foreach ($item in $list_content) {
    $count_line +=1
    if (-not ($count_line % $split_max_item)) {
        $count_batch += 1
        $batch_name = $output_path + "\batch_" + $count_batch.tostring().PadLeft(3,"0") + ".dat"
    }
    Add-Content -Path $batch_name -value $item
}

"Total Line processed     : " + $count_line + " line(s)"
"Total batch(es) created  : " + $count_batch + " file(s)"

$batch_list = Get-ChildItem -Path ($output_path + "\*.dat")



#Remove all jobs
Get-Job | Remove-Job

#Start the jobs. Max 4 jobs running simultaneously.
foreach($item in $batch_list){
    While ($(Get-Job -state running).count -ge $MaxThreads){
        Start-Sleep -Milliseconds 3
    }
    "start job..."
    Start-Job -Scriptblock { 
                $content = Import-CSV -Path $args[0] -Delimiter ";" -header @("id","filename")
                foreach ($line in $content) {
                    Add-Content -path ($output_path + "\" + $content.filename) -value $line
                } 
    } -ArgumentList $item
}

# Wait for all jobs to finish.
While ($(Get-Job -State Running).count -gt 0){
    start-sleep 1
}

# Get information from each job.
foreach($job in Get-Job){
     $info = Receive-Job -Id ($job.Id)
}

#Remove all jobs created.
Get-Job | Remove-Job
