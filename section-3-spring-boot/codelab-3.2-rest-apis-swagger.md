summary: Master RESTful API design, validation, exception handling, and Swagger/OpenAPI documentation by enhancing the Task Management API
id: rest-apis-swagger
categories: Spring Boot, REST API, Swagger, OpenAPI, Validation
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM

# RESTful APIs, Swagger & Exception Handling

## Introduction

Duration: 3:00

Building on Codelab 3.1, we'll transform our basic Task API into a production-ready RESTful service with proper validation, error handling, and API documentation.

### What You'll Learn

- **REST Best Practices:** Richardson Maturity Model, HATEOAS concepts
- **Request Validation:** Bean Validation (JSR-380) annotations
- **Exception Handling:** @ControllerAdvice, custom exceptions, error responses
- **Swagger/OpenAPI:** Interactive API documentation with SpringDoc
- **API Versioning:** Strategies for evolving APIs
- **Content Negotiation:** JSON and XML responses
- **Response DTOs:** Separating internal and external models
- **HTTP Status Codes:** Proper usage for different scenarios

### What You'll Build

Enhanced Task Management API with:

- **Validation:** Input validation with detailed error messages
- **Exception Handling:** Global exception handler with custom exceptions
- **Swagger UI:** Interactive API documentation at `/swagger-ui.html`
- **DTOs:** Request/response data transfer objects
- **Error Responses:** Standardized error format
- **API Documentation:** Complete OpenAPI 3.0 specification

### Prerequisites

- Completed Codelab 3.1 (Spring Core & Boot)
- Task Management API running from 3.1

### New Dependencies

Add to `pom.xml`:

```xml
<!-- SpringDoc OpenAPI (Swagger) -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>

<!-- Validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

> aside positive
> **Git Branch:** Check out `codelab-3.2` branch or continue from 3.1. This codelab builds incrementally on the previous foundation.

## REST API Best Practices

Duration: 8:00

Before diving into code, let's understand REST principles and best practices.

### REST Principles

**REST (Representational State Transfer)** is an architectural style with six constraints:

1. **Client-Server:** Separation of concerns
2. **Stateless:** Each request contains all information needed
3. **Cacheable:** Responses can be cached
4. **Uniform Interface:** Consistent resource identification
5. **Layered System:** Client doesn't know if connected directly to server
6. **Code on Demand (Optional):** Server can extend client functionality

### Richardson Maturity Model

**Level 0: The Swamp of POX**

```
POST /api/endpoint
{"action": "getTask", "id": 1}
```

**Level 1: Resources**

```
POST /api/tasks/1
GET /api/tasks/1
```

**Level 2: HTTP Verbs** (Our target)

```
GET    /api/tasks/1      - Retrieve
POST   /api/tasks        - Create
PUT    /api/tasks/1      - Update
DELETE /api/tasks/1      - Delete
```

**Level 3: Hypermedia Controls (HATEOAS)**

```json
{
  "id": 1,
  "title": "Task",
  "_links": {
    "self": { "href": "/api/tasks/1" },
    "update": { "href": "/api/tasks/1" },
    "delete": { "href": "/api/tasks/1" }
  }
}
```

### HTTP Methods Semantics

| Method | Purpose  | Idempotent | Safe | Request Body | Response Body |
| ------ | -------- | ---------- | ---- | ------------ | ------------- |
| GET    | Retrieve | Yes        | Yes  | No           | Yes           |
| POST   | Create   | No         | No   | Yes          | Yes           |
| PUT    | Replace  | Yes        | No   | Yes          | Yes           |
| PATCH  | Update   | No         | No   | Yes          | Yes           |
| DELETE | Remove   | Yes        | No   | No           | Optional      |

### Proper Endpoint Design

```java
// Good: Resource-based URLs
GET    /api/tasks                    // List all tasks
GET    /api/tasks/1                  // Get specific task
POST   /api/tasks                    // Create task
PUT    /api/tasks/1                  // Replace task
PATCH  /api/tasks/1                  // Update task
DELETE /api/tasks/1                  // Delete task
GET    /api/tasks?status=TODO        // Filter tasks
GET    /api/tasks?page=1&size=10     // Pagination

