@echo off
echo ========================================
echo   RUNNING BACKEND LOCAL
echo ========================================
echo.
echo Backend: http://192.168.1.74:8080
echo ESP32 will connect to this address
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

cd backend_led

echo [1/2] Checking Maven...
if not exist mvnw.cmd (
    echo [ERROR] Maven wrapper not found!
    pause
    exit /b 1
)

echo [2/2] Starting Spring Boot...
echo.
call mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=local

pause


