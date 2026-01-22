@echo off
echo ========================================
echo XOA BO NHO VA FLASH LAI FIRMWARE
echo ========================================
echo.

REM Set ESP-IDF environment
call %USERPROFILE%\esp\v5.1.6\esp-idf\export.bat

echo [1/3] Xoa toan bo bo nho Flash...
python %IDF_PATH%\components\esptool_py\esptool\esptool.py --chip esp32c3 --port COM6 erase_flash

echo.
echo [2/3] Flash lai firmware...
python %IDF_PATH%\components\esptool_py\esptool\esptool.py --chip esp32c3 --port COM6 --baud 460800 write_flash -z 0x0 build\bootloader\bootloader.bin 0x8000 build\partition_table\partition-table.bin 0x10000 build\Relay.bin

echo.
echo [3/3] Mo Monitor de xem ket qua...
idf.py -p COM6 monitor

pause
