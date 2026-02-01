package com.nguyenducphat.backend_led.repository;

import com.nguyenducphat.backend_led.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, UUID> {
    List<Schedule> findByDeviceId(UUID deviceId);
    List<Schedule> findByDeviceIdAndEnabled(UUID deviceId, Boolean enabled);
    List<Schedule> findByEnabled(Boolean enabled);
}
