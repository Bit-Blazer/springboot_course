summary: Master Spring Core concepts including Dependency Injection, IoC, and Spring Boot basics by building the foundation of a Task Management API
id: spring-core-boot-basics
categories: Spring Boot, Spring Core, Dependency Injection, REST API
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM

# Spring Core & Spring Boot Basics

## Introduction

Duration: 3:00

Welcome to Spring Boot! Spring is the most popular Java framework for building enterprise applications. Spring Boot makes it easy to create production-grade Spring applications with minimal configuration.

### What You'll Learn

- **Inversion of Control (IoC):** Understanding the core Spring principle
- **Dependency Injection (DI):** Constructor, setter, and field injection
- **Spring Beans:** Component scanning and bean lifecycle
- **Spring Annotations:** @Component, @Service, @Repository, @Autowired
- **Spring Boot:** Auto-configuration and starters
- **REST Controllers:** Building web endpoints
- **Application Configuration:** Properties and YAML files
- **Project Structure:** Best practices for organizing Spring Boot apps

### What You'll Build

**Task Management API** - A RESTful API for managing tasks:

- Basic task CRUD operations (in-memory for now)
- RESTful endpoints
- Service and repository layers
- Dependency injection throughout
- Spring Boot auto-configuration

This is the **first codelab in an evolving project** that will grow through Codelabs 3.1-3.8, adding features like:

- Database persistence (3.3)
- Security & JWT (3.4-3.5)
- Reactive programming (3.6)
- Messaging (3.7)
- Testing (3.8)

### Prerequisites

- Completed Section 1 and Section 2 codelabs
- JDK 17 or higher installed
- Maven or Gradle installed
- IDE (IntelliJ IDEA recommended, with Spring plugin)
- Basic understanding of REST APIs

### Key Dependencies

```xml
<!-- Spring Boot Starter Web -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Spring Boot DevTools (auto-reload) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>

<!-- Lombok (reduce boilerplate) -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>
```

> aside positive
> **Evolution Strategy:** We'll use Git branches to track progress. Each codelab builds on the previous one. You can always refer back to earlier branches if needed!

## Understanding IoC and DI

Duration: 10:00

Before diving into Spring, let's understand the core concepts that make it powerful.

### The Problem: Tight Coupling

Without IoC and DI, classes create their own dependencies:

```java
// Tightly coupled code - BAD
public class TaskService {
    private TaskRepository repository;

    public TaskService() {
        // TaskService creates its own dependency
        this.repository = new TaskRepository();
    }

    public void saveTask(Task task) {
        repository.save(task);
    }
}
```

**Problems:**

