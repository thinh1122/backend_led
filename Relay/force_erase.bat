@echo off
echo ========================================
echo    XOA BO NHO FLASH ESP32 (FORCE)
echo ========================================
echo.
echo Dang khoi tao ESP-IDF...

call %IDF_PATH%\export.bat >nul 2>&1

echo.
echo [1/2] Xoa toan bo Flash...
python %IDF_PATH%\components\esptool_py\esptool\esptool.py --chip esp32c3 --port COM6 erase_flash

echo.
echo [2/2] Flash lai firmware...
python %IDF_PATH%\components\esptool_py\esptool\esptool.py --chip esp32c3 --port COM6 --baud 460800 write_flash -z 0x0 build\Relay.bin

echo.
echo ========================================
echo    HOAN TAT!
echo ========================================
echo ESP32 da duoc xoa sach va flash lai
echo Bluetooth se tu dong bat sau khi restart
echo.
pause