// Bad: Action-based URLs
POST   /api/getTask
POST   /api/createTask
POST   /api/deleteTask

// Bad: Verbs in URLs
GET    /api/tasks/retrieve/1
POST   /api/tasks/create
```

### HTTP Status Codes Reference

**2xx Success**

- `200 OK` - Request succeeded (GET, PUT, PATCH)
- `201 Created` - Resource created (POST)
- `204 No Content` - Success, no body (DELETE)

**4xx Client Errors**

- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Authenticated but not authorized
- `404 Not Found` - Resource doesn't exist
- `409 Conflict` - Resource conflict (duplicate)
- `422 Unprocessable Entity` - Validation failed

**5xx Server Errors**

- `500 Internal Server Error` - Unexpected server error
- `503 Service Unavailable` - Server temporarily down

### RESTful Response Examples

**Successful GET:**

```http
GET /api/tasks/1
200 OK
Content-Type: application/json

{
  "id": 1,
  "title": "Complete codelab",
  "status": "TODO"
}
```

**Successful POST:**

```http
POST /api/tasks
Content-Type: application/json

{"title": "New task"}

201 Created
Location: /api/tasks/2
Content-Type: application/json

{
  "id": 2,
  "title": "New task",
  "status": "TODO"
}
```

**Not Found:**

```http
GET /api/tasks/999
404 Not Found
Content-Type: application/json

{
  "timestamp": "2025-12-24T14:30:00",
  "status": 404,
  "error": "Not Found",
  "message": "Task not found with id: 999",
  "path": "/api/tasks/999"
}
```

> aside positive
> **Best Practice:** Follow REST conventions consistently. This makes your API intuitive for developers and enables tooling like Swagger to generate better documentation.

## Request Validation

Duration: 10:00

Add input validation to ensure data integrity using Bean Validation (JSR-380).

### Create Request DTOs

**CreateTaskRequest.java:**

```java
package com.example.taskmanager.dto;

import com.example.taskmanager.model.TaskStatus;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateTaskRequest {

    @NotBlank(message = "Title is required")
    @Size(min = 3, max = 100, message = "Title must be between 3 and 100 characters")
    private String title;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    private TaskStatus status;
}
```

**UpdateTaskRequest.java:**

```java
package com.example.taskmanager.dto;

import com.example.taskmanager.model.TaskStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateTaskRequest {

    @NotBlank(message = "Title is required")
    @Size(min = 3, max = 100, message = "Title must be between 3 and 100 characters")
    private String title;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    private TaskStatus status;
}
```

**TaskResponse.java:**

```java
package com.example.taskmanager.dto;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskResponse {
    private Long id;
    private String title;
    private String description;
    private TaskStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Convenience constructor from Task entity
    public TaskResponse(Task task) {
        this.id = task.getId();
        this.title = task.getTitle();
        this.description = task.getDescription();
        this.status = task.getStatus();
        this.createdAt = task.getCreatedAt();
        this.updatedAt = task.getUpdatedAt();
    }

    // Convert to Task entity
    public Task toEntity() {
        return new Task(id, title, description, status, createdAt, updatedAt);
    }
}
```

### Validation Annotations Reference

```java
// String validation
@NotNull          // Must not be null
@NotEmpty         // Must not be null or empty
@NotBlank         // Must not be null, empty, or whitespace
@Size(min=3, max=100)  // Length constraint
@Pattern(regexp="[A-Z]+")  // Regex match
@Email            // Valid email format

