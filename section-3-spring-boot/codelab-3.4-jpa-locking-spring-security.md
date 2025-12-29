summary: Master JPA locking mechanisms, implement Spring Security with role-based access control, and secure the Task Management API with authentication and authorization
id: jpa-locking-spring-security
categories: Spring Boot, JPA, Spring Security, Authentication, Authorization
environments: Web
status: Published
home url: /springboot_course/

# JPA Locking Mechanisms & Spring Security

## Introduction

Duration: 3:00

Add concurrency control with JPA locking and secure the application with Spring Security.

### What You'll Learn

- **JPA Locking:** Optimistic vs pessimistic locking
- **@Version:** Optimistic locking with version fields
- **LockModeType:** Pessimistic locking strategies
- **Spring Security:** Authentication and authorization
- **Security Configuration:** SecurityFilterChain setup
- **User Authentication:** UserDetailsService implementation
- **Password Encoding:** BCrypt password hashing
- **Method Security:** @PreAuthorize, @Secured annotations
- **Role-Based Access:** Admin, user, guest roles
- **Security Context:** Authentication principal access

### What You'll Build

Secure Task Management API with:

- **Optimistic Locking** on Task entity to prevent lost updates
- **Version Conflict Handling** with custom exception
- **User Entity** with password and roles
- **Spring Security** configuration with form and HTTP Basic auth
- **Password Encoder** for secure password storage
- **Custom UserDetailsService** for database authentication
- **Role-Based Endpoints:** Admin-only and user-specific access
- **Method Security** on service layer
- **Security Integration** with existing API

### Prerequisites

- Completed Codelab 3.3 (ORM & Spring Data JPA)
- Understanding of JPA entities and repositories

### New Dependencies

Add to `pom.xml`:

```xml
<!-- Spring Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- Security Test -->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-test</artifactId>
    <scope>test</scope>
</dependency>
```

> aside positive
> **Git Branch:** Start from `codelab-3.3` or continue. This codelab adds enterprise-grade security and concurrency control.

## Understanding Concurrency Problems

Duration: 8:00

Learn why locking is necessary in multi-user applications.

### The Lost Update Problem

**Scenario:** Two users edit the same task simultaneously.

```
Time  User A                    User B                    Database
----  ----------------------    ----------------------    -------------
T1    Read task (status=TODO)                            status=TODO
T2                               Read task (status=TODO)  status=TODO
T3    Update status=DOING
T4                               Update status=DONE
T5    Save (status=DOING)                                 status=DOING
T6                               Save (status=DONE)       status=DONE ❌
```

**Result:** User A's update is lost! User B overwrote it.

### Dirty Reads

**Scenario:** One transaction reads uncommitted changes from another.

```
Time  Transaction A             Transaction B
----  ----------------------    ----------------------
T1    Update task price=100
T2                               Read task price=100
T3    ROLLBACK
T4                               Use price=100 ❌ (dirty)
```

### Non-Repeatable Reads

**Scenario:** Reading the same data twice in a transaction gives different results.

```
Time  Transaction A             Transaction B
----  ----------------------    ----------------------
T1    Read task (status=TODO)
T2                               Update status=DONE
T3                               COMMIT
T4    Read task (status=DONE) ❌ Different value!
```

### Solution: Locking

Two approaches to prevent these problems:

1. **Optimistic Locking:** Assume conflicts are rare, detect them when saving
2. **Pessimistic Locking:** Assume conflicts are common, lock data while reading

## Optimistic Locking with @Version

Duration: 10:00

Add version field to detect concurrent modifications.

### Update Task Entity

```java
package com.example.taskmanager.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "tasks")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(length = 500)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TaskStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User assignedTo;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "task_categories",
        joinColumns = @JoinColumn(name = "task_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    private Set<Category> categories = new HashSet<>();

    // ⭐ Optimistic locking version field
    @Version
    private Long version;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public Task(String title, String description) {
        this.title = title;
        this.description = description;
        this.status = TaskStatus.TODO;
    }
}
```

### How @Version Works

