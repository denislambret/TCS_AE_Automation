
    $keyStorePath = 'Y:\03_DEV\06_GITHUB\tcs-1\Projects\IDIT_CheckSaferPay'
    $keyFile      =  $keyStorePath + '\sftp_avance_pay_prod.openssh.ppk' # Define the Private Key file path
    $computerName = 'sftp.tcs.ch' # Define Server Name
    $userName     = 'sftp_avance_pay_prod' # Define UserName
    $passwd       = 'q21RCB902PDoGMSS'
    
    $nopasswd     = New-Object System.Security.SecureString # defines empty sec string to not popup dialog requesting for a password
    $credential   = New-Object System.Management.Automation.PSCredential ($userName, $nopasswd) #Set Credetials to connect to server
    $SFTPSession = New-SFTPSession -ComputerName $computerName -Credential $credential -KeyFile $keyFile