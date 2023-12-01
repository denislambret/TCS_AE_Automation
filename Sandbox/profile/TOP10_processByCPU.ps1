function Get-Top10processByCPU {
 param(
    [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 0
        )
    ]
    [alias('l')] 
    [int]$limit
  )

  if (-not $limit) {
    $limit = 10
  }

  Get-Process | Sort-Object CPU -Desc |
  Select-Object  ID,
                 Name,CPU,
                 @{n='VirtualMemory(MB)';e={'{0:N2}' –f ($PSItem.VM / 1MB) -as [Double] }},
                 @{n='PagedMemory(MB)';e={'{0:N2}' –f ($PSItem.PM / 1MB) -as [Double] }} -First $limit 
   
}

Get-Top10processByCPU | Format-Table -AutoSize
