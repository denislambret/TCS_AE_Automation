$Env:PSModulePath = $Env:PSModulePath+";Y:\03_DEV\06_GITHUB\tcs-1\libs"
Import-Module libLog

if (-not (Start-Log -path "Y:\03_DEV\06_GITHUB\tcs-1\logs" -Script $MyInvocation.MyCommand.Name)) { exit 1 }
$rc = Set-DefaultLogLevel -Level "INFO"
$rc = Set-MinLogLevel -Level "FATAL"
Log -Level "DEBUG" -Message "Hello There!"
Log -Level "INFO" -Message "I m feeling terrible this morning."
Log -Level "WARNING" -Message "Hey... no one listen to me? I feel terrible"
Log -Level "ERROR" -Message "Feel terribly lonely..."
Log -Level "FATAL" -Message "And gonna die at some time..."
if (-not (Stop-Log)) { exit 1 }
exit 0