- ❌ Hard to test (can't mock repository)
- ❌ Hard to change implementation
- ❌ TaskService knows how to construct TaskRepository
- ❌ Tight coupling between classes

### Inversion of Control (IoC)

**IoC Principle:** Don't create dependencies yourself - let someone else provide them.

```java
// Loosely coupled with IoC - GOOD
public class TaskService {
    private TaskRepository repository;

    // Dependencies provided from outside
    public TaskService(TaskRepository repository) {
        this.repository = repository;
    }

    public void saveTask(Task task) {
        repository.save(task);
    }
}
```

**Benefits:**

- ✅ TaskService doesn't create TaskRepository
- ✅ Easy to test (inject mock repository)
- ✅ Easy to change implementation
- ✅ Loose coupling

### Dependency Injection (DI)

DI is a way to implement IoC. The framework "injects" dependencies into your classes.

**Three types of DI:**

#### 1. Constructor Injection (Recommended)

```java
@Service
public class TaskService {
    private final TaskRepository repository;

    // Spring injects TaskRepository through constructor
    @Autowired  // Optional in Spring 4.3+
    public TaskService(TaskRepository repository) {
        this.repository = repository;
    }
}
```

**Best for:** Required dependencies, immutable fields

#### 2. Setter Injection

```java
@Service
public class TaskService {
    private TaskRepository repository;

    // Spring calls this setter to inject dependency
    @Autowired
    public void setRepository(TaskRepository repository) {
        this.repository = repository;
    }
}
```

**Best for:** Optional dependencies, reconfigurable beans

#### 3. Field Injection (Not Recommended)

```java
@Service
public class TaskService {
    // Spring injects directly into field
    @Autowired
    private TaskRepository repository;
}
```

**Problems:** Hard to test, breaks encapsulation, can't make final

> aside positive
> **Best Practice:** Always use constructor injection for required dependencies. It makes your code more testable and dependencies explicit.

### The Spring Container

The **Spring Container** (ApplicationContext) manages the lifecycle of beans and their dependencies.

```java
// Spring does this for you:
TaskRepository repository = new TaskRepository();
TaskService service = new TaskService(repository);
TaskController controller = new TaskController(service);
```

### Bean Lifecycle

```
1. Container Starts
2. Bean Definitions Scanned (@Component, @Service, etc.)
3. Beans Instantiated
4. Dependencies Injected
5. Post-Initialization Methods Called (@PostConstruct)
6. Bean Ready for Use
7. Pre-Destruction Methods Called (@PreDestroy)
8. Container Shuts Down
```

### Practical Example

```java
// Without Spring (manual wiring)
public class Application {
    public static void main(String[] args) {
        // We create and wire everything manually
        TaskRepository repository = new InMemoryTaskRepository();
        TaskService service = new TaskService(repository);
        TaskController controller = new TaskController(service);

        // Use controller
        controller.getAllTasks();
    }
}

// With Spring (automatic wiring)
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        // Spring creates and wires everything automatically
        SpringApplication.run(Application.class, args);

        // Spring container now contains:
        // - TaskRepository bean
        // - TaskService bean (with repository injected)
        // - TaskController bean (with service injected)
    }
}
```

## Spring Boot Project Setup

Duration: 10:00

Let's create our Task Management API using Spring Initializr.

### Using Spring Initializr

Visit [start.spring.io](https://start.spring.io) or use your IDE's Spring Initializr.

**Configuration:**

- **Project:** Maven
- **Language:** Java
- **Spring Boot:** 3.2.x (latest stable)
- **Group:** com.example
- **Artifact:** taskmanager
- **Name:** Task Manager
- **Package name:** com.example.taskmanager
- **Packaging:** Jar
- **Java:** 17

**Dependencies:**

- Spring Web
- Spring Boot DevTools
- Lombok

### Project Structure

```
taskmanager/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/taskmanager/
│   │   │       ├── TaskManagerApplication.java
│   │   │       ├── controller/
│   │   │       │   └── TaskController.java
│   │   │       ├── service/
│   │   │       │   └── TaskService.java
│   │   │       ├── repository/
│   │   │       │   └── TaskRepository.java
│   │   │       └── model/
│   │   │           └── Task.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── static/
│   └── test/
│       └── java/
│           └── com/example/taskmanager/
├── pom.xml
└── README.md
```

### Maven pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>taskmanager</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>Task Manager</name>
    <description>Task Management API with Spring Boot</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Starter Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Spring Boot DevTools -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>

        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- Spring Boot Starter Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

### Main Application Class

```java
package com.example.taskmanager;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TaskManagerApplication {

    public static void main(String[] args) {
        SpringApplication.run(TaskManagerApplication.class, args);
    }
}
```

**@SpringBootApplication is a combination of:**

- `@Configuration`: Tags class as configuration source
- `@EnableAutoConfiguration`: Enables Spring Boot auto-configuration
- `@ComponentScan`: Scans for components in current package and sub-packages

### application.properties

```properties
# Application name
spring.application.name=task-manager

# Server configuration
server.port=8080

# Logging
logging.level.root=INFO
logging.level.com.example.taskmanager=DEBUG

# DevTools
spring.devtools.restart.enabled=true
```

### Build and Run

```bash
# Maven
mvn clean install
mvn spring-boot:run

# Or run the generated JAR
java -jar target/taskmanager-0.0.1-SNAPSHOT.jar
```

Output:

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.0)

2025-12-24T14:30:45.123  INFO 12345 --- [main] c.e.t.TaskManagerApplication : Starting TaskManagerApplication
2025-12-24T14:30:46.789  INFO 12345 --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 8080 (http)
2025-12-24T14:30:46.800  INFO 12345 --- [main] c.e.t.TaskManagerApplication : Started TaskManagerApplication in 2.5 seconds
```

> aside positive
> **Spring Boot Magic:** Notice we didn't configure Tomcat manually! Spring Boot auto-configures an embedded server for us.

## Create Task Model

Duration: 5:00

Let's create our Task entity using Lombok to reduce boilerplate.

### Task.java

```java
package com.example.taskmanager.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Task {

    private Long id;
    private String title;
    private String description;
    private TaskStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Task(String title, String description) {
        this.title = title;
        this.description = description;
        this.status = TaskStatus.TODO;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
}
```

### TaskStatus.java

```java
package com.example.taskmanager.model;

public enum TaskStatus {
    TODO,
    IN_PROGRESS,
    DONE,
    CANCELLED
}
```

### Understanding Lombok Annotations

```java
@Data
// Generates:
// - getters for all fields
// - setters for all non-final fields
// - toString()
// - equals() and hashCode()
// - required args constructor

@NoArgsConstructor
// Generates: public Task() {}

@AllArgsConstructor
// Generates: public Task(Long id, String title, ...) {}

// Alternative annotations:
@Getter  // Only getters
@Setter  // Only setters
@ToString  // Only toString()
@EqualsAndHashCode  // Only equals/hashCode
```

**Without Lombok, we'd need:**

```java
public class Task {
    private Long id;
    private String title;
    // ... other fields

    // 10+ lines of getters
    public Long getId() { return id; }
    public String getTitle() { return title; }
    // ...

    // 10+ lines of setters
    public void setId(Long id) { this.id = id; }
    public void setTitle(String title) { this.title = title; }
    // ...

    // toString() - 10 lines
    // equals() - 20 lines
    // hashCode() - 10 lines
    // Constructors - 10+ lines
}
```

**Lombok saves ~70 lines of boilerplate!**

> aside positive
> **IDE Setup:** Install the Lombok plugin in IntelliJ (Settings → Plugins → Search "Lombok") or Eclipse (download from projectlombok.org).

## Repository Layer

Duration: 8:00

Create the repository layer to manage task storage (in-memory for now).

### TaskRepository Interface

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.Task;
import java.util.List;
import java.util.Optional;

public interface TaskRepository {
    Task save(Task task);
    Optional<Task> findById(Long id);
    List<Task> findAll();
    void deleteById(Long id);
    boolean existsById(Long id);
}
```

### InMemoryTaskRepository Implementation

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.Task;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Repository
public class InMemoryTaskRepository implements TaskRepository {

    private final Map<Long, Task> tasks = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    @Override
    public Task save(Task task) {
        if (task.getId() == null) {
            // New task - generate ID
            task.setId(idGenerator.getAndIncrement());
            task.setCreatedAt(LocalDateTime.now());
        }
        task.setUpdatedAt(LocalDateTime.now());
        tasks.put(task.getId(), task);
        return task;
    }

    @Override
    public Optional<Task> findById(Long id) {
        return Optional.ofNullable(tasks.get(id));
    }

    @Override
    public List<Task> findAll() {
        return new ArrayList<>(tasks.values());
    }

    @Override
    public void deleteById(Long id) {
        tasks.remove(id);
    }

    @Override
    public boolean existsById(Long id) {
        return tasks.containsKey(id);
    }
}
```

### Understanding @Repository

```java
@Repository
// 1. Marks class as a Spring bean
// 2. Indicates it's a data access component
// 3. Enables exception translation (DB exceptions → Spring DataAccessException)
// 4. Component scanning will find and register it
```

**Component Stereotypes in Spring:**

```java
@Component  // Generic Spring bean
@Service    // Business logic layer
@Repository // Data access layer
@Controller // Web controller (returns views)
@RestController // REST API controller (returns data)

// All extend @Component but provide semantic meaning
```

> aside positive
> **Thread Safety:** We use `ConcurrentHashMap` and `AtomicLong` to make our in-memory repository thread-safe for concurrent requests.

## Service Layer

Duration: 8:00

Create the service layer to implement business logic.

### TaskService.java

```java
package com.example.taskmanager.service;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.repository.TaskRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@Slf4j
public class TaskService {

    private final TaskRepository taskRepository;

    // Constructor injection (recommended)
    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
        log.info("TaskService initialized with repository: {}",
            taskRepository.getClass().getSimpleName());
    }

    public Task createTask(Task task) {
        log.debug("Creating new task: {}", task.getTitle());

        // Business logic: validate and set defaults
        if (task.getStatus() == null) {
            task.setStatus(TaskStatus.TODO);
        }

        Task savedTask = taskRepository.save(task);
        log.info("Task created with ID: {}", savedTask.getId());
        return savedTask;
    }

    public Optional<Task> getTaskById(Long id) {
        log.debug("Fetching task with ID: {}", id);
        return taskRepository.findById(id);
    }

    public List<Task> getAllTasks() {
        log.debug("Fetching all tasks");
        List<Task> tasks = taskRepository.findAll();
        log.info("Found {} tasks", tasks.size());
        return tasks;
    }

    public Task updateTask(Long id, Task taskDetails) {
        log.debug("Updating task with ID: {}", id);

        return taskRepository.findById(id)
            .map(task -> {
                task.setTitle(taskDetails.getTitle());
                task.setDescription(taskDetails.getDescription());
                task.setStatus(taskDetails.getStatus());

                Task updatedTask = taskRepository.save(task);
                log.info("Task updated: {}", id);
                return updatedTask;
            })
            .orElseThrow(() -> {
                log.error("Task not found with ID: {}", id);
                return new RuntimeException("Task not found with id: " + id);
            });
    }

    public void deleteTask(Long id) {
        log.debug("Deleting task with ID: {}", id);

        if (!taskRepository.existsById(id)) {
            log.error("Task not found with ID: {}", id);
            throw new RuntimeException("Task not found with id: " + id);
        }

        taskRepository.deleteById(id);
        log.info("Task deleted: {}", id);
    }

    public Task updateTaskStatus(Long id, TaskStatus status) {
        log.debug("Updating task {} status to {}", id, status);

        return taskRepository.findById(id)
            .map(task -> {
                task.setStatus(status);
                return taskRepository.save(task);
            })
            .orElseThrow(() -> new RuntimeException("Task not found with id: " + id));
    }

    public List<Task> getTasksByStatus(TaskStatus status) {
        log.debug("Fetching tasks with status: {}", status);
        return taskRepository.findAll().stream()
            .filter(task -> task.getStatus() == status)
            .toList();
    }
}
```

### Understanding @Slf4j

```java
@Slf4j
// Lombok generates:
private static final Logger log = LoggerFactory.getLogger(TaskService.class);

// Now you can use:
log.debug("Debug message");
log.info("Info message");
log.error("Error message", exception);
```

### Dependency Injection in Action

```java
public class TaskService {
    private final TaskRepository taskRepository;

    // Spring calls this constructor
    // Sees TaskRepository parameter
    // Finds @Repository bean in container
    // Injects it automatically
    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }
}

