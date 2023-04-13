function convert_1252_UTF8
{
    param(
        [String]$Path,
        [Parameter(Mandatory = $False)][System.Text.Encoding]$DefaultEncoding = [System.Text.Encoding]::ASCII
    )

    Foreach ($item in $list) 
    {
        foreach ($text_input in (get-content $item.FullName)) 
        {
            $enc  = [System.Text.Encoding]::GetEncoding(1252).GetBytes($text_input)
            $text_output = [System.Text.Encoding]::UTF8.GetString($enc)
            Write-host $text1    
        }
    }
}