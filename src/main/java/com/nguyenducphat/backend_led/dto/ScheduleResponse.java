package com.nguyenducphat.backend_led.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleResponse {
    private Long id;
    private Long deviceId;
    private String time; // "HH:mm"
    private String action; // "ON" hoặc "OFF"
    private Boolean enabled;
    private String repeatDays; // "1,2,3,4,5,6,7"
    private String name;
}
