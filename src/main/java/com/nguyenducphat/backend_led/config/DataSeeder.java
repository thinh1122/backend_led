package com.nguyenducphat.backend_led.config;

import com.nguyenducphat.backend_led.entity.Device;
import com.nguyenducphat.backend_led.entity.House;
import com.nguyenducphat.backend_led.entity.Room;
import com.nguyenducphat.backend_led.entity.User;
import com.nguyenducphat.backend_led.repository.DeviceRepository;
import com.nguyenducphat.backend_led.repository.HouseRepository;
import com.nguyenducphat.backend_led.repository.RoomRepository;
import com.nguyenducphat.backend_led.repository.UserRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * DataSeeder - Tự động tạo dữ liệu mẫu khi backend khởi động
 * Chỉ chạy 1 lần khi database còn trống
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder {

    private final UserRepository userRepository;
    private final HouseRepository houseRepository;
    private final RoomRepository roomRepository;
    private final DeviceRepository deviceRepository;
    private final PasswordEncoder passwordEncoder;

    @PostConstruct
    @Transactional
    public void seedDatabase() {
        // Kiểm tra nếu đã có user thì không seed nữa
        if (userRepository.count() > 0) {
            log.info("✅ Database already seeded, skipping...");
            return;
        }

        log.info("🌱 Starting database seeding...");

        try {
            // 1. Tạo Demo User
            User demoUser = User.builder()
                    .email("demo@smarthome.com")
                    .password(passwordEncoder.encode("123456"))
                    .fullName("Demo User")
                    .build();
            userRepository.save(demoUser);
            log.info("✅ Created demo user: demo@smarthome.com");

            // 2. Tạo House
            House house = House.builder()
                    .name("Nhà của tôi")
                    .address("TP. Hồ Chí Minh")
                    .owner(demoUser)
                    .build();
            houseRepository.save(house);
            log.info("✅ Created house: Nhà của tôi");

            // 3. Tạo Rooms
            Room phongKhach = Room.builder()
                    .name("Phòng khách")
                    .house(house)
                    .build();
            roomRepository.save(phongKhach);

            Room phongNgu = Room.builder()
                    .name("Phòng ngủ")
                    .house(house)
                    .build();
            roomRepository.save(phongNgu);

            Room phongBep = Room.builder()
                    .name("Phòng bếp")
                    .house(house)
                    .build();
            roomRepository.save(phongBep);
            log.info("✅ Created 3 rooms");

            // 4. Tạo ESP32 Smart Plug Device (QUAN TRỌNG!)
            Device esp32Relay = Device.builder()
                    .name("Ổ cắm thông minh")
                    .hardwareId("thiet_bi_esp32_relay")  // Khớp với ESP32 code
                    .type("Wi-Fi")
                    .image("assets/images/smart_plug.png")
                    .isOn(false)
                    .isCamera(false)
                    .room(phongKhach)
                    .build();
            deviceRepository.save(esp32Relay);
            log.info("✅ Created ESP32 device: Ổ cắm thông minh (hardwareId: thiet_bi_esp32_relay)");

            // 5. Tạo thêm các thiết bị demo
            Device denPhongKhach = Device.builder()
                    .name("Đèn phòng khách")
                    .hardwareId("den_phong_khach")
                    .type("Wi-Fi")
                    .image("assets/images/Smart_Lamp.png")
                    .isOn(false)
                    .isCamera(false)
                    .room(phongKhach)
                    .build();
            deviceRepository.save(denPhongKhach);

            Device denPhongNgu = Device.builder()
                    .name("Đèn phòng ngủ")
                    .hardwareId("den_phong_ngu")
                    .type("Wi-Fi")
                    .image("assets/images/Smart_Lamp.png")
                    .isOn(false)
                    .isCamera(false)
                    .room(phongNgu)
                    .build();
            deviceRepository.save(denPhongNgu);
            log.info("✅ Created 2 additional demo devices");

            log.info("🎉 Database seeding completed successfully!");
            log.info("📱 Login credentials: demo@smarthome.com / 123456");

        } catch (Exception e) {
            log.error("❌ Error during database seeding: ", e);
        }
    }
}
