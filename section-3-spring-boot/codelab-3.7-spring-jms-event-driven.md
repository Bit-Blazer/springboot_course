summary: Build event-driven architecture with Spring JMS, ActiveMQ Artemis, message queues, async task notifications, and event processing for scalable microservices
id: spring-jms-event-driven
categories: Spring Boot, JMS, Messaging, Event-Driven, ActiveMQ
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM
feedback link: https://github.com/Bit-Blazer/springboot_course/issues/new

# Spring JMS & Event-Driven Architecture

## Introduction

Duration: 3:00

Add asynchronous messaging and event-driven architecture to the Task Management API using Spring JMS and ActiveMQ Artemis.

### What You'll Learn

- **JMS Basics:** Java Message Service fundamentals
- **Message Brokers:** ActiveMQ Artemis embedded server
- **Queue vs Topic:** Point-to-point and publish-subscribe
- **Spring JMS:** JmsTemplate and @JmsListener
- **Event-Driven Design:** Domain events and event handlers
- **Async Messaging:** Non-blocking message sending
- **Message Patterns:** Request-reply, fire-and-forget
- **Error Handling:** Dead letter queues and retry
- **Transaction Management:** Message transactions
- **Event Sourcing:** Audit trail with events

### What You'll Build

Event-driven Task Management API with:

- **Task Events:** TaskCreated, TaskUpdated, TaskDeleted
- **Email Notifications:** Async email on task events
- **Audit Log:** Event sourcing for task history
- **JMS Queues:** Task events, notifications, audit
- **Event Publishers:** Domain event publishing
- **Event Listeners:** Async event processing
- **Dead Letter Queue:** Failed message handling
- **Embedded Artemis:** No external broker needed (dev)
- **Message Priority:** Urgent vs normal notifications
- **Scheduled Messages:** Delayed task reminders

### Prerequisites

- Completed Codelab 3.6 (Reactive & R2DBC)
- Understanding of async programming

### Messaging Patterns

**Queue (Point-to-Point):**

```
Producer → [Queue] → Consumer
           1 message = 1 consumer
```

**Topic (Publish-Subscribe):**

```
Publisher → [Topic] → Subscriber 1
                   → Subscriber 2
                   → Subscriber 3
           1 message = N subscribers
```

### New Dependencies

Add to `pom.xml`:

```xml
<!-- Spring JMS -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-artemis</artifactId>
</dependency>

<!-- ActiveMQ Artemis (embedded broker) -->
<dependency>
    <groupId>org.apache.activemq</groupId>
    <artifactId>artemis-jakarta-server</artifactId>
</dependency>

<!-- JSON serialization for messages -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
</dependency>

<!-- Email (optional, for email notifications) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>
```

> aside positive
> **Event-Driven Benefits:** Loose coupling, async processing, better scalability, resilience to failures, and audit trail out of the box!

## Understanding Event-Driven Architecture

Duration: 8:00

Learn event-driven design principles and messaging patterns.

### Traditional vs Event-Driven

**Traditional (Synchronous):**

```java
@Transactional
public Task createTask(Task task) {
    Task saved = taskRepository.save(task);
    emailService.sendEmail(saved);        // Blocks
    auditService.logCreate(saved);        // Blocks
    notificationService.notify(saved);    // Blocks
    return saved;
}

// Problems:
// - Slow response (waits for all operations)
// - Tight coupling (task creation knows about email, audit)
// - Single point of failure (email down = task creation fails)
```

**Event-Driven (Asynchronous):**

```java
@Transactional
public Task createTask(Task task) {
    Task saved = taskRepository.save(task);
    eventPublisher.publish(new TaskCreatedEvent(saved));  // Fire and forget
    return saved;  // Immediate response
}

@JmsListener(destination = "task.created")
public void handleTaskCreated(TaskCreatedEvent event) {
    emailService.sendEmail(event.getTask());     // Async
}

@JmsListener(destination = "task.created")
public void handleAudit(TaskCreatedEvent event) {
    auditService.logCreate(event.getTask());     // Async
}

// Benefits:
// ✅ Fast response (doesn't wait)
// ✅ Loose coupling (task doesn't know about email)
// ✅ Resilient (email down = task still created)
```

