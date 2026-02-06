@echo off
echo ========================================
echo   SETUP DATABASE
echo ========================================
echo.

set /p POSTGRES_PASSWORD="Enter PostgreSQL password (default: postgres): "
if "%POSTGRES_PASSWORD%"=="" set POSTGRES_PASSWORD=postgres

echo.
echo Creating database 'smarthome'...
echo.

set PGPASSWORD=%POSTGRES_PASSWORD%
psql -U postgres -c "DROP DATABASE IF EXISTS smarthome;"
psql -U postgres -c "CREATE DATABASE smarthome;"

if %errorlevel% equ 0 (
    echo.
    echo ✅ Database created successfully!
    echo.
) else (
    echo.
    echo ❌ Failed to create database
    echo Make sure PostgreSQL is running
    echo.
)

pause
