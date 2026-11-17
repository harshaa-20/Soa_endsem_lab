# SOA End-Sem Lab Viva & Conceptual Guide
## Project: Round Robin Load Balancing at API Gateway (Ride-Sharing Platform)

---

### 1. What is Service-Oriented Architecture (SOA) and how does this project demonstrate it?
- **SOA Definition**: An architectural style where software components (services) communicate over a network via standard protocols (like HTTP/REST) with loose coupling.
- **In this project**:
  - The **API Gateway** acts as the single point of entry (Service Consumer / Reverse Proxy).
  - The **Driver Service** represents an independent, loosely coupled microservice provider with multiple instances handling ride-sharing traffic.

---

### 2. What is an API Gateway and why is it needed in Microservices?
- **Single Entry Point**: Clients (mobile app, web app) communicate with only one endpoint (`http://localhost:8080`) instead of tracking multiple dynamic ports (`8081`, `8082`, `8083`).
- **Load Balancing**: Distributes incoming requests evenly across instances to prevent server overload.
- **Decoupling & Abstraction**: Internal IP addresses, ports, and microservice topology are hidden from external clients.
- **Cross-Cutting Concerns**: Facilitates centralized routing, authentication, SSL termination, rate limiting, and metrics collection.

---

### 3. How does Round Robin Load Balancing work?
- **Concept**: A deterministic, cyclic scheduling algorithm. Given $N$ instances ($I_1, I_2, \dots, I_N$), incoming requests are directed sequentially:
  $$\text{Request } 1 \to I_1, \quad \text{Request } 2 \to I_2, \quad \dots, \quad \text{Request } N \to I_N, \quad \text{Request } N+1 \to I_1$$
- **Uniform Distribution**: Over a batch of $M$ requests where $M$ is a multiple of $N$, each instance receives exactly $M / N$ requests.
- **In our 15-request test**: With 3 instances ($N=3$), each instance processes exactly $15 / 3 = 5$ requests.

---

### 4. What is the difference between Client-Side and Server-Side Load Balancing?
| Feature | Server-Side Load Balancing (e.g., Nginx, AWS ALB, F5) | Client-Side Load Balancing (Spring Cloud LoadBalancer) |
|---|---|---|
| **Where it occurs** | Dedicated hardware/software appliance between client and server | Inside the consumer/gateway application process |
| **Hops** | Extra network hop (Client $\to$ Load Balancer $\to$ Service) | Direct call from Gateway to target service instance |
| **Instance Knowledge** | Load balancer maintains backend pool | Client/Gateway maintains or discovers service instance pool |
| **Single Point of Failure**| Load balancer itself can become a bottleneck | Distributed across consumers |

*Note: In our architecture, the API Gateway performs client-side load balancing when proxying downstream to the Driver Service.*

---

### 5. Why was Netflix Ribbon replaced by Spring Cloud LoadBalancer?
- **Maintenance**: Netflix stopped active development on Ribbon and entered maintenance mode.
- **Reactive Stack**: Spring Cloud Gateway is built on non-blocking reactive streams (Project Reactor / Netty). Ribbon was blocking (Servlet/Tomcat-based) and incompatible with reactive gateways.
- **Spring Cloud LoadBalancer**: The official non-blocking, reactive successor provided by the Spring Cloud team.

---

### 6. How does Spring Cloud Gateway route requests?
Routing is governed by three fundamental concepts:
1. **Route ID**: Unique identifier for the route (`driver-service`).
2. **Predicate**: Matching criteria based on HTTP requests (e.g., `Path=/api/drivers/**`). If matched, the request is routed.
3. **URI**: Target destination. Using `lb://driver-service` triggers Spring Cloud LoadBalancer to resolve the virtual service name `driver-service` into an actual physical host and port (`localhost:8081`, `localhost:8082`, etc.).

---

### 7. How is Health-Aware Failover implemented in this project?
- In static configurations, a naive list supplier sends requests to offline instances, causing HTTP 500/Connection Refused errors.
- In our [`DriverServiceInstances.java`](file:///c:/Users/91965/Desktop/soa%20endsemlab/round-robin-project/api-gateway/src/main/java/com/example/gateway/DriverServiceInstances.java), we implement active reachability verification (`isInstanceHealthy`):
  - When port 8082 is stopped, the connection check fails.
  - The supplier dynamically filters out `8082` and yields `[8081, 8083]`.
  - Spring Cloud LoadBalancer immediately rotates only across healthy nodes ($8081 \to 8083 \to 8081 \to 8083$), achieving zero downtime.

---

### 8. Why is `spring-boot-starter-web` excluded from the API Gateway `pom.xml`?
- `spring-cloud-starter-gateway` is built on **Spring WebFlux** and **Netty** (asynchronous, non-blocking I/O).
- `spring-boot-starter-web` pulls in **Spring MVC** and **embedded Tomcat** (blocking I/O).
- If both are present on the classpath, Spring Boot fails to start with:
  > *"Spring MVC found on classpath, which is incompatible with Spring Cloud Gateway."*
- Therefore, API Gateway uses WebFlux/Gateway, while Driver Service uses standard Spring MVC (`spring-boot-starter-web`).

