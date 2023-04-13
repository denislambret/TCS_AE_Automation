
$list = (netsh.exe wlan show profiles)
$list -match ":"

Measure-Command { $list=(netsh.exe wlan show profiles) -match ':'; For ($x=1; $x -lt $list.count; $x++) { $_ } }