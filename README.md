# Round Robin Load Balancing at API Gateway – Ride-Sharing Platform

A clean, production-grade Spring Boot microservices project demonstrating **Round Robin Load Balancing** at the API Gateway level using **Spring Cloud Gateway** and **Spring Cloud LoadBalancer**.

---

## 📁 Project Structure

```
round-robin-project/
├── driver-service/
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/example/driver/
│       │   ├── DriverServiceApplication.java
│       │   └── DriverController.java
│       └── resources/
│           └── application.properties
│
├── api-gateway/
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/example/gateway/
│       │   ├── GatewayApplication.java
│       │   └── DriverServiceInstances.java
│       └── resources/
│           └── application.properties
│
├── test-load-balancing.sh       (Bash testing script)
├── test-load-balancing.ps1      (PowerShell testing script)
├── test-load-balancing.bat      (Windows CMD batch script)
└── README.md
```

---

## ⚙️ Prerequisites & Versions
- **Java**: 17+ (Java 17, 21, or 25)
- **Maven**: 3.8+ (or your IDE's bundled Maven)
- **Spring Boot**: `3.2.5`
- **Spring Cloud**: `2023.0.1`

---

## 🚀 How to Run the Project

### Option A: Using Eclipse or IntelliJ IDEA

1. **Import Projects**:
   - Open Eclipse or IntelliJ IDEA.
   - Choose **File > Open / Import Project** -> select `round-robin-project/driver-service` and `round-robin-project/api-gateway`.

2. **Run Driver Service Instances**:
   - Create 3 Run Configurations for `DriverServiceApplication`:
     - **Instance 1**: VM arguments: `-Dserver.port=8081`
     - **Instance 2**: VM arguments: `-Dserver.port=8082`
     - **Instance 3**: VM arguments: `-Dserver.port=8083`
   - Run all three simultaneously.

3. **Run API Gateway**:
   - Run `GatewayApplication` (runs by default on port `8080`).

---

### Option B: Using Terminal / Command Prompt

#### Step 1: Package the projects
Open a terminal in each folder:
```bash
# In driver-service directory:
cd driver-service
mvn clean package -DskipTests

# In api-gateway directory:
cd ../api-gateway
mvn clean package -DskipTests
```

#### Step 2: Start 3 Driver Service Instances (in 3 separate terminal tabs)

- **Terminal 1 (Instance 1 on Port 8081):**
  ```bash
  cd driver-service
  java -Dserver.port=8081 -jar target/driver-service-0.0.1-SNAPSHOT.jar
  # Or via maven plugin:
  # mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8081"
  ```

- **Terminal 2 (Instance 2 on Port 8082):**
  ```bash
  cd driver-service
  java -Dserver.port=8082 -jar target/driver-service-0.0.1-SNAPSHOT.jar
  # Or via maven plugin:
  # mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8082"
  ```

- **Terminal 3 (Instance 3 on Port 8083):**
  ```bash
  cd driver-service
  java -Dserver.port=8083 -jar target/driver-service-0.0.1-SNAPSHOT.jar
  # Or via maven plugin:
  # mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8083"
  ```

#### Step 3: Start the API Gateway (in Terminal 4)

- **Terminal 4 (API Gateway on Port 8080):**
  ```bash
  cd api-gateway
  java -jar target/api-gateway-0.0.1-SNAPSHOT.jar
  # Or via maven plugin:
  # mvn spring-boot:run
  ```

---

## 🧪 Testing & Verification

### 1. Direct Health & Driver Checks (Individual Instances)
```bash
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost:8083/health
curl http://localhost:8081/api/drivers
```

### 2. Verification of Round Robin Load Balancing via API Gateway
Send requests to the API Gateway at `http://localhost:8080/api/drivers`.

#### Run the Automated 15-Request Test Script:
- **Bash / Linux / Mac / Git Bash:**
  ```bash
  chmod +x test-load-balancing.sh
  ./test-load-balancing.sh
  ```
- **PowerShell (Windows):**
  ```powershell
  .\test-load-balancing.ps1
  ```
- **Windows Command Prompt:**
  ```cmd
  test-load-balancing.bat
  ```

#### Expected Distribution:
```
Request 1  -> Handled by: 8081 (driver-instance-8081)
Request 2  -> Handled by: 8082 (driver-instance-8082)
Request 3  -> Handled by: 8083 (driver-instance-8083)
Request 4  -> Handled by: 8081 (driver-instance-8081)
Request 5  -> Handled by: 8082 (driver-instance-8082)
Request 6  -> Handled by: 8083 (driver-instance-8083)
Request 7  -> Handled by: 8081 (driver-instance-8081)
Request 8  -> Handled by: 8082 (driver-instance-8082)
Request 9  -> Handled by: 8083 (driver-instance-8083)
Request 10 -> Handled by: 8081 (driver-instance-8081)
Request 11 -> Handled by: 8082 (driver-instance-8082)
Request 12 -> Handled by: 8083 (driver-instance-8083)
Request 13 -> Handled by: 8081 (driver-instance-8081)
Request 14 -> Handled by: 8082 (driver-instance-8082)
Request 15 -> Handled by: 8083 (driver-instance-8083)
```

**Summary:**
- Instance 8081: 5 requests
- Instance 8082: 5 requests
- Instance 8083: 5 requests
*(Total = 15 requests distributed evenly)*

---

## 🛡️ Failure & Health-Aware Resiliency Testing

1. **Stop Instance 2 (Port 8082)**:
   - In Terminal 2, press `Ctrl + C` (or click Stop in IDE).
2. **Execute requests again**:
   ```bash
   curl http://localhost:8080/api/drivers
   ```
   Or rerun `./test-load-balancing.sh` / `.\test-load-balancing.ps1`.
3. **Observed Behavior**:
   - `DriverServiceInstances` detects that port 8082 is unreachable and dynamically excludes it from the LoadBalancer instance supplier.
   - Traffic now rotates smoothly between the remaining healthy instances:
     - Request 1 -> 8081
     - Request 2 -> 8083
     - Request 3 -> 8081
     - Request 4 -> 8083
   - No dropped requests or 500 errors!

