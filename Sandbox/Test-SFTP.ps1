if (-not ($Env:PSModulePath -match ";Y:\03_DEV\06_GITHUB\tcs-1\libs;C:\Program Files\WindowsPowerShell\Modules")) { 
    $Env:PSModulePath = $Env:PSModulePath + ";Y:\03_DEV\06_GITHUB\tcs-1\libs;C:\Program Files\WindowsPowerShell\Modules"
}
Import-Module libSFTP
Get-SFTPConfig -path "Y:\03_DEV\06_GITHUB\tcs-1\libs\libSFTP\default.conf"
