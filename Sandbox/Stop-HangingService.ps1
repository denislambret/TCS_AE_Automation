function Stop-HangingService {
    <#
    .Synopsis
        Stops a hanging service
    .DESCRIPTION
        Stops a single service on a single computer if the service status is Starting or Stopping.
        These are transient states that a service should not be in for more than a few seconds,
        and they are a good indicator that a service may be hanging. If the service is in a running
        or stopped state, you are informed and no further action is taken
    .PARAMETER NAME
        One or more services. The service name(s) is needed, not the Display Name(s)
    .PARAMETER COMPUTERNAME
        One or more computers on which the hanging service(s) should be stopped
    .EXAMPLE
        Stop-HangingService -Name BITS
        Stops the service BITS (if it is in a hanging state) on the local computer
    .EXAMPLE
        Stop-HangingService -Name Wuauserv -ComputerName Srv1,Srv2 -Verbose
        Stops the hanging Windows Update service on the computers Srv1 and Srv2
    .EXAMPLE
        (Get-ADComputer -SearchBase $SqlServersOu -filter *).Name | Stop-HangingService -Name SQLAgent
        Stops the hanging service SQLAgent on all the computers in the specified OU
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0,HelpMessage = "Name of the service you're trying to stop")][string[]]$Name,
        [Parameter(ValueFromPipeline,Position = 1)][string[]]$ComputerName = $env:COMPUTERNAME
    )
    Begin {
        Write-Verbose "$(Get-Date -Format HH:mm:ss) BEGIN  : $($MyInvocation.MyCommand)"
        $StartTime = Get-Date
        #region Helper function, stops a single service on a single computer
        function Stop-SingleService {
        <#
        .Synopsis
            This is a helper function that stops a single service on a single computer. It is a helper
            function for Stop-HangingService
        #>
            [CmdletBinding()]
            Param(
            [Parameter(Mandatory,HelpMessage = "Name of the service you're trying to stop")][string]$Name,
            [Parameter()][string]$ComputerName = $env:COMPUTERNAME
            )
            try {
                    Write-Verbose "$(Get-Date -Format HH:mm:ss) PROCESS: Retrieve status of service $Name on $($ComputerName.ToUpper())"
                    $Service = Get-Service -Name $Name -ComputerName $ComputerName -ErrorAction Stop
                } #try
            catch {
                Write-Verbose "$(Get-Date -Format HH:mm:ss) PROCESS: The service $Name could not be found on $($ComputerName.ToUpper())"
                return
            } #catch
            if ($Service.Status -like "*Stopping*" -or $Service.Status -like "*Starting*") {
                Write-Verbose "$(Get-Date -Format HH:mm:ss) PROCESS: Get Process ID for service $Name"           
                $Process = (Get-CimInstance -ComputerName $ComputerName -ClassName Win32_Service -filter "name = '$Name'")
                Write-Verbose "$(Get-Date -Format HH:mm:ss) PROCESS: Stopping process ID $($Process.ProcessId) for service $Name on $($ComputerName.ToUpper())"
                Invoke-Command -ComputerName $ComputerName -ScriptBlock {Stop-Process -Id $using:Process.ProcessId -Force}
            }
            else {
                Write-Verbose "$(Get-Date -Format HH:mm:ss) PROCESS: The service $Name is not hanging on $($ComputerName.ToUpper())"
            }
        }
        #endregion Helper function
    } #Begin
    Process {
        foreach ($c in $ComputerName) {
            foreach ($n in $Name) {
            
                Stop-SingleService -ComputerName $c -Name $n
            }
        }
    } #Process
    End {
        $EndTime = Get-Date
        Write-Verbose "$(Get-Date -Format HH:mm:ss) FINISH : $($MyInvocation.MyCommand). The operation completed in $(New-TimeSpan -Start $StartTime -End $EndTime )"
        
    }
} #function Stop-HangingService 