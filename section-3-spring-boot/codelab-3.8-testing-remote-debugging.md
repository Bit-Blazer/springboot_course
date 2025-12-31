summary: Master comprehensive testing strategies with JUnit 5, Mockito, Spring Boot Test, Testcontainers for integration tests, and remote debugging techniques for Spring Boot applications
id: testing-remote-debugging
categories: Spring Boot, Testing, JUnit, Mockito, Testcontainers, Debugging
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM
feedback link: https://github.com/Bit-Blazer/springboot_course/issues/new

# Testing & Remote Debugging Spring Boot Apps

## Introduction

Duration: 3:00

Build comprehensive test coverage and master remote debugging for production troubleshooting.

### What You'll Learn

- **Unit Testing:** JUnit 5 and Mockito
- **Integration Testing:** @SpringBootTest
- **Test Slices:** @WebMvcTest, @DataJpaTest, @JsonTest
- **Testcontainers:** Docker-based integration tests
- **WebTestClient:** Testing reactive endpoints
- **MockMvc:** Testing MVC controllers
- **Test Coverage:** JaCoCo code coverage
- **Remote Debugging:** JDWP and IntelliJ/Eclipse
- **Production Debugging:** Thread dumps, heap dumps
- **Actuator:** Health checks and metrics

### What You'll Build

Comprehensive test suite for Task API:

- **Unit Tests:** Services, repositories, utilities
- **Integration Tests:** Full application context
- **Controller Tests:** REST API endpoints
- **Repository Tests:** Database operations
- **Security Tests:** Authentication and authorization
- **Testcontainers:** PostgreSQL integration tests
- **Code Coverage:** 80%+ coverage with JaCoCo
- **Remote Debugging:** Debug running containers

### Prerequisites

- Completed Codelab 3.7 (Spring JMS)
- Understanding of testing concepts

### Testing Pyramid

```
        /\
       /  \  E2E Tests (Few)
      /____\
     /      \
    / Integ. \ Integration Tests (Some)
   /__________\
  /            \
 /  Unit Tests  \ Unit Tests (Many)
/________________\

Unit: Fast, isolated, many
Integration: Slower, real components, some
E2E: Slowest, full system, few
```

### New Dependencies

Add to `pom.xml`:

```xml
<!-- Testing -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<!-- Reactor Test -->
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-test</artifactId>
    <scope>test</scope>
</dependency>

<!-- Testcontainers -->
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>testcontainers</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>

<!-- JaCoCo for code coverage -->
<dependency>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
</dependency>
```

> aside positive
> **Testing is NOT optional!** Tests are your safety net for refactoring, documentation for new developers, and confidence for deployment.

## Unit Testing with JUnit 5

Duration: 10:00

Write unit tests for services and business logic.

### TaskService Unit Test

