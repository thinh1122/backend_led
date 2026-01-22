@echo off
echo ========================================
echo Xoa bo nho WiFi trong ESP32
echo ========================================
echo.
echo Dang xoa NVS (Non-Volatile Storage)...
echo.

REM Thay COM3 bang port cua ban
idf.py -p COM3 erase-flash

echo.
echo ========================================
echo Da xoa xong! 
echo Giờ flash lại firmware:
echo   idf.py -p COM3 flash monitor
echo ========================================
pause
