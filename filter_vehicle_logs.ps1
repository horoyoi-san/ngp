# Filter vehicle-related logs from the server console
# Run this in a separate PowerShell window to see only vehicle interactions

$serverProcess = Get-Process | Where-Object { $_.ProcessName -like "*Ananta*" -and $_.MainWindowTitle -eq "" }

if ($null -eq $serverProcess) {
    Write-Host "No Ananta server process found. Make sure the server is running." -ForegroundColor Red
    exit
}

Write-Host "Monitoring vehicle logs for process $($serverProcess.Id)..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Monitor the server output (this assumes the server writes to stdout/stderr)
# Since we can't easily intercept the existing console, we'll suggest using the log file instead

$logFile = "c:\Ananta\AnantaTestGameServer  ka1.5 modular\latest.log"

if (Test-Path $logFile) {
    Write-Host "Watching log file: $logFile" -ForegroundColor Cyan
    
    Get-Content $logFile -Wait -Tail 0 | Where-Object {
        $_ -match "\[Vehicle\]" -or 
        $_ -match "AskVehicle" -or 
        $_ -match "AskPlayerStartEnterOrExitVehicle" -or
        $_ -match "AskPlayerFinishEnterOrExitVehicle" -or
        $_ -match "EnterArea" -or
        $_ -match "GetOffArea"
    } | ForEach-Object {
        $color = if ($_ -match "CALLED") { "Yellow" } elseif ($_ -match "Updated") { "Green" } else { "White" }
        Write-Host $_ -ForegroundColor $color
    }
} else {
    Write-Host "Log file not found. The server may not be logging to a file." -ForegroundColor Red
    Write-Host "Alternative: Check the main server console for [Vehicle] tagged messages." -ForegroundColor Yellow
}
