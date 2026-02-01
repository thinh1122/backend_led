@echo off
echo ========================================
echo    KIEM TRA ESP32 BLUETOOTH STATUS
echo ========================================
echo.
echo Dang ket noi voi ESP32 tren COM6...
echo.
echo CAC DAU HIEU ESP32 DANG BAT BLUETOOTH:
echo   [✓] "BLE: Starting advertising as PROV_thiet_bi_esp32..."
echo   [✓] "DEVICE IN PROVISIONING MODE (SETUP)"
echo   [✓] "Please open the Mobile App to configure WiFi"
echo.
echo Nhan Ctrl+] de thoat
echo ========================================
echo.

call %IDF_PATH%\export.bat >nul 2>&1
idf.py -p COM6 monitor