// If there are multiple TaskRepository implementations:
@Service
public class TaskService {
    private final TaskRepository taskRepository;

    public TaskService(@Qualifier("inMemoryTaskRepository") TaskRepository repo) {
        this.taskRepository = repo;
    }
}
```

> aside positive
> **Business Logic in Service:** The service layer contains business rules (validation, status defaults, etc.), while the repository only handles data storage.

## REST Controller

Duration: 12:00

Create the REST controller to expose HTTP endpoints.

### TaskController.java

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.service.TaskService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
@Slf4j
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
        log.info("TaskController initialized");
    }

    @PostMapping
    public ResponseEntity<Task> createTask(@RequestBody Task task) {
        log.info("POST /api/tasks - Creating task: {}", task.getTitle());
        Task createdTask = taskService.createTask(task);
        return new ResponseEntity<>(createdTask, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<Task>> getAllTasks() {
        log.info("GET /api/tasks - Fetching all tasks");
        List<Task> tasks = taskService.getAllTasks();
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Task> getTaskById(@PathVariable Long id) {
        log.info("GET /api/tasks/{} - Fetching task", id);
        return taskService.getTaskById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Task> updateTask(
            @PathVariable Long id,
            @RequestBody Task taskDetails) {
        log.info("PUT /api/tasks/{} - Updating task", id);
        try {
            Task updatedTask = taskService.updateTask(id, taskDetails);
            return ResponseEntity.ok(updatedTask);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        log.info("DELETE /api/tasks/{} - Deleting task", id);
        try {
            taskService.deleteTask(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Task> updateTaskStatus(
            @PathVariable Long id,
            @RequestParam TaskStatus status) {
        log.info("PATCH /api/tasks/{}/status?status={}", id, status);
        try {
            Task updatedTask = taskService.updateTaskStatus(id, status);
            return ResponseEntity.ok(updatedTask);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<Task>> getTasksByStatus(@PathVariable TaskStatus status) {
        log.info("GET /api/tasks/status/{}", status);
        List<Task> tasks = taskService.getTasksByStatus(status);
        return ResponseEntity.ok(tasks);
    }
}
```

