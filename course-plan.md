# Spring Boot Course Plan - Final Year CSE Students

**Total Duration:** 24 hours  
**Total Codelabs:** 20  
**Target Audience:** Final year Computer Science Engineering students

---

## Prerequisites & Assumptions

### Required Tools

- **JDK 17 or higher** - Core Java development
- **Maven 3.6+** or **Gradle 7+** - Build automation
- **IDE** - IntelliJ IDEA, Eclipse, or VS Code with Java extensions
- **Postman** or similar API testing tool
- **Git** - Version control
- **Docker Desktop** - Required for Section 4 microservices
- **PostgreSQL or MySQL** - Optional, H2 embedded database used for most exercises

### Assumed Knowledge

- Basic programming concepts (variables, loops, conditionals)
- Comfort with command line/terminal operations
- Understanding of web concepts (HTTP, REST basics)
- Final year CSE students with some Java exposure
- Basic SQL knowledge

---

## Course Structure Overview

### Strategy

- **Sections 1 & 2:** Standalone codelabs for Java fundamentals and modern features
- **Section 3:** Evolving project approach - Task Management API grows through 8 codelabs
- **Section 4:** Microservices architecture with standalone comparative projects
- **Condensed format:** Combined related topics, tighter exercises, efficient progression

### Learning Approach

- Hands-on, practical exercises for every topic
- Progressive complexity with clear prerequisites
- ~15% time buffer built into durations for troubleshooting
- Code examples, starter templates, and solution branches for all codelabs
- Focused exercises covering all topics in half the time

---

## Section 1: Core Java Programming (6 hours)

**5 Codelabs - Standalone approach**

### Codelab 1.1: Java Platform, Data Types & Control Flow

- **ID:** `java-fundamentals-control-flow`
- **Duration:** 75 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Java Platform, JVM, JRE, JDK concepts
  - JVM Architecture (Class Loader, Runtime Data Areas, Execution Engine)
  - Primitive data types, arrays, operators
  - Branching statements (if-else, switch)
  - Looping statements (for, while, do-while)
- **What Students Build:**
  - Set up Java environment, explore JDK tools
  - Calculator application with control flow
  - Menu-driven interface using loops and conditionals
  - Array-based calculation history

---

### Codelab 1.2: Object-Oriented Programming Complete

- **ID:** `oop-complete`
- **Duration:** 90 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Classes, fields, methods, constructors
  - Keywords: this, super, modifiers
  - Inheritance and `extends` keyword
  - Interfaces and `implements` keyword
  - Abstract classes and methods
  - Method overloading & overriding
  - Polymorphism
  - Packages and access modifiers
- **What Students Build:**
  - Complete banking system with Account hierarchy
  - Abstract Animal class with multiple interfaces (Flyable, Swimmable)
  - Multi-package structure (com.bank.accounts, com.bank.services)
  - Demonstrates inheritance, polymorphism, and encapsulation

---

### Codelab 1.3: Exception Handling & File I/O

- **ID:** `exception-handling-file-io`
- **Duration:** 75 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Exception hierarchy, try-catch-finally
  - Throws clause, throw keyword
  - Custom exceptions (checked & unchecked)
  - File class, FileReader, FileWriter
  - BufferedReader, BufferedWriter
  - Try-with-resources
  - File handling best practices
- **What Students Build:**
  - Contact management system with file-based storage
  - Custom exceptions: InvalidDataException, FileOperationException
  - CSV file operations with comprehensive error handling
  - Resource management and graceful error recovery

---

### Codelab 1.4: Collections Framework & Generics

- **ID:** `collections-generics`
- **Duration:** 75 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Collections Framework overview
  - List (ArrayList, LinkedList)
  - Set (HashSet, TreeSet, LinkedHashSet)
  - Map (HashMap, TreeMap, LinkedHashMap)
  - Queue (PriorityQueue)
  - Generics (type parameters, bounded types)
  - Comparable & Comparator interfaces
  - Iterator and enhanced for-loop
- **What Students Build:**
  - Inventory management system
  - Uses all major collection types appropriately
  - Generic utility classes
  - Custom sorting with Comparable and Comparator
  - Demonstrates type safety and collection operations

