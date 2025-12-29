summary: Master ORM concepts and Spring Data JPA by adding database persistence with H2, PostgreSQL, entities, relationships, and query methods to the Task Management API
id: orm-spring-data-jpa
categories: Spring Boot, JPA, Hibernate, Database, ORM
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM

# ORM Concepts & Spring Data JPA

## Introduction

Duration: 3:00

Replace the in-memory repository with real database persistence using Spring Data JPA and Hibernate ORM.

### What You'll Learn

- **ORM Fundamentals:** Object-Relational Mapping concepts
- **JPA Basics:** Java Persistence API overview
- **Entity Mapping:** @Entity, @Table, @Id, @Column annotations
- **Relationships:** @OneToMany, @ManyToOne, @ManyToMany
- **Spring Data JPA:** Repository pattern and query methods
- **Query Methods:** Derived queries from method names
- **@Query Annotation:** Custom JPQL and native SQL
- **Pagination & Sorting:** Pageable interface
- **Database Configuration:** H2 in-memory, PostgreSQL production
- **Transactions:** @Transactional annotation

### What You'll Build

Database-backed Task Management API with:

- **Task Entity** with JPA annotations
- **User Entity** for task ownership
- **Category Entity** with many-to-many relationship
- **JPA Repositories** replacing in-memory storage
- **Custom Queries** for filtering and searching
- **Pagination** for large result sets
- **H2 Console** for development
- **PostgreSQL** configuration for production

### Prerequisites

