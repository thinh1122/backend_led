package com.nguyenducphat.backend_led.repository;

import com.nguyenducphat.backend_led.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findByDeviceId(Long deviceId);
    List<Schedule> findByDeviceIdAndEnabled(Long deviceId, Boolean enabled);
    List<Schedule> findByEnabled(Boolean enabled);
}