---

### Codelab 1.5: Memory Management & Garbage Collection

- **ID:** `memory-management`
- **Duration:** 45 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Heap vs Stack memory
  - Object lifecycle and garbage collection
  - GC algorithms overview
  - Memory leaks and prevention
  - JVM memory monitoring (jconsole, VisualVM)
  - Best practices for memory management
- **What Students Build:**
  - Memory profiling exercises
  - Identify and fix memory leak scenarios
  - Monitor GC behavior with tools
  - Performance optimization examples

---

## Section 2: Java 8 & Latest Features (7 hours)

**5 Codelabs - Standalone approach**

### Codelab 2.1: Functional Programming & Streams API

- **ID:** `functional-programming-streams`
- **Duration:** 90 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Functional programming paradigm
  - Lambda expressions syntax
  - Functional interfaces (Predicate, Function, Consumer, Supplier, BiFunction)
  - Method references (static, instance, constructor)
  - Stream creation and operations
  - Intermediate operations (filter, map, flatMap, sorted, distinct)
  - Terminal operations (collect, forEach, reduce, count)
  - Collectors class (toList, toSet, toMap, groupingBy, partitioningBy)
  - Parallel streams
- **What Students Build:**
  - Sales analytics application with functional style
  - Data filtering and transformation with lambdas
  - Complex aggregations and grouping with Streams
  - Performance comparison: imperative vs functional
  - Sequential vs parallel stream processing

---

### Codelab 2.2: Optional, Date/Time & Modern Java Features

- **ID:** `optional-datetime-modern-java`
- **Duration:** 90 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Optional class API (of, ofNullable, orElse, orElseThrow, map, flatMap)
  - Null safety patterns
  - LocalDate, LocalTime, LocalDateTime, ZonedDateTime
  - Period and Duration
  - Date formatting (DateTimeFormatter)
  - Temporal adjusters
  - Immutable collections (List.of, Set.of, Map.of)
  - Var keyword
  - Switch expressions
  - Text blocks
  - Records
  - Enhanced File APIs (Files.readString, writeString)
  - Collectors API enhancements
- **What Students Build:**
  - Conference scheduling system with time zones
  - User profile service with Optional null-safety
  - Configuration manager using Records and text blocks
  - Switch expressions for parsing
  - Immutable collections for data integrity

---

### Codelab 2.3: Asynchronous Programming Complete

- **ID:** `async-programming-complete`
- **Duration:** 90 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Callable vs Runnable
  - Future interface (get, isDone, cancel)
  - ExecutorService and thread pools
  - CompletableFuture creation (supplyAsync, runAsync)
  - CompletionStage interface
  - Chaining operations (thenApply, thenAccept, thenCompose)
  - Combining futures (thenCombine, allOf, anyOf)
  - Error handling (exceptionally, handle, whenComplete)
  - Timeouts (orTimeout, completeOnTimeout)
- **What Students Build:**
  - Multi-threaded data processor with Future
  - Microservice orchestration with CompletableFuture
  - Chain multiple async API calls
  - Fallback strategies and error handling
  - Compare blocking vs async approaches

---

### Codelab 2.4: Logging with Log4j

- **ID:** `logging-log4j`
- **Duration:** 60 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Logging importance and levels (TRACE, DEBUG, INFO, WARN, ERROR)
  - Log4j 2 architecture
  - Configuration (log4j2.xml, log4j2.properties)
  - Appenders (Console, File, RollingFile)
  - Layouts and patterns
  - Logger hierarchy
  - Best practices (parameterized messages, performance)
- **What Students Build:**
  - Add comprehensive logging to existing application
  - Configure multiple appenders with different levels
  - Structured log patterns with timestamps
  - Rolling file appender for production
  - Demonstrate logging best practices

---

### Codelab 2.5: IDE Debugging Mastery

- **ID:** `debugging-mastery`
- **Duration:** 90 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Breakpoints (line, method, conditional, exception)
  - Logpoints (non-breaking breakpoints)
  - Step In/Over/Out
  - Variables inspection and modification
  - Call stacks analysis
  - Threads and thread dumps
  - Debug console and expression evaluation
  - Hot code replace (hot swap)
  - Remote debugging setup
