$ports = 80,443,5801,5803,5804,8013
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -in $ports } |
    Select-Object LocalAddress,LocalPort,OwningProcess,@{Name='Process';Expression={
        try { (Get-Process -Id $_.OwningProcess -ErrorAction Stop).ProcessName } catch { '?' }
    }} |
    Sort-Object LocalPort |
    Format-Table -AutoSize