### Understanding REST Annotations

```java
@RestController
// Combines @Controller + @ResponseBody
// All methods return data (JSON/XML) not views

@RequestMapping("/api/tasks")
// Base path for all endpoints in this controller

@PostMapping
// HTTP POST request - create resource

@GetMapping
// HTTP GET request - retrieve resource

@PutMapping("/{id}")
// HTTP PUT request - update entire resource

@PatchMapping("/{id}/status")
// HTTP PATCH request - partial update

@DeleteMapping("/{id}")
// HTTP DELETE request - remove resource

@PathVariable Long id
// Extract {id} from URL path

@RequestParam TaskStatus status
// Extract ?status=TODO from query string

@RequestBody Task task
// Parse JSON request body into Task object
```

### HTTP Status Codes

```java
// Success
HttpStatus.OK (200) - GET, PUT, PATCH success
HttpStatus.CREATED (201) - POST success
HttpStatus.NO_CONTENT (204) - DELETE success

// Client Errors
HttpStatus.BAD_REQUEST (400) - Invalid input
HttpStatus.NOT_FOUND (404) - Resource not found
HttpStatus.CONFLICT (409) - Resource conflict

// Server Errors
HttpStatus.INTERNAL_SERVER_ERROR (500) - Server error
```

### ResponseEntity

