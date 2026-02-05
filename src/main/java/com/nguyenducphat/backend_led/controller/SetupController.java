package com.nguyenducphat.backend_led.controller;

import com.nguyenducphat.backend_led.entity.Device;
import com.nguyenducphat.backend_led.entity.House;
import com.nguyenducphat.backend_led.entity.Room;
import com.nguyenducphat.backend_led.entity.User;
import com.nguyenducphat.backend_led.repository.DeviceRepository;
import com.nguyenducphat.backend_led.repository.HouseRepository;
import com.nguyenducphat.backend_led.repository.RoomRepository;
import com.nguyenducphat.backend_led.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/setup")
@RequiredArgsConstructor
public class SetupController {
    
    private final UserRepository userRepository;
    private final HouseRepository houseRepository;
    private final RoomRepository roomRepository;
    private final DeviceRepository deviceRepository;
    private final PasswordEncoder passwordEncoder;
    
    /**
     * Endpoint để tạo dữ liệu mặc định cho testing
     * POST /api/setup/create-default-data
     */
    @PostMapping("/create-default-data")
    public ResponseEntity<?> createDefaultData() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 1. Tạo user mặc định
            User user = userRepository.findByUsername("admin").orElse(null);
            if (user == null) {
                user = new User();
                user.setUsername("admin");
                user.setEmail("admin@smarthome.com");
                user.setPassword(passwordEncoder.encode("admin123"));
                user = userRepository.save(user);
                result.put("user", "Created: admin / admin123");
            } else {
                result.put("user", "Already exists: admin");
            }
            
            // 2. Tạo nhà mặc định
            House house = houseRepository.findByUserIdAndName(user.getId(), "Nhà của tôi").orElse(null);
            if (house == null) {
                house = new House();
                house.setName("Nhà của tôi");
                house.setAddress("TP. Hồ Chí Minh");
                house.setUser(user);
                house = houseRepository.save(house);
                result.put("house", "Created: Nhà của tôi");
            } else {
                result.put("house", "Already exists: Nhà của tôi");
            }
            
            // 3. Tạo phòng mặc định
            Room room = roomRepository.findByHouseIdAndName(house.getId(), "Phòng khách").orElse(null);
            if (room == null) {
                room = new Room();
                room.setName("Phòng khách");
                room.setHouse(house);
                room = roomRepository.save(room);
                result.put("room", "Created: Phòng khách");
            } else {
                result.put("room", "Already exists: Phòng khách");
            }
            
            // 4. Tạo thiết bị ESP32
            Device device = deviceRepository.findByHardwareId("thiet_bi_esp32").orElse(null);
            if (device == null) {
                device = new Device();
                device.setDeviceId("thiet_bi_esp32");
                device.setHardwareId("thiet_bi_esp32");
                device.setName("Thiết bị ESP32");
                device.setType("RELAY");
                device.setState(false);
                device.setRoom(room);
                device = deviceRepository.save(device);
                result.put("device", "Created: Thiết bị ESP32 (ID: thiet_bi_esp32)");
            } else {
                result.put("device", "Already exists: Thiết bị ESP32");
            }
            
            result.put("success", true);
            result.put("message", "✅ Default data created successfully!");
            result.put("login", Map.of("username", "admin", "password", "admin123"));
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("error", e.getMessage());
            return ResponseEntity.status(500).body(result);
        }
    }
}
