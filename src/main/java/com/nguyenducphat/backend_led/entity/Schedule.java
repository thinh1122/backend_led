package com.nguyenducphat.backend_led.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "schedules")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Schedule {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne
    @JoinColumn(name = "device_id", nullable = false)
    private Device device;
    
    @Column(nullable = false)
    private LocalTime time; // Giờ hẹn (HH:mm)
    
    @Column(nullable = false)
    private String action; // "ON" hoặc "OFF"
    
    @Column(nullable = false)
    private Boolean enabled = true; // Bật/tắt lịch hẹn
    
    @Column(nullable = false)
    private String repeatDays = "1,2,3,4,5,6,7"; // Lặp lại theo ngày (1=CN, 2=T2, ..., 7=T7)
    
    private String name; // Tên lịch hẹn (VD: "Bật đèn sáng")
}
