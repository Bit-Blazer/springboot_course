summary: Build a microservices ecosystem with service registry, API gateway, and inter-service communication using Spring Cloud
id: microservices-architecture
categories: Spring Boot, Microservices, Spring Cloud, Eureka, API Gateway
environments: Web
status: Published

# Microservices Architecture & Implementation

## Introduction

Duration: 3:00

Build a complete microservices ecosystem with service discovery, API gateway, and inter-service communication.

### What You'll Learn

- **Architecture Evolution:** Monolith to microservices
- **Service Registry:** Eureka Server for service discovery
- **API Gateway:** Spring Cloud Gateway for routing
- **Load Balancing:** Client-side load balancing
- **Service Communication:** OpenFeign for REST calls
- **Configuration:** Externalized config patterns
- **Health Checks:** Actuator endpoints
- **Docker Compose:** Multi-service orchestration

### What You'll Build

Complete E-Commerce Microservices System:

- **Eureka Server:** Service registry (port 8761)
- **API Gateway:** Single entry point (port 8080)
- **Product Service:** Manage products (port 8081, 8082 for load balancing)
- **Order Service:** Manage orders, calls Product Service (port 8083)

**Architecture:**

```
Client → API Gateway → Product Service
              ↓            ↓
         Eureka Server ← Order Service
```

### Prerequisites

- Completed previous Spring Boot codelabs
- Understanding of REST APIs
- Docker Desktop installed
- Maven 3.6+
- JDK 17+

### Microservices Benefits

**Advantages:**

- Independent deployment
- Technology diversity
- Team autonomy
- Scalability (scale services independently)
- Fault isolation

**Challenges:**

- Distributed system complexity
- Network latency
- Data consistency
- Testing complexity
- Operational overhead

> aside positive
> **When to Use:** Microservices work best for large, complex applications with multiple teams. Start with a monolith, migrate when needed.

## Create Parent Project

Duration: 5:00

Set up Maven multi-module project structure.

### Project Structure

```
ecommerce-microservices/
├── pom.xml (parent)
├── eureka-server/
├── api-gateway/
├── product-service/
├── order-service/
└── docker-compose.yml
```

### Parent POM

**pom.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.1</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>ecommerce-microservices</artifactId>
    <version>1.0.0</version>
    <packaging>pom</packaging>

    <properties>
        <java.version>17</java.version>
        <spring-cloud.version>2023.0.0</spring-cloud.version>
    </properties>

    <modules>
        <module>eureka-server</module>
        <module>api-gateway</module>
        <module>product-service</module>
        <module>order-service</module>
    </modules>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

### Create Modules

```bash
mkdir ecommerce-microservices
cd ecommerce-microservices

# Create parent POM (as shown above)

# Create module directories
mkdir eureka-server api-gateway product-service order-service
```

## Eureka Server - Service Registry

Duration: 10:00

Build service registry for service discovery.

### Eureka Server POM

**eureka-server/pom.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.example</groupId>
        <artifactId>ecommerce-microservices</artifactId>
        <version>1.0.0</version>
    </parent>

    <artifactId>eureka-server</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
    </dependencies>
</project>
```

### Eureka Application

**src/main/java/com/example/eureka/EurekaServerApplication.java:**

```java
package com.example.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

### Eureka Configuration

**src/main/resources/application.yml:**

```yaml
spring:
  application:
    name: eureka-server

server:
  port: 8761

eureka:
  instance:
    hostname: localhost
  client:
    register-with-eureka: false # Don't register self
    fetch-registry: false # Don't fetch registry
    service-url:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
  server:
    wait-time-in-ms-when-sync-empty: 0
```

### Test Eureka Server

```bash
cd eureka-server
mvn spring-boot:run
```

Open http://localhost:8761 - Eureka Dashboard should show no registered services yet.

> aside positive
> **Eureka Dashboard:** Web UI showing all registered services, instances, and health status.

## Product Service

Duration: 12:00

Build Product Service with Eureka client.

### Product Service POM

**product-service/pom.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.example</groupId>
        <artifactId>ecommerce-microservices</artifactId>
        <version>1.0.0</version>
    </parent>

    <artifactId>product-service</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>
