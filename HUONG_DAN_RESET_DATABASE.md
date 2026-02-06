# Hướng dẫn Reset Database trên Render

## Vấn đề
Database hiện tại đang dùng UUID, nhưng code mới đã chuyển sang BIGINT (Long). Cần reset database để Hibernate tạo lại schema mới.

## Cách 1: Dùng Render Dashboard (Khuyên dùng)

### Bước 1: Truy cập Render Dashboard
1. Đăng nhập vào https://dashboard.render.com
2. Vào **Databases** → Chọn database `backend_led`

### Bước 2: Kết nối qua psql Shell
1. Trong trang database, tìm tab **Shell** hoặc **Connect**
2. Click vào **PSQL Command** để mở terminal
3. Hoặc copy **External Database URL** và dùng psql local:
   ```bash
   psql postgresql://backend_user:nEpkYjDJu9VgkkUcX6ke8VDbpebhvWjS@dpg-d5vij3h4tr6s739p4np0-a.singapore-postgres.render.com/backend_led
   ```

### Bước 3: Chạy lệnh DROP tables
Paste các lệnh sau vào psql shell:

```sql
DROP TABLE IF EXISTS schedules CASCADE;
DROP TABLE IF EXISTS devices CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS houses CASCADE;
DROP TABLE IF EXISTS users CASCADE;
```

### Bước 4: Restart Backend Service
1. Quay lại **Services** → Chọn `backend-led-1`
2. Click **Manual Deploy** → **Clear build cache & deploy**
3. Hoặc đơn giản là **Restart Service**

Backend sẽ tự động tạo lại tables với schema mới (BIGINT).

---

## Cách 2: Dùng pgAdmin hoặc DBeaver (Nếu có)

1. Kết nối đến database với thông tin:
   - Host: `dpg-d5vij3h4tr6s739p4np0-a.singapore-postgres.render.com`
   - Port: `5432`
   - Database: `backend_led`
   - User: `backend_user`
   - Password: `nEpkYjDJu9VgkkUcX6ke8VDbpebhvWjS`

2. Chạy file `reset_database.sql`

3. Restart backend service trên Render

---

## Sau khi Reset

1. **Đăng ký lại tài khoản** trên app (data cũ đã mất)
2. **Thêm lại nhà và phòng**
3. **Thêm lại thiết bị ESP32** với hardwareId: `thiet_bi_esp32`
4. **Test lại chức năng hẹn giờ**

---

## Lưu ý

- Tất cả data cũ sẽ bị XÓA (users, houses, rooms, devices, schedules)
- Đây là cách nhanh nhất để fix lỗi UUID → BIGINT
- Nếu muốn giữ data, cần viết migration script phức tạp hơn
