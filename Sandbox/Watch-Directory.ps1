$myWatcher = "myWatcher"
$source = "Y:\03_DEV\01_Powershell\data\Input\logs"

# Create a new directory watcher "MyWatcher"
"Create File System watcher..."
New-FileSystemWatcher -SourceIdentifier $myWatcher -Path $source -NotifyFilter LastWrite, Size -Filter *.log
Register-EngineEvent -SourceIdentifier $myWatcher -Action { $event | ConvertTo-Json | Write-Host }


# In case we want to suspend or resume our watcher
"Get watcher info..."
Get-FileSystemWatcher
"Suspend watcher..."
Suspend-FileSystemWatcher -SourceIdentifier $myWatcher

"Get watcher info..."
Get-FileSystemWatcher
"Resume watcher..."
resume-FileSystemWatcher -SourceIdentifier $myWatcher


# Clean dir watcher from PWSH (named or all)
"Remove named watcher..."
Remove-FileSystemWatcher -SourceIdentifier $myWatcher
"Remove all other watcher(s)..."
Get-FileSystemWatcher | Remove-FileSystemWatcher
