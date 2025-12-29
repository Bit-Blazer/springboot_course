summary: Transform the Task Management API to reactive programming with Spring WebFlux and R2DBC for non-blocking, scalable, event-driven architecture
id: reactive-webflux-r2dbc
categories: Spring Boot, Reactive Programming, WebFlux, R2DBC, Project Reactor
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM

# Reactive Programming with WebFlux & R2DBC

## Introduction

Duration: 3:00

Transform the blocking Task Management API into a fully reactive, non-blocking application using Spring WebFlux and R2DBC.

### What You'll Learn

- **Reactive Programming:** Event-driven, non-blocking paradigm
- **Project Reactor:** Mono and Flux reactive types
- **Spring WebFlux:** Reactive web framework
- **R2DBC:** Reactive Relational Database Connectivity
- **Reactive Repositories:** Non-blocking database access
- **Reactive Security:** WebFlux security configuration
- **Backpressure:** Flow control in reactive streams
- **Operators:** map, flatMap, filter, zip, merge
- **Error Handling:** onErrorResume, onErrorReturn
- **Testing:** WebTestClient for reactive endpoints

### What You'll Build

Reactive Task Management API with:

- **Reactive Controllers** using Mono and Flux
- **R2DBC Repositories** for non-blocking DB access
- **Reactive Security** with JWT
- **Non-blocking Operations** throughout the stack
- **H2 R2DBC** for development
- **PostgreSQL R2DBC** ready for production
- **Reactive Validation** and error handling
- **WebTestClient** integration tests
- **Server-Sent Events** for real-time updates

### Prerequisites

- Completed Codelab 3.5 (JWT & Spring Cloud Config)
- Understanding of functional programming (lambdas, streams)

### Blocking vs Reactive

**Blocking (Traditional):**

```
Thread → DB Query → [WAIT] → Response
(Thread blocked during I/O)
```

**Reactive (Non-blocking):**

```
Thread → DB Query → Release Thread
         ↓
      [I/O Happens]
         ↓
Thread Pool → Response
(Thread freed during I/O)
```

### New Dependencies

Replace blocking dependencies with reactive ones in `pom.xml`:

```xml
<!-- REMOVE these blocking dependencies -->
<!--
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
</dependency>
-->

<!-- ADD these reactive dependencies -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-r2dbc</artifactId>
</dependency>

<!-- R2DBC H2 (for development) -->
<dependency>
    <groupId>io.r2dbc</groupId>
    <artifactId>r2dbc-h2</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- R2DBC PostgreSQL (for production) -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>r2dbc-postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Reactive Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- Validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>

<!-- Lombok -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>

<!-- JWT (same as before) -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>

<!-- Reactor Test -->
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-test</artifactId>
    <scope>test</scope>
</dependency>
```

> aside positive
> **Paradigm Shift:** We're moving from imperative blocking code to declarative reactive streams. This enables better scalability with fewer threads!

## Understanding Reactive Programming

Duration: 8:00

Learn the reactive programming paradigm and Project Reactor.

### Reactive Manifesto

Reactive systems are:

1. **Responsive:** Quick and consistent response times
2. **Resilient:** Responsive despite failures
3. **Elastic:** Responsive under varying load
4. **Message-Driven:** Async message passing with backpressure

### Reactive Streams

```
Publisher → Subscriber
     ↓
  [Data Flow]
     ↓
[Backpressure]
```

**Key Interfaces:**

- `Publisher<T>`: Produces data
- `Subscriber<T>`: Consumes data
- `Subscription`: Connection between them
- `Processor<T,R>`: Both publisher and subscriber

### Project Reactor Types

**Mono<T>:** 0 or 1 element

```java
Mono<Task> mono = taskRepository.findById(1L);
// Emits: Task or empty
```

**Flux<T>:** 0 to N elements

```java
Flux<Task> flux = taskRepository.findAll();
// Emits: Task, Task, Task, ..., complete
```

### Marble Diagrams

**Mono:**

```
Time →
---(Task)---|→
   emit    complete
```

**Flux:**

```
Time →
---(T1)---(T2)---(T3)---|→
   emit  emit  emit   complete
```

**Error:**

```
Time →
---(T1)---(T2)---X
   emit  emit  error
```

### Common Operators