- Completed Codelab 3.2 (REST APIs & Swagger)
- PostgreSQL installed (optional, we'll use H2 first)

### New Dependencies

Add to `pom.xml`:

```xml
<!-- Spring Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- H2 Database (in-memory for development) -->
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- PostgreSQL Driver (for production) -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

> aside positive
> **Git Branch:** Start from `codelab-3.2` or continue from your current work. This codelab transforms our in-memory API into a real database-backed system.

## Understanding ORM

Duration: 8:00

Before diving into code, let's understand Object-Relational Mapping.

### The Impedance Mismatch

**Objects (Java)** vs **Relations (SQL)** have fundamental differences:

**Java Objects:**

```java
public class Task {
    private Long id;
    private String title;
    private TaskStatus status;
    private User assignedTo;  // Object reference
    private List<Category> categories;  // Collection
}
```

**SQL Tables:**

```sql
CREATE TABLE tasks (
    id BIGINT PRIMARY KEY,
    title VARCHAR(255),
    status VARCHAR(20),
    user_id BIGINT,  -- Foreign key, not object
    -- Can't store List directly!
);
```

**Problems without ORM:**

- Manual SQL for every operation
- Type conversions (Java ↔ SQL)
- Relationship management
- Boilerplate code

### ORM to the Rescue

**ORM** automates the mapping between objects and database tables:

```java
// Without ORM - Manual SQL
public Task findById(Long id) {
    String sql = "SELECT * FROM tasks WHERE id = ?";
    PreparedStatement stmt = connection.prepareStatement(sql);
    stmt.setLong(1, id);
    ResultSet rs = stmt.executeQuery();

    Task task = new Task();
    if (rs.next()) {
        task.setId(rs.getLong("id"));
        task.setTitle(rs.getString("title"));
        task.setStatus(TaskStatus.valueOf(rs.getString("status")));
        // ... more mapping code
    }
    return task;
}

// With ORM - Automatic
public Task findById(Long id) {
    return taskRepository.findById(id).orElse(null);
}
```

### JPA Overview

**JPA (Java Persistence API)** is the standard ORM specification for Java.

**Key Players:**

- **JPA:** The specification (interface)
- **Hibernate:** Most popular implementation
- **Spring Data JPA:** Simplifies JPA usage

```
Spring Data JPA
    ↓ (uses)
JPA Specification
    ↓ (implemented by)
Hibernate ORM
    ↓ (talks to)
JDBC
    ↓ (connects to)
Database (H2, PostgreSQL, MySQL)
```

### Entity Lifecycle

```
[Transient]  → new Task()
    ↓ persist()
[Managed]    → entityManager tracks changes
    ↓ commit()
[Detached]   → no longer tracked
    ↓ merge()
[Managed]    → back in context
    ↓ remove()
[Removed]    → scheduled for deletion
```

### JPA Benefits

✅ **Less Boilerplate:** No manual SQL for CRUD
✅ **Database Independence:** Switch DB with config change
✅ **Type Safety:** Compile-time checking
✅ **Relationships:** Automatic join handling
✅ **Caching:** First-level cache (EntityManager)
✅ **Lazy Loading:** Load data only when needed
✅ **Query Methods:** Derive queries from method names

> aside positive
> **Best Practice:** Use JPA for most operations, but don't be afraid to use native SQL for complex queries or performance-critical operations.

## Configure Database

Duration: 5:00

Set up H2 for development and PostgreSQL for production.

### H2 Configuration (Development)

**application.yml:**

```yaml
spring:
  application:
    name: task-manager

  # H2 Database
  datasource:
    url: jdbc:h2:mem:taskdb
    driver-class-name: org.h2.Driver
    username: sa
    password:

  # H2 Console
  h2:
    console:
      enabled: true
      path: /h2-console

  # JPA/Hibernate
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
    hibernate:
      ddl-auto: create-drop
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        use_sql_comments: true

# Logging
logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

### PostgreSQL Configuration (Production)

**application-prod.yml:**

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/taskdb
    driver-class-name: org.postgresql.Driver
    username: postgres
    password: your_password

  jpa:
    database-platform: org.hibernate.dialect.PostgreSQLDialect
    hibernate:
      ddl-auto: validate
    show-sql: false
```

### Hibernate ddl-auto Options

```yaml
hibernate:
  ddl-auto: create-drop
  # create-drop: Drop and recreate tables on startup (development)
  # create: Create tables on startup (development)
  # update: Update existing schema (development)
  # validate: Validate schema matches entities (production)
  # none: Do nothing (production with Flyway/Liquibase)
```

### Access H2 Console

Start application and visit: http://localhost:8080/h2-console

**Connection settings:**

- JDBC URL: `jdbc:h2:mem:taskdb`
- Username: `sa`
- Password: (empty)

> aside negative
> **Production Warning:** Never use `create-drop` or `create` in production! Use `validate` or `none` with migration tools like Flyway.

## Create JPA Entities

Duration: 12:00

Transform our model classes into JPA entities.

### Task Entity

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

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    // Constructor for basic task creation
    public Task(String title, String description) {
        this.title = title;
        this.description = description;
        this.status = TaskStatus.TODO;
    }
}
```

### User Entity

```java
package com.example.taskmanager.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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

    @OneToMany(mappedBy = "assignedTo", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Task> tasks = new ArrayList<>();

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public User(String username, String email, String fullName) {
        this.username = username;
        this.email = email;
        this.fullName = fullName;
    }
}
```

### Category Entity

```java
package com.example.taskmanager.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "categories")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String name;

    @Column(length = 255)
    private String description;

    @ManyToMany(mappedBy = "categories")
    private Set<Task> tasks = new HashSet<>();

    public Category(String name, String description) {
        this.name = name;
        this.description = description;
    }
}
```

### Understanding JPA Annotations

```java
@Entity
// Marks class as JPA entity (table)

@Table(name = "tasks")
// Specifies table name (optional, defaults to class name)

@Id
// Primary key field

@GeneratedValue(strategy = GenerationType.IDENTITY)
// Auto-increment primary key
// IDENTITY: Database auto-increment
// SEQUENCE: Database sequence
// TABLE: Separate table for ID generation
// AUTO: JPA chooses strategy

@Column(nullable = false, length = 100, unique = true)
// Column constraints
// nullable: NOT NULL constraint
// length: VARCHAR length
// unique: UNIQUE constraint
// name: Column name (defaults to field name)

@Enumerated(EnumType.STRING)
// Store enum as string (vs ordinal number)

@CreationTimestamp
// Automatically set on creation (Hibernate-specific)

@UpdateTimestamp
// Automatically update on modification (Hibernate-specific)
```

### Relationship Annotations

```java
// One-to-Many: One user has many tasks
@OneToMany(mappedBy = "assignedTo", cascade = CascadeType.ALL)
private List<Task> tasks;

// Many-to-One: Many tasks belong to one user
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "user_id")
private User assignedTo;

// Many-to-Many: Tasks have many categories, categories have many tasks
@ManyToMany
@JoinTable(
    name = "task_categories",
    joinColumns = @JoinColumn(name = "task_id"),
    inverseJoinColumns = @JoinColumn(name = "category_id")
)
private Set<Category> categories;
```

### Fetch Types

```java
FetchType.LAZY   // Load on demand (default for collections)
FetchType.EAGER  // Load immediately (default for single entities)

// Example
@ManyToOne(fetch = FetchType.LAZY)  // Don't load user until accessed
private User assignedTo;

@OneToMany(fetch = FetchType.LAZY)  // Don't load all tasks immediately
private List<Task> tasks;
```

### Cascade Types

```java
CascadeType.ALL        // Cascade all operations
CascadeType.PERSIST    // Cascade save
CascadeType.MERGE      // Cascade update
CascadeType.REMOVE     // Cascade delete
CascadeType.REFRESH    // Cascade refresh
CascadeType.DETACH     // Cascade detach

// Example: Delete user → delete all their tasks
@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
private List<Task> tasks;
```

> aside positive
> **Best Practice:** Use `FetchType.LAZY` for collections and relationships to avoid N+1 query problems. Load data only when needed.

## Spring Data JPA Repositories

Duration: 10:00

Replace in-memory repositories with Spring Data JPA repositories.

### TaskRepository

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {

    // Derived query methods (Spring Data generates SQL automatically)

    List<Task> findByStatus(TaskStatus status);

    List<Task> findByAssignedToId(Long userId);

    List<Task> findByTitleContainingIgnoreCase(String title);

    List<Task> findByStatusAndAssignedToId(TaskStatus status, Long userId);

    List<Task> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end);

    Page<Task> findByStatus(TaskStatus status, Pageable pageable);

    long countByStatus(TaskStatus status);

    boolean existsByTitleAndAssignedToId(String title, Long userId);

    // Custom JPQL queries

    @Query("SELECT t FROM Task t WHERE t.status = :status AND t.assignedTo.id = :userId")
    List<Task> findTasksByStatusAndUser(
        @Param("status") TaskStatus status,
        @Param("userId") Long userId
    );

    @Query("SELECT t FROM Task t LEFT JOIN FETCH t.categories WHERE t.id = :id")
    Task findByIdWithCategories(@Param("id") Long id);

    @Query("SELECT t FROM Task t LEFT JOIN FETCH t.assignedTo WHERE t.status = :status")
    List<Task> findByStatusWithUser(@Param("status") TaskStatus status);

    // Native SQL query

    @Query(value = "SELECT * FROM tasks t WHERE t.created_at > :date", nativeQuery = true)
    List<Task> findRecentTasks(@Param("date") LocalDateTime date);

    // Aggregation query

    @Query("SELECT t.status, COUNT(t) FROM Task t GROUP BY t.status")
    List<Object[]> countTasksByStatus();
}
```

### UserRepository

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    @Query("SELECT u FROM User u LEFT JOIN FETCH u.tasks WHERE u.id = :id")
    Optional<User> findByIdWithTasks(Long id);
}
```

