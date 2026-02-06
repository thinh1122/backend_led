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
     * 
     * ⚠️ CATCH-UP MECHANISM: Nếu backend bị sleep/restart, sẽ check lịch hẹn
     * trong 5 phút vừa qua để bù lại lịch bị bỏ lỡ
     */
    @Scheduled(cron = "0 * * * * *")
    public void checkAndExecuteSchedules() {
        LocalDateTime now = LocalDateTime.now();
        LocalTime currentTime = now.toLocalTime();
        int currentDayOfWeek = now.getDayOfWeek().getValue();
        int appDayOfWeek = currentDayOfWeek == 7 ? 1 : currentDayOfWeek + 1;
        
        // ⏰ LOG: Thời gian hiện tại
        log.info("⏰ ========== SCHEDULER CHECK: {} ({})==========", 
                currentTime.toString().substring(0, 5), 
                getDayName(appDayOfWeek));
        
        List<Schedule> allSchedules = scheduleRepository.findByEnabled(true);
        
        if (allSchedules.isEmpty()) {
            log.info("📋 No active schedules found.");
            return;
        }
        
        log.info("📋 Total active schedules: {}", allSchedules.size());
        
        // Tìm lịch hẹn gần nhất
        Schedule nextSchedule = null;
        long minMinutesUntilNext = Long.MAX_VALUE;
        
        for (Schedule schedule : allSchedules) {
            LocalTime scheduleTime = schedule.getTime();
            
            // Tính thời gian còn lại đến lịch hẹn này
            long minutesUntil = calculateMinutesUntil(currentTime, scheduleTime);
            
            // ✅ CHECK 1: Thời gian chính xác (giờ:phút)
            boolean isExactTime = scheduleTime.getHour() == currentTime.getHour() && 
                                  scheduleTime.getMinute() == currentTime.getMinute();
            
            // 🔄 CHECK 2: CATCH-UP - Lịch hẹn bị bỏ lỡ trong 5 phút vừa qua
            boolean isMissedRecently = false;
            LocalDateTime fiveMinutesAgo = now.minusMinutes(5);
            LocalDateTime scheduleDateTime = now.withHour(scheduleTime.getHour())
                                                .withMinute(scheduleTime.getMinute())
                                                .withSecond(0)
                                                .withNano(0);
            
            // Nếu schedule time nằm trong [5 phút trước -> hiện tại]
            // VÀ chưa execute trong 10 phút gần đây (tránh spam)
            if (scheduleDateTime.isAfter(fiveMinutesAgo) && 
                scheduleDateTime.isBefore(now)) {
                
                // Kiểm tra lastExecutedAt để tránh execute nhiều lần
                if (schedule.getLastExecutedAt() == null || 
                    schedule.getLastExecutedAt().isBefore(now.minusMinutes(10))) {
                    isMissedRecently = true;
                    log.warn("🔄 CATCH-UP: Found missed schedule '{}' at {} (current: {})", 
                            schedule.getName(), scheduleTime, currentTime);
                }
            }
            
            // Execute nếu match thời gian HOẶC bị bỏ lỡ gần đây
            if ((isExactTime || isMissedRecently) && 
                isScheduleActiveToday(schedule.getRepeatDays(), appDayOfWeek)) {
                executeSchedule(schedule);
            } else {
                // Track lịch hẹn gần nhất
                if (isScheduleActiveToday(schedule.getRepeatDays(), appDayOfWeek) && 
                    minutesUntil > 0 && minutesUntil < minMinutesUntilNext) {
                    nextSchedule = schedule;
                    minMinutesUntilNext = minutesUntil;
                }
            }
        }
        
        // ⏳ LOG: Countdown đến lịch hẹn tiếp theo
        if (nextSchedule != null) {
            long hours = minMinutesUntilNext / 60;
            long minutes = minMinutesUntilNext % 60;
            log.info("⏳ Next schedule: '{}' at {} (in {}h {}m)", 
                    nextSchedule.getName(), 
                    nextSchedule.getTime().toString().substring(0, 5),
                    hours, minutes);
        } else {
            log.info("⏳ No upcoming schedules today.");
        }
        
        log.info("=".repeat(60));
    }
    
    /**
     * Tính số phút từ hiện tại đến thời gian hẹn
     */
    private long calculateMinutesUntil(LocalTime current, LocalTime target) {
        int currentMinutes = current.getHour() * 60 + current.getMinute();
        int targetMinutes = target.getHour() * 60 + target.getMinute();
        
        if (targetMinutes > currentMinutes) {
            return targetMinutes - currentMinutes;
        } else {
            // Lịch hẹn vào ngày mai
            return (24 * 60 - currentMinutes) + targetMinutes;
        }
    }
    
    /**
     * Lấy tên ngày trong tuần
     */
    private String getDayName(int day) {
        switch (day) {
            case 1: return "Sunday";
            case 2: return "Monday";
            case 3: return "Tuesday";
            case 4: return "Wednesday";
            case 5: return "Thursday";
            case 6: return "Friday";
            case 7: return "Saturday";
            default: return "Unknown";
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
            
            // ✅ Cập nhật lastExecutedAt để tránh execute lại
            schedule.setLastExecutedAt(LocalDateTime.now());
            scheduleRepository.save(schedule);
            
            log.info("✅ Schedule executed successfully: {}", schedule.getName());
            
        } catch (Exception e) {
            log.error("❌ Failed to execute schedule: {} - Error: {}", 
                    schedule.getName(), e.getMessage());
        }
    }
}