```java
// map: Transform each element
Flux<String> titles = flux.map(Task::getTitle);

// flatMap: Transform to Publisher and flatten
Flux<User> users = flux.flatMap(task ->
    userRepository.findById(task.getUserId())
);

// filter: Keep elements matching predicate
Flux<Task> todoTasks = flux.filter(task ->
    task.getStatus() == TaskStatus.TODO
);

// take: Limit elements
Flux<Task> first10 = flux.take(10);

// zip: Combine multiple streams
Flux<Tuple2<Task, User>> combined = Flux.zip(tasks, users);

// merge: Interleave multiple streams
Flux<Task> all = Flux.merge(flux1, flux2);

// collectList: Flux → Mono<List>
Mono<List<Task>> list = flux.collectList();

// flatMapMany: Mono → Flux
Flux<Task> tasks = userMono.flatMapMany(user ->
    taskRepository.findByUserId(user.getId())
);
```

### Error Handling

```java
// onErrorResume: Fallback to another publisher
Mono<Task> result = taskRepository.findById(id)
    .onErrorResume(error -> Mono.empty());

// onErrorReturn: Return default value
Mono<Task> result = taskRepository.findById(id)
    .onErrorReturn(new Task());

// onErrorMap: Transform error
Mono<Task> result = taskRepository.findById(id)
    .onErrorMap(e -> new TaskNotFoundException(id));

// doOnError: Side effect on error
Mono<Task> result = taskRepository.findById(id)
    .doOnError(e -> log.error("Error: {}", e.getMessage()));
```

### Subscription

```java
// Nothing happens until you subscribe!
Mono<Task> mono = taskRepository.findById(1L);
// ↑ No database query yet

mono.subscribe(
    task -> System.out.println("Success: " + task),
    error -> System.err.println("Error: " + error),
    () -> System.out.println("Complete")
);
// ↑ Now the query executes
```

### Blocking vs Reactive Example

**Blocking:**

```java
@GetMapping("/tasks")
public List<Task> getTasks() {
    // Thread blocked until DB query completes
    return taskRepository.findAll();
}

// 1000 concurrent requests = 1000 threads needed
```

**Reactive:**

```java
@GetMapping("/tasks")
public Flux<Task> getTasks() {
    // Thread released immediately
    return taskRepository.findAll();
}

// 1000 concurrent requests = Few threads (event loop)
```

### Backpressure

Publisher produces faster than Subscriber can consume:

```
Publisher: ████████████████ (fast)
Subscriber: ██ (slow)

Problem: Memory overflow

Solution: Backpressure
- BUFFER: Store excess
- DROP: Discard excess
- LATEST: Keep only latest
- ERROR: Fail fast
```

```java
Flux<Task> flux = taskRepository.findAll()
    .onBackpressureBuffer(100)  // Buffer up to 100
    .onBackpressureDrop()       // Or drop excess
    .onBackpressureLatest();    // Or keep latest only
```

> aside positive
> **Key Insight:** Reactive programming is about composing asynchronous, non-blocking operations using declarative code. Think "what to do" not "how to do it"!

## Configure R2DBC Database

Duration: 5:00

Set up R2DBC for reactive database access.

### Update application.yml

```yaml
spring:
  application:
    name: task-manager-reactive

  # R2DBC Configuration (H2)
  r2dbc:
    url: r2dbc:h2:mem:///taskdb?options=DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    username: sa
    password:

  # H2 Console (optional, for debugging)
  h2:
    console:
      enabled: true

# Logging
logging:
  level:
    org.springframework.r2dbc: DEBUG
    io.r2dbc: DEBUG
    com.example.taskmanager: DEBUG
```

### PostgreSQL Configuration (Production)

**application-prod.yml:**

```yaml
spring:
  r2dbc:
    url: r2dbc:postgresql://localhost:5432/taskdb
    username: postgres
    password: ${DB_PASSWORD}
    pool:
      initial-size: 10
      max-size: 20
      max-idle-time: 30m
```

### R2DBC URL Format

```
r2dbc:<driver>://<host>:<port>/<database>[?options]

Examples:
r2dbc:h2:mem:///testdb
r2dbc:h2:file:///./data/taskdb
r2dbc:postgresql://localhost:5432/taskdb
r2dbc:mysql://localhost:3306/taskdb
```