```
Initial State: Task(id=1, title="Fix bug", version=0)

User A reads:  Task(id=1, version=0)
User B reads:  Task(id=1, version=0)

User A updates:
  UPDATE tasks
  SET title='Fixed bug', version=1
  WHERE id=1 AND version=0  ✅ Success (1 row updated)

User B updates:
  UPDATE tasks
  SET title='Bug fixed', version=1
  WHERE id=1 AND version=0  ❌ Fails (0 rows updated)

  Throws: OptimisticLockException
```

**Version increments automatically on each update.**

### Version Conflict Exception

Create custom exception:

```java
package com.example.taskmanager.exception;

public class TaskVersionConflictException extends RuntimeException {

    private final Long taskId;
    private final Long attemptedVersion;

    public TaskVersionConflictException(Long taskId, Long attemptedVersion) {
        super(String.format(
            "Task %d was modified by another user. Expected version: %d. " +
            "Please refresh and try again.", taskId, attemptedVersion
        ));
        this.taskId = taskId;
        this.attemptedVersion = attemptedVersion;
    }

    public Long getTaskId() {
        return taskId;
    }

    public Long getAttemptedVersion() {
        return attemptedVersion;
    }
}
```

### Handle OptimisticLockException

Update GlobalExceptionHandler:

```java
import jakarta.persistence.OptimisticLockException;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    // ... existing handlers ...

    @ExceptionHandler(OptimisticLockException.class)
    public ResponseEntity<ErrorResponse> handleOptimisticLock(
            OptimisticLockException ex,
            HttpServletRequest request) {

        log.warn("Optimistic lock conflict: {}", ex.getMessage());

        ErrorResponse error = new ErrorResponse(
            LocalDateTime.now(),
            HttpStatus.CONFLICT.value(),
            "Conflict",
            "The resource was modified by another user. Please refresh and retry.",
            request.getRequestURI(),
            null
        );

        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }

    @ExceptionHandler(TaskVersionConflictException.class)
    public ResponseEntity<ErrorResponse> handleVersionConflict(
            TaskVersionConflictException ex,
            HttpServletRequest request) {

        log.warn("Task version conflict: taskId={}, version={}",
            ex.getTaskId(), ex.getAttemptedVersion());

        ErrorResponse error = new ErrorResponse(
            LocalDateTime.now(),
            HttpStatus.CONFLICT.value(),
            "Version Conflict",
            ex.getMessage(),
            request.getRequestURI(),
            null
        );

        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }
}
```

### Update TaskService

Add version checking in update method:

```java
@Transactional
public Task updateTask(Long id, Task taskDetails) {
    log.debug("Updating task with ID: {}", id);

    Task task = taskRepository.findById(id)
        .orElseThrow(() -> new TaskNotFoundException(id));

    // Check if client provided version for optimistic locking
    if (taskDetails.getVersion() != null &&
        !task.getVersion().equals(taskDetails.getVersion())) {
        throw new TaskVersionConflictException(id, taskDetails.getVersion());
    }

    task.setTitle(taskDetails.getTitle());
    task.setDescription(taskDetails.getDescription());
    task.setStatus(taskDetails.getStatus());

    return taskRepository.save(task);
}
```

### Testing Optimistic Locking

```bash
# Create task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Locking", "description": "Version test"}'

# Response: {"id": 1, "title": "Test Locking", "version": 0, ...}

# Update with correct version
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated", "version": 0}'

# Response: {"id": 1, "title": "Updated", "version": 1, ...}

# Update with old version (simulates conflict)
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Conflict", "version": 0}'

# Response: 409 Conflict
# {"error": "Version Conflict", "message": "Task was modified..."}
```

> aside positive
> **Best Practice:** Optimistic locking is perfect for web applications where conflicts are rare. Include version in DTOs and UI to detect conflicts.

## Pessimistic Locking

Duration: 7:00

Lock records during read to prevent concurrent modifications.

### Pessimistic Lock Modes

```java
// Shared lock (read lock) - allows other reads, blocks writes
LockModeType.PESSIMISTIC_READ

// Exclusive lock (write lock) - blocks all other access
LockModeType.PESSIMISTIC_WRITE

// Increment version without lock
LockModeType.PESSIMISTIC_FORCE_INCREMENT
```

