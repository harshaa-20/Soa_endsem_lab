package com.example.gateway;

import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.DefaultServiceInstance;
import org.springframework.cloud.loadbalancer.core.ServiceInstanceListSupplier;

import reactor.core.publisher.Flux;

@Configuration
public class DriverServiceInstances {

    @Bean
    ServiceInstanceListSupplier serviceInstanceListSupplier() {

        List<ServiceInstance> instances = Arrays.asList(
            new DefaultServiceInstance("driver1", "driver-service", "localhost", 8081, false),
            new DefaultServiceInstance("driver2", "driver-service", "localhost", 8082, false),
            new DefaultServiceInstance("driver3", "driver-service", "localhost", 8083, false)
        );

        return new ServiceInstanceListSupplier() {

            @Override
            public String getServiceId() {
                return "driver-service";
            }

            @Override
            public Flux<List<ServiceInstance>> get() {
                // Health-aware selection: filter and return only reachable instances
                List<ServiceInstance> healthyInstances = instances.stream()
                        .filter(DriverServiceInstances::isInstanceHealthy)
                        .collect(Collectors.toList());

                // Fallback to all instances if probe returns empty (e.g., initial startup)
                if (healthyInstances.isEmpty()) {
                    return Flux.just(instances);
                }

                return Flux.just(healthyInstances);
            }
        };
    }

    /**
     * Checks if a backend instance is reachable by opening a quick socket connection.
     * Stopped instances are excluded from the LoadBalancer rotation.
     */
    private static boolean isInstanceHealthy(ServiceInstance instance) {
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress(instance.getHost(), instance.getPort()), 150);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}

