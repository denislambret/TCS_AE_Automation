$dir_root = "D:\dev\70_Vbox\Vagrant" 
$dir_list = ("dummy","db","dev")

foreach ($item in $dir_List) {
    $vm_path = $dir_root + "\" +  $item
    Push-Location
        "Running " + $item + "..."
        Set-Location $vm_path
        Invoke-Command -Scriptblock {vagrant up}
    Pop-Location
}