- **What Students Build:**
  - Debugging challenge: fix buggy application
  - Systematic debugging approach
  - Fix logic errors, NullPointerException, concurrency bugs
  - Use conditional breakpoints effectively
  - Remote debugging configuration
  - Hot code replace demonstration

---

## Section 3: Spring IOC & Beans (8 hours)

**8 Codelabs - Evolving project approach**

**Project:** Task Management API (grows through codelabs 3.1 to 3.8)

### Codelab 3.1: Spring Core, IoC, DI & Spring Boot Web

- **ID:** `spring-core-boot-web`
- **Duration:** 60 minutes
- **Type:** **PROJECT START** - Evolving
- **Topics Covered:**
  - Inversion of Control (IoC) concept
  - Dependency Injection patterns (constructor, setter, field)
  - Spring Container and ApplicationContext
  - @Component, @Service, @Repository, @Autowired
  - Spring MVC architecture
  - Spring Boot overview and auto-configuration
  - Embedded server setup
  - Application properties
- **What Students Build:**
  - Initialize Task Management project with Spring Boot
  - Create TaskService, TaskRepository beans
  - Demonstrate DI patterns
  - Add @RestController for basic endpoints
  - Configure application.properties
  - Understand Spring Boot starter dependencies

---

### Codelab 3.2: RESTful APIs, Swagger & Exception Handling

- **ID:** `rest-apis-swagger-exceptions`
- **Duration:** 60 minutes
- **Type:** Evolving (builds on 3.1)
- **Topics Covered:**
  - REST principles and HTTP methods
  - @GetMapping, @PostMapping, @PutMapping, @DeleteMapping
  - @RequestBody, @PathVariable, @RequestParam
  - HTTP status codes and ResponseEntity
  - Swagger/OpenAPI integration
  - @Operation, @ApiResponse annotations
  - @ControllerAdvice for global exception handling
  - Custom exceptions and error responses
- **What Students Build:**
  - Complete REST API for Task management (CRUD)
  - Integrate SpringDoc OpenAPI and Swagger UI
  - Document all endpoints
  - Implement global exception handling
  - Custom exceptions (TaskNotFoundException, InvalidTaskException)
  - ErrorResponse DTO

---

### Codelab 3.3: ORM Concepts & Spring Data JPA

- **ID:** `orm-spring-data-jpa`
- **Duration:** 60 minutes
- **Type:** Evolving (builds on 3.2)
- **Topics Covered:**
  - Object-Relational Mapping fundamentals
  - JPA (Java Persistence API) overview
  - Entity relationships
  - @Entity, @Table, @Id, @GeneratedValue, @Column
  - Spring Data JPA and Repository pattern
  - JpaRepository interface
  - Query methods (findBy, countBy)
  - @Query annotation for custom JPQL
  - Pagination and sorting (Pageable)
  - Database configuration (H2, MySQL, PostgreSQL)
- **What Students Build:**
  - Design and create Task entity with JPA annotations
  - Configure H2 in-memory database
  - Replace in-memory repository with JpaRepository
  - Custom finder methods
  - Add pagination to endpoints
  - Enable SQL logging

---

### Codelab 3.4: Advanced JPA Locking & Spring Security

- **ID:** `jpa-locking-security`
- **Duration:** 75 minutes
- **Type:** Evolving (builds on 3.3)
- **Topics Covered:**
  - Optimistic locking with @Version
  - Pessimistic locking (PESSIMISTIC_READ, PESSIMISTIC_WRITE)
  - Handling OptimisticLockException
  - Spring Security architecture
  - Authentication vs Authorization
  - In-memory authentication
  - PasswordEncoder (BCrypt)
  - Role-based access control (RBAC)
  - Method-level security (@PreAuthorize)
- **What Students Build:**
  - Add @Version field for optimistic locking
  - Test concurrent update scenarios
  - Secure Task API with Spring Security
  - Configure users with roles (USER, ADMIN)
  - Protect endpoints with role-based access
  - Configure CSRF for REST APIs

---