### Domain Events

```java
// Event = Something that happened in the past
public class TaskCreatedEvent {
    private Long taskId;
    private String title;
    private Long userId;
    private LocalDateTime occurredAt;
}

public class TaskStatusChangedEvent {
    private Long taskId;
    private TaskStatus oldStatus;
    private TaskStatus newStatus;
    private LocalDateTime changedAt;
}

public class TaskAssignedEvent {
    private Long taskId;
    private Long fromUserId;
    private Long toUserId;
    private LocalDateTime assignedAt;
}
```

### Event-Driven Patterns

**1. Event Notification:**

```
Service A → Event → Service B (reacts)
```

**2. Event-Carried State Transfer:**

```
Service A → Event (with full state) → Service B (stores copy)
```

**3. Event Sourcing:**

```
All changes stored as events
Current state = replay all events
```

**4. CQRS (Command Query Responsibility Segregation):**

```
Write Model → Events → Read Model
(Commands)            (Queries)
```

### JMS Components

```
Producer                     Broker                    Consumer
  |                            |                         |
  |---(1) Send Message-------->|                         |
  |                            |                         |
  |                            |<--(2) Subscribe---------|
  |                            |                         |
  |                            |---(3) Deliver Message-->|
  |                            |                         |
  |<--(4) Ack (optional)-------|<--(4) Acknowledge------|
```

### Queue vs Topic

**Queue (Task Distribution):**

```
Producer → [Queue: task.processing]
              ↓
          Consumer 1 ✓ (processes)
          Consumer 2 (idle)
          Consumer 3 (idle)

Use for: Work distribution, load balancing
```

**Topic (Event Broadcasting):**

```
Publisher → [Topic: task.created]
               ↓
          Subscriber 1: Email ✓
          Subscriber 2: Audit ✓
          Subscriber 3: Analytics ✓

Use for: Notifications, event broadcasting
```

### Message Properties

```java
// Priority: 0-9 (0=lowest, 9=highest)
jmsTemplate.setPriority(9);

// Time-to-live: Message expiration
jmsTemplate.setTimeToLive(60000); // 60 seconds

// Delivery mode: PERSISTENT vs NON_PERSISTENT
jmsTemplate.setDeliveryMode(DeliveryMode.PERSISTENT);

// Message ID: Unique identifier
String messageId = message.getJMSMessageID();

// Correlation ID: Link request-reply
message.setJMSCorrelationID(requestId);
```

> aside positive
> **Best Practice:** Use events for inter-service communication in microservices. Events provide loose coupling and enable independent evolution.

## Configure ActiveMQ Artemis

Duration: 5:00

Set up embedded ActiveMQ Artemis message broker.

### Update application.yml

```yaml
spring:
  application:
    name: task-manager

  # ActiveMQ Artemis Configuration
  artemis:
    mode: embedded
    embedded:
      enabled: true
      persistent: false # In-memory for development
      data-directory: ${java.io.tmpdir}/artemis-data
      queues:
        - task.created
        - task.updated
        - task.deleted
        - task.assigned
        - task.notification
        - task.audit
        - task.email
        - task.dlq # Dead Letter Queue
      topics:
        - task.events

  # JMS Configuration
  jms:
    template:
      default-destination: task.events
      delivery-mode: persistent
      priority: 5
      time-to-live: 3600000 # 1 hour
    listener:
      acknowledge-mode: auto
      concurrency: 3-10
      max-concurrency: 10

# Logging
logging:
  level:
    org.apache.activemq: INFO
    org.springframework.jms: DEBUG
    com.example.taskmanager: DEBUG
```

### Production Configuration

**application-prod.yml:**

```yaml
spring:
  artemis:
    mode: native
    host: localhost
    port: 61616
    user: admin
    password: ${ARTEMIS_PASSWORD}

  jms:
    template:
      delivery-mode: persistent
    listener:
      concurrency: 5-20
```

### JMS Configuration Class

```java
package com.example.taskmanager.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.support.converter.MappingJackson2MessageConverter;
import org.springframework.jms.support.converter.MessageConverter;
import org.springframework.jms.support.converter.MessageType;

@Configuration
@EnableJms
public class JmsConfig {

    @Bean
    public MessageConverter jacksonJmsMessageConverter() {
        MappingJackson2MessageConverter converter = new MappingJackson2MessageConverter();
        converter.setTargetType(MessageType.TEXT);
        converter.setTypeIdPropertyName("_type");
        return converter;
    }
}
```

