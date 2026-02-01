package com.nguyenducphat.backend_led;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class BackendLedApplication {

	public static void main(String[] args) {
		SpringApplication.run(BackendLedApplication.class, args);
	}

}
