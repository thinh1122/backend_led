package com.nguyenducphat.backend_led.controller;

import com.nguyenducphat.backend_led.dto.ScheduleRequest;
import com.nguyenducphat.backend_led.dto.ScheduleResponse;
import com.nguyenducphat.backend_led.service.ScheduleService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {
    
    private final ScheduleService scheduleService;
    
    @PostMapping
    public ResponseEntity<ScheduleResponse> createSchedule(@RequestBody ScheduleRequest request) {
        return ResponseEntity.ok(scheduleService.createSchedule(request));
    }
    
    @GetMapping("/device/{deviceId}")
    public ResponseEntity<List<ScheduleResponse>> getSchedulesByDevice(@PathVariable Long deviceId) {
        return ResponseEntity.ok(scheduleService.getSchedulesByDevice(deviceId));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ScheduleResponse> updateSchedule(
            @PathVariable Long id,
            @RequestBody ScheduleRequest request) {
        return ResponseEntity.ok(scheduleService.updateSchedule(id, request));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSchedule(@PathVariable Long id) {
        scheduleService.deleteSchedule(id);
        return ResponseEntity.ok().build();
    }
}
