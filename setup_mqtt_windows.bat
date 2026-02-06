@echo off
echo ========================================
echo   SETUP MOSQUITTO MQTT (Windows Native)
echo ========================================
echo.

echo Checking if Mosquitto is installed...
where mosquitto >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Mosquitto is already installed
    goto :configure
)

echo.
echo Mosquitto is not installed!
echo.
echo Please install Mosquitto manually:
echo 1. Download from: https://mosquitto.org/download/
echo 2. Install to: C:\Program Files\mosquitto
echo 3. Run this script again
echo.
pause
exit /b 1

:configure
echo.
echo [1/3] Creating Mosquitto config directory...
if not exist "mosquitto\config" mkdir mosquitto\config
if not exist "mosquitto\data" mkdir mosquitto\data
if not exist "mosquitto\log" mkdir mosquitto\log

echo.
echo [2/3] Creating mosquitto.conf...
(
echo # Mosquitto Configuration for Smart Home IoT
echo.
echo listener 1883
echo allow_anonymous false
echo password_file mosquitto\config\passwd
echo.
echo persistence true
echo persistence_location mosquitto\data\
echo.
echo log_dest file mosquitto\log\mosquitto.log
echo log_type all
) > mosquitto\config\mosquitto.conf

echo.
echo [3/3] Creating MQTT user (smarthome/Smarthome123)...
mosquitto_passwd -b -c mosquitto\config\passwd smarthome Smarthome123

echo.
echo ========================================
echo   MQTT CONFIG READY!
echo ========================================
echo.
echo To start Mosquitto, run:
echo   mosquitto -c mosquitto\config\mosquitto.conf -v
echo.
echo Or use the start_mqtt.bat script
echo.
pause
