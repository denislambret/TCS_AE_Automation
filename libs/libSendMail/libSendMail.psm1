
    #..................................................................................................................................
    # Function : Send-TCSMail
    #..................................................................................................................................
    # Input    : $source, $dest, $recurse
    # Output   : false / true
    #..................................................................................................................................
    # Send an email in TCS environment
    #..................................................................................................................................
    function Send-TCSMail {    
        param(
            [Parameter(Mandatory=$True)][String]  $subject,
            [Parameter(Mandatory=$False)][String] $body,
            [Parameter(Mandatory=$True)][String]  $to,
            [Parameter(Mandatory=$True)][String]  $from,
            [Parameter(Mandatory=$False)][String] $cc
        )

        $from = "automation@tcs.ch"
        $tokenSec = New-Object System.Security.SecureString
        $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NTAUTHORITY\ANONYMOUSLOGON",$tokenSec
        try {
            send-mailmessage -to $to -cc $cc -from $from -subject $subject -body $body -smtpServer mail.tcsgroup.ch -credential $creds | Out-Null    
        }
        catch {
            # Error then return KO
            return $false
        }
        
        # If email send ok
        return $true
    }
   

    #..................................................................................................................................
    # Function : Send-Mail
    #..................................................................................................................................
    # Input    : $source, $dest, $recurse
    # Output   : false / true
    #..................................................................................................................................
    # Synopsis
    #..................................................................................................................................
    function Send-EzMail {    
        param(
            [Parameter(Mandatory=$True)][String]  $subject,
            [Parameter(Mandatory=$False)][String] $body,
            [Parameter(Mandatory=$True)][String]  $to,
            [Parameter(Mandatory=$False)][String] $cc
        )

        # Create a mailmessage object and attach to/from/subject/body
        $message = New-Object System.Net.Mail.MailMessage
        $message.subject = $subject
        $message.body = $body
        $message.to.add($to)
        $message.cc.add($cc)
        $message.from.add($conf.sendmail.SMTP_Sender)
        
        # Create a net connection object to SMTP server
        
        $smtp = New-Object System.Net.Mail.SmtpClient($conf.sendmail.SMTP_Server, $conf.sendmail.SMTP_Port);
        $smtp.EnableSSL = $true
        $smtp.Credentials = New-Object System.Net.NetworkCredential($conf.sendmail.SMTP_User, $conf.sendmail.SMTP_pwd);
        
        try {
            $smtp.send($message)
        }
        catch {
            $error
            return $False
        }

        return $True
    }

# Load global conf
$conf = Get-Content $global:global_conf | ConvertFrom-Json
Export-ModuleMember -Function Send-EzMail, Send-TCSMail