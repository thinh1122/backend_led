@echo off
echo ========================================
echo    XOA BO NHO NVS (CHI XOA WIFI)
echo ========================================
echo.

set IDF_PATH=C:\Users\DELL\esp\v5.1.6\esp-idf

echo Dang xoa NVS partition (WiFi credentials)...
python %IDF_PATH%\components\esptool_py\esptool\esptool.py --chip esp32c3 --port COM6 erase_region 0x9000 0x4000

echo.
echo ========================================
echo    HOAN TAT!
echo ========================================
echo WiFi da duoc xoa
echo Nhan nut RESET tren ESP32 de bat Bluetooth
echo.
pause