### Queue Constants

```java
package com.example.taskmanager.messaging;

public class QueueConstants {

    // Queues
    public static final String TASK_CREATED_QUEUE = "task.created";
    public static final String TASK_UPDATED_QUEUE = "task.updated";
    public static final String TASK_DELETED_QUEUE = "task.deleted";
    public static final String TASK_ASSIGNED_QUEUE = "task.assigned";
    public static final String TASK_NOTIFICATION_QUEUE = "task.notification";
    public static final String TASK_AUDIT_QUEUE = "task.audit";
    public static final String TASK_EMAIL_QUEUE = "task.email";
    public static final String DEAD_LETTER_QUEUE = "task.dlq";

    // Topics
    public static final String TASK_EVENTS_TOPIC = "task.events";

    private QueueConstants() {}
}
```

> aside negative
> **Production Note:** Use external Artemis broker in production for reliability and clustering. Embedded mode is for development only!

## Create Domain Events

Duration: 8:00

Define events for task lifecycle.

### Base Event

```java
package com.example.taskmanager.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public abstract class DomainEvent implements Serializable {

    private String eventId;
    private LocalDateTime occurredAt;
    private String eventType;

    protected DomainEvent(String eventType) {
        this.eventId = UUID.randomUUID().toString();
        this.occurredAt = LocalDateTime.now();
        this.eventType = eventType;
    }
}
```

### Task Events

```java
package com.example.taskmanager.event;

import com.example.taskmanager.model.TaskStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class TaskCreatedEvent extends DomainEvent {

    private Long taskId;
    private String title;
    private String description;
    private TaskStatus status;
    private Long userId;

    public TaskCreatedEvent(Long taskId, String title, String description,
                           TaskStatus status, Long userId) {
        super("TaskCreated");
        this.taskId = taskId;
        this.title = title;
        this.description = description;
        this.status = status;
        this.userId = userId;
    }
}
```

```java
package com.example.taskmanager.event;

import com.example.taskmanager.model.TaskStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class TaskUpdatedEvent extends DomainEvent {

    private Long taskId;
    private String title;
    private String description;
    private TaskStatus status;
    private Long userId;

    public TaskUpdatedEvent(Long taskId, String title, String description,
                           TaskStatus status, Long userId) {
        super("TaskUpdated");
        this.taskId = taskId;
        this.title = title;
        this.description = description;
        this.status = status;
        this.userId = userId;
    }
}
```

```java
package com.example.taskmanager.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class TaskDeletedEvent extends DomainEvent {

    private Long taskId;
    private String title;
    private Long userId;

    public TaskDeletedEvent(Long taskId, String title, Long userId) {
        super("TaskDeleted");
        this.taskId = taskId;
        this.title = title;
        this.userId = userId;
    }
}
```

```java
package com.example.taskmanager.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class TaskAssignedEvent extends DomainEvent {

    private Long taskId;
    private String title;
    private Long fromUserId;
    private Long toUserId;

    public TaskAssignedEvent(Long taskId, String title, Long fromUserId, Long toUserId) {
        super("TaskAssigned");
        this.taskId = taskId;
        this.title = title;
        this.fromUserId = fromUserId;
        this.toUserId = toUserId;
    }
}
```

```java
package com.example.taskmanager.event;

import com.example.taskmanager.model.TaskStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class TaskStatusChangedEvent extends DomainEvent {

    private Long taskId;
    private String title;
    private TaskStatus oldStatus;
    private TaskStatus newStatus;
    private Long userId;

    public TaskStatusChangedEvent(Long taskId, String title,
                                 TaskStatus oldStatus, TaskStatus newStatus, Long userId) {
        super("TaskStatusChanged");
        this.taskId = taskId;
        this.title = title;
        this.oldStatus = oldStatus;
        this.newStatus = newStatus;
        this.userId = userId;
    }
}
```

### Notification Event