```java
// Different ways to create ResponseEntity:

// 1. With status
return new ResponseEntity<>(task, HttpStatus.CREATED);

// 2. OK shortcut
return ResponseEntity.ok(task);

// 3. Created with location
URI location = URI.create("/api/tasks/" + task.getId());
return ResponseEntity.created(location).body(task);

// 4. Not found
return ResponseEntity.notFound().build();

// 5. No content
return ResponseEntity.noContent().build();

// 6. Custom status
return ResponseEntity.status(HttpStatus.ACCEPTED).body(task);
```

## Testing the API

Duration: 10:00

Let's test our API using curl, Postman, or the browser.

### Start the Application

```bash
mvn spring-boot:run
```

### API Endpoints

#### 1. Create Task

```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete Spring Boot Codelab",
    "description": "Learn Spring Core and Boot basics",
    "status": "TODO"
  }'
```

Response (201 Created):

```json
{
  "id": 1,
  "title": "Complete Spring Boot Codelab",
  "description": "Learn Spring Core and Boot basics",
  "status": "TODO",
  "createdAt": "2025-12-24T14:30:00",
  "updatedAt": "2025-12-24T14:30:00"
}
```

#### 2. Get All Tasks

```bash
curl http://localhost:8080/api/tasks
```

Response (200 OK):

