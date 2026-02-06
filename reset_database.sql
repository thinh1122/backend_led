-- Script để reset database từ UUID sang BIGINT
-- Chạy script này trên PostgreSQL database của Render

-- Drop tất cả tables (theo thứ tự dependency)
DROP TABLE IF EXISTS schedules CASCADE;
DROP TABLE IF EXISTS devices CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS houses CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Hibernate sẽ tự động tạo lại tables với BIGINT khi backend restart