// Number validation
@Min(0)           // Minimum value
@Max(100)         // Maximum value
@Positive         // Must be > 0
@PositiveOrZero   // Must be >= 0
@Negative         // Must be < 0
@DecimalMin("0.01")  // Minimum decimal
@DecimalMax("99.99") // Maximum decimal

// Date/Time validation
@Past             // Must be in the past
@PastOrPresent    // Past or present
@Future           // Must be in the future
@FutureOrPresent  // Future or present

// Custom
@AssertTrue       // Boolean must be true
@AssertFalse      // Boolean must be false
```

### Update Controller with Validation

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.dto.*;
import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.service.TaskService;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.stream.Collectors;

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
    public ResponseEntity<TaskResponse> createTask(@Valid @RequestBody CreateTaskRequest request) {
        log.info("POST /api/tasks - Creating task: {}", request.getTitle());

        Task task = new Task(request.getTitle(), request.getDescription());
        if (request.getStatus() != null) {
            task.setStatus(request.getStatus());
        }

        Task createdTask = taskService.createTask(task);
        TaskResponse response = new TaskResponse(createdTask);

        URI location = URI.create("/api/tasks/" + createdTask.getId());
        return ResponseEntity.created(location).body(response);
    }

    @GetMapping
    public ResponseEntity<List<TaskResponse>> getAllTasks() {
        log.info("GET /api/tasks - Fetching all tasks");
        List<TaskResponse> tasks = taskService.getAllTasks().stream()
            .map(TaskResponse::new)
            .collect(Collectors.toList());
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TaskResponse> getTaskById(@PathVariable Long id) {
        log.info("GET /api/tasks/{} - Fetching task", id);
        return taskService.getTaskById(id)
            .map(TaskResponse::new)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TaskResponse> updateTask(
            @PathVariable Long id,
            @Valid @RequestBody UpdateTaskRequest request) {
        log.info("PUT /api/tasks/{} - Updating task", id);

        Task taskDetails = new Task();
        taskDetails.setTitle(request.getTitle());
        taskDetails.setDescription(request.getDescription());
        taskDetails.setStatus(request.getStatus());

        Task updatedTask = taskService.updateTask(id, taskDetails);
        return ResponseEntity.ok(new TaskResponse(updatedTask));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        log.info("DELETE /api/tasks/{} - Deleting task", id);
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<TaskResponse> updateTaskStatus(
            @PathVariable Long id,
            @RequestParam TaskStatus status) {
        log.info("PATCH /api/tasks/{}/status?status={}", id, status);
        Task updatedTask = taskService.updateTaskStatus(id, status);
        return ResponseEntity.ok(new TaskResponse(updatedTask));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<TaskResponse>> getTasksByStatus(@PathVariable TaskStatus status) {
        log.info("GET /api/tasks/status/{}", status);
        List<TaskResponse> tasks = taskService.getTasksByStatus(status).stream()
            .map(TaskResponse::new)
            .collect(Collectors.toList());
        return ResponseEntity.ok(tasks);
    }
}
```

### Understanding @Valid

```java
@PostMapping
public ResponseEntity<TaskResponse> createTask(@Valid @RequestBody CreateTaskRequest request) {
    // @Valid triggers validation
    // If validation fails, throws MethodArgumentNotValidException
    // We'll handle this in @ControllerAdvice next
}
```

### Test Validation

```bash
# Valid request - succeeds
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Valid Task", "description": "This is valid"}'

# Invalid: title too short
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "AB", "description": "Title too short"}'

# Invalid: title missing
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"description": "No title provided"}'

# Invalid: description too long (>500 chars)
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Task", "description": "'$(python -c 'print("a"*501)')'"}'
```

> aside positive
> **Why DTOs?** Separating request/response DTOs from entities gives you control over what data is exposed and allows entities to evolve independently.

## Exception Handling

Duration: 12:00

Implement global exception handling for consistent error responses.

### Custom Exceptions

**TaskNotFoundException.java:**

