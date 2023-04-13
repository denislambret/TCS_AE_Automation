
# connect and test script on remote server

$serverList = ("WGE3AS161D","WGE1AS056T") 
# ,"WGE1AS050T","WGE3AS164T","WGE1AS053T","WGE3AS165T")

foreach ($item in $serverList) {              
     "Attempt to connect to : " + $item
     
     # Setup security credential object
     try {
              # Define clear text string for username and password
              [string]$userName = 'LD06974'
              [string]$userPassword = '1234SamsungS10+'
              
              # Convert to SecureString
              [securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
              [pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword )         
     } 
     catch {

              "ERROR : " + $error[0].exception.gettype().fullname 
     }

     # Test remote server connexion
     try {
              Enter-PSSession $item -Credential $credObject
     }
     catch {
              "Attempt to connect to : " + $item + " - Connection failed." 
              continue
    }



    try {
              systeminfo | select-string "Statistics"
              Exit-PSession 
    }
    catch {
              "Remote action action failed!"
    }

}
