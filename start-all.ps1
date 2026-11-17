# Start All Services Script for PowerShell
$ErrorActionPreference = "Continue"

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "Starting Ride-Sharing Platform Services" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan

# Ensure JAVA_HOME
if (-not $env:JAVA_HOME) {
    if (Test-Path "C:\Program Files\Java\jdk-21") {
        $env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
        $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
    }
}

# Ensure Maven in PATH
$mvnCmd = Get-Command mvn -ErrorAction SilentlyContinue
if (-not $mvnCmd) {
    $mvnFallback = "$env:USERPROFILE\.m2\wrapper\dists\apache-maven-3.9.6-bin\apache-maven-3.9.6\bin"
    if (Test-Path $mvnFallback) {
        $env:PATH = "$mvnFallback;$env:PATH"
    }
}

$baseDir = $PSScriptRoot

Write-Host "[1/4] Starting Driver Service Instance 1 on Port 8081..." -ForegroundColor Green
Start-Process cmd.exe -ArgumentList "/k cd /d `"$baseDir\driver-service`" && mvn spring-boot:run -Dspring-boot.run.jvmArguments=`"-Dserver.port=8081`"" -WindowStyle Normal

Start-Sleep -Seconds 5

Write-Host "[2/4] Starting Driver Service Instance 2 on Port 8082..." -ForegroundColor Green
Start-Process cmd.exe -ArgumentList "/k cd /d `"$baseDir\driver-service`" && mvn spring-boot:run -Dspring-boot.run.jvmArguments=`"-Dserver.port=8082`"" -WindowStyle Normal

Start-Sleep -Seconds 5

Write-Host "[3/4] Starting Driver Service Instance 3 on Port 8083..." -ForegroundColor Green
Start-Process cmd.exe -ArgumentList "/k cd /d `"$baseDir\driver-service`" && mvn spring-boot:run -Dspring-boot.run.jvmArguments=`"-Dserver.port=8083`"" -WindowStyle Normal

Start-Sleep -Seconds 5

Write-Host "[4/4] Starting API Gateway on Port 8080..." -ForegroundColor Yellow
Start-Process cmd.exe -ArgumentList "/k cd /d `"$baseDir\api-gateway`" && mvn spring-boot:run" -WindowStyle Normal

Write-Host "`n===============================================================" -ForegroundColor Cyan
Write-Host "All 4 service windows have been launched!" -ForegroundColor Cyan
Write-Host "Wait ~15-20 seconds for the applications to finish initializing." -ForegroundColor White
Write-Host "Then run:" -ForegroundColor Yellow
Write-Host "    .\test-load-balancing.ps1" -ForegroundColor Yellow
Write-Host "===============================================================" -ForegroundColor Cyan

