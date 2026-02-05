@echo off
echo ========================================
echo BUILD, ERASE WIFI VA FLASH FIRMWARE
echo ========================================
echo.

REM Set ESP-IDF environment
call %USERPROFILE%\esp\v5.1.6\esp-idf\export.bat

echo [1/4] Cleaning previous build...
idf.py fullclean

echo [2/4] Building firmware...
idf.py build

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Build FAILED!
    pause
    exit /b 1
)

echo.
echo [3/4] Erasing WiFi credentials...
python "%IDF_PATH%\components\esptool_py\esptool\esptool.py" --chip esp32c3 --port COM6 erase_region 0x9000 0x6000

echo.
echo [4/4] Flashing firmware to ESP32-C3...
idf.py -p COM6 flash

echo.
echo ✅ Done! Opening monitor...
idf.py -p COM6 monitor

pause