### Codelab 3.5: JWT Authentication & Spring Cloud

- **ID:** `jwt-spring-cloud`
- **Duration:** 75 minutes
- **Type:** Evolving (builds on 3.4)
- **Topics Covered:**
  - JWT (JSON Web Token) structure
  - Stateless authentication
  - Token generation and validation
  - Custom authentication filters
  - JWT libraries (jjwt)
  - Token expiration and refresh
  - Spring Cloud ecosystem overview
  - Config Server for externalized configuration
  - Service Discovery concepts (Eureka)
  - Declarative service communication with Feign
- **What Students Build:**
  - Replace Basic Auth with JWT authentication
  - Create /auth/login endpoint
  - Implement JwtAuthenticationFilter
  - Token refresh mechanism
  - Setup Config Server (side project)
  - Create User Service and integrate with Feign
  - @FeignClient interface for inter-service calls

---

### Codelab 3.6: Spring Boot Reactive Stack & R2DBC

- **ID:** `reactive-stack-r2dbc`
- **Duration:** 75 minutes
- **Type:** **NEW PROJECT** - Standalone
- **Topics Covered:**
  - Reactive programming concepts
  - Reactive Streams specification
  - Project Reactor (Mono, Flux)
  - Reactive operators (map, flatMap, filter, zip)
  - Backpressure handling
  - Spring WebFlux
  - Functional endpoints (RouterFunction)
  - R2DBC (Reactive Relational Database Connectivity)
  - Spring Data R2DBC
  - Reactive repositories (ReactiveCrudRepository)
  - DatabaseClient for custom queries
- **What Students Build:**
  - Build Task Notification Service (reactive)
  - WebFlux endpoints returning Flux/Mono
  - Reactive operators demonstration
  - Server-Sent Events (SSE)
  - PostgreSQL with R2DBC integration
  - Reactive CRUD operations
  - Performance comparison: blocking vs reactive

---

### Codelab 3.7: Spring Messaging with JMS

- **ID:** `spring-jms-messaging`
- **Duration:** 45 minutes
- **Type:** Integration (connects Task API and Notification Service)
- **Topics Covered:**
  - Messaging concepts (Point-to-Point, Pub-Sub)
  - JMS (Java Message Service) API
  - Message producers and consumers
  - @JmsListener annotation
  - JmsTemplate for sending messages
  - ActiveMQ Artemis setup
  - Message serialization (JSON)
  - Asynchronous processing benefits
- **What Students Build:**
  - Connect Task API and Notification Service via JMS
  - Send messages when tasks created/updated
  - @JmsListener in Notification Service
  - Configure embedded ActiveMQ Artemis
  - Message transformation
  - Error handling in listeners

---

### Codelab 3.8: Unit Testing & Remote Debugging

- **ID:** `testing-remote-debugging`
- **Duration:** 60 minutes
- **Type:** Applies to all previous codelabs
- **Topics Covered:**
  - Testing pyramid (unit, integration, E2E)
  - JUnit 5 (annotations, assertions, lifecycle)
  - Mockito (@Mock, @InjectMocks)
  - @SpringBootTest for integration tests
  - @WebMvcTest for controller tests
  - MockMvc for REST endpoint testing
  - @DataJpaTest for repository tests
  - TestContainers for database tests
  - Remote debugging configuration (JDWP)
  - Debugging deployed applications
- **What Students Build:**
  - Comprehensive test suite for Task API
  - Unit tests with mocked dependencies
  - Integration tests for repositories
  - Controller tests with MockMvc
  - End-to-end test scenarios
  - Remote debugging setup
  - Debug application in Docker
  - Test coverage analysis

---

## Section 4: Web Applications & Services (3 hours)

**2 Codelabs - Standalone/Comparative approach**

### Codelab 4.1: Microservices Architecture & Implementation

- **ID:** `microservices-architecture`
- **Duration:** 90 minutes
- **Type:** Standalone
- **Topics Covered:**
  - Web application architecture evolution
  - Monolithic architecture (pros, cons)
  - Microservices architecture (characteristics, trade-offs)
  - Service boundaries and decomposition
  - Data ownership and database per service
  - Service Registry and Discovery (Eureka Server/Client)
  - API Gateway pattern (Spring Cloud Gateway)
  - Load Balancing (Spring Cloud LoadBalancer)
  - Service-to-service communication (Feign)
  - Configuration management (Config Server)
  - Health checks and resilience