```java
package com.example.taskmanager.exception;

public class TaskNotFoundException extends RuntimeException {
    public TaskNotFoundException(Long id) {
        super("Task not found with id: " + id);
    }
}
```

**InvalidTaskException.java:**

```java
package com.example.taskmanager.exception;

public class InvalidTaskException extends RuntimeException {
    public InvalidTaskException(String message) {
        super(message);
    }
}
```

**DuplicateTaskException.java:**

```java
package com.example.taskmanager.exception;

public class DuplicateTaskException extends RuntimeException {
    public DuplicateTaskException(String title) {
        super("Task already exists with title: " + title);
    }
}
```

### Error Response DTO

**ErrorResponse.java:**

```java
package com.example.taskmanager.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ErrorResponse {
    private LocalDateTime timestamp;
    private int status;
    private String error;
    private String message;
    private String path;
    private List<ValidationError> validationErrors;

    public ErrorResponse(int status, String error, String message, String path) {
        this.timestamp = LocalDateTime.now();
        this.status = status;
        this.error = error;
        this.message = message;
        this.path = path;
    }

    @Data
    @AllArgsConstructor
    public static class ValidationError {
        private String field;
        private String message;
    }
}
```

### Global Exception Handler

**GlobalExceptionHandler.java:**

```java
package com.example.taskmanager.exception;

import com.example.taskmanager.dto.ErrorResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.util.List;
import java.util.stream.Collectors;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(TaskNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleTaskNotFoundException(
            TaskNotFoundException ex, WebRequest request) {
        log.error("Task not found: {}", ex.getMessage());

        ErrorResponse errorResponse = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            "Not Found",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", "")
        );

        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(InvalidTaskException.class)
    public ResponseEntity<ErrorResponse> handleInvalidTaskException(
            InvalidTaskException ex, WebRequest request) {
        log.error("Invalid task: {}", ex.getMessage());

        ErrorResponse errorResponse = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Bad Request",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", "")
        );

        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(DuplicateTaskException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateTaskException(
            DuplicateTaskException ex, WebRequest request) {
        log.error("Duplicate task: {}", ex.getMessage());

        ErrorResponse errorResponse = new ErrorResponse(
            HttpStatus.CONFLICT.value(),
            "Conflict",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", "")
        );

        return new ResponseEntity<>(errorResponse, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex, WebRequest request) {
        log.error("Validation failed: {}", ex.getMessage());

        List<ErrorResponse.ValidationError> validationErrors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(error -> new ErrorResponse.ValidationError(
                error.getField(),
                error.getDefaultMessage()
            ))
            .collect(Collectors.toList());

        ErrorResponse errorResponse = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation Failed",
            "Invalid request parameters",
            request.getDescription(false).replace("uri=", "")
        );
        errorResponse.setValidationErrors(validationErrors);

        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
            Exception ex, WebRequest request) {
        log.error("Unexpected error: {}", ex.getMessage(), ex);

        ErrorResponse errorResponse = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "Internal Server Error",
            "An unexpected error occurred",
            request.getDescription(false).replace("uri=", "")
        );

        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
```

### Update Service to Use Custom Exceptions

```java
package com.example.taskmanager.service;

import com.example.taskmanager.exception.InvalidTaskException;
import com.example.taskmanager.exception.TaskNotFoundException;
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

    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
        log.info("TaskService initialized with repository: {}",
            taskRepository.getClass().getSimpleName());
    }

    public Task createTask(Task task) {
        log.debug("Creating new task: {}", task.getTitle());

        // Validation
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
                return new TaskNotFoundException(id);
            });
    }

    public void deleteTask(Long id) {
        log.debug("Deleting task with ID: {}", id);

        if (!taskRepository.existsById(id)) {
            log.error("Task not found with ID: {}", id);
            throw new TaskNotFoundException(id);
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
            .orElseThrow(() -> new TaskNotFoundException(id));
    }

    public List<Task> getTasksByStatus(TaskStatus status) {
        log.debug("Fetching tasks with status: {}", status);
        return taskRepository.findAll().stream()
            .filter(task -> task.getStatus() == status)
            .toList();
    }
}
```