</project>
```

### Product Model

**src/main/java/com/example/product/model/Product.java:**

```java
package com.example.product.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {
    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private Integer stock;
}
```

### Product Service

**src/main/java/com/example/product/service/ProductService.java:**

```java
package com.example.product.service;

import com.example.product.model.Product;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class ProductService {

    private final Map<Long, Product> products = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    public ProductService() {
        // Initialize with sample data
        createProduct(new Product(null, "Laptop", "High-performance laptop",
            new BigDecimal("1299.99"), 50));
        createProduct(new Product(null, "Mouse", "Wireless mouse",
            new BigDecimal("29.99"), 200));
        createProduct(new Product(null, "Keyboard", "Mechanical keyboard",
            new BigDecimal("89.99"), 100));
    }

    public List<Product> getAllProducts() {
        return new ArrayList<>(products.values());
    }

    public Optional<Product> getProductById(Long id) {
        return Optional.ofNullable(products.get(id));
    }

    public Product createProduct(Product product) {
        product.setId(idGenerator.getAndIncrement());
        products.put(product.getId(), product);
        return product;
    }

    public boolean checkStock(Long productId, Integer quantity) {
        Product product = products.get(productId);
        return product != null && product.getStock() >= quantity;
    }

    public boolean reduceStock(Long productId, Integer quantity) {
        Product product = products.get(productId);
        if (product != null && product.getStock() >= quantity) {
            product.setStock(product.getStock() - quantity);
            return true;
        }
        return false;
    }
}
```

### Product Controller

**src/main/java/com/example/product/controller/ProductController.java:**

```java
package com.example.product.controller;

import com.example.product.model.Product;
import com.example.product.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private static final Logger log = LoggerFactory.getLogger(ProductController.class);

    private final ProductService productService;

    @Value("${server.port}")
    private String serverPort;

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        log.info("Getting all products from instance on port: {}", serverPort);
        return ResponseEntity.ok(productService.getAllProducts());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        log.info("Getting product {} from instance on port: {}", id, serverPort);
        return productService.getProductById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        Product created = productService.createProduct(product);
        return ResponseEntity.ok(created);
    }

    @PostMapping("/{id}/check-stock")
    public ResponseEntity<Boolean> checkStock(
            @PathVariable Long id,
            @RequestParam Integer quantity) {
        boolean available = productService.checkStock(id, quantity);
        return ResponseEntity.ok(available);
    }

    @PostMapping("/{id}/reduce-stock")
    public ResponseEntity<Boolean> reduceStock(
            @PathVariable Long id,
            @RequestParam Integer quantity) {
        boolean success = productService.reduceStock(id, quantity);
        return ResponseEntity.ok(success);
    }
}
```

### Product Application

**src/main/java/com/example/product/ProductServiceApplication.java:**

```java
package com.example.product;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ProductServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ProductServiceApplication.class, args);
    }
}
```

### Product Configuration

**src/main/resources/application.yml:**

```yaml
spring:
  application:
    name: product-service

server:
  port: 8081

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
  instance:
    prefer-ip-address: true

management:
  endpoints:
    web:
      exposure:
        include: health,info
```

### Test Product Service

```bash
cd product-service
mvn spring-boot:run
```

Check Eureka Dashboard - `PRODUCT-SERVICE` should be registered.

Test API:

```bash
curl http://localhost:8081/api/products
```

## Order Service with Feign

Duration: 15:00

Build Order Service that communicates with Product Service via Feign.

### Order Service POM

**order-service/pom.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.example</groupId>
        <artifactId>ecommerce-microservices</artifactId>
        <version>1.0.0</version>
    </parent>

    <artifactId>order-service</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>
</project>
```

### Order Models

**src/main/java/com/example/order/model/Order.java:**

```java
package com.example.order.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    private Long id;
    private String customerName;
    private List<OrderItem> items;
    private BigDecimal totalAmount;
    private OrderStatus status;
    private LocalDateTime createdAt;
}
```

**src/main/java/com/example/order/model/OrderItem.java:**

```java
package com.example.order.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderItem {
    private Long productId;
    private String productName;
    private Integer quantity;
}
```

