
New-FileSystemWatcher -SourceIdentifier "myTemp" -path Y:\03_DEV\06_GITHUB\tcs-1\data\input\testfolder
Register-EngineEvent -SourceIdentifier "myTemp" -Action {$event | convertto-json | Write-host}
Suspend-FileSystemWatcher -SourceIdentifier "myTemp"
Get-EventSubscriber
Resume-FileSystemWatcher -SourceIdentifier "myTemp" 
Remove-FileSystemWatcher -SourceIdentifier "myTemp"