package com.nguyenducphat.backend_led.repository;

import com.nguyenducphat.backend_led.entity.Device;
import com.nguyenducphat.backend_led.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DeviceRepository extends JpaRepository<Device, UUID> {
    @Query("SELECT d FROM Device d WHERE d.room.house.owner = :owner")
    List<Device> findByOwner(@Param("owner") User owner);

    java.util.Optional<Device> findByHardwareId(String hardwareId);
}
