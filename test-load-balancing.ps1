Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Testing Round Robin Load Balancing (15 Requests)" -ForegroundColor Cyan
Write-Host "Target: http://localhost:8080/api/drivers" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Pre-flight check: verify API Gateway is listening on port 8080
$port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if (-not $port8080) {
    Write-Host "`n[!] API Gateway is NOT running on port 8080 yet." -ForegroundColor Red
    Write-Host "Please start the services first before running this test:" -ForegroundColor Yellow
    Write-Host "  Option A (Script): Run .\start-all.ps1 or double-click start-all.bat" -ForegroundColor White
    Write-Host "  Option B (IDE): Run DriverServiceApplication (ports 8081, 8082, 8083) and GatewayApplication (port 8080)" -ForegroundColor White
    Write-Host "`nExiting test." -ForegroundColor Red
    exit
}

$counts = @{}

for ($i = 1; $i -le 15; $i++) {
    try {
        $raw = Invoke-RestMethod -Uri "http://localhost:8080/api/drivers" -Method Get -TimeoutSec 5
        $port = $raw.port
        if (-not $port) { $port = $raw.instanceId }
        
        Write-Host "Request $i -> Handled by Instance: $port ($($raw.instanceId))" -ForegroundColor Green
        
        if ($counts.ContainsKey($port)) {
            $counts[$port] += 1
        } else {
            $counts[$port] = 1
        }
    } catch {
        Write-Host "Request $i -> FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 150
}

Write-Host "`n==========================================================" -ForegroundColor Yellow
Write-Host "Request Distribution Summary (Total 15 Requests):" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow
foreach ($key in $counts.Keys | Sort-Object) {
    Write-Host "Instance $key : $($counts[$key]) requests" -ForegroundColor White
}
Write-Host "==========================================================" -ForegroundColor Yellow
