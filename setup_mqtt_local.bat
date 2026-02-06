@echo off
echo ========================================
echo   SETUP MOSQUITTO MQTT LOCAL
echo ========================================
echo.

cd flutter

echo [1/3] Starting Mosquitto MQTT broker...
docker-compose up -d mosquitto

echo.
echo [2/3] Waiting for Mosquitto to start...
timeout /t 5 /nobreak > nul

echo.
echo [3/3] Creating MQTT user (smarthome/Smarthome123)...
docker exec smarthome_mqtt mosquitto_passwd -b -c /mosquitto/config/passwd smarthome Smarthome123

echo.
echo ========================================
echo   MQTT BROKER READY!
echo ========================================
echo   Host: localhost (or your PC IP)
echo   Port: 1883
echo   Username: smarthome
echo   Password: Smarthome123
echo ========================================
echo.
echo To find your PC IP address, run: ipconfig
echo Look for "IPv4 Address" under your WiFi adapter
echo.
pause
