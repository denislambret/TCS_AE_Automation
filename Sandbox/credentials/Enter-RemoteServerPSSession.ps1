$catalog = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"

function Enter-RemoteServerPSSession {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("server","ComputerName")]
        [ValidateNotNullOrEmpty()]
        [string]$srv
    )
    if (Test-Path $catalog) {
        [xml]$srvList = Get-Content $catalog
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