```json
[
  {
    "id": 1,
    "title": "Complete Spring Boot Codelab",
    "description": "Learn Spring Core and Boot basics",
    "status": "TODO",
    "createdAt": "2025-12-24T14:30:00",
    "updatedAt": "2025-12-24T14:30:00"
  }
]
```

#### 3. Get Task by ID

```bash
curl http://localhost:8080/api/tasks/1
```

Response (200 OK): Single task JSON

#### 4. Update Task

```bash
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete Spring Boot Codelab - Updated",
    "description": "Master Spring Core and Boot",
    "status": "IN_PROGRESS"
  }'
```

Response (200 OK): Updated task JSON

#### 5. Update Task Status

```bash
curl -X PATCH http://localhost:8080/api/tasks/1/status?status=DONE
```

Response (200 OK): Task with new status

#### 6. Get Tasks by Status

```bash
curl http://localhost:8080/api/tasks/status/TODO
```

Response (200 OK): Array of tasks with TODO status

#### 7. Delete Task

```bash
curl -X DELETE http://localhost:8080/api/tasks/1
```

Response (204 No Content)

### Using Postman

1. **Import Collection:**

   - Create new collection "Task Manager API"
   - Base URL: `http://localhost:8080`

2. **Create Requests:**

   - POST /api/tasks (Body → raw → JSON)
   - GET /api/tasks
   - GET /api/tasks/:id
   - PUT /api/tasks/:id
   - PATCH /api/tasks/:id/status
   - DELETE /api/tasks/:id

3. **Save Examples:**
   - Save successful responses as examples
   - Document expected request/response

### Test Scenarios

```bash
# Scenario 1: Create multiple tasks
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Task 1", "description": "First task"}'

curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Task 2", "description": "Second task"}'

curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Task 3", "description": "Third task"}'

# Scenario 2: Update status workflow
# TODO → IN_PROGRESS → DONE
curl -X PATCH http://localhost:8080/api/tasks/1/status?status=IN_PROGRESS
curl -X PATCH http://localhost:8080/api/tasks/1/status?status=DONE

# Scenario 3: Filter by status
curl http://localhost:8080/api/tasks/status/TODO
curl http://localhost:8080/api/tasks/status/DONE

# Scenario 4: Error cases
# Get non-existent task
curl http://localhost:8080/api/tasks/999
# Response: 404 Not Found

# Delete non-existent task
curl -X DELETE http://localhost:8080/api/tasks/999
# Response: 404 Not Found
```

### Verify Logs

Check console output to see Spring's dependency injection and logging:

```
2025-12-24 14:30:45.123  INFO --- [main] c.e.t.TaskManagerApplication : Starting TaskManagerApplication
2025-12-24 14:30:45.456  INFO --- [main] c.e.t.service.TaskService    : TaskService initialized with repository: InMemoryTaskRepository
2025-12-24 14:30:45.789  INFO --- [main] c.e.t.controller.TaskController : TaskController initialized
2025-12-24 14:30:46.123  INFO --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer : Tomcat started on port(s): 8080 (http)

2025-12-24 14:31:00.456  INFO --- [nio-8080-exec-1] c.e.t.controller.TaskController : POST /api/tasks - Creating task: Complete Spring Boot Codelab
2025-12-24 14:31:00.457  DEBUG --- [nio-8080-exec-1] c.e.t.service.TaskService : Creating new task: Complete Spring Boot Codelab
2025-12-24 14:31:00.458  INFO --- [nio-8080-exec-1] c.e.t.service.TaskService : Task created with ID: 1
```

> aside positive
> **DevTools Magic:** With Spring Boot DevTools, changes to code automatically restart the application. Try modifying a controller method and save - the app restarts instantly!

## Configuration Deep Dive

Duration: 8:00

Understanding Spring Boot configuration and customization.

### application.properties vs application.yml

**application.properties:**

