$source = "D:\dev\40_PowerShell\PowerShell\data\input"
1..10 | foreach-object {
        $idx =  ([string]$_).PadLeft(4,'0')
        copy-Item "$source\TPL.txt" "$source\TestTXT_$idx.txt"
    }