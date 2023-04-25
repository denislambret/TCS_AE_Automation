$ModulePath = "D:\dev\40_PowerShell\tcs\libs"
$Path = (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment").PSModulePath
$NewPath = "$ModulePath" + ";" + $Path
 
If($Path -notlike "*$ModulePath*") {
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment" -Name PSModulePath -Type String -Value "$NewPath"
}