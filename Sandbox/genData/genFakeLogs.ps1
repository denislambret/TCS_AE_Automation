param (
   [int]$iter,
   [parameter(Mandatory=$true)][string]$creationDate,
   [parameter(Mandatory=$true)][string]$dest,
   [switch]$randomDate,
   [switch]$help
)

$creationDate = [Datetime]::ParseExact($creationDate, 'yyyyMMdd', $null)

$countIter = 0
While ($countIter -le $iter) {
   $logFileName = $dest + "\Logfile_" + $countIter.ToString().PadLeft(4,"0") + ".log"
   Write-Host "Create file -> $logFileName"
   "Fake log file" | Set-Content -Path $logFileName -Force -ErrorAction Continue
   $newFile = Get-ChildItem -Path $logFileName
   $newFile.LastWriteTime = $creationDate
   $countIter += 1
}