### Add Lock Support to Repository

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {

    // ... existing methods ...

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT t FROM Task t WHERE t.id = :id")
    Optional<Task> findByIdWithLock(@Param("id") Long id);

    @Lock(LockModeType.PESSIMISTIC_READ)
    @Query("SELECT t FROM Task t WHERE t.status = :status")
    List<Task> findByStatusWithLock(@Param("status") TaskStatus status);
}
```

### Use Pessimistic Locking in Service

```java
@Transactional
public Task updateTaskWithLock(Long id, Task taskDetails) {
    log.debug("Updating task {} with pessimistic lock", id);

    // Acquire write lock (blocks other transactions)
    Task task = taskRepository.findByIdWithLock(id)
        .orElseThrow(() -> new TaskNotFoundException(id));

    // Hold lock until transaction commits
    task.setTitle(taskDetails.getTitle());
    task.setDescription(taskDetails.getDescription());
    task.setStatus(taskDetails.getStatus());

    return taskRepository.save(task);
    // Lock released when transaction commits
}
```

### Generated SQL

```sql
-- PostgreSQL
SELECT * FROM tasks WHERE id = 1 FOR UPDATE;

-- MySQL
SELECT * FROM tasks WHERE id = 1 FOR UPDATE;

-- H2
SELECT * FROM tasks WHERE id = 1 FOR UPDATE;
```

### Pessimistic vs Optimistic

| Aspect              | Optimistic          | Pessimistic        |
| ------------------- | ------------------- | ------------------ |
| **When to use**     | Low contention      | High contention    |
| **Performance**     | Better (no locks)   | Slower (locks)     |
| **Failures**        | At save time        | At read time       |
| **Scalability**     | Better              | Limited            |
| **Deadlocks**       | No                  | Possible           |
| **User Experience** | May need retry      | Blocks/waits       |
| **Use case**        | Web apps, REST APIs | Banking, inventory |

> aside negative
> **Deadlock Warning:** Pessimistic locking can cause deadlocks if two transactions lock resources in different orders. Always lock in consistent order!

## Spring Security Setup

Duration: 10:00

Configure Spring Security for authentication and authorization.

### Update User Entity

```java
package com.example.taskmanager.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(nullable = false, length = 100)
    private String fullName;

    // ⭐ Security fields
    @Column(nullable = false)
    private String password;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role")
    private Set<String> roles = new HashSet<>();

    @Column(nullable = false)
    private boolean enabled = true;

    @OneToMany(mappedBy = "assignedTo", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Task> tasks = new ArrayList<>();

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public User(String username, String email, String fullName, String password) {
        this.username = username;
        this.email = email;
        this.fullName = fullName;
        this.password = password;
        this.roles.add("ROLE_USER");
    }
}
```

### Create UserDetailsService Implementation

```java
package com.example.taskmanager.security;

import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.UserRepository;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.stream.Collectors;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new UsernameNotFoundException(
                "User not found with username: " + username));

        return new org.springframework.security.core.userdetails.User(
            user.getUsername(),
            user.getPassword(),
            user.isEnabled(),
            true, // accountNonExpired
            true, // credentialsNonExpired
            true, // accountNonLocked
            getAuthorities(user)
        );
    }

    private Collection<? extends GrantedAuthority> getAuthorities(User user) {
        return user.getRoles().stream()
            .map(SimpleGrantedAuthority::new)
            .collect(Collectors.toList());
    }
}
```

### Security Configuration

```java
package com.example.taskmanager.config;