```java
package com.example.taskmanager.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationEvent implements Serializable {

    private Long userId;
    private String email;
    private String subject;
    private String message;
    private NotificationType type;

    public enum NotificationType {
        EMAIL,
        SMS,
        PUSH
    }
}
```

> aside positive
> **Event Design:** Events are immutable, past tense (TaskCreated not CreateTask), and contain all data needed by subscribers.

## Event Publisher Service

Duration: 8:00

Create service to publish events to JMS queues.

### EventPublisher

```java
package com.example.taskmanager.messaging;

import com.example.taskmanager.event.DomainEvent;
import com.example.taskmanager.event.NotificationEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class EventPublisher {

    private final JmsTemplate jmsTemplate;

    public EventPublisher(JmsTemplate jmsTemplate) {
        this.jmsTemplate = jmsTemplate;
    }

    public void publishTaskCreated(DomainEvent event) {
        log.info("Publishing TaskCreated event: {}", event.getEventId());
        jmsTemplate.convertAndSend(QueueConstants.TASK_CREATED_QUEUE, event);
        publishToTopic(event);
    }

    public void publishTaskUpdated(DomainEvent event) {
        log.info("Publishing TaskUpdated event: {}", event.getEventId());
        jmsTemplate.convertAndSend(QueueConstants.TASK_UPDATED_QUEUE, event);
        publishToTopic(event);
    }

    public void publishTaskDeleted(DomainEvent event) {
        log.info("Publishing TaskDeleted event: {}", event.getEventId());
        jmsTemplate.convertAndSend(QueueConstants.TASK_DELETED_QUEUE, event);
        publishToTopic(event);
    }

    public void publishTaskAssigned(DomainEvent event) {
        log.info("Publishing TaskAssigned event: {}", event.getEventId());
        jmsTemplate.convertAndSend(QueueConstants.TASK_ASSIGNED_QUEUE, event);
        publishToTopic(event);
    }

    public void publishNotification(NotificationEvent notification) {
        log.info("Publishing notification to user: {}", notification.getUserId());
        jmsTemplate.convertAndSend(QueueConstants.TASK_NOTIFICATION_QUEUE, notification);
    }

    public void publishAuditEvent(DomainEvent event) {
        log.info("Publishing audit event: {}", event.getEventId());
        jmsTemplate.convertAndSend(QueueConstants.TASK_AUDIT_QUEUE, event);
    }

    public void publishEmailNotification(NotificationEvent notification) {
        log.info("Publishing email notification: {}", notification.getSubject());
        jmsTemplate.convertAndSend(QueueConstants.TASK_EMAIL_QUEUE, notification);
    }

    // Publish to topic for broadcast
    private void publishToTopic(DomainEvent event) {
        log.debug("Publishing to topic: {}", QueueConstants.TASK_EVENTS_TOPIC);
        jmsTemplate.convertAndSend(QueueConstants.TASK_EVENTS_TOPIC, event);
    }

    // Priority message
    public void publishUrgentNotification(NotificationEvent notification) {
        log.warn("Publishing URGENT notification: {}", notification.getSubject());
        jmsTemplate.convertAndSend(QueueConstants.TASK_NOTIFICATION_QUEUE, notification, message -> {
            message.setJMSPriority(9);  // Highest priority
            return message;
        });
    }

    // Delayed message
    public void publishDelayedNotification(NotificationEvent notification, long delayMs) {
        log.info("Publishing delayed notification ({}ms): {}", delayMs, notification.getSubject());
        jmsTemplate.convertAndSend(QueueConstants.TASK_NOTIFICATION_QUEUE, notification, message -> {
            message.setLongProperty("_AMQ_SCHED_DELIVERY", System.currentTimeMillis() + delayMs);
            return message;
        });
    }
}
```

### Update TaskService

