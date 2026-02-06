@echo off
echo ========================================
echo   STARTING MOSQUITTO MQTT BROKER
echo ========================================
echo.
echo Host: 192.168.1.74 (your PC)
echo Port: 1883
echo Username: smarthome
echo Password: Smarthome123
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

mosquitto -c mosquitto\config\mosquitto.conf -v
