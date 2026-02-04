package com.nguyenducphat.backend_led.repository;

import com.nguyenducphat.backend_led.entity.House;
import com.nguyenducphat.backend_led.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomRepository extends JpaRepository<Room, Long> {
    List<Room> findByHouse(House house);
    List<Room> findByHouseId(Long houseId);
}
