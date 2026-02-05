package com.nguyenducphat.backend_led.service;

import com.nguyenducphat.backend_led.dto.ScheduleRequest;
import com.nguyenducphat.backend_led.dto.ScheduleResponse;
import com.nguyenducphat.backend_led.entity.Device;
import com.nguyenducphat.backend_led.entity.Schedule;
import com.nguyenducphat.backend_led.repository.DeviceRepository;
import com.nguyenducphat.backend_led.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduleService {
    
    private final ScheduleRepository scheduleRepository;
    private final DeviceRepository deviceRepository;
    private final MqttService mqttService;
    
    public ScheduleResponse createSchedule(ScheduleRequest request) {
        Device device = deviceRepository.findById(request.getDeviceId())
                .orElseThrow(() -> new RuntimeException("Device not found"));
        
        Schedule schedule = new Schedule();
        schedule.setDevice(device);
        schedule.setTime(LocalTime.parse(request.getTime()));
        schedule.setAction(request.getAction());
        schedule.setEnabled(request.getEnabled() != null ? request.getEnabled() : true);
        schedule.setRepeatDays(request.getRepeatDays() != null ? request.getRepeatDays() : "1,2,3,4,5,6,7");
        schedule.setName(request.getName());
        
        Schedule saved = scheduleRepository.save(schedule);
        
        // 📅 Gửi thông báo schedule tới ESP32 qua MQTT
        try {
            String topic = "smarthome/devices/" + device.getHardwareId() + "/schedule";
            String payload = String.format(
                "{\"time\":\"%s\",\"action\":\"%s\",\"repeatDays\":\"%s\",\"name\":\"%s\"}",
                saved.getTime().toString().substring(0, 5), // HH:mm
                saved.getAction(),
                saved.getRepeatDays(),
                saved.getName() != null ? saved.getName() : "Lịch hẹn"
            );
            mqttService.publish(topic, payload);
            log.info("📅 Schedule notification sent to ESP32: {}", payload);
        } catch (Exception e) {
            log.error("Failed to send schedule notification: {}", e.getMessage());
        }
        
        return toResponse(saved);
    }
    
    public List<ScheduleResponse> getSchedulesByDevice(Long deviceId) {
        return scheduleRepository.findByDeviceId(deviceId)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }
    
    public ScheduleResponse updateSchedule(Long id, ScheduleRequest request) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Schedule not found"));
        
        if (request.getTime() != null) {
            schedule.setTime(LocalTime.parse(request.getTime()));
        }
        if (request.getAction() != null) {
            schedule.setAction(request.getAction());
        }
        if (request.getEnabled() != null) {
            schedule.setEnabled(request.getEnabled());
        }
        if (request.getRepeatDays() != null) {
            schedule.setRepeatDays(request.getRepeatDays());
        }
        if (request.getName() != null) {
            schedule.setName(request.getName());
        }
        
        Schedule updated = scheduleRepository.save(schedule);
        return toResponse(updated);
    }
    
    public void deleteSchedule(Long id) {
        scheduleRepository.deleteById(id);
    }
    
    private ScheduleResponse toResponse(Schedule schedule) {
        return new ScheduleResponse(
                schedule.getId(),
                schedule.getDevice().getId(),
                schedule.getTime().toString(),
                schedule.getAction(),
                schedule.getEnabled(),
                schedule.getRepeatDays(),
                schedule.getName()
        );
    }
}