```java
package com.example.taskmanager.service;

import com.example.taskmanager.event.*;
import com.example.taskmanager.exception.TaskNotFoundException;
import com.example.taskmanager.messaging.EventPublisher;
import com.example.taskmanager.model.Task;
import com.example.taskmanager.model.TaskStatus;
import com.example.taskmanager.repository.TaskRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Slf4j
public class TaskService {

    private final TaskRepository taskRepository;
    private final EventPublisher eventPublisher;

    public TaskService(TaskRepository taskRepository, EventPublisher eventPublisher) {
        this.taskRepository = taskRepository;
        this.eventPublisher = eventPublisher;
    }

    @Transactional
    public Task createTask(Task task) {
        log.debug("Creating task: {}", task.getTitle());

        task.setCreatedAt(LocalDateTime.now());
        task.setUpdatedAt(LocalDateTime.now());

        if (task.getStatus() == null) {
            task.setStatus(TaskStatus.TODO);
        }

        Task saved = taskRepository.save(task);

        // Publish event
        TaskCreatedEvent event = new TaskCreatedEvent(
            saved.getId(),
            saved.getTitle(),
            saved.getDescription(),
            saved.getStatus(),
            saved.getUserId()
        );
        eventPublisher.publishTaskCreated(event);

        log.info("Task created with ID: {}", saved.getId());
        return saved;
    }

    @Transactional
    public Task updateTask(Long id, Task taskDetails) {
        log.debug("Updating task: {}", id);

        Task task = taskRepository.findById(id)
            .orElseThrow(() -> new TaskNotFoundException(id));

        TaskStatus oldStatus = task.getStatus();

        task.setTitle(taskDetails.getTitle());
        task.setDescription(taskDetails.getDescription());
        task.setStatus(taskDetails.getStatus());
        task.setUpdatedAt(LocalDateTime.now());

        Task updated = taskRepository.save(task);

        // Publish events
        TaskUpdatedEvent event = new TaskUpdatedEvent(
            updated.getId(),
            updated.getTitle(),
            updated.getDescription(),
            updated.getStatus(),
            updated.getUserId()
        );
        eventPublisher.publishTaskUpdated(event);

        // Publish status change event if status changed
        if (!oldStatus.equals(updated.getStatus())) {
            TaskStatusChangedEvent statusEvent = new TaskStatusChangedEvent(
                updated.getId(),
                updated.getTitle(),
                oldStatus,
                updated.getStatus(),
                updated.getUserId()
            );
            eventPublisher.publishTaskUpdated(statusEvent);
        }

        log.info("Task updated: {}", id);
        return updated;
    }

    @Transactional
    public void deleteTask(Long id) {
        log.debug("Deleting task: {}", id);

        Task task = taskRepository.findById(id)
            .orElseThrow(() -> new TaskNotFoundException(id));

        taskRepository.delete(task);

        // Publish event
        TaskDeletedEvent event = new TaskDeletedEvent(
            task.getId(),
            task.getTitle(),
            task.getUserId()
        );
        eventPublisher.publishTaskDeleted(event);

        log.info("Task deleted: {}", id);
    }

    @Transactional
    public Task assignTaskToUser(Long taskId, Long userId) {
        log.debug("Assigning task {} to user {}", taskId, userId);

        Task task = taskRepository.findById(taskId)
            .orElseThrow(() -> new TaskNotFoundException(taskId));

        Long oldUserId = task.getUserId();
        task.setUserId(userId);
        task.setUpdatedAt(LocalDateTime.now());

        Task updated = taskRepository.save(task);

        // Publish event
        TaskAssignedEvent event = new TaskAssignedEvent(
            updated.getId(),
            updated.getTitle(),
            oldUserId,
            userId
        );
        eventPublisher.publishTaskAssigned(event);

        return updated;
    }

    // ... other methods remain the same ...
}
```

## Event Listeners

Duration: 10:00

Create listeners to handle events asynchronously.

### Audit Event Listener

