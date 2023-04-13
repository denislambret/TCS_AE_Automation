clear
$source = "D:\dev\40_PowerShell\PowerShell"
$output_file  = ".\filelist.dat"
$id = "MyWatcher"

function doSomething {
        [CmdletBinding()] param(
            [parameter(ValueFromPipeline)] $item
        )
        $item | ConvertTo-Csv $output_file | Out-File -Append $output_file
        $item | ConvertTo-Json | Write-Host
}

#New-FileSystemWatcher  -SourceIdentifier $id -Path $source -Action { $event | doSomething }
New-FileSystemWatcher -SourceIdentifier $id -Path $source  -IncludeSubdirectories  -Filter *.txt -Action { $event | doSomething }
$evt_subscriber = Get-EventSubscriber 
$fs_watcher = Get-FileSystemWatcher

#Suspend-FileSystemWatcher -SourceIdentifier $id

#Remove-FileSystemWatcher -SourceIdentifier $id
 