```java
package com.example.taskmanager.service;

import com.example.taskmanager.event.*;
import com.example.taskmanager.exception.TaskNotFoundException;
import com.example.taskmanager.messaging.EventPublisher;
import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.repository.TaskRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("TaskService Unit Tests")
class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @Mock
    private EventPublisher eventPublisher;

    @InjectMocks
    private TaskService taskService;

    private Task testTask;

    @BeforeEach
    void setUp() {
        testTask = new Task();
        testTask.setId(1L);
        testTask.setTitle("Test Task");
        testTask.setDescription("Test Description");
        testTask.setStatus(TaskStatus.TODO);
        testTask.setUserId(1L);
    }

    @Test
    @DisplayName("Should create task successfully")
    void shouldCreateTask() {
        // Given
        Task newTask = new Task("New Task", "Description");
        newTask.setUserId(1L);

        Task savedTask = new Task("New Task", "Description");
        savedTask.setId(2L);
        savedTask.setUserId(1L);
        savedTask.setStatus(TaskStatus.TODO);

        when(taskRepository.save(any(Task.class))).thenReturn(savedTask);
        doNothing().when(eventPublisher).publishTaskCreated(any(TaskCreatedEvent.class));

        // When
        Task result = taskService.createTask(newTask);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(2L);
        assertThat(result.getTitle()).isEqualTo("New Task");
        assertThat(result.getStatus()).isEqualTo(TaskStatus.TODO);

        verify(taskRepository, times(1)).save(any(Task.class));
        verify(eventPublisher, times(1)).publishTaskCreated(any(TaskCreatedEvent.class));
    }

    @Test
    @DisplayName("Should get task by ID")
    void shouldGetTaskById() {
        // Given
        when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));

        // When
        Task result = taskService.getTaskById(1L);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getTitle()).isEqualTo("Test Task");

        verify(taskRepository, times(1)).findById(1L);
    }

    @Test
    @DisplayName("Should throw exception when task not found")
    void shouldThrowExceptionWhenTaskNotFound() {
        // Given
        when(taskRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> taskService.getTaskById(999L))
            .isInstanceOf(TaskNotFoundException.class)
            .hasMessageContaining("999");

        verify(taskRepository, times(1)).findById(999L);
    }

    @Test
    @DisplayName("Should get all tasks")
    void shouldGetAllTasks() {
        // Given
        Task task2 = new Task("Task 2", "Description 2");
        task2.setId(2L);

        when(taskRepository.findAll()).thenReturn(Arrays.asList(testTask, task2));

        // When
        List<Task> results = taskService.getAllTasks();

        // Then
        assertThat(results).hasSize(2);
        assertThat(results).extracting(Task::getTitle)
            .containsExactly("Test Task", "Task 2");

        verify(taskRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Should update task")
    void shouldUpdateTask() {
        // Given
        Task updateData = new Task();
        updateData.setTitle("Updated Title");
        updateData.setDescription("Updated Description");
        updateData.setStatus(TaskStatus.IN_PROGRESS);

        when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
        when(taskRepository.save(any(Task.class))).thenReturn(testTask);
        doNothing().when(eventPublisher).publishTaskUpdated(any(TaskUpdatedEvent.class));

        // When
        Task result = taskService.updateTask(1L, updateData);

        // Then
        assertThat(result.getTitle()).isEqualTo("Updated Title");
        assertThat(result.getDescription()).isEqualTo("Updated Description");
        assertThat(result.getStatus()).isEqualTo(TaskStatus.IN_PROGRESS);

        verify(taskRepository, times(1)).findById(1L);
        verify(taskRepository, times(1)).save(any(Task.class));
        verify(eventPublisher, times(1)).publishTaskUpdated(any(TaskUpdatedEvent.class));
    }

    @Test
    @DisplayName("Should delete task")
    void shouldDeleteTask() {
        // Given
        when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
        doNothing().when(taskRepository).delete(any(Task.class));
        doNothing().when(eventPublisher).publishTaskDeleted(any(TaskDeletedEvent.class));

        // When
        taskService.deleteTask(1L);

        // Then
        verify(taskRepository, times(1)).findById(1L);
        verify(taskRepository, times(1)).delete(testTask);
        verify(eventPublisher, times(1)).publishTaskDeleted(any(TaskDeletedEvent.class));
    }

    @Test
    @DisplayName("Should publish correct event when creating task")
    void shouldPublishCorrectEventWhenCreatingTask() {
        // Given
        Task newTask = new Task("Event Task", "Description");
        newTask.setUserId(1L);

        Task savedTask = new Task("Event Task", "Description");
        savedTask.setId(3L);
        savedTask.setUserId(1L);
        savedTask.setStatus(TaskStatus.TODO);

        when(taskRepository.save(any(Task.class))).thenReturn(savedTask);

        ArgumentCaptor<TaskCreatedEvent> eventCaptor =
            ArgumentCaptor.forClass(TaskCreatedEvent.class);

        // When
        taskService.createTask(newTask);

        // Then
        verify(eventPublisher).publishTaskCreated(eventCaptor.capture());

        TaskCreatedEvent capturedEvent = eventCaptor.getValue();
        assertThat(capturedEvent.getTaskId()).isEqualTo(3L);
        assertThat(capturedEvent.getTitle()).isEqualTo("Event Task");
        assertThat(capturedEvent.getStatus()).isEqualTo(TaskStatus.TODO);
    }

    @Test
    @DisplayName("Should assign task to user")
    void shouldAssignTaskToUser() {
        // Given
        when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
        when(taskRepository.save(any(Task.class))).thenReturn(testTask);
        doNothing().when(eventPublisher).publishTaskAssigned(any(TaskAssignedEvent.class));

        // When
        Task result = taskService.assignTaskToUser(1L, 2L);

        // Then
        assertThat(result.getUserId()).isEqualTo(2L);
        verify(eventPublisher, times(1)).publishTaskAssigned(any(TaskAssignedEvent.class));
    }
}
```

