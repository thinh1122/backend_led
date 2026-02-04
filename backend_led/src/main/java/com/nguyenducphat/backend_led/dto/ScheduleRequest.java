package com.nguyenducphat.backend_led.dto;

import lombok.Data;

@Data
public class ScheduleRequest {
    private Long deviceId;
    private String time; // Format: "HH:mm" (VD: "07:00")
    private String action; // "ON" hoặc "OFF"
    private Boolean enabled;
    private String repeatDays; // "1,2,3,4,5,6,7" (1=CN, 2=T2, ..., 7=T7)
    private String name; // Tên lịch hẹn
}