### Initialize Database Schema

R2DBC doesn't auto-create tables like JPA. Create schema initialization:

**resources/schema.sql:**

```sql
-- Drop tables if exist
DROP TABLE IF EXISTS task_categories;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS users;

-- Users table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- User roles table
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (user_id, role),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tasks table
CREATE TABLE tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    status VARCHAR(20) NOT NULL,
    user_id BIGINT,
    version BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Categories table
CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- Task-Category junction table
CREATE TABLE task_categories (
    task_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    PRIMARY KEY (task_id, category_id),
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);
```

### Schema Initialization Configuration

```java
package com.example.taskmanager.config;

import io.r2dbc.spi.ConnectionFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.r2dbc.connection.init.ConnectionFactoryInitializer;
import org.springframework.r2dbc.connection.init.ResourceDatabasePopulator;

@Configuration
public class R2dbcConfig {

    @Bean
    public ConnectionFactoryInitializer initializer(ConnectionFactory connectionFactory) {
        ConnectionFactoryInitializer initializer = new ConnectionFactoryInitializer();
        initializer.setConnectionFactory(connectionFactory);

        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.addScript(new ClassPathResource("schema.sql"));

        initializer.setDatabasePopulator(populator);
        return initializer;
    }
}
```

> aside negative
> **Important:** R2DBC doesn't support JPA annotations like @Entity, @OneToMany. Use plain POJOs with @Table and @Id from Spring Data R2DBC.

## Create Reactive Entities

Duration: 8:00

Transform entities for R2DBC (no JPA annotations).

### Task Entity

```java
package com.example.taskmanager.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Table("tasks")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Task {

    @Id
    private Long id;

    @Column("title")
    private String title;

    @Column("description")
    private String description;

    @Column("status")
    private TaskStatus status;

    @Column("user_id")
    private Long userId;

    @Version
    private Long version;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
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

### TaskStatus Enum

```java
package com.example.taskmanager.model;

public enum TaskStatus {
    TODO,
    IN_PROGRESS,
    DONE,
    CANCELLED
}
```

### User Entity

```java
package com.example.taskmanager.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Table("users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    private Long id;

    @Column("username")
    private String username;

    @Column("email")
    private String email;

    @Column("full_name")
    private String fullName;

    @Column("password")
    private String password;

    @Column("enabled")
    private Boolean enabled = true;

    @Column("created_at")
    private LocalDateTime createdAt;

    // Roles loaded separately (no direct mapping in R2DBC)
    @Transient
    private Set<String> roles = new HashSet<>();

    public User(String username, String email, String fullName, String password) {
        this.username = username;
        this.email = email;
        this.fullName = fullName;
        this.password = password;
        this.enabled = true;
        this.createdAt = LocalDateTime.now();
        this.roles.add("ROLE_USER");
    }
}
```

### Category Entity

```java
package com.example.taskmanager.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Table("categories")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Category {

    @Id
    private Long id;

    @Column("name")
    private String name;

    @Column("description")
    private String description;

    public Category(String name, String description) {
        this.name = name;
        this.description = description;
    }
}
```

### Key Differences from JPA

| JPA                                | R2DBC                  |
| ---------------------------------- | ---------------------- |
| `@Entity`                          | `@Table`               |
| `@GeneratedValue`                  | Auto by DB             |
| `@OneToMany`, `@ManyToOne`         | Manual join queries    |
| `@ManyToMany`                      | Junction table, manual |
| `@Column(name)`                    | `@Column("name")`      |
| Lazy/Eager loading                 | Manual with `flatMap`  |
| Cascade operations                 | Manual                 |
| Relationships loaded automatically | Load explicitly        |

> aside positive
> **R2DBC Philosophy:** Simple, lightweight mapping. Complex relationships handled in application code using reactive operators.

## Reactive Repositories

Duration: 10:00

Create reactive repositories using R2dbcRepository.

### TaskRepository

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface TaskRepository extends R2dbcRepository<Task, Long> {

    // Derived query methods
    Flux<Task> findByStatus(TaskStatus status);

    Flux<Task> findByUserId(Long userId);

    Flux<Task> findByTitleContainingIgnoreCase(String title);

    Mono<Long> countByStatus(TaskStatus status);

    Mono<Boolean> existsByTitleAndUserId(String title, Long userId);

    // Custom queries
    @Query("SELECT * FROM tasks WHERE status = :status AND user_id = :userId")
    Flux<Task> findByStatusAndUserId(TaskStatus status, Long userId);

    @Query("SELECT * FROM tasks WHERE created_at > :since ORDER BY created_at DESC")
    Flux<Task> findRecentTasks(String since);

    @Query("DELETE FROM tasks WHERE status = :status")
    Mono<Void> deleteByStatus(TaskStatus status);
}
```