```properties
spring.application.name=task-manager
server.port=8080
logging.level.root=INFO
logging.level.com.example.taskmanager=DEBUG
```

**application.yml (same config):**

```yaml
spring:
  application:
    name: task-manager

server:
  port: 8080

logging:
  level:
    root: INFO
    com.example.taskmanager: DEBUG
```

### Expanded Configuration

```yaml
# Application
spring:
  application:
    name: task-manager

  # Jackson (JSON)
  jackson:
    serialization:
      write-dates-as-timestamps: false
    time-zone: UTC
    default-property-inclusion: non_null

# Server
server:
  port: 8080
  servlet:
    context-path: /
  error:
    include-message: always
    include-stacktrace: on_param

# Logging
logging:
  level:
    root: INFO
    com.example.taskmanager: DEBUG
    org.springframework.web: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
  file:
    name: logs/taskmanager.log

# Management (Actuator - add dependency to use)
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
```

### Profile-Specific Configuration

Create multiple config files for different environments:

**application-dev.yml:**

```yaml
server:
  port: 8080

logging:
  level:
    com.example.taskmanager: DEBUG
```

**application-prod.yml:**

```yaml
server:
  port: 80

logging:
  level:
    com.example.taskmanager: INFO
```

**Activate profile:**

```bash
# Command line
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Environment variable
export SPRING_PROFILES_ACTIVE=dev
mvn spring-boot:run

# In application.properties
spring.profiles.active=dev
```

### Custom Properties

**application.yml:**

```yaml
app:
  name: Task Manager
  version: 1.0.0
  max-tasks: 1000
```

**Configuration class:**

```java
package com.example.taskmanager.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app")
@Data
public class AppProperties {
    private String name;
    private String version;
    private int maxTasks;
}
```

**Usage:**

```java
@Service
public class TaskService {
    private final TaskRepository taskRepository;
    private final AppProperties appProperties;

    public TaskService(TaskRepository taskRepository, AppProperties appProperties) {
        this.taskRepository = taskRepository;
        this.appProperties = appProperties;
        log.info("App: {} v{}, Max Tasks: {}",
            appProperties.getName(),
            appProperties.getVersion(),
            appProperties.getMaxTasks());
    }

    public Task createTask(Task task) {
        List<Task> allTasks = taskRepository.findAll();
        if (allTasks.size() >= appProperties.getMaxTasks()) {
            throw new RuntimeException("Maximum tasks limit reached");
        }
        return taskRepository.save(task);
    }
}
```

### @Value Annotation

For simple property injection:

```java
@Service
public class TaskService {

    @Value("${app.name}")
    private String appName;

    @Value("${app.max-tasks:100}")  // Default value: 100
    private int maxTasks;

    @Value("${feature.enabled:false}")
    private boolean featureEnabled;
}
```

> aside positive
> **Best Practice:** Use `@ConfigurationProperties` for grouped properties and `@Value` for single properties. ConfigurationProperties provides type safety and validation.

## Bean Scopes and Lifecycle

Duration: 6:00

Understanding bean scopes and lifecycle hooks.

### Bean Scopes

```java
// 1. Singleton (default) - one instance per container
@Service
@Scope("singleton")
public class TaskService { }

// 2. Prototype - new instance each time requested
@Service
@Scope("prototype")
public class ReportGenerator { }

// 3. Request - one instance per HTTP request
@Service
@Scope("request")
public class RequestContext { }

// 4. Session - one instance per HTTP session
@Service
@Scope("session")
public class UserSession { }

// 5. Application - one instance per ServletContext
@Service
@Scope("application")
public class AppConfig { }
```

### Bean Lifecycle Hooks

```java
package com.example.taskmanager.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TaskService {

    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
        log.info("1. Constructor called");
    }

    @PostConstruct
    public void init() {
        log.info("2. @PostConstruct - Bean initialized");
        // Initialize resources, load data, etc.
        // This runs AFTER dependency injection

        // Example: Load default tasks
        Task defaultTask = new Task("Sample Task", "This is a sample task");
        taskRepository.save(defaultTask);
        log.info("Default task created");
    }

    @PreDestroy
    public void cleanup() {
        log.info("3. @PreDestroy - Bean being destroyed");
        // Cleanup resources, close connections, etc.
        // This runs BEFORE bean is removed from container

        log.info("Cleaning up resources...");
    }
}
```

