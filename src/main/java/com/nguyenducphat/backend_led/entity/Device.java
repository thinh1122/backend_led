package com.nguyenducphat.backend_led.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "devices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Device {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(name = "hardware_id")
    private String hardwareId; // Hardware ID (e.g. esp32_001) for MQTT

    private String type; // e.g., Wi-Fi, Bluetooth

    private String image; // Asset path or URL

    @Column(name = "is_on")
    private boolean isOn;

    @Column(name = "is_camera")
    private boolean isCamera;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;
}