```java
package com.example.taskmanager.messaging.listener;

import com.example.taskmanager.event.*;
import com.example.taskmanager.model.AuditLog;
import com.example.taskmanager.repository.AuditLogRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@Slf4j
public class AuditEventListener {

    private final AuditLogRepository auditLogRepository;

    public AuditEventListener(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    @JmsListener(destination = "task.created")
    public void handleTaskCreated(TaskCreatedEvent event) {
        log.info("Audit: Task created - ID: {}, Title: {}", event.getTaskId(), event.getTitle());

        AuditLog auditLog = new AuditLog();
        auditLog.setEventType("TASK_CREATED");
        auditLog.setEntityId(event.getTaskId());
        auditLog.setEntityType("Task");
        auditLog.setUserId(event.getUserId());
        auditLog.setEventData(String.format("Created task: %s", event.getTitle()));
        auditLog.setOccurredAt(event.getOccurredAt());
        auditLog.setCreatedAt(LocalDateTime.now());

        auditLogRepository.save(auditLog);
    }

    @JmsListener(destination = "task.updated")
    public void handleTaskUpdated(TaskUpdatedEvent event) {
        log.info("Audit: Task updated - ID: {}", event.getTaskId());

        AuditLog auditLog = new AuditLog();
        auditLog.setEventType("TASK_UPDATED");
        auditLog.setEntityId(event.getTaskId());
        auditLog.setEntityType("Task");
        auditLog.setUserId(event.getUserId());
        auditLog.setEventData(String.format("Updated task: %s (Status: %s)",
            event.getTitle(), event.getStatus()));
        auditLog.setOccurredAt(event.getOccurredAt());
        auditLog.setCreatedAt(LocalDateTime.now());

        auditLogRepository.save(auditLog);
    }

    @JmsListener(destination = "task.deleted")
    public void handleTaskDeleted(TaskDeletedEvent event) {
        log.info("Audit: Task deleted - ID: {}", event.getTaskId());

        AuditLog auditLog = new AuditLog();
        auditLog.setEventType("TASK_DELETED");
        auditLog.setEntityId(event.getTaskId());
        auditLog.setEntityType("Task");
        auditLog.setUserId(event.getUserId());
        auditLog.setEventData(String.format("Deleted task: %s", event.getTitle()));
        auditLog.setOccurredAt(event.getOccurredAt());
        auditLog.setCreatedAt(LocalDateTime.now());

        auditLogRepository.save(auditLog);
    }

    @JmsListener(destination = "task.assigned")
    public void handleTaskAssigned(TaskAssignedEvent event) {
        log.info("Audit: Task assigned - ID: {} to User: {}",
            event.getTaskId(), event.getToUserId());

        AuditLog auditLog = new AuditLog();
        auditLog.setEventType("TASK_ASSIGNED");
        auditLog.setEntityId(event.getTaskId());
        auditLog.setEntityType("Task");
        auditLog.setUserId(event.getToUserId());
        auditLog.setEventData(String.format("Assigned task '%s' from user %d to user %d",
            event.getTitle(), event.getFromUserId(), event.getToUserId()));
        auditLog.setOccurredAt(event.getOccurredAt());
        auditLog.setCreatedAt(LocalDateTime.now());

        auditLogRepository.save(auditLog);
    }
}
```

### Notification Event Listener

```java
package com.example.taskmanager.messaging.listener;

import com.example.taskmanager.event.*;
import com.example.taskmanager.messaging.EventPublisher;
import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class NotificationEventListener {

    private final UserRepository userRepository;
    private final EventPublisher eventPublisher;

    public NotificationEventListener(UserRepository userRepository,
                                     EventPublisher eventPublisher) {
        this.userRepository = userRepository;
        this.eventPublisher = eventPublisher;
    }

    @JmsListener(destination = "task.created")
    public void handleTaskCreated(TaskCreatedEvent event) {
        log.info("Notification: Task created - sending notification to user: {}",
            event.getUserId());

        if (event.getUserId() != null) {
            userRepository.findById(event.getUserId()).ifPresent(user -> {
                NotificationEvent notification = new NotificationEvent(
                    user.getId(),
                    user.getEmail(),
                    "Task Created",
                    String.format("Your task '%s' has been created successfully.", event.getTitle()),
                    NotificationEvent.NotificationType.EMAIL
                );
                eventPublisher.publishEmailNotification(notification);
            });
        }
    }

    @JmsListener(destination = "task.assigned")
    public void handleTaskAssigned(TaskAssignedEvent event) {
        log.info("Notification: Task assigned - notifying user: {}", event.getToUserId());

        if (event.getToUserId() != null) {
            userRepository.findById(event.getToUserId()).ifPresent(user -> {
                NotificationEvent notification = new NotificationEvent(
                    user.getId(),
                    user.getEmail(),
                    "Task Assigned to You",
                    String.format("Task '%s' has been assigned to you.", event.getTitle()),
                    NotificationEvent.NotificationType.EMAIL
                );
                // Urgent notification
                eventPublisher.publishUrgentNotification(notification);
            });
        }
    }

    @JmsListener(destination = "task.updated")
    public void handleTaskStatusChanged(TaskStatusChangedEvent event) {
        if (event == null || event.getOldStatus().equals(event.getNewStatus())) {
            return;
        }

        log.info("Notification: Task status changed - {} to {}",
            event.getOldStatus(), event.getNewStatus());

        if (event.getUserId() != null) {
            userRepository.findById(event.getUserId()).ifPresent(user -> {
                NotificationEvent notification = new NotificationEvent(
                    user.getId(),
                    user.getEmail(),
                    "Task Status Changed",
                    String.format("Task '%s' status changed from %s to %s.",
                        event.getTitle(), event.getOldStatus(), event.getNewStatus()),
                    NotificationEvent.NotificationType.EMAIL
                );
                eventPublisher.publishNotification(notification);
            });
        }
    }
}
```

