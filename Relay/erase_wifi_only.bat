@echo off
echo ========================================
echo XOA CHI WIFI CREDENTIALS (GIU FIRMWARE)
echo ========================================
echo.

REM Set ESP-IDF environment
call %USERPROFILE%\esp\v5.1.6\esp-idf\export.bat

echo Dang xoa NVS partition (WiFi credentials)...
python %IDF_PATH%\components\esptool_py\esptool\esptool.py --chip esp32c3 --port COM6 erase_region 0x9000 0x6000

echo.
echo ✅ Da xoa xong! ESP32 se quay lai che do Setup (BLE)
echo.
echo Mo Monitor de xem:
idf.py -p COM6 monitor

pause
