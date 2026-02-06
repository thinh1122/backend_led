@echo off
echo ========================================
echo   RUNNING BACKEND LOCAL (H2 DATABASE)
echo ========================================
echo.
echo Backend will run on: http://192.168.1.72:8080
echo ESP32 will connect to this address
echo Using H2 in-memory database (no PostgreSQL needed)
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

echo Starting backend with H2 database...
call mvnw.cmd spring-boot:run ^
    -Dspring-boot.run.arguments="--server.port=8080 --spring.datasource.url=jdbc:h2:mem:testdb --spring.datasource.driver-class-name=org.h2.Driver --spring.jpa.database-platform=org.hibernate.dialect.H2Dialect"