### Email Event Listener

```java
package com.example.taskmanager.messaging.listener;

import com.example.taskmanager.event.NotificationEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class EmailEventListener {

    // Simulate email service (replace with real EmailService in production)

    @JmsListener(destination = "task.email")
    public void handleEmailNotification(NotificationEvent notification) {
        log.info("📧 Sending email to: {}", notification.getEmail());
        log.info("   Subject: {}", notification.getSubject());
        log.info("   Message: {}", notification.getMessage());

        // Simulate email sending
        try {
            Thread.sleep(1000); // Simulate network delay
            log.info("✅ Email sent successfully to: {}", notification.getEmail());
        } catch (InterruptedException e) {
            log.error("❌ Failed to send email: {}", e.getMessage());
            throw new RuntimeException("Email sending failed", e);
        }
    }
}
```

### Dead Letter Queue Listener

```java
package com.example.taskmanager.messaging.listener;

import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

import jakarta.jms.Message;

@Component
@Slf4j
public class DeadLetterQueueListener {

    @JmsListener(destination = "task.dlq")
    public void handleDeadLetter(Message message) {
        try {
            log.error("💀 Message moved to DLQ: {}", message.getJMSMessageID());
            log.error("   Type: {}", message.getJMSType());
            log.error("   Timestamp: {}", message.getJMSTimestamp());

            // Log for manual intervention
            // In production: alert admin, store for replay, etc.

        } catch (Exception e) {
            log.error("Error processing DLQ message: {}", e.getMessage());
        }
    }
}
```

### AuditLog Entity

```java
package com.example.taskmanager.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuditLog {

    private Long id;
    private String eventType;
    private Long entityId;
    private String entityType;
    private Long userId;
    private String eventData;
    private LocalDateTime occurredAt;
    private LocalDateTime createdAt;
}
```

### AuditLogRepository

```java
package com.example.taskmanager.repository;

import com.example.taskmanager.model.AuditLog;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Repository
public class AuditLogRepository {

    private final ConcurrentHashMap<Long, AuditLog> auditLogs = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    public AuditLog save(AuditLog auditLog) {
        if (auditLog.getId() == null) {
            auditLog.setId(idGenerator.getAndIncrement());
        }
        auditLogs.put(auditLog.getId(), auditLog);
        return auditLog;
    }

    public List<AuditLog> findAll() {
        return new ArrayList<>(auditLogs.values());
    }

    public List<AuditLog> findByEntityId(Long entityId) {
        return auditLogs.values().stream()
            .filter(log -> log.getEntityId().equals(entityId))
            .toList();
    }
}
```

> aside positive
> **Listener Patterns:** @JmsListener methods run asynchronously. Multiple listeners can subscribe to same queue (load balancing) or topic (broadcasting).

## Testing Event-Driven System

Duration: 5:00

Test async messaging and event handling.

### Manual Testing

**1. Create a task:**

```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "Event-Driven Task",
    "description": "Testing JMS events"
  }'
```

**Check logs:**

```
Publishing TaskCreated event: <uuid>
Audit: Task created - ID: 1, Title: Event-Driven Task
Notification: Task created - sending notification to user: 1
📧 Sending email to: user@example.com
✅ Email sent successfully
```