### Lifecycle Order

```
1. Constructor called
2. Dependencies injected
3. @PostConstruct method called
4. Bean ready for use
5. Application runs...
6. Application shutdown triggered
7. @PreDestroy method called
8. Bean destroyed
```

### InitializingBean and DisposableBean (Alternative)

```java
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;

@Service
public class TaskService implements InitializingBean, DisposableBean {

    @Override
    public void afterPropertiesSet() throws Exception {
        // Called after properties set (like @PostConstruct)
        log.info("InitializingBean: afterPropertiesSet()");
    }

    @Override
    public void destroy() throws Exception {
        // Called before bean destruction (like @PreDestroy)
        log.info("DisposableBean: destroy()");
    }
}
```

> aside positive
> **Recommendation:** Use `@PostConstruct` and `@PreDestroy` annotations. They're standard Java annotations and don't couple your code to Spring interfaces.

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've built the foundation of a Spring Boot application!

### What You've Learned

- ✅ **IoC and DI:** Understanding Spring's core principles
- ✅ **Spring Beans:** Component scanning, stereotypes, injection
- ✅ **Spring Boot:** Auto-configuration, starters, embedded server
- ✅ **Layered Architecture:** Controller → Service → Repository
- ✅ **REST API:** Building RESTful endpoints with proper HTTP semantics
- ✅ **Configuration:** Properties, profiles, custom properties
- ✅ **Bean Lifecycle:** Scopes, initialization, destruction
- ✅ **Lombok:** Reducing boilerplate code
- ✅ **Logging:** Structured logging with SLF4J

### Task Management API v1.0

You've created a complete REST API with:

- ✅ CRUD operations for tasks
- ✅ Status management workflow
- ✅ Filtering by status
- ✅ In-memory storage (thread-safe)
- ✅ Proper HTTP status codes
- ✅ Structured logging
- ✅ Clean architecture (separation of concerns)

### Key Takeaways

1. **Constructor injection is best** for required dependencies
2. **Spring Boot auto-configures** most things intelligently
3. **Lombok saves time** with `@Data`, `@Slf4j`, etc.
4. **Stereotype annotations** provide semantic meaning (`@Service`, `@Repository`)
5. **ResponseEntity** gives full control over HTTP responses
6. **Configuration profiles** enable environment-specific settings

### Git Branching Strategy

```bash
# Tag this version
git add .
git commit -m "Codelab 3.1: Spring Core & Boot basics complete"
git tag codelab-3.1
git push origin codelab-3.1

# Create branch for next codelab
git checkout -b codelab-3.2
```

### Next Steps

Continue to:

- **Codelab 3.2:** RESTful APIs & Swagger Documentation

  - Add Swagger UI
  - Request/response validation
  - Global exception handling
  - Custom error responses

- **Codelab 3.3:** ORM & Spring Data JPA
  - Replace in-memory storage with database
  - JPA entities and relationships
  - Query methods and custom queries

### Project Evolution

Our Task Management API will grow through:

- **3.2:** Swagger docs, validation, exception handling
- **3.3:** Database persistence with JPA
- **3.4:** Security and JWT authentication
- **3.5:** Spring Cloud and microservices
- **3.6:** Reactive programming with WebFlux
- **3.7:** Messaging with JMS
- **3.8:** Comprehensive testing

### Additional Resources

- [Spring Framework Documentation](https://spring.io/projects/spring-framework)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Boot Guides](https://spring.io/guides)
- [Baeldung Spring Tutorials](https://www.baeldung.com/spring-tutorial)
- [Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/html/)

> aside positive
> **Production Ready Foundation!** You've built a solid Spring Boot application following best practices. The architecture you've learned scales from small apps to enterprise systems!
