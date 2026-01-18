package com.nguyenducphat.backend_led.service;

import com.nguyenducphat.backend_led.dto.DeviceResponse;
import com.nguyenducphat.backend_led.entity.Device;
import com.nguyenducphat.backend_led.entity.User;
import com.nguyenducphat.backend_led.repository.DeviceRepository;
import com.nguyenducphat.backend_led.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DeviceService {
    private final DeviceRepository deviceRepository;
    private final UserRepository userRepository;
    private final com.nguyenducphat.backend_led.repository.RoomRepository roomRepository;
    private final com.nguyenducphat.backend_led.repository.HouseRepository houseRepository;
    private final com.nguyenducphat.backend_led.mqtt.MqttGateway mqttGateway;

    @org.springframework.transaction.annotation.Transactional
    public DeviceResponse addDevice(com.nguyenducphat.backend_led.dto.DeviceRequest request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User không tồn tại!"));

        com.nguyenducphat.backend_led.entity.Room room;
        if (request.getRoomId() != null) {
            room = roomRepository.findById(request.getRoomId())
                    .orElseThrow(() -> new RuntimeException("Phòng không tồn tại!"));
        } else {
            // Find or create a default room for this user
            List<com.nguyenducphat.backend_led.entity.House> houses = houseRepository.findByOwner(user);
            com.nguyenducphat.backend_led.entity.House targetHouse;

            if (houses.isEmpty()) {
                // Tự tạo Nhà Mặc Định nếu chưa có
                targetHouse = com.nguyenducphat.backend_led.entity.House.builder()
                        .name("Nhà của bạn")
                        .address("Mặc định")
                        .owner(user)
                        .build();
                targetHouse = houseRepository.save(targetHouse);
            } else {
                targetHouse = houses.get(0);
            }

            List<com.nguyenducphat.backend_led.entity.Room> rooms = roomRepository.findByHouseId(targetHouse.getId());
            if (rooms.isEmpty()) {
                // Tự tạo Phòng Khách nếu chưa có
                room = com.nguyenducphat.backend_led.entity.Room.builder()
                        .name("Phòng khách")
                        .house(targetHouse)
                        .build();
                room = roomRepository.save(room);
            } else {
                room = rooms.get(0);
            }
        }

        Device device = Device.builder()
                .name(request.getName())
                .hardwareId(request.getHardwareId())
                .type(request.getType() != null ? request.getType() : "Wi-Fi")
                .image(request.getImage())
                .isOn(false)
                .isCamera(request.isCamera())
                .room(room)
                .build();

        Device savedDevice = deviceRepository.save(device);
        return mapToResponse(savedDevice);
    }

    public List<DeviceResponse> getMyDevices() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User không tồn tại!"));

        return deviceRepository.findByOwner(user).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @org.springframework.transaction.annotation.Transactional
    public void deleteDevice(java.util.UUID deviceId) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User không tồn tại!"));

        Device device = deviceRepository.findById(deviceId)
                .orElseThrow(() -> new RuntimeException("Thiết bị không tồn tại!"));

        // Check quyền sở hữu: Thiết bị phải thuộc phòng của nhà của user
        if (!device.getRoom().getHouse().getOwner().getId().equals(user.getId())) {
             throw new RuntimeException("Bạn không có quyền xóa thiết bị này!");
        }

        deviceRepository.delete(device);
    }

    @org.springframework.transaction.annotation.Transactional
    public void toggleDevice(java.util.UUID deviceId, boolean isOn) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User không tồn tại!"));

        Device device = deviceRepository.findById(deviceId)
                .orElseThrow(() -> new RuntimeException("Thiết bị không tồn tại!"));

        // Check quyền sở hữu
        if (!device.getRoom().getHouse().getOwner().getId().equals(user.getId())) {
             throw new RuntimeException("Bạn không có quyền điều khiển thiết bị này!");
        }

        device.setOn(isOn);
        deviceRepository.save(device);
        
        // Gửi lệnh MQTT (Đồng bộ với App Flutter và Web)
        try {
            // Priority: Use hardwareId if available, otherwise fallback to slug name
            String deviceIdForMqtt = device.getHardwareId();
            if (deviceIdForMqtt == null || deviceIdForMqtt.isEmpty()) {
                deviceIdForMqtt = cleanId(device.getName());
            }

            String payload = isOn ? "ON" : "OFF";
            
            // 1. Gửi đến /set topic (cho ESP32 nhận lệnh)
            String setTopic = "smarthome/devices/" + deviceIdForMqtt + "/set";
            System.out.println("Backend sending MQTT to: " + setTopic + " Payload: " + payload);
            mqttGateway.sendToMqtt(setTopic, payload);
            
            // 💡 QUAN TRỌNG: Backend KHÔNG gửi đến /state topic nữa.
            // Hãy để ESP32 tự báo cáo trạng thái thực tế của nó. 
            // Việc này giúp tránh xung đột và App/Web sẽ nhận confirm TRỰC TIẾP từ ESP32 nhanh hơn.
            
        } catch (Exception e) {
            System.err.println("Lỗi gửi MQTT: " + e.getMessage());
            // Không throw exception để tránh rollback transaction DB
        }
    }

    private String cleanId(String input) {
        if (input == null) return "";
        String str = input.toLowerCase();
        str = java.text.Normalizer.normalize(str, java.text.Normalizer.Form.NFD);
        str = str.replaceAll("\\p{M}", ""); // Remove accents
        str = str.replace('đ', 'd').replace('Đ', 'd');
        str = str.replaceAll("[^a-z0-9]", "_");
        str = str.replaceAll("_+", "_");
        return str;
    }

    private DeviceResponse mapToResponse(Device device) {
        return DeviceResponse.builder()
                .id(device.getId())
                .name(device.getName())
                .hardwareId(device.getHardwareId())
                .type(device.getType())
                .image(device.getImage())
                .isOn(device.isOn())
                .isCamera(device.isCamera())
                .roomName(device.getRoom().getName())
                .roomId(device.getRoom().getId())
                .build();
    }
}
