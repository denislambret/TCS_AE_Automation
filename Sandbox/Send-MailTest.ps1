# Send a test email on a google account.
# Use  System.Net.Mail.MailMessa to create message enveloppe and content
# Use  System.Net.Mail.SmtpClient to ensure connection with SMTP server
# Use  System.Net.NetworkCredential to encrypt password and authentify through SMTP SSL
#
# Specific to GMAIL account -> Create & use App Passwords
# If you use 2-Step-Verification and get a "password incorrect" error when you sign in, you can try to use an App Password.
#
# 1. Go to your Google Account.
# 2. Select Security.
# 3. Under "Signing in to Google," select App Passwords. 
# At the bottom, choose Select app and choose the app you using and then Select device and choose the device you’re using and then Generate.
# Follow the instructions to enter the App Password. The App Password is the 16-character code in the yellow bar on your device.
# Tap Done.
# Tip: Most of the time, you’ll only have to enter an App Password once per app or device, so don’t worry about memorizing it.

# function send-mailTest {
#     param(
#         [Parameter(Mandatory=$True)][String] $subject,
#         [Parameter(Mandatory=$False)][String] $body,
#         [Parameter(Mandatory=$True)][String] $to,
#         [Parameter(Mandatory=$False)][String] $cc
#     )
#     # Create a mailmessage object and attach to/from/subject/body
#     $message = New-Object System.Net.Mail.MailMessage
#     $message.subject = $subject
#     $message.body = $body
#     $message.to.add($to)
#     $message.cc.add($cc)
#     $message.from($conf.sendmail.SMTP_Sender)

#     # Create a net connection object to SMTP server
#     $smtp = New-Object System.Net.Mail.SmtpClient($conf.sendmail.SMTP_Server, $conf.sendmail.SMTP_Port);
#     $smtp.EnableSSL = $true
#     $smtp.Credentials = New-Object System.Net.NetworkCredential($conf.sendmail.SMTP_User, $conf.sendmail.SMTP_pwd);
#     $smtp.send($message)
# }

# $conf = Get-Content "../libs/global.json" | ConvertFrom-Json
# "--------------------------------------------------------------------------------------------------------------"
# "Send-MailTest.ps1"
# "--------------------------------------------------------------------------------------------------------------"
# "Server   : " + $conf.sendmail.SMTP_Server
# "Port     : " + $conf.sendmail.SMTP_Port
# "User     : " + $conf.sendmail.SMTP_User
# "Password : " + $conf.sendmail.SMTP_Pwd
# "--------------------------------------------------------------------------------------------------------------"
# $from = "admin@mothership.ddns.net"
# $to = "denis.lambret@gmail.com"
# $cc = "denis.lambret@gmail.com"
# $subject = "-= Test SendMail =-"
# $body = @" 
# If you read this message this simply means everything is OK and you received your
# first email from a powershell script !

# Congrats
# There is nothing much to do except deleting this mail.

# The Author
# "@


# "Sending mail"
# # Create a mailmessage object and attach to/from/subject/body
# $message = New-Object System.Net.Mail.MailMessage
# $message.subject = $subject
# $message.body = $body
# $message.to.add($to)
# $message.cc.add($cc)
# $message.from = $from

# # Create a net connection object to SMTP server
# $smtp = New-Object System.Net.Mail.SmtpClient($conf.sendmail.SMTP_Server, $conf.sendmail.SMTP_Port);

# # Enable flag to support SSL connexion
# $smtp.EnableSSL = $true

# # Creadte credential object
# $smtp.Credentials = New-Object System.Net.NetworkCredential($conf.sendmail.SMTP_User, $conf.sendmail.SMTP_pwd);

# # Then send message
# $smtp.send($message)

Import-Module libEnvRoot
    
# Setup Environment root variables
Set-EnvRoot

Import-Module libSendMail

$to = "denis.lambret@gmail.com"
$cc = "denis.lambret@gmail.com"
$subject = "Test Send-EZMail"
$body = @" 

Congrats
There is nothing much to do except deleting this mail.

The Author
"@

"Send-EzMail -to $to -cc $to -subject $subject -body $body"
Send-EzMail -to $to -cc $to -subject "$subject" -body $body