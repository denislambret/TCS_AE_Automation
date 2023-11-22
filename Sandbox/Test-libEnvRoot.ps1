Remove-Module libEnvRoot_ext
Import-Module libEnvRoot_ext
Import-Module libConstants

$SEP_L1
($MyInvocation.MyCommand.Name -replace 'ps1','') + " Unitary tests validator "
$SEP_L1
"001 - Get root path     -> " + (Get-RootPath)
"002 - Test root path    -> " + (Test-RootPath)
"003 - Set root path     -> " + (Set-RootPath)
"004 - Get root path     -> " + (Get-RootPath)
"005 - Remove root path  -> " + (Remove-RootPath)
"006 - Set root path     -> " + (Set-RootPath)
"007 - Get root path     -> " + (Get-RootPath)
"008 - Set environment   -> " + (Set-EnvRoot)
"009 - Get environment   -> " + (Get-EnvRoot)
$envvar = Set-EnvRoot
"010 - Load envvar       -> " + $envvar


"011 - Count item        -> " + ($envvar).count
"012 - Display keys      -> " + ($envvar).keys
"012 - Display scr root  -> " + $EnvVar['scriptroot']
"013 - Test environment  -> " + (Test-EnvRoot)
"014 - Get environment   -> " + (Get-EnvRoot)
$SEP_L1