### JUnit 5 Assertions

```java
// AssertJ assertions (recommended)
assertThat(actual).isEqualTo(expected);
assertThat(list).hasSize(3);
assertThat(string).contains("substring");
assertThat(object).isNotNull();
assertThat(list).extracting("name").containsExactly("A", "B");

// Exception assertions
assertThatThrownBy(() -> service.method())
    .isInstanceOf(RuntimeException.class)
    .hasMessageContaining("error");

assertThatCode(() -> service.method()).doesNotThrowAnyException();

// JUnit assertions
assertEquals(expected, actual);
assertNotNull(object);
assertTrue(condition);
assertThrows(Exception.class, () -> method());
```

### Mockito Mocking

```java
// Create mock
@Mock
private Repository repository;

// Stub method
when(repository.findById(1L)).thenReturn(Optional.of(entity));
when(repository.save(any())).thenReturn(savedEntity);
doNothing().when(publisher).publish(any());
doThrow(new RuntimeException()).when(service).delete(1L);

// Verify interactions
verify(repository, times(1)).findById(1L);
verify(repository, never()).delete(any());
verify(publisher, atLeastOnce()).publish(any());

// Argument captors
ArgumentCaptor<Task> captor = ArgumentCaptor.forClass(Task.class);
verify(repository).save(captor.capture());
Task captured = captor.getValue();
assertThat(captured.getTitle()).isEqualTo("Expected");
```

> aside positive
> **Best Practice:** Use AssertJ for fluent, readable assertions. Use Mockito for mocking dependencies in unit tests.

## Integration Testing

Duration: 10:00

Test with full Spring context and real components.

### Integration Test with @SpringBootTest

```java
package com.example.taskmanager;

import com.example.taskmanager.dto.CreateTaskRequest;
import com.example.taskmanager.dto.TaskResponse;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.repository.TaskRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@DisplayName("Task API Integration Tests")
class TaskApiIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private TaskRepository taskRepository;

    private String baseUrl;

    @BeforeEach
    void setUp() {
        baseUrl = "http://localhost:" + port + "/api/tasks";
        taskRepository.deleteAll();
    }

    @Test
    @DisplayName("Should create task via API")
    void shouldCreateTaskViaApi() {
        // Given
        CreateTaskRequest request = new CreateTaskRequest(
            "Integration Test Task",
            "Testing full stack",
            TaskStatus.TODO
        );

        // When
        ResponseEntity<TaskResponse> response = restTemplate.postForEntity(
            baseUrl,
            request,
            TaskResponse.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getTitle()).isEqualTo("Integration Test Task");
        assertThat(response.getHeaders().getLocation()).isNotNull();
    }

    @Test
    @DisplayName("Should get all tasks via API")
    void shouldGetAllTasksViaApi() {
        // Given - create some tasks first
        taskRepository.save(createTestTask("Task 1"));
        taskRepository.save(createTestTask("Task 2"));

        // When
        ResponseEntity<TaskResponse[]> response = restTemplate.getForEntity(
            baseUrl,
            TaskResponse[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).hasSize(2);
    }

    @Test
    @DisplayName("Should return 404 for non-existent task")
    void shouldReturn404ForNonExistentTask() {
        // When
        ResponseEntity<TaskResponse> response = restTemplate.getForEntity(
            baseUrl + "/999",
            TaskResponse.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }

    @Test
    @DisplayName("Should update task via API")
    void shouldUpdateTaskViaApi() {
        // Given
        Task existing = taskRepository.save(createTestTask("Original"));

        UpdateTaskRequest update = new UpdateTaskRequest(
            "Updated Title",
            "Updated Description",
            TaskStatus.IN_PROGRESS
        );

        // When
        restTemplate.put(baseUrl + "/" + existing.getId(), update);

        // Then
        Task updated = taskRepository.findById(existing.getId()).orElseThrow();
        assertThat(updated.getTitle()).isEqualTo("Updated Title");
        assertThat(updated.getStatus()).isEqualTo(TaskStatus.IN_PROGRESS);
    }

    @Test
    @DisplayName("Should delete task via API")
    void shouldDeleteTaskViaApi() {
        // Given
        Task existing = taskRepository.save(createTestTask("To Delete"));

        // When
        restTemplate.delete(baseUrl + "/" + existing.getId());

        // Then
        assertThat(taskRepository.findById(existing.getId())).isEmpty();
    }

    private Task createTestTask(String title) {
        Task task = new Task(title, "Description");
        task.setStatus(TaskStatus.TODO);
        return task;
    }
}
```

