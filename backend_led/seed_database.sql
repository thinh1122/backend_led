-- =====================================================
-- SEED DATABASE SCRIPT - ESP32 Smart Plug
-- Chạy script này sau khi backend khởi động lần đầu
-- =====================================================

-- 1. Tạo User demo (password đã hash bằng BCrypt = "123456")
INSERT INTO users (email, password, full_name) 
VALUES ('demo@smarthome.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.Q6VKJqpTvU8S7IhQiy', 'Demo User')
ON CONFLICT (email) DO NOTHING;

-- 2. Lấy ID của user vừa tạo
-- (PostgreSQL sẽ tự động tạo ID = 1 nếu chưa có user nào)

-- 3. Tạo House cho user
INSERT INTO houses (name, address, user_id)
SELECT 'Nhà của tôi', 'TP. Hồ Chí Minh', id FROM users WHERE email = 'demo@smarthome.com'
ON CONFLICT DO NOTHING;

-- 4. Tạo các Room trong House
INSERT INTO rooms (name, house_id)
SELECT 'Phòng khách', id FROM houses WHERE name = 'Nhà của tôi'
ON CONFLICT DO NOTHING;

INSERT INTO rooms (name, house_id)
SELECT 'Phòng ngủ', id FROM houses WHERE name = 'Nhà của tôi'
ON CONFLICT DO NOTHING;

INSERT INTO rooms (name, house_id)
SELECT 'Phòng bếp', id FROM houses WHERE name = 'Nhà của tôi'
ON CONFLICT DO NOTHING;

-- 5. Tạo ESP32 Smart Plug Device
INSERT INTO devices (name, hardware_id, type, image, is_on, is_camera, room_id)
SELECT 
    'Ổ cắm thông minh',           -- Tên hiển thị
    'thiet_bi_esp32_relay',       -- Hardware ID (QUAN TRỌNG: phải khớp với ESP32 code)
    'Wi-Fi',                       -- Loại kết nối
    'assets/images/smart_plug.png', -- Hình ảnh
    false,                         -- Trạng thái ban đầu (OFF)
    false,                         -- Không phải camera
    id                             -- room_id
FROM rooms WHERE name = 'Phòng khách'
ON CONFLICT DO NOTHING;

-- 6. Thêm thêm vài thiết bị demo khác (tùy chọn)
INSERT INTO devices (name, hardware_id, type, image, is_on, is_camera, room_id)
SELECT 'Đèn phòng khách', 'den_phong_khach', 'Wi-Fi', 'assets/images/Smart_Lamp.png', false, false, id
FROM rooms WHERE name = 'Phòng khách'
ON CONFLICT DO NOTHING;

INSERT INTO devices (name, hardware_id, type, image, is_on, is_camera, room_id)
SELECT 'Đèn phòng ngủ', 'den_phong_ngu', 'Wi-Fi', 'assets/images/Smart_Lamp.png', false, false, id
FROM rooms WHERE name = 'Phòng ngủ'
ON CONFLICT DO NOTHING;

-- =====================================================
-- KẾT QUẢ: Sau khi chạy script này, database sẽ có:
-- - 1 User: demo@smarthome.com / 123456
-- - 1 House: Nhà của tôi
-- - 3 Rooms: Phòng khách, Phòng ngủ, Phòng bếp
-- - 3 Devices: Ổ cắm thông minh, Đèn phòng khách, Đèn phòng ngủ
-- =====================================================
