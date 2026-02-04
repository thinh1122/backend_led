package com.nguyenducphat.backend_led.service;

import com.nguyenducphat.backend_led.entity.Schedule;
import com.nguyenducphat.backend_led.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class SchedulerTaskService {
    
    private final ScheduleRepository scheduleRepository;
    private final MqttService mqttService;
    
    /**
     * Chạy mỗi phút để kiểm tra lịch hẹn
     * Cron: "0 * * * * *" = Giây 0 của mỗi phút
     */
    @Scheduled(cron = "0 * * * * *")
    public void checkAndExecuteSchedules() {
        LocalDateTime now = LocalDateTime.now();
        LocalTime currentTime = now.toLocalTime();
        int currentDayOfWeek = now.getDayOfWeek().getValue(); // 1=Monday, 7=Sunday
        
        // Chuyển đổi: Java (1=Mon, 7=Sun) -> App (1=Sun, 2=Mon, ..., 7=Sat)
        // Java: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
        // App:  1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
        int appDayOfWeek = currentDayOfWeek == 7 ? 1 : currentDayOfWeek + 1;
        
        log.debug("⏰ Checking schedules at {} (Day: {})", currentTime, appDayOfWeek);
        
        // Lấy tất cả lịch hẹn đang bật
        List<Schedule> allSchedules = scheduleRepository.findByEnabled(true);
        
        for (Schedule schedule : allSchedules) {
            // Kiểm tra thời gian (chỉ so sánh giờ:phút, bỏ giây)
            LocalTime scheduleTime = schedule.getTime();
            if (scheduleTime.getHour() == currentTime.getHour() && 
                scheduleTime.getMinute() == currentTime.getMinute()) {
                
                // Kiểm tra ngày lặp lại
                if (isScheduleActiveToday(schedule.getRepeatDays(), appDayOfWeek)) {
                    executeSchedule(schedule);
                }
            }
        }
    }
    
    /**
     * Kiểm tra lịch hẹn có active vào ngày hôm nay không
     * @param repeatDays "1,2,3,4,5,6,7" (1=CN, 2=T2, ..., 7=T7)
     * @param currentDay Ngày hiện tại (1-7)
     */
    private boolean isScheduleActiveToday(String repeatDays, int currentDay) {
        if (repeatDays == null || repeatDays.isEmpty()) {
            return true; // Mặc định: chạy mọi ngày
        }
        
        List<String> days = Arrays.asList(repeatDays.split(","));
        return days.contains(String.valueOf(currentDay));
    }
    
    /**
     * Thực thi lịch hẹn: Gửi lệnh MQTT
     */
    private void executeSchedule(Schedule schedule) {
        try {
            String deviceHwId = schedule.getDevice().getHardwareId();
            String action = schedule.getAction(); // "ON" hoặc "OFF"
            String topic = "smarthome/devices/" + deviceHwId + "/set";
            
            log.info("🚀 Executing schedule: {} - Device: {} - Action: {}", 
                    schedule.getName(), deviceHwId, action);
            
            // Gửi lệnh qua MQTT
            mqttService.publish(topic, action);
            
            log.info("✅ Schedule executed successfully: {}", schedule.getName());
            
        } catch (Exception e) {
            log.error("❌ Failed to execute schedule: {} - Error: {}", 
                    schedule.getName(), e.getMessage());
        }
    }
}