### Test Configuration

**src/test/resources/application-test.yml:**

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password:

  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true

  jms:
    template:
      default-destination: test.queue

  artemis:
    mode: embedded
    embedded:
      enabled: true
      persistent: false

logging:
  level:
    com.example.taskmanager: DEBUG
    org.hibernate.SQL: DEBUG
```

### WebMvc Test Slice

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.dto.TaskResponse;
import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.service.TaskService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.hamcrest.Matchers.*;

@WebMvcTest(TaskController.class)
@DisplayName("TaskController MVC Tests")
class TaskControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private TaskService taskService;

    @Test
    @DisplayName("Should return all tasks")
    void shouldReturnAllTasks() throws Exception {
        // Given
        Task task1 = createTask(1L, "Task 1");
        Task task2 = createTask(2L, "Task 2");

        when(taskService.getAllTasks()).thenReturn(Arrays.asList(task1, task2));

        // When & Then
        mockMvc.perform(get("/api/tasks"))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$", hasSize(2)))
            .andExpect(jsonPath("$[0].title", is("Task 1")))
            .andExpect(jsonPath("$[1].title", is("Task 2")));
    }

    @Test
    @DisplayName("Should create task")
    void shouldCreateTask() throws Exception {
        // Given
        CreateTaskRequest request = new CreateTaskRequest(
            "New Task",
            "Description",
            TaskStatus.TODO
        );

        Task savedTask = createTask(1L, "New Task");
        when(taskService.createTask(any())).thenReturn(savedTask);

        // When & Then
        mockMvc.perform(post("/api/tasks")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(header().exists("Location"))
            .andExpect(jsonPath("$.id", is(1)))
            .andExpect(jsonPath("$.title", is("New Task")));
    }

    @Test
    @DisplayName("Should return 404 for non-existent task")
    void shouldReturn404() throws Exception {
        // Given
        when(taskService.getTaskById(999L))
            .thenThrow(new TaskNotFoundException(999L));

        // When & Then
        mockMvc.perform(get("/api/tasks/999"))
            .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Should validate request body")
    void shouldValidateRequestBody() throws Exception {
        // Given - invalid request (empty title)
        CreateTaskRequest invalid = new CreateTaskRequest("", "Description", null);

        // When & Then
        mockMvc.perform(post("/api/tasks")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalid)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.validationErrors").exists());
    }

    private Task createTask(Long id, String title) {
        Task task = new Task(title, "Description");
        task.setId(id);
        task.setStatus(TaskStatus.TODO);
        return task;
    }
}
```

## Testcontainers for Integration Tests

Duration: 10:00

Use Docker containers for realistic integration tests.

### PostgreSQL Testcontainer

