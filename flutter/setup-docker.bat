@echo off
echo ========================================
echo Smart Home IoT - Docker Setup
echo ========================================
echo.

REM Tạo thư mục cần thiết
echo [1/4] Tạo thư mục...
if not exist "mosquitto\config" mkdir mosquitto\config
if not exist "mosquitto\data" mkdir mosquitto\data
if not exist "mosquitto\log" mkdir mosquitto\log
if not exist "backend" mkdir backend
echo ✓ Đã tạo thư mục

echo.
echo [2/4] Tạo MQTT password file...
echo Nhập password cho user 'smarthome': Smarthome123
docker run -it --rm -v %cd%/mosquitto/config:/mosquitto/config eclipse-mosquitto:2.0 mosquitto_passwd -c /mosquitto/config/passwd smarthome

echo.
echo [3/4] Tạo file .env...
if not exist ".env" (
    copy .env.example .env
    echo ✓ Đã tạo file .env
) else (
    echo ⚠ File .env đã tồn tại, bỏ qua
)

echo.
echo [4/4] Khởi động Docker containers...
docker-compose up -d

echo.
echo ========================================
echo ✓ Setup hoàn tất!
echo ========================================
echo.
echo Services đang chạy:
docker-compose ps
echo.
echo Để xem logs: docker-compose logs -f
echo Để dừng: docker-compose stop
echo.
echo ⚠ LƯU Ý: Bạn cần có backend code trong thư mục 'backend/'
echo Xem README_DOCKER.md để biết thêm chi tiết
echo.
pause