### UserRepository

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.User;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface UserRepository extends R2dbcRepository<User, Long> {

    Mono<User> findByUsername(String username);

    Mono<User> findByEmail(String email);

    Mono<Boolean> existsByUsername(String username);

    Mono<Boolean> existsByEmail(String email);

    @Query("SELECT r.role FROM user_roles r WHERE r.user_id = :userId")
    Flux<String> findRolesByUserId(Long userId);
}
```

### UserRoleRepository

```java
package com.example.taskmanager.repository;

import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface UserRoleRepository extends ReactiveCrudRepository<UserRole, Long> {

    @Query("INSERT INTO user_roles (user_id, role) VALUES (:userId, :role)")
    Mono<Void> insertRole(Long userId, String role);

    @Query("DELETE FROM user_roles WHERE user_id = :userId AND role = :role")
    Mono<Void> deleteRole(Long userId, String role);

    @Query("SELECT role FROM user_roles WHERE user_id = :userId")
    Flux<String> findRolesByUserId(Long userId);
}
```

### CategoryRepository

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.Category;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface CategoryRepository extends R2dbcRepository<Category, Long> {

    Mono<Category> findByName(String name);

    Mono<Boolean> existsByName(String name);
}
```

### R2dbcRepository Methods

```java
// All methods return Mono or Flux
Mono<Task> save(Task task);               // Save or update
Flux<Task> saveAll(Iterable<Task> tasks); // Batch save
Mono<Task> findById(Long id);             // Find by ID
Flux<Task> findAll();                     // Find all
Flux<Task> findAllById(Iterable<Long> ids); // Find multiple
Mono<Long> count();                       // Count all
Mono<Boolean> existsById(Long id);        // Check exists
Mono<Void> deleteById(Long id);           // Delete by ID
Mono<Void> delete(Task task);             // Delete entity
Mono<Void> deleteAll();                   // Delete all
```

> aside positive
> **Reactive Repositories:** All methods return Mono or Flux instead of blocking values. Queries execute only when subscribed!

## Reactive Service Layer

Duration: 10:00

Transform services to use reactive operators.

### TaskService