```java
package com.example.taskmanager;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.repository.TaskRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Testcontainers
@DisplayName("Task Repository Integration Tests with Testcontainers")
class TaskRepositoryIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private TaskRepository taskRepository;

    @Test
    @DisplayName("Should save and retrieve task from PostgreSQL")
    void shouldSaveAndRetrieveTask() {
        // Given
        Task task = new Task("Testcontainer Task", "Testing with real PostgreSQL");
        task.setStatus(TaskStatus.TODO);
        task.setUserId(1L);

        // When
        Task saved = taskRepository.save(task);
        Task retrieved = taskRepository.findById(saved.getId()).orElseThrow();

        // Then
        assertThat(retrieved.getTitle()).isEqualTo("Testcontainer Task");
        assertThat(retrieved.getStatus()).isEqualTo(TaskStatus.TODO);
    }

    @Test
    @DisplayName("Should find tasks by status")
    void shouldFindTasksByStatus() {
        // Given
        taskRepository.deleteAll();
        taskRepository.save(createTask("Task 1", TaskStatus.TODO));
        taskRepository.save(createTask("Task 2", TaskStatus.TODO));
        taskRepository.save(createTask("Task 3", TaskStatus.DONE));

        // When
        List<Task> todoTasks = taskRepository.findByStatus(TaskStatus.TODO);

        // Then
        assertThat(todoTasks).hasSize(2);
        assertThat(todoTasks).extracting(Task::getStatus)
            .containsOnly(TaskStatus.TODO);
    }

    @Test
    @DisplayName("Should find tasks by user ID")
    void shouldFindTasksByUserId() {
        // Given
        taskRepository.deleteAll();
        Task task1 = createTask("User 1 Task", TaskStatus.TODO);
        task1.setUserId(1L);
        taskRepository.save(task1);

        Task task2 = createTask("User 2 Task", TaskStatus.TODO);
        task2.setUserId(2L);
        taskRepository.save(task2);

        // When
        List<Task> user1Tasks = taskRepository.findByUserId(1L);

        // Then
        assertThat(user1Tasks).hasSize(1);
        assertThat(user1Tasks.get(0).getTitle()).isEqualTo("User 1 Task");
    }

    @Test
    @DisplayName("Should search tasks by title")
    void shouldSearchTasksByTitle() {
        // Given
        taskRepository.deleteAll();
        taskRepository.save(createTask("Important Meeting", TaskStatus.TODO));
        taskRepository.save(createTask("Code Review", TaskStatus.TODO));
        taskRepository.save(createTask("Important Call", TaskStatus.TODO));

        // When
        List<Task> importantTasks = taskRepository.findByTitleContainingIgnoreCase("important");

        // Then
        assertThat(importantTasks).hasSize(2);
    }

    private Task createTask(String title, TaskStatus status) {
        Task task = new Task(title, "Description");
        task.setStatus(status);
        task.setUserId(1L);
        return task;
    }
}
```

### Base Testcontainer Configuration

```java
package com.example.taskmanager.config;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
public abstract class AbstractIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test")
        .withReuse(true);  // Reuse container across tests

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
```

### Use Base Class

```java
@SpringBootTest
class MyIntegrationTest extends AbstractIntegrationTest {
    // Inherits Testcontainer configuration

    @Test
    void myTest() {
        // Uses real PostgreSQL from container
    }
}
```

> aside positive
> **Testcontainers Benefits:** Test against real databases, message brokers, etc. Containers start automatically and are cleaned up after tests.

## Security Testing

Duration: 6:00

Test authentication and authorization.

### Security Integration Test

```java
package com.example.taskmanager.security;

import com.example.taskmanager.dto.LoginRequest;
import com.example.taskmanager.dto.SignupRequest;
import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@DisplayName("Security Integration Tests")
class SecurityIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("Should signup new user")
    void shouldSignupNewUser() {
        // Given
        SignupRequest request = new SignupRequest(
            "testuser",
            "test@example.com",
            "Test User",
            "password123"
        );

        // When
        ResponseEntity<AuthResponse> response = restTemplate.postForEntity(
            "/api/auth/signup",
            request,
            AuthResponse.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getToken()).isNotBlank();
        assertThat(response.getBody().getUsername()).isEqualTo("testuser");
    }

    @Test
    @DisplayName("Should login with valid credentials")
    void shouldLoginWithValidCredentials() {
        // Given - create user
        User user = new User("loginuser", "login@example.com", "Login User",
            passwordEncoder.encode("password123"));
        user.getRoles().add("ROLE_USER");
        userRepository.save(user);

        LoginRequest request = new LoginRequest("loginuser", "password123");

        // When
        ResponseEntity<AuthResponse> response = restTemplate.postForEntity(
            "/api/auth/login",
            request,
            AuthResponse.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getToken()).isNotBlank();
    }

    @Test
    @DisplayName("Should reject login with invalid credentials")
    void shouldRejectInvalidCredentials() {
        // Given
        LoginRequest request = new LoginRequest("invalid", "wrongpassword");

        // When
        ResponseEntity<AuthResponse> response = restTemplate.postForEntity(
            "/api/auth/login",
            request,
            AuthResponse.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    @DisplayName("Should access protected endpoint with valid token")
    void shouldAccessProtectedEndpointWithToken() {
        // Given - create user and get token
        SignupRequest signup = new SignupRequest(
            "authuser",
            "auth@example.com",
            "Auth User",
            "password123"
        );

        ResponseEntity<AuthResponse> authResponse = restTemplate.postForEntity(
            "/api/auth/signup",
            signup,
            AuthResponse.class
        );

        String token = authResponse.getBody().getToken();

        // When - access protected endpoint
        ResponseEntity<TaskResponse[]> tasksResponse = restTemplate
            .withBasicAuth("Bearer", token)
            .getForEntity("/api/tasks", TaskResponse[].class);

        // Then
        assertThat(tasksResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}
```

