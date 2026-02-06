-- =====================================================
-- Script: Thêm thiết bị mặc định vào database
-- Device ID: thiet_bi_esp32
-- =====================================================

-- 1. Tạo user mặc định (nếu chưa có)
INSERT INTO users (id, username, email, password, created_at, updated_at)
VALUES (1, 'admin', 'admin@smarthome.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
-- Password: admin123 (đã hash BCrypt)

-- 2. Tạo nhà mặc định
INSERT INTO houses (id, name, address, user_id, created_at, updated_at)
VALUES (1, 'Nhà của tôi', 'TP. Hồ Chí Minh', 1, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- 3. Tạo phòng mặc định
INSERT INTO rooms (id, name, house_id, created_at, updated_at)
VALUES (1, 'Phòng khách', 1, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- 4. Thêm thiết bị ESP32
INSERT INTO devices (id, device_id, hardware_id, name, type, state, room_id, created_at, updated_at)
VALUES (1, 'thiet_bi_esp32', 'thiet_bi_esp32', 'Thiết bị ESP32', 'RELAY', false, 1, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- Kiểm tra kết quả
-- =====================================================
SELECT 'User created:' as info, username, email FROM users WHERE id = 1;
SELECT 'House created:' as info, name, address FROM houses WHERE id = 1;
SELECT 'Room created:' as info, name FROM rooms WHERE id = 1;
SELECT 'Device created:' as info, device_id, name, type FROM devices WHERE id = 1;
