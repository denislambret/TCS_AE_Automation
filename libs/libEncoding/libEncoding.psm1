
#..................................................................................................................................
# Function : ConvertTo-UTF8
#..................................................................................................................................
# Input    : $path
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Convert file content into UTF8
#..................................................................................................................................
function ConvertTo-UTF8
{
    Param (
        [Parameter(Mandatory=$True)][String]$Path
    )
    
    if (Test-Path $Path) { 
        $content = Get-Content -Path $Path 
        Set-Content -Path $Path -Value $content -Encoding UTF8 -Force
    } else { return $False }
}


#..................................................................................................................................
# Function : Get-FileEncoding 
#..................................................................................................................................
# Input    : $path
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Get file encoding information
#..................................................................................................................................
function Get-FileEncoding 
{
    [CmdletBinding()]
    param (
        [Alias("PSPath")]
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$Path
        ,
        [Parameter(Mandatory = $False)]
        [System.Text.Encoding]$DefaultEncoding = [System.Text.Encoding]::ASCII
    )
    
    process {
        $bom = Get-Content -Encoding $DefaultEncoding -ReadCount 4 -TotalCount 4 -Path $Path
        
        $encoding_found = $false
        
        foreach ($encoding in [System.Text.Encoding]::GetEncodings().GetEncoding()) {
            $preamble = $encoding.GetPreamble()
            if ($preamble) {
                foreach ($i in 0..$preamble.Length) {
                    if ($preamble[$i] -ne $bom[$i]) {
                        break
                    } elseif ($i -eq $preable.Length) {
                        $encoding_found = $encoding
                    }
                }
            }
        }
        
        if (!$encoding_found) {
            $encoding_found = $DefaultEncoding
        }
        return $encoding_found
    }
}

function Get-Encoding
{
  param
  (
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string]
    $Path
  )

    $bom = New-Object -TypeName System.Byte[](4)
        
    $file = New-Object System.IO.FileStream($Path, 'Open', 'Read')
    
    $null = $file.Read($bom,0,4)
    $file.Close()
    $file.Dispose()
    
    $enc = [Text.Encoding]::ASCII
    if ($bom[0] -eq 0x2b -and $bom[1] -eq 0x2f -and $bom[2] -eq 0x76) 
      { $enc =  [Text.Encoding]::UTF7 }
    if ($bom[0] -eq 0xff -and $bom[1] -eq 0xfe) 
      { $enc =  [Text.Encoding]::Unicode }
    if ($bom[0] -eq 0xfe -and $bom[1] -eq 0xff) 
      { $enc =  [Text.Encoding]::BigEndianUnicode }
    if ($bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xfe -and $bom[3] -eq 0xff) 
      { $enc =  [Text.Encoding]::UTF32}
    if ($bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf) 
      { $enc =  [Text.Encoding]::UTF8}
        
    [PSCustomObject]@{
      Encoding = $enc
      Path = $Path
    }
}


#..................................................................................................................................
# Function : is_UTF8
#..................................................................................................................................
# Input    : $path
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Return true if $path file is UTF8 encoded, false for any other values
#..................................................................................................................................
function is_UTF8
{
    param( 
        [Parameter(Mandatory=$True)][String]$Path
    )

    "PAth -> $Path"
    if ((Get-Encoding -path $Path).Encoding -Match "System.Text.UTF8Encoding") {
        return $true
    } else {
        return $false
    }
}

#..................................................................................................................................
# Function : Remove-StringDiacritic
#..................................................................................................................................
# Input    : $path
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# String translation of all accentuated characters in non accentuated equivalent, then save file with UTF8 encoding
#..................................................................................................................................
function Remove-StringDiacritic
{
    param
    (
        [ValidateNotNullOrEmpty()]
        [Alias('Text')]
        [System.String]$String,
        [System.Text.NormalizationForm]$NormalizationForm = "FormD"
    )
    
    BEGIN
    {
        $Normalized = $String.Normalize($NormalizationForm)
        $NewString = New-Object -TypeName System.Text.StringBuilder
        
    }
    PROCESS
    {
        $normalized.ToCharArray() | ForEach-Object -Process {
            if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($psitem) -ne [Globalization.UnicodeCategory]::NonSpacingMark)
            {
                [void]$NewString.Append($psitem)
            }
        }
    }
    END
    {
        return $($NewString -as [string])
    }
}

#..................................................................................................................................
# Function : Remove-FileDiatric()
#..................................................................................................................................
# Input    : $path
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# File translation of all accentuated characters in non accentuated equivalent, then save file with UTF8 encoding
#..................................................................................................................................

function Remove-FileDiatric
{
    param( 
        [Parameter(Mandatory=$True)][String]$Path
    )

    if (Test-Path -Path $path) {
        $content_processed = $null
        $content = Get-Content -Path $path
        $content
        foreach ($item in $content) {
            if ($item) {
                $str_processed = $(Remove-StringDiacritic($item))
                $content_processed += $str_processed + "`n"
            }
        }
        $content_processed
        Set-Content -Path $path -Value $content_processed -Encoding UTF8 -Force    
        return $True
    } else 
    { 
        return $False
    }
}

Export-ModuleMember -Function Get-FileEncoding, Get-Encoding, ConvertTo-UTF8, is_UTF8, Remove-StringDiacritic, Remove-FileDiatric