```java
package com.example.taskmanager.service;

import com.example.taskmanager.exception.TaskNotFoundException;
import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.repository.TaskRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;

@Service
@Slf4j
public class TaskService {

    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public Mono<Task> createTask(Task task) {
        log.debug("Creating task: {}", task.getTitle());

        task.setCreatedAt(LocalDateTime.now());
        task.setUpdatedAt(LocalDateTime.now());

        if (task.getStatus() == null) {
            task.setStatus(TaskStatus.TODO);
        }

        return taskRepository.save(task)
            .doOnSuccess(saved -> log.info("Task created with ID: {}", saved.getId()))
            .doOnError(error -> log.error("Error creating task: {}", error.getMessage()));
    }

    public Mono<Task> getTaskById(Long id) {
        log.debug("Fetching task: {}", id);

        return taskRepository.findById(id)
            .switchIfEmpty(Mono.error(new TaskNotFoundException(id)))
            .doOnSuccess(task -> log.debug("Found task: {}", task.getTitle()));
    }

    public Flux<Task> getAllTasks() {
        log.debug("Fetching all tasks");
        return taskRepository.findAll()
            .doOnComplete(() -> log.debug("Fetched all tasks"));
    }

    public Mono<Task> updateTask(Long id, Task taskDetails) {
        log.debug("Updating task: {}", id);

        return taskRepository.findById(id)
            .switchIfEmpty(Mono.error(new TaskNotFoundException(id)))
            .flatMap(task -> {
                task.setTitle(taskDetails.getTitle());
                task.setDescription(taskDetails.getDescription());
                task.setStatus(taskDetails.getStatus());
                task.setUpdatedAt(LocalDateTime.now());
                return taskRepository.save(task);
            })
            .doOnSuccess(updated -> log.info("Task updated: {}", id));
    }

    public Mono<Void> deleteTask(Long id) {
        log.debug("Deleting task: {}", id);

        return taskRepository.existsById(id)
            .flatMap(exists -> {
                if (!exists) {
                    return Mono.error(new TaskNotFoundException(id));
                }
                return taskRepository.deleteById(id);
            })
            .doOnSuccess(v -> log.info("Task deleted: {}", id));
    }

    public Mono<Task> updateTaskStatus(Long id, TaskStatus status) {
        log.debug("Updating task {} status to {}", id, status);

        return taskRepository.findById(id)
            .switchIfEmpty(Mono.error(new TaskNotFoundException(id)))
            .flatMap(task -> {
                task.setStatus(status);
                task.setUpdatedAt(LocalDateTime.now());
                return taskRepository.save(task);
            });
    }

    public Flux<Task> getTasksByStatus(TaskStatus status) {
        log.debug("Fetching tasks with status: {}", status);
        return taskRepository.findByStatus(status);
    }

    public Flux<Task> getTasksByUser(Long userId) {
        log.debug("Fetching tasks for user: {}", userId);
        return taskRepository.findByUserId(userId);
    }

    public Flux<Task> searchTasks(String keyword) {
        log.debug("Searching tasks with keyword: {}", keyword);
        return taskRepository.findByTitleContainingIgnoreCase(keyword);
    }

    public Mono<Task> assignTaskToUser(Long taskId, Long userId) {
        log.debug("Assigning task {} to user {}", taskId, userId);

        return taskRepository.findById(taskId)
            .switchIfEmpty(Mono.error(new TaskNotFoundException(taskId)))
            .flatMap(task -> {
                task.setUserId(userId);
                task.setUpdatedAt(LocalDateTime.now());
                return taskRepository.save(task);
            });
    }

    public Mono<Long> countTasksByStatus(TaskStatus status) {
        return taskRepository.countByStatus(status);
    }

    public Flux<Task> getRecentTasks(int days) {
        LocalDateTime since = LocalDateTime.now().minusDays(days);
        return taskRepository.findRecentTasks(since.toString());
    }

    // Reactive batch operation
    public Flux<Task> createMultipleTasks(Flux<Task> tasks) {
        return tasks
            .doOnNext(task -> {
                task.setCreatedAt(LocalDateTime.now());
                task.setUpdatedAt(LocalDateTime.now());
                if (task.getStatus() == null) {
                    task.setStatus(TaskStatus.TODO);
                }
            })
            .flatMap(taskRepository::save)
            .doOnComplete(() -> log.info("Batch task creation completed"));
    }
}
```

### UserService

```java
package com.example.taskmanager.service;

import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.UserRepository;
import com.example.taskmanager.repository.UserRoleRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;

@Service
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final UserRoleRepository userRoleRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository,
                       UserRoleRepository userRoleRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.userRoleRepository = userRoleRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public Mono<User> registerUser(User user) {
        log.debug("Registering user: {}", user.getUsername());

        return userRepository.existsByUsername(user.getUsername())
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new RuntimeException("Username already exists"));
                }
                return userRepository.existsByEmail(user.getEmail());
            })
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new RuntimeException("Email already exists"));
                }

                user.setPassword(passwordEncoder.encode(user.getPassword()));
                user.setCreatedAt(LocalDateTime.now());
                user.setEnabled(true);

                return userRepository.save(user);
            })
            .flatMap(savedUser -> {
                // Insert default role
                return userRoleRepository.insertRole(savedUser.getId(), "ROLE_USER")
                    .thenReturn(savedUser);
            })
            .doOnSuccess(u -> log.info("User registered: {}", u.getUsername()));
    }

    public Mono<User> getUserById(Long id) {
        return userRepository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("User not found")))
            .flatMap(this::loadUserRoles);
    }

    public Mono<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username)
            .switchIfEmpty(Mono.error(new RuntimeException("User not found")))
            .flatMap(this::loadUserRoles);
    }

    public Flux<User> getAllUsers() {
        return userRepository.findAll()
            .flatMap(this::loadUserRoles);
    }

    public Mono<Void> deleteUser(Long id) {
        return userRepository.existsById(id)
            .flatMap(exists -> {
                if (!exists) {
                    return Mono.error(new RuntimeException("User not found"));
                }
                return userRepository.deleteById(id);
            });
    }

    // Helper: Load user roles
    private Mono<User> loadUserRoles(User user) {
        return userRoleRepository.findRolesByUserId(user.getId())
            .collectList()
            .map(roles -> {
                user.getRoles().addAll(roles);
                return user;
            });
    }
}
```

