@echo off
echo ========================================
echo Monitor ESP32 MQTT Connection Status
echo ========================================
echo.
echo Dang ket noi toi ESP32 tren COM6...
echo Nhan Ctrl+] de thoat
echo.
echo ========================================
echo.

REM Thay COM6 bang port cua ban
python -m serial.tools.miniterm COM6 115200 --filter colorize

pause