### Test Exception Handling

```bash
# Test 1: Task not found (404)
curl -v http://localhost:8080/api/tasks/999
# Response: 404 with ErrorResponse JSON

# Test 2: Validation error (400)
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "AB"}'
# Response: 400 with validation errors

# Test 3: Missing required field (400)
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"description": "No title"}'
# Response: 400 with validation error for title field
```

**Expected Error Response:**

```json
{
  "timestamp": "2025-12-24T14:30:00",
  "status": 400,
  "error": "Validation Failed",
  "message": "Invalid request parameters",
  "path": "/api/tasks",
  "validationErrors": [
    {
      "field": "title",
      "message": "Title must be between 3 and 100 characters"
    }
  ]
}
```

> aside positive
> **@RestControllerAdvice:** This annotation combines `@ControllerAdvice` and `@ResponseBody`, making exception handlers return JSON responses automatically.

## Swagger/OpenAPI Documentation

Duration: 12:00

Add interactive API documentation using SpringDoc OpenAPI.

### Configure Swagger

**OpenAPIConfig.java:**

```java
package com.example.taskmanager.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenAPIConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Task Management API")
                .version("1.0.0")
                .description("RESTful API for managing tasks with Spring Boot")
                .contact(new Contact()
                    .name("API Support")
                    .email("support@taskmanager.com")
                    .url("https://taskmanager.com/support"))
                .license(new License()
                    .name("Apache 2.0")
                    .url("https://www.apache.org/licenses/LICENSE-2.0.html")))
            .servers(List.of(
                new Server()
                    .url("http://localhost:8080")
                    .description("Development server"),
                new Server()
                    .url("https://api.taskmanager.com")
                    .description("Production server")
            ));
    }
}
```