- **What Students Build:**
  - Design exercise: monolith to microservices conversion
  - Multi-service ecosystem:
    - **Eureka Server** - Service registry
    - **API Gateway** - Routing and load balancing
    - **Product Service** - Product management
    - **Order Service** - Order management (calls Product Service)
  - Services register with Eureka
  - Gateway routes requests
  - Test with Docker Compose

---

### Codelab 4.2: Java Servlets & Blocking vs Reactive Stacks

- **ID:** `servlets-blocking-reactive`
- **Duration:** 90 minutes
- **Type:** Standalone (Comparative)
- **Topics Covered:**
  - Servlet containers (Tomcat, Jetty)
  - Servlet API and lifecycle (init, service, destroy)
  - HttpServlet, HttpServletRequest, HttpServletResponse
  - Servlet mapping and filters
  - Understanding Spring's abstraction
  - Blocking I/O model (thread-per-request)
  - Non-blocking I/O model (event loop)
  - Spring MVC (Servlet/blocking stack)
  - Spring WebFlux (Reactive/non-blocking stack)
  - Performance characteristics
  - When to use blocking vs non-blocking
  - Spring 5 improvements
- **What Students Build:**

  - Raw servlet-based REST API (without Spring)
  - Create TaskServlet and AuthenticationFilter
  - Manual JSON parsing
  - Deploy to standalone Tomcat
  - Compare with Spring Boot abstraction
  - Build same API twice:
    1. **Blocking version** - Spring MVC + JDBC
    2. **Reactive version** - WebFlux + R2DBC
  - Load test both implementations
  - Compare metrics (throughput, latency, resource usage)
  - Analyze thread dumps
  - Determine best use cases for each

---

## Implementation Guide for Each Codelab

Each codelab should include:

### 1. Metadata Block

```markdown
Summary: Brief description of what students will learn

Id: unique-lowercase-identifier

Categories: Backend, Java, Spring Boot

Environments: Web

Status: Draft
```

### 2. Standard Sections

#### Introduction

- Learning objectives (3-5 bullet points)
- What students will build
- Prerequisites (what they should know)
- Estimated completion time

#### Prerequisites Step

- Required tools and versions
- Required knowledge from previous codelabs
- Starter code repository link
- Setup instructions

#### Main Content Steps (5-10 steps)

- Clear, action-oriented step titles
- Contextual introduction for each step
- Code examples with syntax highlighting
- Info boxes for tips and warnings
- Progressive complexity
- Verification checkpoints

#### Testing/Verification Step

- How to test what was built
- Expected output
- Common issues and troubleshooting

#### Conclusion Step

- Summary of what was learned
- Key takeaways (3-5 bullet points)
- Next steps
- Additional resources

### 3. Code Standards

- Follow Java naming conventions
- Proper package structure
- Comprehensive comments
- Error handling
- Logging where appropriate

### 4. Repository Structure

```
/section-1-core-java (5 codelabs)
  /codelab-1.1-java-fundamentals-control-flow
    /starter
    /solution
    README.md
  /codelab-1.2-oop-complete
    ...

/section-2-java8-features (5 codelabs)
  /codelab-2.1-functional-programming-streams
    ...

/section-3-spring-boot (8 codelabs)
  /task-management-api
    /codelab-3.1-spring-core-boot-web (branch)
    /codelab-3.2-rest-apis-swagger-exceptions (branch)
    ...
    README.md
  /reactive-notification-service
    ...

/section-4-microservices (2 codelabs)
  /microservices-ecosystem
    ...
```

---

## Supporting Materials

### 1. Master Troubleshooting Guide

- Common errors and solutions
- IDE setup issues
- Dependency conflicts
- Database connection problems
- Port already in use
- Spring context loading failures

### 2. Quick Reference Sheets