**src/main/java/com/example/order/model/OrderStatus.java:**

```java
package com.example.order.model;

public enum OrderStatus {
    PENDING, CONFIRMED, CANCELLED
}
```

### Feign Client

**src/main/java/com/example/order/client/ProductClient.java:**

```java
package com.example.order.client;

import com.example.order.dto.ProductDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "product-service")
public interface ProductClient {

    @GetMapping("/api/products/{id}")
    ProductDto getProduct(@PathVariable Long id);

    @PostMapping("/api/products/{id}/check-stock")
    Boolean checkStock(@PathVariable Long id, @RequestParam Integer quantity);

    @PostMapping("/api/products/{id}/reduce-stock")
    Boolean reduceStock(@PathVariable Long id, @RequestParam Integer quantity);
}
```

**src/main/java/com/example/order/dto/ProductDto.java:**

```java
package com.example.order.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class ProductDto {
    private Long id;
    private String name;
    private BigDecimal price;
    private Integer stock;
}
```

### Order Service

**src/main/java/com/example/order/service/OrderService.java:**

```java
package com.example.order.service;

import com.example.order.client.ProductClient;
import com.example.order.dto.ProductDto;
import com.example.order.model.Order;
import com.example.order.model.OrderItem;
import com.example.order.model.OrderStatus;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
@RequiredArgsConstructor
public class OrderService {

    private static final Logger log = LoggerFactory.getLogger(OrderService.class);

    private final ProductClient productClient;
    private final Map<Long, Order> orders = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    public List<Order> getAllOrders() {
        return new ArrayList<>(orders.values());
    }

    public Optional<Order> getOrderById(Long id) {
        return Optional.ofNullable(orders.get(id));
    }

    public Order createOrder(String customerName, List<OrderItem> items) {
        log.info("Creating order for customer: {}", customerName);

        // Check stock for all items
        for (OrderItem item : items) {
            log.info("Checking stock for product: {}", item.getProductId());
            Boolean stockAvailable = productClient.checkStock(
                item.getProductId(),
                item.getQuantity()
            );

            if (!stockAvailable) {
                throw new RuntimeException(
                    "Insufficient stock for product: " + item.getProductId()
                );
            }
        }

        // Calculate total and get product names
        BigDecimal total = BigDecimal.ZERO;
        for (OrderItem item : items) {
            ProductDto product = productClient.getProduct(item.getProductId());
            item.setProductName(product.getName());

            BigDecimal itemTotal = product.getPrice()
                .multiply(BigDecimal.valueOf(item.getQuantity()));
            total = total.add(itemTotal);
        }

        // Reduce stock for all items
        for (OrderItem item : items) {
            log.info("Reducing stock for product: {}", item.getProductId());
            productClient.reduceStock(item.getProductId(), item.getQuantity());
        }

        // Create order
        Order order = new Order(
            idGenerator.getAndIncrement(),
            customerName,
            items,
            total,
            OrderStatus.CONFIRMED,
            LocalDateTime.now()
        );

        orders.put(order.getId(), order);
        log.info("Order created: {}", order.getId());

        return order;
    }
}
```

### Order Controller

**src/main/java/com/example/order/controller/OrderController.java:**

```java
package com.example.order.controller;

import com.example.order.dto.CreateOrderRequest;
import com.example.order.model.Order;
import com.example.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public ResponseEntity<List<Order>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(@PathVariable Long id) {
        return orderService.getOrderById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody CreateOrderRequest request) {
        Order order = orderService.createOrder(
            request.getCustomerName(),
            request.getItems()
        );
        return ResponseEntity.ok(order);
    }
}
```

**src/main/java/com/example/order/dto/CreateOrderRequest.java:**

```java
package com.example.order.dto;

import com.example.order.model.OrderItem;
import lombok.Data;
import java.util.List;

@Data
public class CreateOrderRequest {
    private String customerName;
    private List<OrderItem> items;
}
```

### Order Application

**src/main/java/com/example/order/OrderServiceApplication.java:**

```java
package com.example.order;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}
```

### Order Configuration

**src/main/resources/application.yml:**

