package com.nguyenducphat.backend_led.controller;

import com.nguyenducphat.backend_led.dto.DeviceResponse;
import com.nguyenducphat.backend_led.service.DeviceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/devices")
@RequiredArgsConstructor
public class DeviceController {
    private final DeviceService deviceService;

    @GetMapping
    public ResponseEntity<List<DeviceResponse>> getMyDevices() {
        return ResponseEntity.ok(deviceService.getMyDevices());
    }

    @PostMapping
    public ResponseEntity<DeviceResponse> addDevice(@RequestBody com.nguyenducphat.backend_led.dto.DeviceRequest request) {
        return ResponseEntity.ok(deviceService.addDevice(request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteDevice(@PathVariable java.util.UUID id) {
        deviceService.deleteDevice(id);
        return ResponseEntity.ok("Deleted successfully");
    }

    @PostMapping("/{id}/toggle")
    public ResponseEntity<String> toggleDevice(@PathVariable java.util.UUID id, @RequestParam boolean isOn) {
        deviceService.toggleDevice(id, isOn);
        return ResponseEntity.ok(isOn ? "Device turned ON" : "Device turned OFF");
    }
}