### Reactive Patterns

```java
// Pattern 1: Chain operations
mono.flatMap(value -> doSomething(value))
    .flatMap(result -> doAnotherThing(result))
    .map(finalResult -> transform(finalResult));

// Pattern 2: Error handling
mono.switchIfEmpty(Mono.error(new NotFoundException()))
    .onErrorResume(e -> Mono.just(defaultValue));

// Pattern 3: Combine multiple sources
Mono.zip(mono1, mono2, mono3)
    .map(tuple -> combine(tuple.getT1(), tuple.getT2(), tuple.getT3()));

// Pattern 4: Conditional logic
mono.flatMap(value -> {
    if (condition) {
        return Mono.just(value);
    } else {
        return Mono.error(new ValidationException());
    }
});

// Pattern 5: Side effects
mono.doOnSuccess(v -> log.info("Success: {}", v))
    .doOnError(e -> log.error("Error: {}", e))
    .doFinally(signal -> log.debug("Completed with signal: {}", signal));
```

> aside positive
> **Reactive Composition:** Chain operations using flatMap, map, filter. Each operator returns a new Publisher, enabling functional composition!

## Reactive Controllers

Duration: 8:00

Create WebFlux controllers with Mono and Flux.

### TaskController

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.dto.CreateTaskRequest;
import com.example.taskmanager.dto.TaskResponse;
import com.example.taskmanager.dto.UpdateTaskRequest;
import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.service.TaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.time.Duration;
import java.util.Map;

