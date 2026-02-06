@echo off
echo =====================================================
echo SEED DATABASE - Smart Home App
echo =====================================================
echo.

REM Cấu hình PostgreSQL (Thay đổi nếu cần)
set PGHOST=localhost
set PGPORT=5432
set PGUSER=postgres
set PGPASSWORD=postgres
set PGDATABASE=smarthome

echo Connecting to PostgreSQL...
echo Host: %PGHOST%:%PGPORT%
echo Database: %PGDATABASE%
echo.

REM Chạy script SQL
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f seed_database.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =====================================================
    echo ✅ DATABASE SEEDED SUCCESSFULLY!
    echo =====================================================
    echo.
    echo Demo User: demo@smarthome.com
    echo Password:  123456
    echo.
    echo Thiết bị đã tạo:
    echo   - Ổ cắm thông minh (thiet_bi_esp32_relay)
    echo   - Đèn phòng khách
    echo   - Đèn phòng ngủ
    echo.
) else (
    echo.
    echo ❌ ERROR: Failed to seed database!
    echo Check PostgreSQL connection settings.
)

pause
