summary: Compare blocking and reactive web stacks by building the same API with raw Servlets, Spring MVC, and Spring WebFlux, then analyze performance differences
id: servlets-blocking-reactive
categories: Java, Servlets, Spring MVC, Spring WebFlux, Reactive Programming
environments: Web
status: Published

# Servlets & Blocking vs Reactive Stacks

## Introduction

Duration: 3:00

Understand servlet containers, blocking vs reactive architectures, and when to use each approach.

### What You'll Learn

- **Servlet API:** HttpServlet, lifecycle, filters
- **Servlet Containers:** Tomcat architecture
- **Blocking I/O:** Thread-per-request model
- **Reactive I/O:** Event-loop model
- **Spring MVC:** Servlet-based blocking stack
- **Spring WebFlux:** Reactive non-blocking stack
- **Performance:** Load testing and comparison
- **Best Practices:** When to use each approach

### What You'll Build

Same Task API three ways:

1. **Raw Servlet API** - No Spring, manual JSON (Tomcat)
2. **Blocking Stack** - Spring MVC + JDBC
3. **Reactive Stack** - Spring WebFlux + R2DBC

Then load test and compare!

### Prerequisites

- Completed Spring Boot codelabs
- Understanding of REST APIs
- Basic multithreading knowledge
- JDK 17+, Maven 3.6+
- Apache JMeter (for load testing)

### Blocking vs Reactive

**Blocking (Thread-per-Request):**

```
Request 1 → Thread 1 (blocked on I/O)
Request 2 → Thread 2 (blocked on I/O)
Request 3 → Thread 3 (blocked on I/O)
...
Request 200 → Need 200 threads!
```

**Reactive (Event Loop):**

```
Request 1 ──┐
Request 2 ──┤
Request 3 ──┼→ Event Loop (few threads) → Non-blocking I/O
Request 4 ──┤
Request 5 ──┘
```

> aside positive
> **Key Insight:** Blocking uses thread-per-request. Reactive uses event loop with callbacks. Choose based on I/O characteristics!

## Raw Servlet API

Duration: 15:00

Build Task API with raw servlets to understand Spring's abstraction.

### Project Setup

**pom.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>servlet-task-api</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>com.google.code.gson</groupId>
            <artifactId>gson</artifactId>
            <version>2.10.1</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>servlet-task-api</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.3.2</version>
            </plugin>
        </plugins>
    </build>
</project>
```

### Task Model

**src/main/java/com/example/servlet/model/Task.java:**

```java
package com.example.servlet.model;

public class Task {
    private Long id;
    private String title;
    private String description;
    private String status;

    public Task() {}

    public Task(Long id, String title, String description, String status) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.status = status;
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
```

### Task Repository

**src/main/java/com/example/servlet/repository/TaskRepository.java:**

```java
package com.example.servlet.repository;

import com.example.servlet.model.Task;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

public class TaskRepository {
    private static final TaskRepository INSTANCE = new TaskRepository();
    private final Map<Long, Task> tasks = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    private TaskRepository() {
        // Initialize with sample data
        createTask(new Task(null, "Sample Task", "Description", "TODO"));
    }

    public static TaskRepository getInstance() {
        return INSTANCE;
    }

    public List<Task> findAll() {
        return new ArrayList<>(tasks.values());
    }

    public Optional<Task> findById(Long id) {
        return Optional.ofNullable(tasks.get(id));
    }

    public Task createTask(Task task) {
        task.setId(idGenerator.getAndIncrement());
        tasks.put(task.getId(), task);
        return task;
    }

    public boolean deleteTask(Long id) {
        return tasks.remove(id) != null;
    }
}
```

### Task Servlet

**src/main/java/com/example/servlet/TaskServlet.java:**

```java
package com.example.servlet;

import com.example.servlet.model.Task;
import com.example.servlet.repository.TaskRepository;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.stream.Collectors;

@WebServlet(name = "TaskServlet", urlPatterns = {"/api/tasks", "/api/tasks/*"})
public class TaskServlet extends HttpServlet {

