$source = "D:\dev\40_PowerShell\PowerShell\data\input"
1..100 | % {
        $idx =  ([string]$_).PadLeft(4,'0')
        copy-Item "$source\TPL.pdf" "$source\TestPDF_$idx.pdf"
    }