package com.nguyenducphat.backend_led.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeviceRequest {
    private String name;
    private String hardwareId;

    private String type;
    private String image;
    private boolean isCamera;
    private Long roomId; // Optional: if null, assign to a default room
}
