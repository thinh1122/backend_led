@echo off
echo ========================================
echo    BUILDING ESP32 WITH VOICE CONTROL
echo ========================================

REM Set IDF environment
set IDF_PATH=C:\Users\DELL\esp\v5.1.6\esp-idf
call %IDF_PATH%\export.bat

REM Clean and build
echo Cleaning previous build...
idf.py clean

echo Building project with voice control...
idf.py build

if %ERRORLEVEL% EQU 0 (
    echo ========================================
    echo    BUILD SUCCESSFUL! 
    echo    Ready to flash with voice control
    echo ========================================
    
    echo Flashing to ESP32...
    idf.py -p COM6 flash monitor
) else (
    echo ========================================
    echo    BUILD FAILED!
    echo ========================================
    pause
)