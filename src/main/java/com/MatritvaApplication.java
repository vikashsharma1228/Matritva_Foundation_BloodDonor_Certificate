package com;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
@EnableAsync
@SpringBootApplication
@EnableScheduling

public class MatritvaApplication {
    public static void main(String[] args) {
        SpringApplication.run(MatritvaApplication.class, args);
    }
}