**2. Assign task:**

```bash
curl -X PUT http://localhost:8080/api/tasks/1/assign/2 \
  -H "Authorization: Bearer <token>"
```

**Check logs:**

```
Publishing TaskAssigned event: <uuid>
Audit: Task assigned - ID: 1 to User: 2
Notification: Task assigned - notifying user: 2
📧 Sending email to: user2@example.com (URGENT)
```

**3. View audit logs:**

```bash
curl http://localhost:8080/api/audit/task/1 \
  -H "Authorization: Bearer <token>"
```

### Integration Test

```java
package com.example.taskmanager.messaging;

import com.example.taskmanager.event.TaskCreatedEvent;
import com.example.taskmanager.model.TaskStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jms.core.JmsTemplate;

import static org.awaitility.Awaitility.await;
import static java.util.concurrent.TimeUnit.SECONDS;

@SpringBootTest
public class EventPublisherIntegrationTest {

    @Autowired
    private EventPublisher eventPublisher;

    @Autowired
    private JmsTemplate jmsTemplate;

    @Test
    public void testPublishTaskCreatedEvent() {
        TaskCreatedEvent event = new TaskCreatedEvent(
            1L, "Test Task", "Description", TaskStatus.TODO, 1L
        );

        eventPublisher.publishTaskCreated(event);

        // Wait for async processing
        await().atMost(5, SECONDS).untilAsserted(() -> {
            // Verify audit log created
            // Verify notification sent
        });
    }
}
```

### Add Awaitility Dependency

```xml
<dependency>
    <groupId>org.awaitility</groupId>
    <artifactId>awaitility</artifactId>
    <version>4.2.0</version>
    <scope>test</scope>
</dependency>
```

### Monitor Artemis Console

Access embedded Artemis console:

- URL: http://localhost:8161/console
- Default credentials: admin/admin

View:

- Queue depths
- Message rates
- Active consumers
- DLQ messages

> aside positive
> **Testing Async:** Use Awaitility to test async operations with timeouts. Never use Thread.sleep() in tests!

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've built an event-driven architecture with Spring JMS!

### What You've Learned

- ✅ **JMS Basics:** Queues, topics, message brokers
- ✅ **ActiveMQ Artemis:** Embedded broker configuration
- ✅ **Event-Driven Design:** Domain events and handlers
- ✅ **Spring JMS:** JmsTemplate and @JmsListener
- ✅ **Async Processing:** Non-blocking event handling
- ✅ **Event Publishing:** Fire-and-forget messaging
- ✅ **Event Listeners:** Decoupled event subscribers
- ✅ **Audit Trail:** Event sourcing for history
- ✅ **Notifications:** Email notifications via events
- ✅ **DLQ:** Dead letter queue for failures

### Task Management API v1.6

Event-driven features:

- ✅ Domain events for task lifecycle
- ✅ Async event publishing
- ✅ Audit log via event sourcing
- ✅ Email notifications
- ✅ Decoupled event handlers
- ✅ JMS queues and topics
- ✅ Message priority support
- ✅ Dead letter queue handling
- ✅ Embedded Artemis broker
- ✅ Production-ready messaging

### Event-Driven Benefits

**Before (Synchronous):**

- 🔴 Slow response times
- 🔴 Tight coupling
- 🔴 Single point of failure
- 🔴 Hard to scale

**After (Event-Driven):**

- ✅ Fast response times
- ✅ Loose coupling
- ✅ Resilient to failures
- ✅ Easy horizontal scaling
- ✅ Audit trail included
- ✅ Async processing

### Git Branching

```bash
git add .
git commit -m "Codelab 3.7: Spring JMS & Event-Driven Architecture complete"
git tag codelab-3.7
```

### Next Steps

- **Codelab 3.8:** Testing & Remote Debugging

### Additional Resources

- [Spring JMS Documentation](https://docs.spring.io/spring-framework/reference/integration/jms.html)
- [ActiveMQ Artemis](https://activemq.apache.org/components/artemis/)
- [Event-Driven Architecture](https://martinfowler.com/articles/201701-event-driven.html)

> aside positive
> **Microservices Ready!** Your API now uses event-driven architecture - the foundation for scalable, loosely-coupled microservices!