### Test with Security Context

```java
@Test
@WithMockUser(username = "testuser", roles = {"USER"})
void shouldAccessEndpointWithMockUser() {
    // Test runs with authenticated user context
}

@Test
@WithMockUser(roles = {"ADMIN"})
void shouldAccessAdminEndpoint() {
    // Test runs with admin role
}
```

## Code Coverage with JaCoCo

Duration: 5:00

Measure and enforce code coverage.

### JaCoCo Maven Plugin

Add to `pom.xml`:

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.11</version>
            <executions>
                <execution>
                    <id>prepare-agent</id>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>
                <execution>
                    <id>report</id>
                    <phase>test</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                </execution>
                <execution>
                    <id>check</id>
                    <goals>
                        <goal>check</goal>
                    </goals>
                    <configuration>
                        <rules>
                            <rule>
                                <element>PACKAGE</element>
                                <limits>
                                    <limit>
                                        <counter>LINE</counter>
                                        <value>COVEREDRATIO</value>
                                        <minimum>0.80</minimum>
                                    </limit>
                                </limits>
                            </rule>
                        </rules>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### Generate Coverage Report

```bash
mvn clean test
mvn jacoco:report
```

**View report:**
Open `target/site/jacoco/index.html` in browser

### Coverage Metrics

- **Line Coverage:** % of lines executed
- **Branch Coverage:** % of if/else branches taken
- **Method Coverage:** % of methods called
- **Class Coverage:** % of classes loaded

**Target:** 80% line coverage minimum

### Exclude from Coverage

```java
@Generated  // Exclude generated code
public class AutoGeneratedClass {
}

// Or configure in pom.xml:
<configuration>
    <excludes>
        <exclude>**/config/**</exclude>
        <exclude>**/dto/**</exclude>
        <exclude>**/*Application.class</exclude>
    </excludes>
</configuration>
```

> aside positive
> **Coverage Goal:** Aim for 80%+ coverage, but focus on testing critical business logic over hitting arbitrary numbers.

## Remote Debugging

Duration: 8:00

Debug running applications in development and production.

### Enable Remote Debugging

**application.yml (development):**

```yaml
spring:
  devtools:
    remote:
      secret: mysecret
```

**Run with Debug Mode:**

```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 \
  -jar target/task-manager.jar
```

**Parameters:**

- `transport=dt_socket`: Use socket transport
- `server=y`: Act as debug server
- `suspend=n`: Don't wait for debugger (use `y` to wait)
- `address=*:5005`: Listen on all interfaces, port 5005

### IntelliJ IDEA Remote Debug

1. **Run → Edit Configurations**
2. **Add New Configuration → Remote JVM Debug**
3. **Configure:**
   - Name: `Remote Debug`
   - Host: `localhost`
   - Port: `5005`
   - Use module classpath: `task-manager`
4. **Click Debug** (ensure app is running with debug agent)

### Eclipse Remote Debug

1. **Run → Debug Configurations**
2. **Remote Java Application → New**
3. **Configure:**
   - Project: `task-manager`
   - Host: `localhost`
   - Port: `5005`
4. **Click Debug**

### Debug Docker Container

**Dockerfile:**

```dockerfile
FROM openjdk:17-slim
COPY target/task-manager.jar app.jar
EXPOSE 8080 5005
ENTRYPOINT ["java", \
    "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", \
    "-jar", "/app.jar"]
```

**docker-compose.yml:**

```yaml
version: "3.8"
services:
  app:
    build: .
    ports:
      - "8080:8080"
      - "5005:5005" # Debug port
    environment:
      - SPRING_PROFILES_ACTIVE=dev
```

**Run and attach debugger:**

```bash
docker-compose up
# Attach IDE debugger to localhost:5005
```

### Kubernetes Debug