- Spring Boot annotations cheat sheet
- JPA annotations reference
- REST API design guidelines
- Testing annotations reference
- Git workflow for codelabs

### 3. Assessment Materials

- Quiz questions per section
- Coding challenges
- Code review rubrics
- Project evaluation criteria

### 4. Capstone Project (Optional)

**Multi-Service Task Management System**

- Task Management Service (from Section 3)
- User Management Service
- Notification Service (reactive)
- API Gateway
- Frontend (React/Angular)
- Features: Full authentication, real-time notifications, microservices, Docker deployment

### 5. Additional Resources

- Spring official documentation links
- Baeldung tutorials references
- YouTube playlists
- GitHub repos with examples
- Community forums

---

## Teaching Strategy

### Week-by-Week Breakdown (Example for 6-week intensive course)

- **Week 1:** Section 1 (Core Java) - All 5 codelabs (6 hours)
- **Week 2:** Section 2 (Java 8+) - All 5 codelabs (7 hours)
- **Weeks 3-4:** Section 3 (Spring Boot) - 4 codelabs per week (8 hours)
- **Week 5:** Section 4 (Microservices) - Both codelabs (3 hours)
- **Week 6:** Capstone project and final assessment

**Alternative 12-Week Pace:**

- **Weeks 1-2:** Section 1 - 2-3 codelabs per week
- **Weeks 3-4:** Section 2 - 2-3 codelabs per week
- **Weeks 5-9:** Section 3 - 1-2 codelabs per week
- **Weeks 10-11:** Section 4 - 1 codelab per week
- **Week 12:** Capstone project

### Live Session Topics

- Environment setup help
- Code review sessions
- Q&A on complex topics
- Live debugging demonstrations
- Architecture discussions
- Industry best practices

### Assessment Checkpoints

- End of Section 1: Java fundamentals quiz
- End of Section 2: Java 8+ coding challenge
- End of Section 3: Spring Boot API project submission
- End of Section 4: Microservices architecture presentation
- Final: Capstone project

---

## Success Criteria

Students completing this course should be able to:

1. Write clean, idiomatic Java code using modern features
2. Understand and apply OOP principles and design patterns
3. Build production-ready REST APIs with Spring Boot
4. Implement security, testing, and error handling
5. Work with databases using Spring Data JPA
6. Understand microservices architecture and trade-offs
7. Deploy applications with Docker
8. Debug and troubleshoot Spring Boot applications
9. Write comprehensive tests (unit, integration, E2E)
10. Apply best practices for enterprise Java development

---

## Notes for AI Expansion

When expanding each codelab, ensure:

- **Progressive complexity** - Each step builds on previous
- **Hands-on focus** - More code examples than theory
- **Real-world relevance** - Use practical scenarios
- **Clear instructions** - Step-by-step, no ambiguity
- **Verification points** - Students can check their work
- **Error scenarios** - Include common mistakes and fixes
- **Best practices** - Highlight industry standards
- **Time estimates** - Realistic for condensed format (already includes debugging buffer)
- **Code quality** - Production-ready, not just working
- **Documentation** - Comments, README, API docs
- **Combined topics** - Each codelab covers multiple related concepts efficiently

For the **evolving Task Management API** (Section 3, 8 codelabs):

- Each codelab builds on previous branch
- Clear git strategy (branch per codelab)
- Incremental feature additions
- Maintain backward compatibility where possible
- Comprehensive README updates per codelab
- Integration tests added progressively
- Faster progression - topics combined intelligently

**Condensed Format Notes:**

- **Section 1 (5 codelabs):** Combined related fundamentals - platform+control flow, complete OOP in one, exceptions+file I/O together
- **Section 2 (5 codelabs):** Merged functional programming+streams, Optional+datetime+modern features, combined async topics
- **Section 3 (8 codelabs):** Streamlined Spring topics by combining related concepts - Spring core+Boot together, REST+Swagger+exceptions in one, ORM+JPA together, locking+security combined
- **Section 4 (2 codelabs):** Architecture+implementation combined, servlets+blocking/reactive comparison in one

All 48 hours of content condensed to 24 hours while maintaining complete topic coverage.

---

**END OF COURSE PLAN**
