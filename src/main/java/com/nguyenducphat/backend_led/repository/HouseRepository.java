package com.nguyenducphat.backend_led.repository;

import com.nguyenducphat.backend_led.entity.House;
import com.nguyenducphat.backend_led.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface HouseRepository extends JpaRepository<House, UUID> {
    List<House> findByOwner(User owner);
}
