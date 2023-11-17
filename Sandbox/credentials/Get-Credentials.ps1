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
    
    $catalog = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
    if (Test-Path $catalog) {
        [xml]$srvList = Get-Content "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
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

    
    $catalog = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
    if (Test-Path $catalog) {
        [xml]$srvList = Get-Content "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
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

$cred = Get-ServerCrendentials -ComputerName obdev
$cred | ft
$node = Get-ServerDefinition -ComputerName obdev
$node | ft


