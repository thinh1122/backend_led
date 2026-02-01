package com.nguyenducphat.backend_led.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleResponse {
    private UUID id;
    private UUID deviceId;
    private String time; // "HH:mm"
    private String action; // "ON" hoặc "OFF"
    private Boolean enabled;
    private String repeatDays; // "1,2,3,4,5,6,7"
    private String name;
}
