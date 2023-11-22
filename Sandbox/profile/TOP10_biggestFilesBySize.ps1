function Get-Top10BigestFiles {
 param(
    [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )
    ]
    [alias('p')] $path,       
    
    [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 1
        )
    ]
    [alias('f')] $filter,
    
    [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 2
        )
    ]
    [alias('r')] 
    [switch]$recurse,
    
    [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 2
        )
    ]
    [alias('l')] 
    [int]$limit
  )

  if (-not $path) {
    $path = "."
  }

  if (-not $filter) {
    $filter = '*.*'
  }
   if (-not $limit) {
    $limit = 10
   }

  if ($recurse) {
        $fileList = (Get-ChildItem -Path $path -Filter $filter -recurse | Sort-Object Length -Desc | Select-Object -First $limit)
    } else {
        $fileList = (Get-ChildItem -Path $path -Filter $filter | Sort-Object Length -Desc | Select-Object -First $limit)
    }

   $fileList | Select-Object Name,Length,Mode,LastWriteTime
}

Get-Top10BigestFiles
