try {
   Get-Content "toto.tst" -ErrorAction continue
} 
catch [System.IO.IOException] {
    write-host  $($_.exception.message)
    write-host "stop here"
}
catch {
    $($_.exception.message)
    write-host "stop here"

}
Write-host "Here"