### CategoryRepository

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    Optional<Category> findByName(String name);

    boolean existsByName(String name);
}
```

### Query Method Keywords

Spring Data JPA generates SQL from method names:

```java
// Keywords and examples:
findBy...          // SELECT
countBy...         // COUNT
deleteBy...        // DELETE
existsBy...        // EXISTS

// Conditions:
And                // WHERE ... AND ...
Or                 // WHERE ... OR ...
Is, Equals         // =
Between            // BETWEEN
LessThan           // <
GreaterThan        // >
After, Before      // > or <
IsNull, IsNotNull  // IS NULL
Like, NotLike      // LIKE
StartingWith       // LIKE 'value%'
EndingWith         // LIKE '%value'
Containing         // LIKE '%value%'
IgnoreCase         // UPPER(field) = UPPER(value)
OrderBy...Asc      // ORDER BY ... ASC
OrderBy...Desc     // ORDER BY ... DESC

// Examples:
findByTitle(String title)
// SELECT * FROM tasks WHERE title = ?

findByTitleAndStatus(String title, TaskStatus status)
// SELECT * FROM tasks WHERE title = ? AND status = ?

findByCreatedAtAfter(LocalDateTime date)
// SELECT * FROM tasks WHERE created_at > ?

findByTitleContainingIgnoreCaseOrderByCreatedAtDesc(String title)
// SELECT * FROM tasks WHERE UPPER(title) LIKE UPPER(?) ORDER BY created_at DESC
```

### JpaRepository Methods

```java
// Provided by JpaRepository:
save(T entity)              // INSERT or UPDATE
saveAll(Iterable<T>)        // Batch save
findById(ID id)             // SELECT by ID
findAll()                   // SELECT all
findAllById(Iterable<ID>)   // SELECT by IDs
count()                     // COUNT
existsById(ID id)           // EXISTS
deleteById(ID id)           // DELETE by ID
delete(T entity)            // DELETE
deleteAll()                 // DELETE all
flush()                     // Force sync with DB
getOne(ID id)               // Get reference (lazy)
```

> aside positive
> **Magic Methods:** Spring Data JPA automatically implements repository methods based on naming conventions. You write the interface, Spring provides the implementation!

## Update Service Layer

Duration: 10:00

Update services to use JPA repositories and handle relationships.

### Enhanced TaskService

```java
package com.example.taskmanager.service;

