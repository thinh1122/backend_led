@echo off
echo ========================================
echo BUILD VA FLASH (GIU WIFI)
echo ========================================
echo.

REM Set ESP-IDF environment
call %USERPROFILE%\esp\v5.1.6\esp-idf\export.bat

echo [1/2] Building firmware...
idf.py build

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Build FAILED!
    pause
    exit /b 1
)

echo.
echo [2/2] Flashing firmware (KEEPING WiFi credentials)...
idf.py -p COM6 flash

echo.
echo ✅ Done! Opening monitor...
idf.py -p COM6 monitor

pause
