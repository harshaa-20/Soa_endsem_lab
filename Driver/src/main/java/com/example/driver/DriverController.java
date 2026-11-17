package com.example.driver;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@RestController
public class DriverController {

    @Value("${server.port:8081}")
    private String serverPort;

    @GetMapping("/api/drivers")
    public Map<String, Object> getDrivers() {
        Map<String, Object> response = new HashMap<>();

        String port = System.getProperty("server.port", serverPort);
        response.put("instanceId", "driver-instance-" + port);
        response.put("port", port);
        response.put("message", "Request handled successfully");

        response.put("drivers", Arrays.asList(
                Map.of("id", 101, "name", "Rahul", "available", true),
                Map.of("id", 102, "name", "Arjun", "available", true)
        ));

        return response;
    }

    @GetMapping({"/health", "/api/drivers/health"})
    public String health() {
        String port = System.getProperty("server.port", serverPort);
        return "Driver Service is running on port " + port;
    }
}