### Add Swagger Annotations to Controller

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.dto.*;
import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.service.TaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tasks")
@Tag(name = "Task Management", description = "APIs for managing tasks")
@Slf4j
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
        log.info("TaskController initialized");
    }

    @Operation(
        summary = "Create a new task",
        description = "Creates a new task with the provided information"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "201",
            description = "Task created successfully",
            content = @Content(schema = @Schema(implementation = TaskResponse.class))
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid input",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    @PostMapping
    public ResponseEntity<TaskResponse> createTask(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                description = "Task creation request",
                required = true
            )
            @Valid @RequestBody CreateTaskRequest request) {
        log.info("POST /api/tasks - Creating task: {}", request.getTitle());

        Task task = new Task(request.getTitle(), request.getDescription());
        if (request.getStatus() != null) {
            task.setStatus(request.getStatus());
        }

        Task createdTask = taskService.createTask(task);
        TaskResponse response = new TaskResponse(createdTask);

        URI location = URI.create("/api/tasks/" + createdTask.getId());
        return ResponseEntity.created(location).body(response);
    }

    @Operation(
        summary = "Get all tasks",
        description = "Retrieves a list of all tasks"
    )
    @ApiResponse(
        responseCode = "200",
        description = "Tasks retrieved successfully"
    )
    @GetMapping
    public ResponseEntity<List<TaskResponse>> getAllTasks() {
        log.info("GET /api/tasks - Fetching all tasks");
        List<TaskResponse> tasks = taskService.getAllTasks().stream()
            .map(TaskResponse::new)
            .collect(Collectors.toList());
        return ResponseEntity.ok(tasks);
    }

    @Operation(
        summary = "Get task by ID",
        description = "Retrieves a specific task by its ID"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Task found",
            content = @Content(schema = @Schema(implementation = TaskResponse.class))
        ),
        @ApiResponse(
            responseCode = "404",
            description = "Task not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    @GetMapping("/{id}")
    public ResponseEntity<TaskResponse> getTaskById(
            @Parameter(description = "Task ID", required = true)
            @PathVariable Long id) {
        log.info("GET /api/tasks/{} - Fetching task", id);
        return taskService.getTaskById(id)
            .map(TaskResponse::new)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @Operation(
        summary = "Update a task",
        description = "Updates an existing task with new information"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Task updated successfully",
            content = @Content(schema = @Schema(implementation = TaskResponse.class))
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid input",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "404",
            description = "Task not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    @PutMapping("/{id}")
    public ResponseEntity<TaskResponse> updateTask(
            @Parameter(description = "Task ID", required = true)
            @PathVariable Long id,
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                description = "Task update request",
                required = true
            )
            @Valid @RequestBody UpdateTaskRequest request) {
        log.info("PUT /api/tasks/{} - Updating task", id);

        Task taskDetails = new Task();
        taskDetails.setTitle(request.getTitle());
        taskDetails.setDescription(request.getDescription());
        taskDetails.setStatus(request.getStatus());

        Task updatedTask = taskService.updateTask(id, taskDetails);
        return ResponseEntity.ok(new TaskResponse(updatedTask));
    }

    @Operation(
        summary = "Delete a task",
        description = "Deletes a task by its ID"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "204",
            description = "Task deleted successfully"
        ),
        @ApiResponse(
            responseCode = "404",
            description = "Task not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(
            @Parameter(description = "Task ID", required = true)
            @PathVariable Long id) {
        log.info("DELETE /api/tasks/{} - Deleting task", id);
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

    @Operation(
        summary = "Update task status",
        description = "Updates only the status of a task"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Task status updated successfully"
        ),
        @ApiResponse(
            responseCode = "404",
            description = "Task not found"
        )
    })
    @PatchMapping("/{id}/status")
    public ResponseEntity<TaskResponse> updateTaskStatus(
            @Parameter(description = "Task ID", required = true)
            @PathVariable Long id,
            @Parameter(description = "New task status", required = true)
            @RequestParam TaskStatus status) {
        log.info("PATCH /api/tasks/{}/status?status={}", id, status);
        Task updatedTask = taskService.updateTaskStatus(id, status);
        return ResponseEntity.ok(new TaskResponse(updatedTask));
    }

    @Operation(
        summary = "Get tasks by status",
        description = "Retrieves all tasks with a specific status"
    )
    @ApiResponse(
        responseCode = "200",
        description = "Tasks retrieved successfully"
    )
    @GetMapping("/status/{status}")
    public ResponseEntity<List<TaskResponse>> getTasksByStatus(
            @Parameter(description = "Task status filter", required = true)
            @PathVariable TaskStatus status) {
        log.info("GET /api/tasks/status/{}", status);
        List<TaskResponse> tasks = taskService.getTasksByStatus(status).stream()
            .map(TaskResponse::new)
            .collect(Collectors.toList());
        return ResponseEntity.ok(tasks);
    }
}
```

### Configure application.properties

```properties
# Swagger/OpenAPI Configuration
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.operationsSorter=method
springdoc.swagger-ui.tagsSorter=alpha
springdoc.swagger-ui.tryItOutEnabled=true
```

### Access Swagger UI

Start the application and visit:

- **Swagger UI:** http://localhost:8080/swagger-ui.html
- **OpenAPI JSON:** http://localhost:8080/api-docs

**Swagger UI Features:**

- Interactive API documentation
- Try out endpoints directly in browser
- View request/response schemas
- See all validation constraints
- Test different scenarios

> aside positive
> **Interactive Testing:** Swagger UI lets you test APIs without curl or Postman. Click "Try it out" on any endpoint to send requests directly!

## Advanced Topics

Duration: 8:00

### Pagination and Sorting

**PagedResponse.java:**

```java
package com.example.taskmanager.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PagedResponse<T> {
    private List<T> content;
    private int pageNumber;
    private int pageSize;
    private long totalElements;
    private int totalPages;
    private boolean last;
}
```

**Controller with pagination:**

```java
@Operation(summary = "Get all tasks with pagination")
@GetMapping
public ResponseEntity<PagedResponse<TaskResponse>> getAllTasks(
        @Parameter(description = "Page number (0-based)")
        @RequestParam(defaultValue = "0") int page,
        @Parameter(description = "Page size")
        @RequestParam(defaultValue = "10") int size,
        @Parameter(description = "Sort by field")
        @RequestParam(defaultValue = "id") String sortBy) {

    // Implementation depends on repository layer
    // Will be fully implemented in Codelab 3.3 with JPA
    List<TaskResponse> allTasks = taskService.getAllTasks().stream()
        .map(TaskResponse::new)
        .toList();

    int start = page * size;
    int end = Math.min(start + size, allTasks.size());
    List<TaskResponse> paged = allTasks.subList(start, end);

    PagedResponse<TaskResponse> response = new PagedResponse<>(
        paged,
        page,
        size,
        allTasks.size(),
        (int) Math.ceil((double) allTasks.size() / size),
        end >= allTasks.size()
    );

    return ResponseEntity.ok(response);
}
```

### API Versioning

**Strategy 1: URI Versioning**

```java
@RequestMapping("/api/v1/tasks")
public class TaskControllerV1 { }

