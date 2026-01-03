package com.nguyenducphat.backend_led.controller;

import com.nguyenducphat.backend_led.dto.HouseRequest;
import com.nguyenducphat.backend_led.dto.HouseResponse;
import com.nguyenducphat.backend_led.service.HouseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/houses")
@RequiredArgsConstructor
public class HouseController {
    private final HouseService houseService;

    @PostMapping
    public ResponseEntity<HouseResponse> createHouse(@RequestBody HouseRequest request) {
        return ResponseEntity.ok(houseService.createHouse(request));
    }

    @GetMapping
    public ResponseEntity<List<HouseResponse>> getMyHouses() {
        return ResponseEntity.ok(houseService.getMyHouses());
    }
}
