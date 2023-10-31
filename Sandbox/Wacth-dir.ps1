New-FileSystemWatcher -SourceIdentifier "MyEvent" -Path C:\Tempfile
Register-EngineEvent -SourceIdentifier "MyEvent" -Action { $event | ConvertTo-Json | Write-Host }
Get-FileSystemWatcher

$run = $true
While ($run) {

}
# to dispose all 
Get-FileSystemWatcher | Remove-FileSystemWatcher