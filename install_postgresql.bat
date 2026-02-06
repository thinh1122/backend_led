@echo off
echo ========================================
echo   INSTALL POSTGRESQL
echo ========================================
echo.
echo Downloading PostgreSQL installer...
echo.

REM Download PostgreSQL 14 installer
powershell -Command "& {Invoke-WebRequest -Uri 'https://get.enterprisedb.com/postgresql/postgresql-14.9-1-windows-x64.exe' -OutFile 'postgresql-installer.exe'}"

if exist postgresql-installer.exe (
    echo.
    echo Starting installer...
    echo.
    echo IMPORTANT:
    echo 1. Remember the password for user 'postgres'
    echo 2. Use default port 5432
    echo 3. Install all components
    echo.
    pause
    start /wait postgresql-installer.exe
    
    echo.
    echo Installation complete!
    echo.
    del postgresql-installer.exe
) else (
    echo Download failed!
    echo.
    echo Please download manually:
    echo https://www.postgresql.org/download/windows/
)

pause