import com.example.taskmanager.exception.InvalidTaskException;
import com.example.taskmanager.exception.TaskNotFoundException;
import com.example.taskmanager.model.Category;
import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.CategoryRepository;
import com.example.taskmanager.repository.TaskRepository;
import com.example.taskmanager.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Service
@Slf4j
@Transactional(readOnly = true)
public class TaskService {

    private final TaskRepository taskRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;

    public TaskService(TaskRepository taskRepository,
                       UserRepository userRepository,
                       CategoryRepository categoryRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
        this.categoryRepository = categoryRepository;
        log.info("TaskService initialized with JPA repositories");
    }

    @Transactional
    public Task createTask(Task task) {
        log.debug("Creating new task: {}", task.getTitle());

        if (task.getTitle() == null || task.getTitle().isBlank()) {
            throw new InvalidTaskException("Task title cannot be empty");
        }

        if (task.getStatus() == null) {
            task.setStatus(TaskStatus.TODO);
        }

        Task savedTask = taskRepository.save(task);
        log.info("Task created with ID: {}", savedTask.getId());
        return savedTask;
    }

    public Task getTaskById(Long id) {
        log.debug("Fetching task with ID: {}", id);
        return taskRepository.findById(id)
            .orElseThrow(() -> new TaskNotFoundException(id));
    }

    public List<Task> getAllTasks() {
        log.debug("Fetching all tasks");
        List<Task> tasks = taskRepository.findAll();
        log.info("Found {} tasks", tasks.size());
        return tasks;
    }

    public Page<Task> getAllTasks(Pageable pageable) {
        log.debug("Fetching tasks page: {}, size: {}",
            pageable.getPageNumber(), pageable.getPageSize());
        return taskRepository.findAll(pageable);
    }

    @Transactional
    public Task updateTask(Long id, Task taskDetails) {
        log.debug("Updating task with ID: {}", id);

        Task task = taskRepository.findById(id)
            .orElseThrow(() -> new TaskNotFoundException(id));

        task.setTitle(taskDetails.getTitle());
        task.setDescription(taskDetails.getDescription());
        task.setStatus(taskDetails.getStatus());

        Task updatedTask = taskRepository.save(task);
        log.info("Task updated: {}", id);
        return updatedTask;
    }