@RestController
@RequestMapping("/api/tasks")
@Tag(name = "Task Management (Reactive)")
@SecurityRequirement(name = "bearer-jwt")
@Slf4j
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @Operation(summary = "Create a new task")
    @PostMapping
    public Mono<ResponseEntity<TaskResponse>> createTask(
            @Valid @RequestBody CreateTaskRequest request) {

        log.info("POST /api/tasks - Creating task: {}", request.getTitle());

        Task task = new Task();
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        task.setStatus(request.getStatus() != null ? request.getStatus() : TaskStatus.TODO);

        return taskService.createTask(task)
            .map(TaskResponse::new)
            .map(response -> ResponseEntity
                .created(URI.create("/api/tasks/" + response.getId()))
                .body(response));
    }

    @Operation(summary = "Get all tasks")
    @GetMapping
    public Flux<TaskResponse> getAllTasks() {
        log.info("GET /api/tasks");
        return taskService.getAllTasks()
            .map(TaskResponse::new);
    }

    @Operation(summary = "Get task by ID")
    @GetMapping("/{id}")
    public Mono<ResponseEntity<TaskResponse>> getTaskById(@PathVariable Long id) {
        log.info("GET /api/tasks/{}", id);
        return taskService.getTaskById(id)
            .map(TaskResponse::new)
            .map(ResponseEntity::ok)
            .defaultIfEmpty(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Update task")
    @PutMapping("/{id}")
    public Mono<ResponseEntity<TaskResponse>> updateTask(
            @PathVariable Long id,
            @Valid @RequestBody UpdateTaskRequest request) {

        log.info("PUT /api/tasks/{}", id);

        Task task = new Task();
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        task.setStatus(request.getStatus());

        return taskService.updateTask(id, task)
            .map(TaskResponse::new)
            .map(ResponseEntity::ok);
    }

    @Operation(summary = "Delete task")
    @DeleteMapping("/{id}")
    public Mono<ResponseEntity<Void>> deleteTask(@PathVariable Long id) {
        log.info("DELETE /api/tasks/{}", id);
        return taskService.deleteTask(id)
            .then(Mono.just(ResponseEntity.noContent().<Void>build()));
    }

    @Operation(summary = "Update task status")
    @PatchMapping("/{id}/status")
    public Mono<ResponseEntity<TaskResponse>> updateTaskStatus(
            @PathVariable Long id,
            @RequestBody Map<String, TaskStatus> request) {

        log.info("PATCH /api/tasks/{}/status", id);
        TaskStatus status = request.get("status");

        return taskService.updateTaskStatus(id, status)
            .map(TaskResponse::new)
            .map(ResponseEntity::ok);
    }

    @Operation(summary = "Get tasks by status")
    @GetMapping("/status/{status}")
    public Flux<TaskResponse> getTasksByStatus(@PathVariable TaskStatus status) {
        log.info("GET /api/tasks/status/{}", status);
        return taskService.getTasksByStatus(status)
            .map(TaskResponse::new);
    }

    @Operation(summary = "Search tasks")
    @GetMapping("/search")
    public Flux<TaskResponse> searchTasks(@RequestParam String keyword) {
        log.info("GET /api/tasks/search?keyword={}", keyword);
        return taskService.searchTasks(keyword)
            .map(TaskResponse::new);
    }

    @Operation(summary = "Get task statistics")
    @GetMapping("/stats")
    public Mono<Map<TaskStatus, Long>> getTaskStats() {
        log.info("GET /api/tasks/stats");

        return Flux.fromArray(TaskStatus.values())
            .flatMap(status ->
                taskService.countTasksByStatus(status)
                    .map(count -> Map.entry(status, count))
            )
            .collectMap(Map.Entry::getKey, Map.Entry::getValue);
    }

    // Server-Sent Events (SSE) - Real-time task updates
    @Operation(summary = "Stream task updates (SSE)")
    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<TaskResponse> streamTasks() {
        log.info("GET /api/tasks/stream - SSE connection established");

        return taskService.getAllTasks()
            .map(TaskResponse::new)
            .delayElements(Duration.ofSeconds(1)); // Emit one task per second
    }
}
```

### AuthController (Reactive)

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.dto.AuthResponse;
import com.example.taskmanager.dto.LoginRequest;
import com.example.taskmanager.dto.SignupRequest;
import com.example.taskmanager.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication (Reactive)")
@Slf4j
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "User login - Get JWT token")
    @PostMapping("/login")
    public Mono<ResponseEntity<AuthResponse>> login(
            @Valid @RequestBody LoginRequest loginRequest) {

        log.info("POST /api/auth/login - User: {}", loginRequest.getUsername());
        return authService.login(loginRequest)
            .map(ResponseEntity::ok);
    }

    @Operation(summary = "User signup - Register and get JWT token")
    @PostMapping("/signup")
    public Mono<ResponseEntity<AuthResponse>> signup(
            @Valid @RequestBody SignupRequest signupRequest) {

        log.info("POST /api/auth/signup - User: {}", signupRequest.getUsername());
        return authService.signup(signupRequest)
            .map(ResponseEntity::ok);
    }
}
```

### Server-Sent Events (SSE)

```java
// Real-time streaming example
@GetMapping(value = "/live-updates", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public Flux<TaskResponse> liveTaskUpdates() {
    return Flux.interval(Duration.ofSeconds(5))
        .flatMap(tick -> taskService.getAllTasks())
        .map(TaskResponse::new);
}
```

> aside positive
> **SSE Advantage:** With reactive streams, Server-Sent Events are trivial to implement. Just return Flux with TEXT_EVENT_STREAM_VALUE!

## Testing Reactive API

Duration: 5:00

Test reactive endpoints with WebTestClient.

### Integration Test

```java
package com.example.taskmanager;

import com.example.taskmanager.dto.CreateTaskRequest;
import com.example.taskmanager.dto.TaskResponse;
import com.example.taskmanager.model.TaskStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.reactive.server.WebTestClient;
import reactor.core.publisher.Mono;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureWebTestClient
public class TaskControllerIntegrationTest {

    @Autowired
    private WebTestClient webTestClient;

    @Test
    public void testCreateTask() {
        CreateTaskRequest request = new CreateTaskRequest(
            "Test Task",
            "Test Description",
            TaskStatus.TODO
        );

        webTestClient.post()
            .uri("/api/tasks")
            .contentType(MediaType.APPLICATION_JSON)
            .body(Mono.just(request), CreateTaskRequest.class)
            .exchange()
            .expectStatus().isCreated()
            .expectBody(TaskResponse.class)
            .value(response -> {
                assert response.getTitle().equals("Test Task");
                assert response.getStatus() == TaskStatus.TODO;
            });
    }

    @Test
    public void testGetAllTasks() {
        webTestClient.get()
            .uri("/api/tasks")
            .exchange()
            .expectStatus().isOk()
            .expectBodyList(TaskResponse.class)
            .hasSize(0); // Assuming empty database
    }

    @Test
    public void testStreamTasks() {
        webTestClient.get()
            .uri("/api/tasks/stream")
            .accept(MediaType.TEXT_EVENT_STREAM)
            .exchange()
            .expectStatus().isOk()
            .expectHeader().contentType(MediaType.TEXT_EVENT_STREAM_VALUE)
            .expectBodyList(TaskResponse.class);
    }
}
```

### Unit Test with Reactor Test

```java
package com.example.taskmanager.service;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.repository.TaskRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @InjectMocks
    private TaskService taskService;

    @Test
    public void testCreateTask() {
        Task task = new Task("Test", "Description");
        task.setId(1L);

        when(taskRepository.save(any(Task.class))).thenReturn(Mono.just(task));

        Mono<Task> result = taskService.createTask(task);

        StepVerifier.create(result)
            .expectNextMatches(t -> t.getId().equals(1L))
            .verifyComplete();
    }

    @Test
    public void testGetAllTasks() {
        Task task1 = new Task("Task 1", "Desc 1");
        Task task2 = new Task("Task 2", "Desc 2");

        when(taskRepository.findAll()).thenReturn(Flux.just(task1, task2));

        Flux<Task> result = taskService.getAllTasks();

        StepVerifier.create(result)
            .expectNext(task1)
            .expectNext(task2)
            .verifyComplete();
    }
}
```

### Run Tests

```bash
mvn test
```

> aside positive
> **Reactor Test:** StepVerifier provides a fluent API for testing reactive streams. Verify emissions, errors, and completion!

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've transformed your API to fully reactive!

### What You've Learned

- ✅ **Reactive Programming:** Non-blocking, event-driven paradigm
- ✅ **Project Reactor:** Mono and Flux for reactive streams
- ✅ **Spring WebFlux:** Reactive web framework
- ✅ **R2DBC:** Reactive database connectivity
- ✅ **Reactive Repositories:** Non-blocking data access
- ✅ **Reactive Operators:** map, flatMap, filter, zip, merge
- ✅ **Error Handling:** onErrorResume, switchIfEmpty
- ✅ **Server-Sent Events:** Real-time streaming
- ✅ **Testing:** WebTestClient and StepVerifier

### Task Management API v1.5

Reactive features:

- ✅ Fully non-blocking architecture
- ✅ WebFlux controllers with Mono/Flux
- ✅ R2DBC for reactive database access
- ✅ Reactive repositories and services
- ✅ Server-Sent Events for real-time updates
- ✅ Better scalability with event loop
- ✅ Lower memory footprint
- ✅ Backpressure support
- ✅ Functional reactive composition

### Performance Benefits

**Blocking (Web MVC):**

- 1000 requests = 1000 threads
- High memory usage
- Context switching overhead

**Reactive (WebFlux):**

- 1000 requests = ~10 threads (event loop)
- Low memory usage
- No context switching
- 10x+ better throughput

### Git Branching

```bash
git add .
git commit -m "Codelab 3.6: Reactive WebFlux & R2DBC complete"
git tag codelab-3.6
```

### Next Steps

- **Codelab 3.7:** Spring JMS & Event-Driven Architecture

### Additional Resources

- [Project Reactor Documentation](https://projectreactor.io/docs)
- [Spring WebFlux Reference](https://docs.spring.io/spring-framework/reference/web/webflux.html)
- [R2DBC Documentation](https://r2dbc.io/)
- [Reactive Manifesto](https://www.reactivemanifesto.org/)

> aside positive
> **Cloud Native Ready!** Your API now handles high concurrency with minimal resources - perfect for cloud deployments and microservices!