@RequestMapping("/api/v2/tasks")
public class TaskControllerV2 { }
```

**Strategy 2: Header Versioning**

```java
@GetMapping(headers = "X-API-VERSION=1")
public ResponseEntity<TaskResponse> getTaskV1(@PathVariable Long id) { }

@GetMapping(headers = "X-API-VERSION=2")
public ResponseEntity<TaskResponseV2> getTaskV2(@PathVariable Long id) { }
```

**Strategy 3: Accept Header Versioning**

```java
@GetMapping(produces = "application/vnd.taskmanager.v1+json")
public ResponseEntity<TaskResponse> getTaskV1(@PathVariable Long id) { }

@GetMapping(produces = "application/vnd.taskmanager.v2+json")
public ResponseEntity<TaskResponseV2> getTaskV2(@PathVariable Long id) { }
```

### Content Negotiation

**Support JSON and XML:**

Add dependency:

```xml
<dependency>
    <groupId>com.fasterxml.jackson.dataformat</groupId>
    <artifactId>jackson-dataformat-xml</artifactId>
</dependency>
```

Controller:

```java
@GetMapping(produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
public ResponseEntity<TaskResponse> getTask(@PathVariable Long id) {
    // Returns JSON or XML based on Accept header
    return taskService.getTaskById(id)
        .map(TaskResponse::new)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
}
```

Usage:

```bash
# Request JSON (default)
curl -H "Accept: application/json" http://localhost:8080/api/tasks/1

# Request XML
curl -H "Accept: application/xml" http://localhost:8080/api/tasks/1
```

### CORS Configuration

**CorsConfig.java:**

```java
package com.example.taskmanager.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        config.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",
            "http://localhost:4200",
            "https://taskmanager.com"
        ));
        config.setAllowedHeaders(Arrays.asList("*"));
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);

        return new CorsFilter(source);
    }
}
```

> aside positive
> **Production Tip:** Be specific with CORS origins in production. Never use `*` for `allowedOrigins` when `allowCredentials` is true.

## Testing with Swagger UI

Duration: 5:00

Let's test all our enhancements using Swagger UI.

### Navigate to Swagger UI

1. Start application: `mvn spring-boot:run`
2. Open browser: http://localhost:8080/swagger-ui.html
3. You'll see all endpoints organized by tags

### Test Scenarios

**Scenario 1: Create Valid Task**

1. Expand "POST /api/tasks"
2. Click "Try it out"
3. Enter request body:

```json
{
  "title": "Complete REST API Codelab",
  "description": "Learn validation and Swagger",
  "status": "TODO"
}
```

4. Click "Execute"
5. See 201 Created response with Location header

**Scenario 2: Validation Error**

1. Expand "POST /api/tasks"
2. Try with invalid data:

```json
{
  "title": "AB",
  "description": "Title too short"
}
```

3. See 400 Bad Request with validation errors:

```json
{
  "timestamp": "2025-12-24T14:30:00",
  "status": 400,
  "error": "Validation Failed",
  "validationErrors": [
    {
      "field": "title",
      "message": "Title must be between 3 and 100 characters"
    }
  ]
}
```

**Scenario 3: Not Found Error**

1. Expand "GET /api/tasks/{id}"
2. Enter non-existent ID: 999
3. Click "Execute"
4. See 404 Not Found with error response

**Scenario 4: Update Task Status**

1. Create a task first (get its ID)
2. Expand "PATCH /api/tasks/{id}/status"
3. Enter task ID and status: "IN_PROGRESS"
4. Click "Execute"
5. See updated task with new status

**Scenario 5: Get Tasks by Status**

1. Create several tasks with different statuses
2. Expand "GET /api/tasks/status/{status}"
3. Enter status: "TODO"
4. See filtered list

### Verify Error Responses

All error scenarios should return consistent ErrorResponse format:

- Task not found: 404
- Validation failure: 400 with field details
- Invalid request: 400
- Server error: 500

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've enhanced your Task API to production standards!

### What You've Learned

- ✅ **REST Best Practices:** Richardson Maturity Model, proper HTTP methods
- ✅ **Request Validation:** Bean Validation with `@Valid` and constraints
- ✅ **Exception Handling:** Global `@RestControllerAdvice` with custom exceptions
- ✅ **DTOs:** Separating request/response models from entities
- ✅ **Swagger/OpenAPI:** Interactive API documentation
- ✅ **Error Responses:** Standardized error format
- ✅ **HTTP Status Codes:** Proper usage for different scenarios
- ✅ **Advanced Topics:** Pagination, versioning, CORS, content negotiation

### Task Management API v1.1

Enhanced features:

- ✅ Input validation with detailed error messages
- ✅ Global exception handling
- ✅ Custom exceptions (TaskNotFoundException, etc.)
- ✅ Swagger UI at /swagger-ui.html
- ✅ Complete OpenAPI 3.0 documentation
- ✅ DTOs for clean API contracts
- ✅ Consistent error responses
- ✅ Production-ready REST API

### Key Takeaways

1. **Validate all inputs** to prevent bad data
2. **Use DTOs** to control API surface
3. **Global exception handling** ensures consistency
4. **Swagger** is essential for API documentation
5. **HTTP status codes** communicate intent clearly
6. **Custom exceptions** make error handling semantic
7. **Richardson Level 2** is the practical REST target

### Git Branching

```bash
git add .
git commit -m "Codelab 3.2: REST APIs, Swagger & Exception Handling complete"
git tag codelab-3.2
git push origin codelab-3.2
```

### Next Steps

Continue to:

- **Codelab 3.3:** ORM & Spring Data JPA
  - Replace in-memory repository with database
  - JPA entities and relationships
  - Spring Data JPA repositories
  - Query methods and JPQL

### Additional Resources

- [Spring REST Docs](https://spring.io/guides/gs/rest-service/)
- [Bean Validation Spec](https://beanvalidation.org/)
- [SpringDoc OpenAPI](https://springdoc.org/)
- [REST API Best Practices](https://www.baeldung.com/rest-api-best-practices)
- [HTTP Status Codes](https://httpstatuses.com/)

> aside positive
> **API Excellence!** Your Task Management API now has validation, error handling, and documentation - essential for any production API. Next, we'll add database persistence!
