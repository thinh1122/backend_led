@echo off
echo ========================================
echo   RUNNING BACKEND WITH RENDER POSTGRESQL
echo ========================================
echo.
echo Backend will run on: http://192.168.1.72:8080
echo Database: PostgreSQL on Render.com
echo Data will be saved permanently
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

cd backend_led

REM Check if Maven wrapper exists
if not exist mvnw.cmd (
    echo [ERROR] Maven wrapper not found!
    echo Please run this from smart_home_app directory
    pause
    exit /b 1
)

echo Starting backend with Render PostgreSQL...
echo.
echo IMPORTANT: You need to set these environment variables:
echo   DB_URL=jdbc:postgresql://your-db-host.render.com:5432/your_db_name
echo   DB_USERNAME=your_username
echo   DB_PASSWORD=your_password
echo.
echo Or edit this file and add them below:
echo.

REM ===== ĐIỀN THÔNG TIN POSTGRESQL CỦA BẠN Ở ĐÂY =====
REM Lấy từ Render Dashboard > Database > Connection String
set DB_URL=jdbc:postgresql://dpg-d60qhuaqcgvc7383v9f0-a.singapore-postgres.render.com:5432/backend_led_v1t1
set DB_USERNAME=backend_user
set DB_PASSWORD=M3xCF81IhImlsjvfhA7Ny5WMMgAO2IKj
REM =====================================================

call mvnw.cmd spring-boot:run

