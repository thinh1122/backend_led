package com.nguyenducphat.backend_led.service;

import com.nguyenducphat.backend_led.dto.HouseRequest;
import com.nguyenducphat.backend_led.dto.HouseResponse;
import com.nguyenducphat.backend_led.entity.House;
import com.nguyenducphat.backend_led.entity.Room;
import com.nguyenducphat.backend_led.entity.User;
import com.nguyenducphat.backend_led.repository.HouseRepository;
import com.nguyenducphat.backend_led.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HouseService {
    private final HouseRepository houseRepository;
    private final UserRepository userRepository;

    @Transactional
    public HouseResponse createHouse(HouseRequest request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User không tồn tại!"));

        House house = House.builder()
                .name(request.getName())
                .address(request.getAddress())
                .owner(user)
                .build();

        if (request.getRoomNames() != null) {
            List<Room> rooms = request.getRoomNames().stream()
                    .map(name -> Room.builder()
                            .name(name)
                            .house(house)
                            .build())
                    .collect(Collectors.toList());
            house.setRooms(rooms);
        }

        House savedHouse = houseRepository.save(house);
        return mapToResponse(savedHouse);
    }

    public List<HouseResponse> getMyHouses() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User không tồn tại!"));

        return houseRepository.findByOwner(user).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public HouseResponse.RoomResponse addRoom(Long houseId, com.nguyenducphat.backend_led.dto.RoomRequest request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User không tồn tại!"));

        House house = houseRepository.findById(houseId)
                .orElseThrow(() -> new RuntimeException("House không tồn tại!"));

        if (!house.getOwner().getId().equals(user.getId())) {
            throw new RuntimeException("Không có quyền truy cập house này!");
        }

        Room room = Room.builder()
                .name(request.getName())
                .house(house)
                .build();

        house.getRooms().add(room);
        houseRepository.save(house);

        return HouseResponse.RoomResponse.builder()
                .id(room.getId())
                .name(room.getName())
                .build();
    }

    private HouseResponse mapToResponse(House house) {
        return HouseResponse.builder()
                .id(house.getId())
                .name(house.getName())
                .address(house.getAddress())
                .rooms(house.getRooms().stream()
                        .map(room -> HouseResponse.RoomResponse.builder()
                                .id(room.getId())
                                .name(room.getName())
                                .build())
                        .collect(Collectors.toList()))
                .build();
    }
}