import com.example.taskmanager.security.CustomUserDetailsService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;

    public SecurityConfig(CustomUserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Disable for REST API
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/h2-console/**").permitAll()
                .requestMatchers("/swagger-ui/**", "/api-docs/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/users/register").permitAll()

                // Admin only endpoints
                .requestMatchers("/api/users/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/tasks/**").hasRole("ADMIN")

                // Authenticated endpoints
                .requestMatchers("/api/tasks/**").authenticated()
                .requestMatchers("/api/categories/**").authenticated()

                // All other requests require authentication
                .anyRequest().authenticated()
            )
            .httpBasic(basic -> {})  // Enable HTTP Basic authentication
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .headers(headers -> headers.frameOptions(frame -> frame.disable())); // For H2 console

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }
}
```

### Understanding Security Configuration

```java
// Public access (no authentication required)
.requestMatchers("/swagger-ui/**").permitAll()

// Role-based access (requires specific role)
.requestMatchers("/api/users/**").hasRole("ADMIN")

// Authenticated (any logged-in user)
.requestMatchers("/api/tasks/**").authenticated()

// HTTP Basic Authentication
.httpBasic()

// Stateless sessions (for REST APIs)
.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
```

**Role Naming Convention:**

- Database: `ROLE_ADMIN`, `ROLE_USER`
- Code: `hasRole("ADMIN")` - Spring adds "ROLE\_" prefix automatically

> aside positive
> **Security Note:** We disabled CSRF for REST APIs using stateless sessions. Enable CSRF for traditional web apps with session-based authentication.

## Method Security

Duration: 8:00

Secure service methods with annotations.

### Update UserService

```java
package com.example.taskmanager.service;

import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Slf4j
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public User registerUser(User user) {
        log.debug("Registering user: {}", user.getUsername());

        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists: " + user.getUsername());
        }

        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists: " + user.getEmail());
        }

        // Encode password
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // Set default role
        if (user.getRoles().isEmpty()) {
            user.getRoles().add("ROLE_USER");
        }

        return userRepository.save(user);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public User createUserAsAdmin(User user, String role) {
        log.debug("Admin creating user: {} with role: {}", user.getUsername(), role);
        user.getRoles().add(role);
        return registerUser(user);
    }

    @PreAuthorize("hasRole('ADMIN') or #username == authentication.principal.username")
    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("User not found: " + username));
    }

    @PreAuthorize("hasRole('ADMIN')")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN') or #id == principal.id")
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found with id: " + id);
        }
        userRepository.deleteById(id);
    }

    public User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        return userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("Current user not found"));
    }
}
```

### Update TaskService

```java
@Service
@Slf4j
@Transactional(readOnly = true)
public class TaskService {

    // ... existing fields ...

    @Transactional
    @PreAuthorize("hasRole('USER')")
    public Task createTask(Task task) {
        log.debug("Creating new task: {}", task.getTitle());

        // Auto-assign to current user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        User currentUser = userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("User not found"));

        task.setAssignedTo(currentUser);

        if (task.getStatus() == null) {
            task.setStatus(TaskStatus.TODO);
        }

        Task savedTask = taskRepository.save(task);
        log.info("Task created with ID: {}", savedTask.getId());
        return savedTask;
    }

    @PreAuthorize("hasRole('USER')")
    public Task getTaskById(Long id) {
        Task task = taskRepository.findById(id)
            .orElseThrow(() -> new TaskNotFoundException(id));

        // Check ownership
        checkTaskOwnership(task);
        return task;
    }

    @Transactional
    @PreAuthorize("hasRole('USER')")
    public Task updateTask(Long id, Task taskDetails) {
        Task task = taskRepository.findById(id)
            .orElseThrow(() -> new TaskNotFoundException(id));

        // Check ownership
        checkTaskOwnership(task);

        task.setTitle(taskDetails.getTitle());
        task.setDescription(taskDetails.getDescription());
        task.setStatus(taskDetails.getStatus());

        return taskRepository.save(task);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteTask(Long id) {
        if (!taskRepository.existsById(id)) {
            throw new TaskNotFoundException(id);
        }
        taskRepository.deleteById(id);
    }

    @PreAuthorize("hasRole('USER')")
    public List<Task> getMyTasks() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("User not found"));

        return taskRepository.findByAssignedToId(user.getId());
    }

    private void checkTaskOwnership(Task task) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();

        if (task.getAssignedTo() != null &&
            !task.getAssignedTo().getUsername().equals(username)) {

            // Check if user has ADMIN role
            boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

            if (!isAdmin) {
                throw new RuntimeException("Access denied: Task belongs to another user");
            }
        }
    }
}
```

### Method Security Annotations

```java
// @PreAuthorize - Check before method execution
@PreAuthorize("hasRole('ADMIN')")
public void adminMethod() { }

@PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
public void userOrAdminMethod() { }

@PreAuthorize("#username == authentication.principal.username")
public void ownResourceMethod(String username) { }

// @PostAuthorize - Check after method execution
@PostAuthorize("returnObject.owner == authentication.principal.username")
public Task getTask(Long id) { }

// @Secured - Simple role checking
@Secured("ROLE_ADMIN")
public void simpleAdminMethod() { }

@Secured({"ROLE_USER", "ROLE_ADMIN"})
public void multiRoleMethod() { }
```

### SpEL Expressions in Security

```java
// Authentication principal
authentication.principal.username
principal.username  // shorthand

// Authorities/Roles
hasRole('ADMIN')
hasAnyRole('USER', 'ADMIN')
hasAuthority('READ_PRIVILEGE')

// Method parameters
#username == principal.username
#id == principal.id

// Return value
returnObject.owner == principal.username

// Combine conditions
hasRole('ADMIN') or #user.id == principal.id
```

> aside positive
> **Best Practice:** Use method security to protect service layer. Never rely only on controller-level security - someone could call service methods directly.

## Update Controllers

Duration: 6:00

Add registration endpoint and update controllers for security.

### Update UserController

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.model.User;
import com.example.taskmanager.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@Tag(name = "User Management")
@Slf4j
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @Operation(summary = "Register a new user (public)")
    @PostMapping("/register")
    public ResponseEntity<User> registerUser(@RequestBody User user) {
        log.info("POST /api/users/register - Registering: {}", user.getUsername());
        User registered = userService.registerUser(user);
        // Don't expose password in response
        registered.setPassword(null);
        URI location = URI.create("/api/users/" + registered.getId());
        return ResponseEntity.created(location).body(registered);
    }

    @Operation(summary = "Get current user", security = @SecurityRequirement(name = "basicAuth"))
    @GetMapping("/me")
    public ResponseEntity<User> getCurrentUser() {
        log.info("GET /api/users/me");
        User user = userService.getCurrentUser();
        user.setPassword(null);
        return ResponseEntity.ok(user);
    }

    @Operation(summary = "Get all users (Admin only)", security = @SecurityRequirement(name = "basicAuth"))
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<User>> getAllUsers() {
        log.info("GET /api/users");
        List<User> users = userService.getAllUsers();
        users.forEach(u -> u.setPassword(null));
        return ResponseEntity.ok(users);
    }

    @Operation(summary = "Get user by username", security = @SecurityRequirement(name = "basicAuth"))
    @GetMapping("/username/{username}")
    public ResponseEntity<User> getUserByUsername(@PathVariable String username) {
        log.info("GET /api/users/username/{}", username);
        User user = userService.getUserByUsername(username);
        user.setPassword(null);
        return ResponseEntity.ok(user);
    }

    @Operation(summary = "Delete user (Admin only)", security = @SecurityRequirement(name = "basicAuth"))
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        log.info("DELETE /api/users/{}", id);
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
```

### Update TaskController

```java
@RestController
@RequestMapping("/api/tasks")
@Tag(name = "Task Management")
@SecurityRequirement(name = "basicAuth")
@Slf4j
public class TaskController {

    // ... existing code ...

    @Operation(summary = "Get my tasks")
    @GetMapping("/my-tasks")
    public ResponseEntity<List<TaskResponse>> getMyTasks() {
        log.info("GET /api/tasks/my-tasks");
        List<TaskResponse> tasks = taskService.getMyTasks().stream()
            .map(TaskResponse::new)
            .toList();
        return ResponseEntity.ok(tasks);
    }
}
```

### Update OpenAPIConfig

```java
package com.example.taskmanager.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenAPIConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .components(new Components()
                .addSecuritySchemes("basicAuth",
                    new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("basic")
                        .description("HTTP Basic Authentication")
                )
            )
            .info(new Info()
                .title("Task Management API")
                .version("1.3.0")
                .description("Secure Task Management API with JPA locking and Spring Security")
                .contact(new Contact()
                    .name("Your Name")
                    .email("your.email@example.com")
                    .url("https://yourwebsite.com")
                )
                .license(new License()
                    .name("Apache 2.0")
                    .url("https://www.apache.org/licenses/LICENSE-2.0.html")
                )
            );
    }
}
```

## Testing Secured API

Duration: 5:00

Test authentication and authorization.

### Create Test Users

Add data initialization:

```java
package com.example.taskmanager;

import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@Slf4j
public class DataInitializer {

    @Bean
    public CommandLineRunner initData(UserRepository userRepository,
                                       PasswordEncoder passwordEncoder) {
        return args -> {
            if (userRepository.count() == 0) {
                // Create admin user
                User admin = new User();
                admin.setUsername("admin");
                admin.setEmail("admin@example.com");
                admin.setFullName("Admin User");
                admin.setPassword(passwordEncoder.encode("admin123"));
                admin.getRoles().add("ROLE_ADMIN");
                admin.getRoles().add("ROLE_USER");
                userRepository.save(admin);

                // Create regular user
                User user = new User();
                user.setUsername("john");
                user.setEmail("john@example.com");
                user.setFullName("John Doe");
                user.setPassword(passwordEncoder.encode("user123"));
                user.getRoles().add("ROLE_USER");
                userRepository.save(user);

                log.info("Test users created: admin/admin123, john/user123");
            }
        };
    }
}
```

### Test Authentication

**1. Register new user:**

```bash
curl -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "email": "alice@example.com",
    "fullName": "Alice Smith",
    "password": "password123"
  }'
```

**2. Get current user (authenticated):**

```bash
curl -u john:user123 http://localhost:8080/api/users/me
```

**3. Create task (auto-assigned):**

```bash
curl -u john:user123 -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Secure Task",
    "description": "Testing Spring Security"
  }'
```

**4. Get my tasks:**

```bash
curl -u john:user123 http://localhost:8080/api/tasks/my-tasks
```

**5. Try admin endpoint (should fail):**

```bash
curl -u john:user123 http://localhost:8080/api/users
# Response: 403 Forbidden
```

**6. Admin endpoint (should succeed):**

```bash
curl -u admin:admin123 http://localhost:8080/api/users
```

**7. Delete task (admin only):**

```bash
curl -u admin:admin123 -X DELETE http://localhost:8080/api/tasks/1
```

### Test in Swagger UI

1. Visit: http://localhost:8080/swagger-ui.html
2. Click **Authorize** button
3. Enter credentials: `john` / `user123`
4. Try endpoints with authentication

> aside positive
> **Production Note:** In production, use JWT tokens instead of HTTP Basic auth for better security and stateless authentication.

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've secured your application with Spring Security and JPA locking!

### What You've Learned

- ✅ **Optimistic Locking:** @Version for conflict detection
- ✅ **Pessimistic Locking:** Database-level locks
- ✅ **Spring Security:** Authentication and authorization
- ✅ **Password Encoding:** BCrypt for secure passwords
- ✅ **Role-Based Access:** ADMIN and USER roles
- ✅ **Method Security:** @PreAuthorize annotations
- ✅ **Security Context:** Access current user
- ✅ **HTTP Basic Auth:** Simple authentication for REST

### Task Management API v1.3

Security features:

- ✅ Optimistic locking with @Version
- ✅ Pessimistic locking for critical operations
- ✅ Spring Security configuration
- ✅ User registration and authentication
- ✅ Role-based access control (RBAC)
- ✅ Method-level security
- ✅ Password encryption with BCrypt
- ✅ Public registration endpoint
- ✅ Protected task operations
- ✅ Admin-only user management

### Key Security Principles

1. **Defense in Depth:** Multiple layers of security
2. **Least Privilege:** Users get minimum required access
3. **Password Security:** Never store plain passwords
4. **Stateless Sessions:** Better for REST APIs
5. **Method Security:** Protect service layer
6. **Ownership Checks:** Users access only their resources
7. **Role-Based Access:** Organize permissions by roles

### Git Branching

```bash
git add .
git commit -m "Codelab 3.4: JPA Locking & Spring Security complete"
git tag codelab-3.4
```

### Next Steps

- **Codelab 3.5:** JWT Authentication & Spring Cloud

### Additional Resources

- [Spring Security Reference](https://docs.spring.io/spring-security/reference/)
- [JPA Locking](https://docs.oracle.com/javaee/7/tutorial/persistence-locking.htm)
- [OWASP Security Guidelines](https://owasp.org/www-project-top-ten/)

> aside positive
> **Enterprise Ready!** Your API now has proper security and concurrency control, ready for multi-user production environments!
