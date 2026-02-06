package com.nguyenducphat.backend_led.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeviceResponse {
    private Long id;
    private String name;
    private String hardwareId;

    private String type;
    private String image;
    
    @JsonProperty("isOn")
    private boolean isOn;
    
    @JsonProperty("isCamera")
    private boolean isCamera;
    
    private String roomName;
    private Long roomId;
}
