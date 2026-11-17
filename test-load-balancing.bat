@echo off
setlocal enabledelayedexpansion
echo ==========================================================
echo Testing Round Robin Load Balancing (15 Requests)
echo Target: http://localhost:8080/api/drivers
echo ==========================================================

for /L %%i in (1,1,15) do (
    echo Request %%i:
    curl -s http://localhost:8080/api/drivers
    echo.
    echo ----------------------------------------------------------
)

echo Done.
pause