```yaml
spring:
  application:
    name: order-service

server:
  port: 8083

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
  instance:
    prefer-ip-address: true

management:
  endpoints:
    web:
      exposure:
        include: health,info
```

### Test Order Service

```bash
cd order-service
mvn spring-boot:run
```

Check Eureka - both services registered.

Create order:

```bash
curl -X POST http://localhost:8083/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "John Doe",
    "items": [
      {"productId": 1, "quantity": 1},
      {"productId": 2, "quantity": 2}
    ]
  }'
```

> aside positive
> **Feign Magic:** Feign automatically discovers Product Service via Eureka and handles load balancing!

## API Gateway

Duration: 12:00

Build API Gateway as single entry point.

### Gateway POM

**api-gateway/pom.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.example</groupId>
        <artifactId>ecommerce-microservices</artifactId>
        <version>1.0.0</version>
    </parent>

    <artifactId>api-gateway</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>
</project>
```

### Gateway Application

**src/main/java/com/example/gateway/ApiGatewayApplication.java:**

```java
package com.example.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
```

### Gateway Configuration

**src/main/resources/application.yml:**

```yaml
spring:
  application:
    name: api-gateway

  cloud:
    gateway:
      discovery:
        locator:
          enabled: true
          lower-case-service-id: true

      routes:
        - id: product-service
          uri: lb://product-service
          predicates:
            - Path=/api/products/**

        - id: order-service
          uri: lb://order-service
          predicates:
            - Path=/api/orders/**

server:
  port: 8080

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/

management:
  endpoints:
    web:
      exposure:
        include: health,info,gateway

logging:
  level:
    org.springframework.cloud.gateway: DEBUG
```

### Test Gateway

```bash
cd api-gateway
mvn spring-boot:run
```

**Access via Gateway:**

```bash
# Products via Gateway
curl http://localhost:8080/api/products

# Orders via Gateway
curl http://localhost:8080/api/orders

# Create order via Gateway
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "Jane Smith",
    "items": [{"productId": 3, "quantity": 1}]
  }'
```

Gateway routes to appropriate service!

## Load Balancing

Duration: 8:00

Test client-side load balancing with multiple instances.

### Run Multiple Product Instances

**Terminal 1:**

```bash
cd product-service
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8081
```

**Terminal 2:**

```bash
cd product-service
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8082
```

Check Eureka Dashboard - 2 instances of Product Service.

### Test Load Balancing

```bash
# Call multiple times
for i in {1..10}; do
  curl http://localhost:8080/api/products
  echo ""
done
```

Check logs - requests distributed between ports 8081 and 8082!

### Load Balancing Configuration

Feign uses Spring Cloud LoadBalancer by default.

**Customize (optional):**

```java
@Configuration
public class LoadBalancerConfig {

    @Bean
    public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(
            ConfigurableApplicationContext context) {
        return ServiceInstanceListSupplier.builder()
            .withDiscoveryClient()
            .withCaching()
            .build(context);
    }
}
```

> aside positive
> **Client-Side Load Balancing:** Feign + LoadBalancer distribute requests across service instances automatically.

## Docker Compose Deployment

Duration: 10:00

Deploy entire ecosystem with Docker Compose.

### Dockerfiles

**eureka-server/Dockerfile:**

```dockerfile
FROM openjdk:17-slim
COPY target/eureka-server-1.0.0.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

**Same pattern for other services** (api-gateway/Dockerfile, product-service/Dockerfile, order-service/Dockerfile)

### Docker Compose

**docker-compose.yml (root directory):**

```yaml
version: "3.8"

services:
  eureka-server:
    build: ./eureka-server
    ports:
      - "8761:8761"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
    networks:
      - microservices-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8761/actuator/health"]
      interval: 10s
      timeout: 5s
      retries: 5

  product-service-1:
    build: ./product-service
    ports:
      - "8081:8081"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SERVER_PORT=8081
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eureka-server:8761/eureka/
    depends_on:
      eureka-server:
        condition: service_healthy
    networks:
      - microservices-net

  product-service-2:
    build: ./product-service
    ports:
      - "8082:8082"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SERVER_PORT=8082
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eureka-server:8761/eureka/
    depends_on:
      eureka-server:
        condition: service_healthy
    networks:
      - microservices-net

  order-service:
    build: ./order-service
    ports:
      - "8083:8083"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eureka-server:8761/eureka/
    depends_on:
      eureka-server:
        condition: service_healthy
    networks:
      - microservices-net

  api-gateway:
    build: ./api-gateway
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eureka-server:8761/eureka/
    depends_on:
      eureka-server:
        condition: service_healthy
    networks:
      - microservices-net

networks:
  microservices-net:
    driver: bridge
```

### Build and Deploy

```bash
# Build all services
mvn clean package -DskipTests

# Start all services
docker-compose up --build

# Check logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Test Full System

```bash
# Via Gateway
curl http://localhost:8080/api/products
curl http://localhost:8080/api/orders

# Eureka UI
open http://localhost:8761
```

## Monitoring & Resilience

Duration: 5:00

Add health checks and monitoring.

### Health Endpoints

All services have Actuator:

```bash
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8083/actuator/health
```

### Circuit Breaker (Optional)

Add Resilience4j for fault tolerance:

**pom.xml:**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
</dependency>
```

**Feign with Circuit Breaker:**

```java
@FeignClient(
    name = "product-service",
    fallback = ProductClientFallback.class
)
public interface ProductClient {
    @GetMapping("/api/products/{id}")
    ProductDto getProduct(@PathVariable Long id);
}

@Component
class ProductClientFallback implements ProductClient {
    @Override
    public ProductDto getProduct(Long id) {
        // Return default or cached product
        ProductDto fallback = new ProductDto();
        fallback.setId(id);
        fallback.setName("Product Unavailable");
        return fallback;
    }
}
```

> aside negative
> **Production Readiness:** Add circuit breakers, distributed tracing (Zipkin), centralized logging (ELK), and metrics (Prometheus) for production systems.

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've built a complete microservices ecosystem!

### What You've Learned

- ✅ **Architecture Evolution:** Monolith vs Microservices
- ✅ **Service Registry:** Eureka for service discovery
- ✅ **API Gateway:** Single entry point with routing
- ✅ **Service Communication:** Feign for inter-service calls
- ✅ **Load Balancing:** Client-side load balancing
- ✅ **Deployment:** Docker Compose orchestration
- ✅ **Health Checks:** Actuator endpoints
- ✅ **Distributed Systems:** Challenges and solutions

### Architecture Patterns

**Service Registry:**

- Services register on startup
- Clients discover services dynamically
- Health checks and heartbeats

**API Gateway:**

- Single entry point for clients
- Routing to microservices
- Cross-cutting concerns (auth, logging)

**Service Communication:**

- Synchronous: REST with Feign
- Asynchronous: Messaging (JMS, Kafka)
- Service mesh: Istio, Linkerd

### Best Practices

1. **Database per Service:** Each service owns its data
2. **API Versioning:** /v1/products, /v2/products
3. **Centralized Config:** Spring Cloud Config
4. **Distributed Tracing:** Track requests across services
5. **Circuit Breakers:** Handle service failures gracefully
6. **API Gateway:** Authentication, rate limiting, caching
7. **Health Checks:** Monitor service availability
8. **Logging:** Centralized log aggregation

### Trade-offs

**Use Microservices When:**

- Large, complex applications
- Multiple development teams
- Independent deployment needs
- Technology diversity required

**Avoid Microservices When:**

- Small applications
- Single team
- Simple domain
- High network latency concerns

### Next Steps

- **Add Database:** PostgreSQL per service
- **Add Security:** OAuth2, JWT gateway
- **Add Tracing:** Sleuth + Zipkin
- **Add Config Server:** Externalize configuration
- **Add Messaging:** Async communication with Kafka
- **Add Monitoring:** Prometheus + Grafana

### Resources

- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)
- [Microservices Patterns](https://microservices.io/patterns/)
- [Spring Cloud Netflix](https://spring.io/projects/spring-cloud-netflix)
- [Spring Cloud Gateway](https://spring.io/projects/spring-cloud-gateway)

> aside positive
> **Production Journey:** You've built the foundation. Add security, monitoring, logging, and resilience patterns for production-ready microservices!
