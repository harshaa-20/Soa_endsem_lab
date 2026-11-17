@echo off
title Start All Services - SOA Round Robin Project
setlocal enabledelayedexpansion

echo ===============================================================
echo Starting Ride-Sharing Platform Services
echo ===============================================================

:: Detect JAVA_HOME
if not defined JAVA_HOME (
    if exist "C:\Program Files\Java\jdk-21" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-21"
        set "PATH=!JAVA_HOME!\bin;!PATH!"
    )
)

:: Detect Maven
where mvn >nul 2>&1
if %ERRORLEVEL% neq 0 (
    if exist "%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.6-bin\apache-maven-3.9.6\bin\mvn.cmd" (
        set "PATH=%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.6-bin\apache-maven-3.9.6\bin;!PATH!"
    )
)

set "BASE_DIR=%~dp0"

echo [1/4] Starting Driver Service Instance 1 on Port 8081...
start "Driver-Instance-8081" cmd /k "cd /d "%BASE_DIR%driver-service" && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8081""

timeout /t 6 /nobreak >nul

echo [2/4] Starting Driver Service Instance 2 on Port 8082...
start "Driver-Instance-8082" cmd /k "cd /d "%BASE_DIR%driver-service" && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8082""

timeout /t 6 /nobreak >nul

echo [3/4] Starting Driver Service Instance 3 on Port 8083...
start "Driver-Instance-8083" cmd /k "cd /d "%BASE_DIR%driver-service" && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8083""

timeout /t 6 /nobreak >nul

echo [4/4] Starting API Gateway on Port 8080...
start "API-Gateway-8080" cmd /k "cd /d "%BASE_DIR%api-gateway" && mvn spring-boot:run"

echo ===============================================================
echo All 4 service instances are starting in separate windows.
echo Please wait 10-15 seconds for Spring Boot to finish booting,
echo then run:
echo     .\test-load-balancing.ps1
echo ===============================================================
pause