    private final TaskRepository repository = TaskRepository.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        if (pathInfo == null || pathInfo.equals("/")) {
            // Get all tasks
            String json = gson.toJson(repository.findAll());
            resp.getWriter().write(json);
        } else {
            // Get task by ID
            Long id = Long.parseLong(pathInfo.substring(1));
            repository.findById(id).ifPresentOrElse(
                task -> {
                    try {
                        resp.getWriter().write(gson.toJson(task));
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                },
                () -> resp.setStatus(HttpServletResponse.SC_NOT_FOUND)
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Read request body
        String body = req.getReader().lines().collect(Collectors.joining());
        Task task = gson.fromJson(body, Task.class);

        // Create task
        Task created = repository.createTask(task);

        // Send response
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.setStatus(HttpServletResponse.SC_CREATED);
        resp.getWriter().write(gson.toJson(created));
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();
        if (pathInfo != null && !pathInfo.equals("/")) {
            Long id = Long.parseLong(pathInfo.substring(1));
            boolean deleted = repository.deleteTask(id);

            if (deleted) {
                resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
        } else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
```

### Servlet Filter

**src/main/java/com/example/servlet/LoggingFilter.java:**

```java
package com.example.servlet;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

@WebFilter(urlPatterns = "/api/*")
public class LoggingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("LoggingFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        long startTime = System.currentTimeMillis();

        System.out.println("Request: " + httpRequest.getMethod() + " " +
                          httpRequest.getRequestURI());

        chain.doFilter(request, response);

        long duration = System.currentTimeMillis() - startTime;
        System.out.println("Response time: " + duration + "ms");
    }

    @Override
    public void destroy() {
        System.out.println("LoggingFilter destroyed");
    }
}
```

### Deploy to Tomcat

**Build WAR:**

```bash
mvn clean package
```

**Copy to Tomcat:**

```bash
cp target/servlet-task-api.war $TOMCAT_HOME/webapps/
```

**Test:**

```bash
curl http://localhost:8080/servlet-task-api/api/tasks
```

> aside negative
> **Raw Servlets:** Manual request/response handling, JSON parsing, routing, error handling. Spring abstracts all this complexity!

## Blocking Stack - Spring MVC

Duration: 15:00

Build same API with Spring MVC and JDBC.

### Project Setup

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
    </parent>

    <groupId>com.example</groupId>
    <artifactId>blocking-task-api</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>
</project>
```

### Task Entity

**src/main/java/com/example/blocking/model/Task.java:**

```java
package com.example.blocking.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Task {
    private Long id;
    private String title;
    private String description;
    private String status;
}
```

### JDBC Repository

**src/main/java/com/example/blocking/repository/TaskRepository.java:**

```java
package com.example.blocking.repository;

import com.example.blocking.model.Task;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class TaskRepository {

    private final JdbcTemplate jdbcTemplate;

    private final RowMapper<Task> taskRowMapper = (rs, rowNum) -> new Task(
        rs.getLong("id"),
        rs.getString("title"),
        rs.getString("description"),
        rs.getString("status")
    );

    public List<Task> findAll() {
        return jdbcTemplate.query(
            "SELECT * FROM tasks",
            taskRowMapper
        );
    }

    public Optional<Task> findById(Long id) {
        List<Task> tasks = jdbcTemplate.query(
            "SELECT * FROM tasks WHERE id = ?",
            taskRowMapper,
            id
        );
        return tasks.isEmpty() ? Optional.empty() : Optional.of(tasks.get(0));
    }

    public Task save(Task task) {
        if (task.getId() == null) {
            jdbcTemplate.update(
                "INSERT INTO tasks (title, description, status) VALUES (?, ?, ?)",
                task.getTitle(), task.getDescription(), task.getStatus()
            );
            Long id = jdbcTemplate.queryForObject(
                "SELECT LAST_INSERT_ID()",
                Long.class
            );
            task.setId(id);
        } else {
            jdbcTemplate.update(
                "UPDATE tasks SET title = ?, description = ?, status = ? WHERE id = ?",
                task.getTitle(), task.getDescription(), task.getStatus(), task.getId()
            );
        }
        return task;
    }

    public void deleteById(Long id) {
        jdbcTemplate.update("DELETE FROM tasks WHERE id = ?", id);
    }
}
```

### Task Service with Simulated Delay

**src/main/java/com/example/blocking/service/TaskService.java:**

```java
package com.example.blocking.service;

import com.example.blocking.model.Task;
import com.example.blocking.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class TaskService {

    private final TaskRepository repository;

    public List<Task> getAllTasks() {
        log.info("Getting all tasks - Thread: {}", Thread.currentThread().getName());
        simulateSlowOperation(); // Simulate I/O delay
        return repository.findAll();
    }

    public Optional<Task> getTaskById(Long id) {
        log.info("Getting task {} - Thread: {}", id, Thread.currentThread().getName());
        simulateSlowOperation();
        return repository.findById(id);
    }

    public Task createTask(Task task) {
        log.info("Creating task - Thread: {}", Thread.currentThread().getName());
        simulateSlowOperation();
        return repository.save(task);
    }

    public void deleteTask(Long id) {
        log.info("Deleting task {} - Thread: {}", id, Thread.currentThread().getName());
        simulateSlowOperation();
        repository.deleteById(id);
    }

    private void simulateSlowOperation() {
        try {
            Thread.sleep(100); // Simulate slow database/external API
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

### REST Controller

**src/main/java/com/example/blocking/controller/TaskController.java:**

```java
package com.example.blocking.controller;

import com.example.blocking.model.Task;
import com.example.blocking.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @GetMapping
    public ResponseEntity<List<Task>> getAllTasks() {
        return ResponseEntity.ok(taskService.getAllTasks());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Task> getTaskById(@PathVariable Long id) {
        return taskService.getTaskById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Task> createTask(@RequestBody Task task) {
        return ResponseEntity.ok(taskService.createTask(task));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }
}
```

### Configuration

**src/main/resources/application.yml:**

```yaml
spring:
  application:
    name: blocking-task-api

  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver

  h2:
    console:
      enabled: true

server:
  port: 8081
  tomcat:
    threads:
      max: 200 # Default thread pool size

logging:
  level:
    com.example.blocking: INFO
```

**src/main/resources/schema.sql:**

```sql
CREATE TABLE tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL
);

INSERT INTO tasks (title, description, status) VALUES
('Sample Task 1', 'Description 1', 'TODO'),
('Sample Task 2', 'Description 2', 'IN_PROGRESS');
```

### Run and Test

```bash
mvn spring-boot:run
curl http://localhost:8081/api/tasks
```

> aside positive
> **Blocking Model:** Each request gets a thread from pool. Thread blocks on I/O (database, external API). Thread count limits concurrency.

## Reactive Stack - Spring WebFlux

Duration: 15:00

Build same API with Spring WebFlux and R2DBC.

### Project Setup

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
    </parent>

    <groupId>com.example</groupId>
    <artifactId>reactive-task-api</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webflux</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-r2dbc</artifactId>
        </dependency>
        <dependency>
            <groupId>io.r2dbc</groupId>
            <artifactId>r2dbc-h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>
</project>
```

### Task Entity

**src/main/java/com/example/reactive/model/Task.java:**

```java
package com.example.reactive.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Table("tasks")
public class Task {
    @Id
    private Long id;
    private String title;
    private String description;
    private String status;
}
```

### R2DBC Repository

**src/main/java/com/example/reactive/repository/TaskRepository.java:**

```java
package com.example.reactive.repository;

import com.example.reactive.model.Task;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TaskRepository extends ReactiveCrudRepository<Task, Long> {
    // Reactive CRUD methods inherited
}
```

### Task Service with Simulated Delay

**src/main/java/com/example/reactive/service/TaskService.java:**

```java
package com.example.reactive.service;

import com.example.reactive.model.Task;
import com.example.reactive.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Duration;

@Service
@RequiredArgsConstructor
@Slf4j
public class TaskService {

    private final TaskRepository repository;

    public Flux<Task> getAllTasks() {
        log.info("Getting all tasks - Thread: {}", Thread.currentThread().getName());
        return repository.findAll()
            .delayElements(Duration.ofMillis(100)); // Simulate I/O delay
    }

    public Mono<Task> getTaskById(Long id) {
        log.info("Getting task {} - Thread: {}", id, Thread.currentThread().getName());
        return repository.findById(id)
            .delayElement(Duration.ofMillis(100));
    }

    public Mono<Task> createTask(Task task) {
        log.info("Creating task - Thread: {}", Thread.currentThread().getName());
        return repository.save(task)
            .delayElement(Duration.ofMillis(100));
    }

    public Mono<Void> deleteTask(Long id) {
        log.info("Deleting task {} - Thread: {}", id, Thread.currentThread().getName());
        return repository.deleteById(id)
            .delayElement(Duration.ofMillis(100));
    }
}
```

### Reactive Controller

**src/main/java/com/example/reactive/controller/TaskController.java:**

```java
package com.example.reactive.controller;

import com.example.reactive.model.Task;
import com.example.reactive.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @GetMapping
    public Flux<Task> getAllTasks() {
        return taskService.getAllTasks();
    }

    @GetMapping("/{id}")
    public Mono<ResponseEntity<Task>> getTaskById(@PathVariable Long id) {
        return taskService.getTaskById(id)
            .map(ResponseEntity::ok)
            .defaultIfEmpty(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Mono<Task> createTask(@RequestBody Task task) {
        return taskService.createTask(task);
    }

    @DeleteMapping("/{id}")
    public Mono<ResponseEntity<Void>> deleteTask(@PathVariable Long id) {
        return taskService.deleteTask(id)
            .then(Mono.just(ResponseEntity.noContent().<Void>build()));
    }
}
```

### Configuration

**src/main/resources/application.yml:**

```yaml
spring:
  application:
    name: reactive-task-api

  r2dbc:
    url: r2dbc:h2:mem:///testdb

server:
  port: 8082

logging:
  level:
    com.example.reactive: INFO
    io.r2dbc: DEBUG
```

**src/main/resources/schema.sql:**

```sql
CREATE TABLE IF NOT EXISTS tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL
);
```

### Data Initialization

**src/main/java/com/example/reactive/config/DataInitializer.java:**

```java
package com.example.reactive.config;

import com.example.reactive.model.Task;
import com.example.reactive.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final TaskRepository repository;

    @Override
    public void run(String... args) {
        repository.deleteAll()
            .thenMany(Flux.just(
                new Task(null, "Sample Task 1", "Description 1", "TODO"),
                new Task(null, "Sample Task 2", "Description 2", "IN_PROGRESS")
            ))
            .flatMap(repository::save)
            .subscribe();
    }
}
```

### Run and Test

```bash
mvn spring-boot:run
curl http://localhost:8082/api/tasks
```

> aside positive
> **Reactive Model:** Small thread pool (event loop). Non-blocking I/O with callbacks. Handles many concurrent requests with few threads.

## Performance Testing

Duration: 15:00

Load test both implementations and compare performance.

### Install JMeter

Download from: https://jmeter.apache.org/download_jmeter.cgi

### JMeter Test Plan - Blocking

**blocking-load-test.jmx:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Blocking API Load Test">
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments">
        <collectionProp name="Arguments.arguments"/>
      </elementProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Users">
        <stringProp name="ThreadGroup.num_threads">500</stringProp>
        <stringProp name="ThreadGroup.ramp_time">10</stringProp>
        <stringProp name="ThreadGroup.duration">60</stringProp>
        <boolProp name="ThreadGroup.scheduler">true</boolProp>
      </ThreadGroup>
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="GET Tasks">
          <stringProp name="HTTPSampler.domain">localhost</stringProp>
          <stringProp name="HTTPSampler.port">8081</stringProp>
          <stringProp name="HTTPSampler.path">/api/tasks</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
        </HTTPSamplerProxy>

        <ResultCollector guiclass="SummaryReport" testclass="ResultCollector" testname="Summary Report">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
            </value>
          </objProp>
        </ResultCollector>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
```

### JMeter Test Plan - Reactive

Same structure, change port to 8082.

### Run Load Tests

**Terminal 1 - Start Blocking API:**

```bash
cd blocking-task-api
mvn spring-boot:run
```

**Terminal 2 - Run JMeter Test:**

```bash
jmeter -n -t blocking-load-test.jmx -l blocking-results.jtl -e -o blocking-report/
```

**Terminal 3 - Start Reactive API:**

```bash
cd reactive-task-api
mvn spring-boot:run
```

**Terminal 4 - Run JMeter Test:**

```bash
jmeter -n -t reactive-load-test.jmx -l reactive-results.jtl -e -o reactive-report/
```

### Monitor Resources

**During tests, monitor:**

```bash
# CPU and Memory
top

# Thread count
jstack <pid> | grep "java.lang.Thread.State" | wc -l

# Heap usage
jstat -gc <pid> 1000
```

### Expected Results

**Blocking API (Spring MVC):**

- Threads: ~200 (max pool size)
- Throughput: ~100-200 req/sec
- Latency: Higher under load
- Memory: Higher (more threads)

**Reactive API (Spring WebFlux):**

- Threads: ~10-20 (event loop)
- Throughput: ~300-500 req/sec
- Latency: Lower under load
- Memory: Lower (fewer threads)

### Performance Comparison

| Metric          | Blocking (MVC) | Reactive (WebFlux) |
| --------------- | -------------- | ------------------ |
| Thread Count    | 200+           | 10-20              |
| Requests/sec    | 150            | 400                |
| Avg Latency     | 500ms          | 200ms              |
| 95th Percentile | 1200ms         | 400ms              |
| Memory (Heap)   | 512MB          | 256MB              |
| CPU Usage       | 60%            | 40%                |

> aside positive
> **Reactive Wins:** When many concurrent requests with I/O waits. Blocking wins for CPU-intensive operations or simple CRUD.

## Thread Dump Analysis

Duration: 5:00

Analyze thread behavior in both models.

### Capture Thread Dumps

**Blocking API:**

```bash
jstack <pid> > blocking-threads.txt
```

**Example blocking threads:**

```
"http-nio-8081-exec-1" #25 daemon prio=5 os_prio=0
   java.lang.Thread.State: TIMED_WAITING (sleeping)
        at java.lang.Thread.sleep(Native Method)
        at com.example.blocking.service.TaskService.simulateSlowOperation

"http-nio-8081-exec-2" #26 daemon prio=5 os_prio=0
   java.lang.Thread.State: TIMED_WAITING (sleeping)
        at java.lang.Thread.sleep(Native Method)

... (200 threads)
```

**Reactive API:**

```bash
jstack <pid> > reactive-threads.txt
```

**Example reactive threads:**

```
"reactor-http-nio-2" #14 daemon prio=5 os_prio=0
   java.lang.Thread.State: RUNNABLE
        at sun.nio.ch.EPoll.wait(Native Method)

"reactor-http-nio-3" #15 daemon prio=5 os_prio=0
   java.lang.Thread.State: RUNNABLE

... (10-20 threads total)
```

### Thread Analysis

**Blocking:**

- Many threads (1 per request)
- TIMED_WAITING state (blocked on I/O)
- High context switching overhead

**Reactive:**

- Few threads (event loop)
- RUNNABLE state (event loop waiting for events)
- Low context switching

## When to Use Each Approach

Duration: 5:00

Decision matrix for choosing the right stack.

### Use Blocking (Spring MVC + JDBC)

✅ **Good for:**

- CRUD applications
- Low to moderate concurrency (<100 concurrent users)
- CPU-intensive operations
- Simple application logic
- Team familiar with traditional blocking model
- Extensive use of blocking libraries
- Existing JDBC/JPA codebase

**Example:**

- Internal admin dashboards
- Simple REST APIs
- Traditional web applications
- Batch processing

### Use Reactive (Spring WebFlux + R2DBC)

✅ **Good for:**

- High concurrency (1000+ concurrent users)
- I/O-intensive operations
- Streaming data
- Microservices with many service calls
- Event-driven systems
- Real-time applications

**Example:**

- Real-time dashboards
- Chat applications
- Stock trading platforms
- IoT data ingestion
- Video streaming services

### Performance Comparison Summary

```
Concurrency Level vs Throughput

Blocking:     Reactive:
    ^             ^
    |          /  |
Req |       /     |
/sec|    /        |       /
    | /           |    /
    +------->     | /
    Users         +------->
                  Users

Blocking degrades with high concurrency
Reactive scales better with concurrency
```

### Complexity Trade-off

**Blocking:**

- ✅ Easier to understand
- ✅ Easier to debug
- ✅ Synchronous, imperative code
- ❌ Limited scalability

**Reactive:**

- ❌ Steeper learning curve
- ❌ Harder to debug
- ❌ Asynchronous, functional code
- ✅ Better scalability

> aside negative
> **Don't Use Reactive Everywhere!** Reactive adds complexity. Use it only when you need the performance benefits for high-concurrency I/O scenarios.

## Spring Framework Evolution

Duration: 3:00

Understanding Spring's unified stack approach.

### Spring 5+ Architecture

```
Spring Framework 5+
├── Spring MVC (Servlet Stack)
│   ├── Tomcat/Jetty (Servlet Container)
│   ├── Spring MVC
│   ├── Spring Data JPA
│   └── JDBC
│
└── Spring WebFlux (Reactive Stack)
    ├── Netty/Undertow (Reactive Server)
    ├── Spring WebFlux
    ├── Spring Data R2DBC
    └── R2DBC

Both share:
- Spring Core (IoC, DI)
- Spring Boot Auto-configuration
- Spring Security
- Spring Cloud
```

### Unified Programming Model

**Same annotations, different execution:**

```java
// Both work the same from API perspective

// Blocking
@GetMapping("/tasks")
public List<Task> getTasks() {
    return service.findAll();
}

// Reactive
@GetMapping("/tasks")
public Flux<Task> getTasks() {
    return service.findAll();
}
```

### Migration Path

1. **Start with Blocking** (Spring MVC)
2. **Identify bottlenecks** (monitoring, profiling)
3. **Migrate specific services** to reactive
4. **Use reactive for new microservices**
5. **Keep blocking for simple CRUD**

### Hybrid Approach

```java
// Mix blocking and reactive in same app

@RestController
public class HybridController {

    // Blocking endpoint
    @GetMapping("/users")
    public List<User> getUsers() {
        return userService.findAll(); // JDBC
    }

    // Reactive endpoint
    @GetMapping("/notifications")
    public Flux<Notification> getNotifications() {
        return notificationService.findAll(); // R2DBC
    }
}
```

> aside positive
> **Best Practice:** Use the right tool for each service. Blocking for simple CRUD, reactive for high-concurrency I/O.

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered servlet containers, blocking, and reactive architectures!

### What You've Learned

- ✅ **Servlet API:** Raw servlets, filters, lifecycle
- ✅ **Blocking I/O:** Thread-per-request model
- ✅ **Reactive I/O:** Event-loop model
- ✅ **Spring MVC:** Servlet-based blocking stack
- ✅ **Spring WebFlux:** Reactive non-blocking stack
- ✅ **Performance:** Load testing and analysis
- ✅ **Decision Making:** When to use each approach

### Key Takeaways

1. **Blocking:** Simple, easy to debug, limited concurrency
2. **Reactive:** Complex, harder to debug, high concurrency
3. **Choose based on use case:** Not all apps need reactive
4. **Spring abstracts complexity:** Raw servlets vs Spring
5. **Performance depends on I/O:** Reactive shines with many concurrent I/O operations

### Performance Summary

**Use Blocking When:**

- Simple CRUD applications
- CPU-intensive operations
- Low concurrency (<100 users)
- Team prefers imperative code

**Use Reactive When:**

- High concurrency (1000+ users)
- I/O-intensive operations
- Streaming/real-time data
- Microservices architecture

### Course Complete! 🎓

You've completed all 20 codelabs:

- ✅ Section 1: Core Java (5 codelabs)
- ✅ Section 2: Java 8+ Features (5 codelabs)
- ✅ Section 3: Spring Boot (8 codelabs)
- ✅ Section 4: Microservices (2 codelabs)

### Next Steps

- Build capstone project
- Contribute to open source
- Explore Kubernetes deployment
- Study distributed tracing (Zipkin)
- Learn API Gateway patterns
- Master Docker and containers

### Additional Resources

- [Spring WebFlux Documentation](https://docs.spring.io/spring-framework/reference/web/webflux.html)
- [Project Reactor](https://projectreactor.io/)
- [R2DBC Documentation](https://r2dbc.io/)
- [Servlet API Specification](https://jakarta.ee/specifications/servlet/)
- [Reactive Programming Guide](https://www.reactivemanifesto.org/)

> aside positive
> **Congratulations!** You're now equipped with production-ready Spring Boot skills. Go build amazing applications! 🚀
