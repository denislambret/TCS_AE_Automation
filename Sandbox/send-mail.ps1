$from = "noreply@tcs.ch"
$subject = "TEST MAIL"
$recipients = @("denis.lambret@tcs.ch")
$body = "Test mail send by script"
$S = New-Object System.Security.SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NTAUTHORITY\ANONYMOUSLOGON",$S
$myAttachment = "Y:\03_DEV\01_Powershell\logs\20221012_124559_check-IDITPayments.log"
send-mailmessage -to $recipients -from $from -subject $subject -body $body -attachment $myAttachment -smtpServer mail.tcsgroup.ch -credential $creds | Out-Null