    @Transactional
    public void deleteTask(Long id) {
        log.debug("Deleting task with ID: {}", id);

        if (!taskRepository.existsById(id)) {
            throw new TaskNotFoundException(id);
        }

        taskRepository.deleteById(id);
        log.info("Task deleted: {}", id);
    }

    @Transactional
    public Task updateTaskStatus(Long id, TaskStatus status) {
        log.debug("Updating task {} status to {}", id, status);

        Task task = taskRepository.findById(id)
            .orElseThrow(() -> new TaskNotFoundException(id));

        task.setStatus(status);
        return taskRepository.save(task);
    }

    public List<Task> getTasksByStatus(TaskStatus status) {
        log.debug("Fetching tasks with status: {}", status);
        return taskRepository.findByStatus(status);
    }

    public Page<Task> getTasksByStatus(TaskStatus status, Pageable pageable) {
        log.debug("Fetching tasks with status: {} (paginated)", status);
        return taskRepository.findByStatus(status, pageable);
    }

    public List<Task> getTasksByUser(Long userId) {
        log.debug("Fetching tasks for user: {}", userId);
        return taskRepository.findByAssignedToId(userId);
    }

    public List<Task> searchTasks(String keyword) {
        log.debug("Searching tasks with keyword: {}", keyword);
        return taskRepository.findByTitleContainingIgnoreCase(keyword);
    }

    @Transactional
    public Task assignTaskToUser(Long taskId, Long userId) {
        log.debug("Assigning task {} to user {}", taskId, userId);

        Task task = taskRepository.findById(taskId)
            .orElseThrow(() -> new TaskNotFoundException(taskId));

        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        task.setAssignedTo(user);
        return taskRepository.save(task);
    }

    @Transactional
    public Task addCategoriesToTask(Long taskId, Set<Long> categoryIds) {
        log.debug("Adding {} categories to task {}", categoryIds.size(), taskId);

        Task task = taskRepository.findById(taskId)
            .orElseThrow(() -> new TaskNotFoundException(taskId));

        Set<Category> categories = Set.copyOf(categoryRepository.findAllById(categoryIds));
        task.getCategories().addAll(categories);

        return taskRepository.save(task);
    }

    public long countTasksByStatus(TaskStatus status) {
        return taskRepository.countByStatus(status);
    }

    public List<Task> getRecentTasks(int days) {
        LocalDateTime since = LocalDateTime.now().minusDays(days);
        return taskRepository.findByCreatedAtBetween(since, LocalDateTime.now());
    }
}
```

### UserService

```java
package com.example.taskmanager.service;

import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Slf4j
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public User createUser(User user) {
        log.debug("Creating user: {}", user.getUsername());

        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists: " + user.getUsername());
        }

        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists: " + user.getEmail());
        }

        return userRepository.save(user);
    }

    public User getUserById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
    }

    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("User not found with username: " + username));
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Transactional
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found with id: " + id);
        }
        userRepository.deleteById(id);
    }
}
```

### CategoryService

```java
package com.example.taskmanager.service;

import com.example.taskmanager.model.Category;
import com.example.taskmanager.repository.CategoryRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Slf4j
@Transactional(readOnly = true)
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @Transactional
    public Category createCategory(Category category) {
        log.debug("Creating category: {}", category.getName());

        if (categoryRepository.existsByName(category.getName())) {
            throw new RuntimeException("Category already exists: " + category.getName());
        }

        return categoryRepository.save(category);
    }

    public Category getCategoryById(Long id) {
        return categoryRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Category not found with id: " + id));
    }

    public Category getCategoryByName(String name) {
        return categoryRepository.findByName(name)
            .orElseThrow(() -> new RuntimeException("Category not found: " + name));
    }

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }
}
```

### Understanding @Transactional

```java
@Transactional(readOnly = true)  // Class level: all methods read-only
public class TaskService {

    @Transactional  // Override: this method needs write access
    public Task createTask(Task task) {
        // Will commit changes to database
        return taskRepository.save(task);
    }