**deployment.yaml:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-manager
spec:
  template:
    spec:
      containers:
        - name: app
          image: task-manager:latest
          ports:
            - containerPort: 8080
            - containerPort: 5005 # Debug port
          env:
            - name: JAVA_TOOL_OPTIONS
              value: "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
```

**Port forward:**

```bash
kubectl port-forward pod/task-manager-xxx 5005:5005
# Attach IDE debugger to localhost:5005
```

### Debug Tips

**Conditional Breakpoints:**

```java
// Right-click breakpoint → Condition
// Break only when: taskId == 42L
```

**Logpoints (no code change):**

```java
// Right-click line → Add Logpoint
// Message: Task {taskId} status changed to {status}
```

**Evaluate Expression:**

```
Alt+F8 (IntelliJ) or Ctrl+Shift+I (Eclipse)
Evaluate any expression in current context
```

**Watch Variables:**

```
Add variables to watch list
See values update in real-time
```

> aside negative
> **Production Warning:** Never enable debug ports in production without proper network security. Use VPN or SSH tunnels for remote debugging production systems.

## Production Debugging Tools

Duration: 6:00

Diagnose issues in running production systems.

### Spring Boot Actuator

**Enable Actuator:**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

**application.yml:**

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,threaddump,heapdump,loggers
      base-path: /actuator
  endpoint:
    health:
      show-details: always
```

**Endpoints:**

```bash
# Health check
curl http://localhost:8080/actuator/health

# Metrics
curl http://localhost:8080/actuator/metrics
curl http://localhost:8080/actuator/metrics/jvm.memory.used

# Thread dump
curl http://localhost:8080/actuator/threaddump

# Heap dump (downloads .hprof file)
curl http://localhost:8080/actuator/heapdump -o heapdump.hprof

# Change log level at runtime
curl -X POST http://localhost:8080/actuator/loggers/com.example.taskmanager \
  -H "Content-Type: application/json" \
  -d '{"configuredLevel": "DEBUG"}'
```

### Thread Dump Analysis

**Get thread dump:**

```bash
jstack <pid> > threaddump.txt
# Or via Actuator
curl http://localhost:8080/actuator/threaddump > threaddump.json
```

**Analyze for:**

- Deadlocks
- Thread pool exhaustion
- Blocked threads
- CPU-intensive threads

**Example deadlock:**

```
Found one Java-level deadlock:
=============================
"Thread-1":
  waiting to lock monitor 0x00007f8f8c004e00 (object 0x000000076ab80000, a java.lang.Object),
  which is held by "Thread-2"
"Thread-2":
  waiting to lock monitor 0x00007f8f8c006b00 (object 0x000000076ab80010, a java.lang.Object),
  which is held by "Thread-1"
```

### Heap Dump Analysis

**Generate heap dump:**

```bash
jmap -dump:live,format=b,file=heapdump.hprof <pid>
# Or via Actuator
curl http://localhost:8080/actuator/heapdump -o heapdump.hprof
```

**Analyze with tools:**

- **Eclipse MAT** (Memory Analyzer Tool)
- **VisualVM**
- **JProfiler**

**Look for:**

- Memory leaks
- Large object retentions
- Unexpected object counts

### JVM Metrics

**Key metrics to monitor:**

```bash
# Memory usage
jcmd <pid> GC.heap_info

# CPU usage
top -H -p <pid>

# GC logs
java -Xlog:gc*:file=gc.log -jar app.jar
```

### Logging Best Practices

```java
// Use parameterized logging (no string concatenation)
log.debug("Processing task: {} for user: {}", taskId, userId);

// Include correlation IDs
log.info("Request {} - Creating task", requestId);

// Log exceptions with context
log.error("Failed to create task for user: {}", userId, exception);

// Use appropriate levels
log.trace("Detailed trace");  // Very verbose
log.debug("Debug info");      // Development
log.info("Important event");  // Production info
log.warn("Warning");          // Potential issue
log.error("Error");           // Actual error
```

## Performance Testing

Duration: 4:00

Test application performance and load handling.

### Load Test with JMeter

**Test Plan:**

