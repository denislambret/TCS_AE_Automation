function autogenlog {
  param(
    [string]$name,
    [string]$date,
    [int]$delay
  )

  ($name ? 1 : ($name = "autogenLog"))| Out-Null
  ($date ? 1 : ($date = '{0:yyyy-MM-dd}' -f (Get-Date)))| Out-Null
  ($delay ? 1 : ($delay = 365))| Out-Null

  [datetime]$myDate = Get-Date $date
  
  $myDate = $myDate.AddDays(-1 * $delay)
  $count  = $delay
  
  while ($count) {
    $FileName =  ('{0:yyyyMMdd}' -f $myDate)+ "_" + $name + ".log"
    Add-Content $FileName -Value ("Test log - $FileName - Created on " + (Get-Date))
    $myDate = $myDate.AddDays(1)
    $count--
  }
}

function Remove-Log  {
  param(
    [string]$path,
    [int]$elderThan
  )

  if (Test-Path -Path $path) {
    (Get-ChildItem -path $path -Filter *.log) | Where-Object { $_.LastWriteTime -lt (get-date).AddDays(-1 * $elderThan) }| Remove-Item 
  }
}



# Parser simple pour VISECA ONE
# Faire dump transactions html sur fichier text en appliquant cleaning 
$content = gc .\transactions.txt

$count = 0
$max = 4
foreach ($line in $content) { 
    if ($count -eq $max) {
      $output
      Set-Content -path "./formated_transactions.txt" -value $output
      $count = 0
      $output = "" 
    }

    $output += $line + ";"
    $count++
}