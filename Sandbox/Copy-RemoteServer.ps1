Import-Module Posh-SSH

function Get-ServerCrendentials {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=2)]         
        [Alias("usr")]
        [ValidateNotNullOrEmpty()]
        [string]$user,

        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=3)]         
        [Alias("password")]
        [ValidateNotNullOrEmpty()]
        [string]$plainTextPwd,

        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("server","ComputerName")]
        [ValidateNotNullOrEmpty()]
        [string]$srv
    )
    
    $catalog = $DEFAULT_CONF_PATH + "\servers_catalog.xml"
	$srv = $srv.ToUpper()
    if (Test-Path $catalog) {
        [xml]$srvList = Get-Content $catalog
        if (($srvList.servers.server.alias -contains $srv) -or ($srvList.servers.server.ComputerName -contains $srv)) {
            $node = $srvList.SelectSingleNode("/servers/server[@alias='$srv']")
            if ($node -eq $null) {
                $node = $srvList.SelectSingleNode("/servers/server[@ComputerName='$srv']")
            }
            # $node | Select-Object group, alias, name, user

            # Create credentials for remote connection
            [securestring]$securePassword = ConvertTo-SecureString -String $node.pwd -AsPlainText -Force
            [pscredential]$cred = New-Object System.Management.Automation.PSCredential($node.user, $securePassword) 
            return $cred
        }
    } else {
        "Catalog not found... Please check servers_catalog.xml is in /conf."
    }
    return $null
}

function Get-ServerDefinition {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("server","ComputerName")]
        [ValidateNotNullOrEmpty()]
        [string]$srv
    )
    
    $catalog = $DEFAULT_CONF_PATH + "\servers_catalog.xml"
    $srv = $srv.ToUpper()
	if (Test-Path $catalog) {
        [xml]$srvList = Get-Content $catalog
        if (($srvList.servers.server.alias -contains $srv) -or ($srvList.servers.server.ComputerName -contains $srv)) {
            $node = $srvList.SelectSingleNode("/servers/server[@alias='$srv']")
            if ($node -eq $null) {
                $node = $srvList.SelectSingleNode("/servers/server[@ComputerName='$srv']")
            }
            return $node
        }
        "Server not found"
        return $null
    } else {
        "Catalog not found... Please check servers_catalog.xml is in /conf."
        return $null
    }
}

function Enter-RemoteServerPSSession {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("server","ComputerName")]
        [ValidateNotNullOrEmpty()]
        [string]$srv
    )
    
        
        $catalog = $DEFAULT_CONF_PATH + "servers_catalog.xml"
        $srv = $srv.ToUpper()
		if (Test-Path $catalog) {
            [xml]$srvList = Get-Content "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
            if (($srvList.servers.server.alias -contains $srv) -or ($srvList.servers.server.ComputerName -contains $srv)) {
                $node = $srvList.SelectSingleNode("/servers/server[@alias='$srv']")
                if ($node -eq $null) {
                    $node = $srvList.SelectSingleNode("/servers/server[@ComputerName='$srv']")
                }
                if ($node -eq $null) {
                    "Server " + $srv + " not found in catalog...."
                    return $null
                }

                $cred = Get-ServerCrendentials -ComputerName $node.ComputerName
                $srvDef = Get-ServerDefinition -ComputerName $node.ComputerName 
                "Set remote session on " + $srvDef.ComputerName
                try {
                    Enter-PSSession -ComputerName $srvDef.ComputerName -Credential $cred
                }
                catch {
                    return $null
                }
            }
        } else {
            "Catalog not found... Please check servers_catalog.xml is in /conf."
            return $null
        }
}

$cred = Get-ServerCrendentials -server obdev
$srv = (Get-ServerDefinition -server obdev).ComputerName
$session = New-PSSession -ComputerName $srv -Credential $cred

try {
   copy-item  D:\Scripts\data\input\test.txt -Destination 'd:\work' -ToSession $session 
}
catch {
   $error
}

Remove-PSSession -Session $session 