```xml
<!-- task-api-load-test.jmx -->
<jmeterTestPlan>
  <ThreadGroup>
    <stringProp name="ThreadGroup.num_threads">100</stringProp>
    <stringProp name="ThreadGroup.ramp_time">10</stringProp>
    <stringProp name="ThreadGroup.duration">60</stringProp>
  </ThreadGroup>

  <HTTPSamplerProxy>
    <stringProp name="HTTPSampler.domain">localhost</stringProp>
    <stringProp name="HTTPSampler.port">8080</stringProp>
    <stringProp name="HTTPSampler.path">/api/tasks</stringProp>
    <stringProp name="HTTPSampler.method">GET</stringProp>
  </HTTPSamplerProxy>
</jmeterTestPlan>
```

**Run:**

```bash
jmeter -n -t task-api-load-test.jmx -l results.jtl -e -o report/
```

### Performance Assertions

```java
@Test
@DisplayName("Should handle 1000 tasks in under 1 second")
void shouldHandleHighLoad() {
    StopWatch stopWatch = new StopWatch();
    stopWatch.start();

    for (int i = 0; i < 1000; i++) {
        taskService.createTask(createTestTask("Task " + i));
    }

    stopWatch.stop();
    assertThat(stopWatch.getTotalTimeMillis()).isLessThan(1000);
}
```

### Database Performance

```java
@Test
@DisplayName("Should avoid N+1 query problem")
void shouldAvoidNPlusOne() {
    // Given
    createTasksWithUsers(100);

    // When
    Statistics statistics = sessionFactory.getStatistics();
    statistics.clear();
    statistics.setStatisticsEnabled(true);

    List<Task> tasks = taskRepository.findAllWithUser();

    // Then - should be 2 queries (1 for tasks, 1 for users)
    // Not 101 (1 for tasks + 100 for each user)
    assertThat(statistics.getPrepareStatementCount()).isLessThan(5);
}
```

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered testing and debugging Spring Boot applications!

### What You've Learned

- ✅ **Unit Testing:** JUnit 5 and Mockito
- ✅ **Integration Testing:** @SpringBootTest
- ✅ **Test Slices:** @WebMvcTest, @DataJpaTest
- ✅ **Testcontainers:** Docker-based tests
- ✅ **Security Testing:** Authentication tests
- ✅ **Code Coverage:** JaCoCo reports
- ✅ **Remote Debugging:** JDWP protocol
- ✅ **Container Debugging:** Docker and K8s
- ✅ **Production Tools:** Actuator, thread/heap dumps
- ✅ **Performance Testing:** Load testing basics

### Testing Best Practices

1. **Test Pyramid:** Many unit, some integration, few E2E
2. **Fast Tests:** Unit tests < 100ms, integration < 1s
3. **Isolated Tests:** No dependencies between tests
4. **Readable Tests:** Given-When-Then structure
5. **Meaningful Assertions:** Test behavior, not implementation
6. **Test Data:** Use builders or factories
7. **Coverage:** 80%+ for critical code
8. **CI/CD:** Run tests on every commit

### Debugging Best Practices

1. **Logging First:** Good logs prevent most debugging
2. **Correlation IDs:** Track requests across services
3. **Structured Logging:** Use JSON for production
4. **Metrics:** Monitor key indicators
5. **Alerting:** Proactive error detection
6. **Production Access:** Secure debug ports
7. **Reproduce Locally:** Test with production data patterns

### Git Branching

```bash
git add .
git commit -m "Codelab 3.8: Testing & Remote Debugging complete"
git tag codelab-3.8
```

### Section 3 Complete!

All 8 Spring Boot codelabs finished:

- ✅ 3.1: Spring Core & Boot basics
- ✅ 3.2: REST APIs & Swagger
- ✅ 3.3: ORM & Spring Data JPA
- ✅ 3.4: JPA Locking & Spring Security
- ✅ 3.5: JWT & Spring Cloud Config
- ✅ 3.6: Reactive Programming & R2DBC
- ✅ 3.7: Spring JMS & Event-Driven
- ✅ 3.8: Testing & Remote Debugging

### Next Steps

- **Section 4:** Microservices Architecture

### Additional Resources

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [Testcontainers](https://www.testcontainers.org/)
- [Spring Boot Testing](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing)
- [JaCoCo](https://www.jacoco.org/jacoco/)

> aside positive
> **Production Ready!** You now have comprehensive testing, debugging skills, and confidence to deploy quality Spring Boot applications to production!