    // Inherits readOnly = true from class
    public List<Task> getAllTasks() {
        return taskRepository.findAll();
    }
}
```

**Benefits:**

- Automatic transaction management
- Rollback on exceptions
- Flush changes to database
- Connection management

> aside positive
> **Performance Tip:** Use `@Transactional(readOnly = true)` for read operations. It optimizes performance and prevents accidental writes.

## Add Controllers

Duration: 8:00

Add controllers for users and categories, update task controller.

### UserController

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.model.User;
import com.example.taskmanager.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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

    @Operation(summary = "Create a new user")
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        log.info("POST /api/users - Creating user: {}", user.getUsername());
        User createdUser = userService.createUser(user);
        URI location = URI.create("/api/users/" + createdUser.getId());
        return ResponseEntity.created(location).body(createdUser);
    }

    @Operation(summary = "Get all users")
    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        log.info("GET /api/users");
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @Operation(summary = "Get user by ID")
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        log.info("GET /api/users/{}", id);
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @Operation(summary = "Get user by username")
    @GetMapping("/username/{username}")
    public ResponseEntity<User> getUserByUsername(@PathVariable String username) {
        log.info("GET /api/users/username/{}", username);
        return ResponseEntity.ok(userService.getUserByUsername(username));
    }

    @Operation(summary = "Delete user")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        log.info("DELETE /api/users/{}", id);
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
```

### CategoryController

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.model.Category;
import com.example.taskmanager.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/categories")
@Tag(name = "Category Management")
@Slf4j
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @Operation(summary = "Create a new category")
    @PostMapping
    public ResponseEntity<Category> createCategory(@RequestBody Category category) {
        log.info("POST /api/categories - Creating: {}", category.getName());
        Category created = categoryService.createCategory(category);
        URI location = URI.create("/api/categories/" + created.getId());
        return ResponseEntity.created(location).body(created);
    }

    @Operation(summary = "Get all categories")
    @GetMapping
    public ResponseEntity<List<Category>> getAllCategories() {
        log.info("GET /api/categories");
        return ResponseEntity.ok(categoryService.getAllCategories());
    }

    @Operation(summary = "Get category by ID")
    @GetMapping("/{id}")
    public ResponseEntity<Category> getCategoryById(@PathVariable Long id) {
        log.info("GET /api/categories/{}", id);
        return ResponseEntity.ok(categoryService.getCategoryById(id));
    }
}
```

### Enhanced TaskController

Add new endpoints to TaskController:

```java
@Operation(summary = "Assign task to user")
@PutMapping("/{taskId}/assign/{userId}")
public ResponseEntity<TaskResponse> assignTask(
        @PathVariable Long taskId,
        @PathVariable Long userId) {
    log.info("PUT /api/tasks/{}/assign/{}", taskId, userId);
    Task task = taskService.assignTaskToUser(taskId, userId);
    return ResponseEntity.ok(new TaskResponse(task));
}

@Operation(summary = "Add categories to task")
@PostMapping("/{taskId}/categories")
public ResponseEntity<TaskResponse> addCategories(
        @PathVariable Long taskId,
        @RequestBody Set<Long> categoryIds) {
    log.info("POST /api/tasks/{}/categories", taskId);
    Task task = taskService.addCategoriesToTask(taskId, categoryIds);
    return ResponseEntity.ok(new TaskResponse(task));
}

@Operation(summary = "Get tasks by user")
@GetMapping("/user/{userId}")
public ResponseEntity<List<TaskResponse>> getTasksByUser(@PathVariable Long userId) {
    log.info("GET /api/tasks/user/{}", userId);
    List<TaskResponse> tasks = taskService.getTasksByUser(userId).stream()
        .map(TaskResponse::new)
        .toList();
    return ResponseEntity.ok(tasks);
}

@Operation(summary = "Search tasks")
@GetMapping("/search")
public ResponseEntity<List<TaskResponse>> searchTasks(@RequestParam String keyword) {
    log.info("GET /api/tasks/search?keyword={}", keyword);
    List<TaskResponse> tasks = taskService.searchTasks(keyword).stream()
        .map(TaskResponse::new)
        .toList();
    return ResponseEntity.ok(tasks);
}

