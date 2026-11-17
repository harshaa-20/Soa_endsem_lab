@echo off
title Stop All Services - SOA Round Robin Project
echo ===============================================================
echo Stopping all running instances on ports 8080, 8081, 8082, 8083
echo ===============================================================

for %%p in (8080 8081 8082 8083) do (
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%%p ^| findstr LISTENING') do (
        echo Killing process on port %%p (PID: %%a)...
        taskkill /F /PID %%a >nul 2>&1
    )
)

echo All services stopped cleanly.
pause