@Operation(summary = "Get task statistics")
@GetMapping("/stats")
public ResponseEntity<Map<TaskStatus, Long>> getTaskStats() {
    log.info("GET /api/tasks/stats");
    Map<TaskStatus, Long> stats = new HashMap<>();
    for (TaskStatus status : TaskStatus.values()) {
        stats.put(status, taskService.countTasksByStatus(status));
    }
    return ResponseEntity.ok(stats);
}
```

## Testing the Database API

Duration: 5:00

Test the database-backed API.

### Start Application

```bash
mvn spring-boot:run
```

Check logs for Hibernate SQL:

```
Hibernate: create table tasks (...)
Hibernate: create table users (...)
Hibernate: create table categories (...)
Hibernate: create table task_categories (...)
```

### Test Scenarios

**1. Create User**

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "fullName": "John Doe"
  }'
```

**2. Create Categories**

```bash
curl -X POST http://localhost:8080/api/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Work", "description": "Work-related tasks"}'

curl -X POST http://localhost:8080/api/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Personal", "description": "Personal tasks"}'
```

**3. Create Task**

```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete JPA Codelab",
    "description": "Learn Spring Data JPA",
    "status": "TODO"
  }'
```

**4. Assign Task to User**

```bash
curl -X PUT http://localhost:8080/api/tasks/1/assign/1
```

**5. Add Categories to Task**

```bash
curl -X POST http://localhost:8080/api/tasks/1/categories \
  -H "Content-Type: application/json" \
  -d '[1, 2]'
```

**6. Search Tasks**

```bash
curl "http://localhost:8080/api/tasks/search?keyword=JPA"
```

**7. Get Task Stats**

```bash
curl http://localhost:8080/api/tasks/stats
```

### Verify in H2 Console

1. Visit: http://localhost:8080/h2-console
2. Connect with `jdbc:h2:mem:taskdb`
3. Run queries:

```sql
SELECT * FROM tasks;
SELECT * FROM users;
SELECT * FROM categories;
SELECT * FROM task_categories;

-- Join query
SELECT t.title, u.username, c.name
FROM tasks t
LEFT JOIN users u ON t.user_id = u.id
LEFT JOIN task_categories tc ON t.id = tc.task_id
LEFT JOIN categories c ON tc.category_id = c.id;
```

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've added database persistence with Spring Data JPA!

### What You've Learned

- ✅ **ORM Concepts:** Object-Relational Mapping fundamentals
- ✅ **JPA Entities:** @Entity, @Table, @Column annotations
- ✅ **Relationships:** @OneToMany, @ManyToOne, @ManyToMany
- ✅ **Spring Data JPA:** Magic repository methods
- ✅ **Query Methods:** Derived queries and @Query
- ✅ **Transactions:** @Transactional management
- ✅ **Database Config:** H2 for dev, PostgreSQL for prod
- ✅ **Cascade & Fetch:** Managing relationships

### Task Management API v1.2

Database-backed features:

- ✅ JPA entities with relationships
- ✅ User and Category entities
- ✅ Task assignment to users
- ✅ Many-to-many task categories
- ✅ Derived query methods
- ✅ Custom JPQL queries
- ✅ H2 console for development
- ✅ PostgreSQL ready for production

### Key Takeaways

1. **Spring Data JPA** eliminates boilerplate CRUD code
2. **Lazy loading** prevents N+1 query problems
3. **@Transactional** manages database transactions
4. **Query methods** are generated from names
5. **@Query** for complex queries
6. **H2** perfect for development
7. **Relationships** handled automatically

### Git Branching

```bash
git add .
git commit -m "Codelab 3.3: ORM & Spring Data JPA complete"
git tag codelab-3.3
```

### Next Steps

- **Codelab 3.4:** JPA Locking & Spring Security

### Additional Resources

- [Spring Data JPA Reference](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/)
- [JPA Specifications](https://jakarta.ee/specifications/persistence/)
- [Hibernate Documentation](https://hibernate.org/orm/documentation/)

> aside positive
> **Database Powered!** Your Task API now has real database persistence with relationships and query capabilities. Ready for enterprise!
