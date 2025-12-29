summary: Master logging with Log4j 2 including levels, configuration, appenders, patterns, and best practices by adding comprehensive logging to applications
id: logging-log4j
categories: Java, Logging, Log4j, Best Practices
environments: Web
status: Published
home url: /springboot_course/

# Logging with Log4j 2

## Introduction

Duration: 3:00

Logging is essential for monitoring, debugging, and maintaining applications in production. Log4j 2 is the most popular logging framework for Java, offering high performance and extensive configuration options.

### What You'll Learn

- **Logging Fundamentals:** Why logging matters
- **Logging Levels:** TRACE, DEBUG, INFO, WARN, ERROR, FATAL
- **Log4j 2 Architecture:** Loggers, Appenders, Layouts
- **Configuration:** XML and properties formats
- **Appenders:** Console, File, RollingFile
- **Patterns:** Custom log formatting
- **Best Practices:** Performance, security, structured logging
- **Integration:** Using with existing applications

### What You'll Build

Transform an existing application with:

- Multi-level logging strategy
- Console and file appenders
- Rolling file policies for production
- Custom log patterns with timestamps
- Async logging for performance
- MDC (Mapped Diagnostic Context) for request tracking

### Prerequisites

- Completed Codelab 1.3 (Exception Handling)
- Understanding of Maven or Gradle
- Basic Java application knowledge

## Why Logging Matters

Duration: 5:00

Logging is your window into application behavior, especially in production where debugging isn't possible.

### The Problem with System.out.println

```java
// Bad: Using System.out for logging
public class UserService {
    public User findUser(String id) {
        System.out.println("Finding user: " + id);
        User user = database.findById(id);
        System.out.println("Found user: " + user.getName());
        return user;
    }
}
```

**Problems:**

- ❌ No log levels (can't filter by severity)
- ❌ No timestamps
- ❌ Can't redirect to files
- ❌ No structured format
- ❌ Performance issues (synchronous)
- ❌ Hard to disable in production

### Proper Logging with Log4j

```java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class UserService {
    private static final Logger logger = LogManager.getLogger(UserService.class);

    public User findUser(String id) {
        logger.debug("Finding user with id: {}", id);

        try {
            User user = database.findById(id);
            logger.info("User found: id={}, name={}", user.getId(), user.getName());
            return user;
        } catch (Exception e) {
            logger.error("Failed to find user with id: {}", id, e);
            throw e;
        }
    }
}
```

**Benefits:**

- ✅ Log levels for filtering
- ✅ Automatic timestamps
- ✅ Multiple output destinations
- ✅ Structured, parseable format
- ✅ High performance
- ✅ Easy to configure

> aside positive
> **Production Ready:** Proper logging is non-negotiable for production applications. It's your primary tool for diagnosing issues after deployment.

### Common Use Cases

```java
// 1. Debugging during development
logger.debug("Request payload: {}", requestJson);

// 2. Tracking user actions
logger.info("User {} logged in successfully", username);

// 3. Warning about potential issues
logger.warn("API response time exceeded threshold: {}ms", responseTime);

// 4. Recording errors
logger.error("Payment processing failed for order {}", orderId, exception);

// 5. Security auditing
logger.info("Failed login attempt for user: {}", username);

// 6. Performance monitoring
long startTime = System.currentTimeMillis();
// ... operation ...
logger.info("Operation completed in {}ms", System.currentTimeMillis() - startTime);
```

## Logging Levels

Duration: 8:00

Log4j 2 provides six logging levels, ordered from most verbose to most severe.

### Level Hierarchy

```
ALL < TRACE < DEBUG < INFO < WARN < ERROR < FATAL < OFF
```

### TRACE - Finest Detail

```java
logger.trace("Entering method processOrder()");
logger.trace("Processing item: {}", item);
logger.trace("Loop iteration: {}", i);
```

**When to use:** Very detailed information, typically only enabled during development or deep troubleshooting.

### DEBUG - Diagnostic Information

```java
logger.debug("Database query: {}", sql);
logger.debug("Cache hit rate: {}", hitRate);
logger.debug("Request parameters: {}", params);
```

**When to use:** Information useful for debugging, typically disabled in production.

### INFO - General Information

```java
logger.info("Application started successfully");
logger.info("User {} created account", username);
logger.info("Processing batch of {} records", count);
```

**When to use:** Important events that happen during normal operation. Default production level.

### WARN - Warning Messages

```java
logger.warn("Database connection pool is 80% utilized");
logger.warn("API response time exceeded 2 seconds: {}ms", responseTime);
logger.warn("Deprecated method called: {}", methodName);
```

**When to use:** Potentially harmful situations that don't prevent operation but need attention.

### ERROR - Error Events

```java
logger.error("Failed to connect to database", exception);
logger.error("Payment processing failed for order {}", orderId, e);
logger.error("Invalid configuration: {}", configKey);
```

**When to use:** Error events that might still allow the application to continue running.

### FATAL - Critical Errors

```java
logger.fatal("Database is unreachable, shutting down", exception);
logger.fatal("Critical configuration missing: {}", requiredConfig);
```

**When to use:** Severe errors that will presumably lead the application to abort.

### Practical Example

```java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class OrderProcessor {
    private static final Logger logger = LogManager.getLogger(OrderProcessor.class);

    public void processOrder(Order order) {
        logger.trace("processOrder() called with orderId: {}", order.getId());
        logger.debug("Order details: {}", order);

        try {
            validateOrder(order);
            logger.info("Processing order {} for customer {}",
                order.getId(), order.getCustomerId());

            if (order.getAmount() > 10000) {
                logger.warn("High-value order detected: ${}", order.getAmount());
            }

            // Process order
            logger.info("Order {} processed successfully", order.getId());

        } catch (ValidationException e) {
            logger.error("Order validation failed: {}", order.getId(), e);
            throw e;
        } catch (Exception e) {
            logger.fatal("Critical error processing order {}", order.getId(), e);
            notifyAdministrators(e);
            throw e;
        }

        logger.trace("processOrder() completed");
    }
}
```

### Log Level Configuration

```xml
<!-- log4j2.xml -->
<Configuration>
    <Loggers>
        <!-- Root logger: INFO level -->
        <Root level="INFO">
            <AppenderRef ref="Console"/>
        </Root>

        <!-- Package-specific levels -->
        <Logger name="com.myapp.service" level="DEBUG"/>
        <Logger name="com.myapp.database" level="TRACE"/>
        <Logger name="org.springframework" level="WARN"/>
    </Loggers>
</Configuration>
```

> aside positive
> **Best Practice:** Use INFO as the default production level. Enable DEBUG or TRACE only for specific packages when troubleshooting.

## Log4j 2 Setup

Duration: 10:00

Let's set up Log4j 2 in a Java project.

### Maven Dependencies

```xml
<!-- pom.xml -->
<dependencies>
    <!-- Log4j 2 Core -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-core</artifactId>
        <version>2.21.1</version>
    </dependency>

    <!-- Log4j 2 API -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-api</artifactId>
        <version>2.21.1</version>
    </dependency>

    <!-- Optional: SLF4J Bridge (if using SLF4J) -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-slf4j-impl</artifactId>
        <version>2.21.1</version>
    </dependency>
</dependencies>
```

### Gradle Dependencies

```gradle
// build.gradle
dependencies {
    implementation 'org.apache.logging.log4j:log4j-core:2.21.1'
    implementation 'org.apache.logging.log4j:log4j-api:2.21.1'

    // Optional: SLF4J Bridge
    implementation 'org.apache.logging.log4j:log4j-slf4j-impl:2.21.1'
}
```

### Basic Configuration - log4j2.xml

Create `src/main/resources/log4j2.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Appenders>
        <!-- Console Appender -->
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
        </Console>
    </Appenders>

    <Loggers>
        <Root level="INFO">
            <AppenderRef ref="Console"/>
        </Root>
    </Loggers>
</Configuration>
```

### Alternative - log4j2.properties

Create `src/main/resources/log4j2.properties`:

```properties
# Root logger
rootLogger.level = INFO
rootLogger.appenderRef.console.ref = Console

# Console appender
appender.console.type = Console
appender.console.name = Console
appender.console.layout.type = PatternLayout
appender.console.layout.pattern = %d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n
```

### Basic Usage

```java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class Application {
    // Logger instance (one per class)
    private static final Logger logger = LogManager.getLogger(Application.class);

    public static void main(String[] args) {
        logger.info("Application starting...");

        try {
            // Application logic
            logger.debug("Debug information");
            logger.info("Processing complete");
        } catch (Exception e) {
            logger.error("Application error", e);
        }

        logger.info("Application shutting down");
    }
}
```

### Verify Setup

```console
$ mvn compile
$ mvn exec:java -Dexec.mainClass="Application"

14:30:45.123 [main] INFO  Application - Application starting...
14:30:45.456 [main] INFO  Application - Processing complete
14:30:45.789 [main] INFO  Application - Application shutting down
```

> aside negative
> **Important:** Place log4j2.xml (or log4j2.properties) in `src/main/resources` so it's included in the classpath.

## Appenders and Layouts

Duration: 12:00

Appenders control where logs go. Layouts control how they look.

### Console Appender

```xml
<Console name="Console" target="SYSTEM_OUT">
    <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss} %-5level %logger{36} - %msg%n"/>
</Console>
```

### File Appender

```xml
<File name="FileLogger" fileName="logs/application.log">
    <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss} [%t] %-5level %logger{36} - %msg%n"/>
</File>
```

### RollingFile Appender (Production)

```xml
<RollingFile name="RollingFile"
             fileName="logs/app.log"
             filePattern="logs/app-%d{yyyy-MM-dd}-%i.log.gz">

    <PatternLayout>
        <Pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n</Pattern>
    </PatternLayout>

    <Policies>
        <!-- Roll over daily -->
        <TimeBasedTriggeringPolicy />

        <!-- Roll over when file reaches 10 MB -->
        <SizeBasedTriggeringPolicy size="10 MB"/>
    </Policies>

    <!-- Keep 30 days of logs -->
    <DefaultRolloverStrategy max="30"/>
</RollingFile>
```

### Async Appender (High Performance)

```xml
<Async name="AsyncConsole">
    <AppenderRef ref="Console"/>
</Async>

<Async name="AsyncFile">
    <AppenderRef ref="RollingFile"/>
</Async>
```

### Pattern Layout Syntax

```
%d{yyyy-MM-dd HH:mm:ss.SSS} - Date/time
%t or %thread - Thread name
%-5level - Log level (left-justified, 5 chars)
%logger{36} - Logger name (max 36 chars)
%C or %class - Class name
%M or %method - Method name
%L or %line - Line number
%msg or %m - Log message
%n - New line
%ex or %throwable - Exception stack trace
%highlight{...} - Colored output
%X{key} - MDC value
```

### Custom Patterns

```xml
<!-- Simple pattern -->
<PatternLayout pattern="%d %level %msg%n"/>

<!-- Detailed pattern -->
<PatternLayout pattern="%d{ISO8601} [%t] %-5level %c{1}:%L - %msg%n"/>

<!-- Colored console output -->
<PatternLayout>
    <Pattern>%d{HH:mm:ss.SSS} %highlight{%-5level} %logger{36} - %msg%n</Pattern>
</PatternLayout>

<!-- JSON format -->
<JsonLayout complete="false" compact="true"/>
```

### Complete Configuration Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Properties>
        <Property name="LOG_PATTERN">
            %d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n
        </Property>
    </Properties>

    <Appenders>
        <!-- Console: Colored output for development -->
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout>
                <Pattern>%d{HH:mm:ss.SSS} %highlight{%-5level} %logger{36} - %msg%n</Pattern>
            </PatternLayout>
        </Console>

        <!-- File: All logs -->
        <RollingFile name="AllLogs"
                     fileName="logs/application.log"
                     filePattern="logs/application-%d{yyyy-MM-dd}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy />
                <SizeBasedTriggeringPolicy size="10MB"/>
            </Policies>
            <DefaultRolloverStrategy max="30"/>
        </RollingFile>

        <!-- File: Errors only -->
        <RollingFile name="ErrorLogs"
                     fileName="logs/error.log"
                     filePattern="logs/error-%d{yyyy-MM-dd}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy />
                <SizeBasedTriggeringPolicy size="10MB"/>
            </Policies>
            <DefaultRolloverStrategy max="90"/>
            <!-- Only ERROR and above -->
            <ThresholdFilter level="ERROR" onMatch="ACCEPT" onMismatch="DENY"/>
        </RollingFile>

        <!-- Async wrappers for performance -->
        <Async name="AsyncConsole">
            <AppenderRef ref="Console"/>
        </Async>

        <Async name="AsyncAllLogs">
            <AppenderRef ref="AllLogs"/>
        </Async>

        <Async name="AsyncErrorLogs">
            <AppenderRef ref="ErrorLogs"/>
        </Async>
    </Appenders>

    <Loggers>
        <!-- Application loggers -->
        <Logger name="com.myapp" level="DEBUG" additivity="false">
            <AppenderRef ref="AsyncConsole"/>
            <AppenderRef ref="AsyncAllLogs"/>
            <AppenderRef ref="AsyncErrorLogs"/>
        </Logger>

        <!-- Third-party libraries -->
        <Logger name="org.springframework" level="INFO"/>
        <Logger name="org.hibernate" level="WARN"/>

        <!-- Root logger -->
        <Root level="INFO">
            <AppenderRef ref="AsyncConsole"/>
            <AppenderRef ref="AsyncAllLogs"/>
        </Root>
    </Loggers>
</Configuration>
```

## Logging Best Practices

Duration: 10:00

### 1. Parameterized Logging

```java
// Bad: String concatenation (always evaluated)
logger.debug("User details: " + user.toString());

// Good: Parameterized (only evaluated if DEBUG enabled)
logger.debug("User details: {}", user);

// Multiple parameters
logger.info("User {} logged in from IP {} at {}", username, ipAddress, timestamp);
```

### 2. Guard Expensive Operations

```java
// If the operation is expensive
if (logger.isDebugEnabled()) {
    String expensiveString = generateDetailedReport();
    logger.debug("Report: {}", expensiveString);
}

// Modern approach with Supplier (Java 8+)
logger.debug("Report: {}", () -> generateDetailedReport());
```

### 3. Log Exceptions Properly

```java
// Bad: Loses stack trace
logger.error("Error occurred: " + e.getMessage());

// Good: Includes full exception
logger.error("Failed to process order {}", orderId, e);

// With context
try {
    processOrder(order);
} catch (ValidationException e) {
    logger.error("Order validation failed: orderId={}, customerId={}",
        order.getId(), order.getCustomerId(), e);
}
```

### 4. Avoid Logging Sensitive Data

```java
// Bad: Logs password!
logger.info("User login: username={}, password={}", username, password);

// Good: Mask or omit sensitive data
logger.info("User login: username={}", username);

// Good: Sanitized data
logger.info("Credit card payment: cardNumber={}", maskCardNumber(cardNumber));

private String maskCardNumber(String cardNumber) {
    return "**** **** **** " + cardNumber.substring(cardNumber.length() - 4);
}
```

### 5. Use Appropriate Log Levels

```java
public class OrderService {
    private static final Logger logger = LogManager.getLogger(OrderService.class);

    public void processOrder(Order order) {
        // DEBUG: Detailed information for troubleshooting
        logger.debug("Processing order: {}", order);

        // INFO: Important business events
        logger.info("Order {} submitted by customer {}",
            order.getId(), order.getCustomerId());

        // WARN: Potential issues
        if (order.getAmount() > 10000) {
            logger.warn("High-value order: orderId={}, amount={}",
                order.getId(), order.getAmount());
        }

        try {
            chargeCustomer(order);
        } catch (PaymentException e) {
            // ERROR: Recoverable errors
            logger.error("Payment failed for order {}", order.getId(), e);
            throw e;
        } catch (Exception e) {
            // FATAL: Critical errors
            logger.fatal("Unexpected error processing order {}", order.getId(), e);
            throw e;
        }
    }
}
```

### 6. Structured Logging with MDC

```java
import org.apache.logging.log4j.ThreadContext;

public class RequestFilter {
    public void doFilter(HttpServletRequest request) {
        // Add context to all logs in this thread
        ThreadContext.put("requestId", UUID.randomUUID().toString());
        ThreadContext.put("userId", request.getUserId());
        ThreadContext.put("ipAddress", request.getRemoteAddr());

        try {
            // All logs will include this context
            processRequest(request);
        } finally {
            // Clean up
            ThreadContext.clearAll();
        }
    }
}

// Access MDC in pattern
// Pattern: %d [%X{requestId}] [%X{userId}] %-5level %logger - %msg%n
```

### 7. Performance Considerations

```java
// Use async appenders for high-throughput applications
<Async name="AsyncFile">
    <AppenderRef ref="RollingFile"/>
</Async>

// Avoid logging in tight loops
for (int i = 0; i < 1000000; i++) {
    // Bad: Creates 1 million log entries
    logger.debug("Processing item {}", i);
}

// Better: Log summary
logger.debug("Processing {} items", items.size());
// Log first/last or sampling
if (i % 1000 == 0) {
    logger.debug("Processed {} items so far", i);
}
```

### 8. Don't Log and Throw

```java
// Bad: Double logging
try {
    processData();
} catch (Exception e) {
    logger.error("Error processing data", e);
    throw e;  // Caller will log again!
}

// Good: Log OR throw, not both
try {
    processData();
} catch (Exception e) {
    // Either log and handle
    logger.error("Error processing data, using fallback", e);
    return fallbackValue;

    // OR just throw (let caller decide what to log)
    throw new ProcessingException("Failed to process data", e);
}
```

## Build Logged Application

Duration: 10:00

Let's add comprehensive logging to a complete application!

Create `BankingApplication.java`:

```java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.ThreadContext;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.*;

class Transaction {
    private String id;
    private String accountId;
    private BigDecimal amount;
    private String type;
    private LocalDateTime timestamp;

    public Transaction(String id, String accountId, BigDecimal amount, String type) {
        this.id = id;
        this.accountId = accountId;
        this.amount = amount;
        this.type = type;
        this.timestamp = LocalDateTime.now();
    }

    // Getters
    public String getId() { return id; }
    public String getAccountId() { return accountId; }
    public BigDecimal getAmount() { return amount; }
    public String getType() { return type; }
    public LocalDateTime getTimestamp() { return timestamp; }

    @Override
    public String toString() {
        return String.format("Transaction{id='%s', account='%s', amount=%s, type='%s'}",
            id, accountId, amount, type);
    }
}

class Account {
    private String id;
    private String customerId;
    private BigDecimal balance;

    public Account(String id, String customerId, BigDecimal balance) {
        this.id = id;
        this.customerId = customerId;
        this.balance = balance;
    }

    // Getters and setters
    public String getId() { return id; }
    public String getCustomerId() { return customerId; }
    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal balance) { this.balance = balance; }
}

class TransactionService {
    private static final Logger logger = LogManager.getLogger(TransactionService.class);
    private final Map<String, Account> accounts = new ConcurrentHashMap<>();

    public TransactionService() {
        // Initialize with sample accounts
        accounts.put("ACC001", new Account("ACC001", "CUST001", new BigDecimal("10000")));
        accounts.put("ACC002", new Account("ACC002", "CUST002", new BigDecimal("5000")));
        logger.info("TransactionService initialized with {} accounts", accounts.size());
    }

    public Transaction processTransaction(Transaction transaction) {
        String txnId = transaction.getId();

        // Add transaction context to all logs
        ThreadContext.put("transactionId", txnId);
        ThreadContext.put("accountId", transaction.getAccountId());

        logger.info("Processing transaction: type={}, amount={}",
            transaction.getType(), transaction.getAmount());

        try {
            // Validate transaction
            validateTransaction(transaction);

            // Process based on type
            switch (transaction.getType()) {
                case "DEPOSIT":
                    processDeposit(transaction);
                    break;
                case "WITHDRAWAL":
                    processWithdrawal(transaction);
                    break;
                case "TRANSFER":
                    processTransfer(transaction);
                    break;
                default:
                    logger.error("Unknown transaction type: {}", transaction.getType());
                    throw new IllegalArgumentException("Unknown transaction type");
            }

            logger.info("Transaction processed successfully: {}", txnId);
            return transaction;

        } catch (InsufficientFundsException e) {
            logger.warn("Transaction failed - insufficient funds: txnId={}, required={}, available={}",
                txnId, transaction.getAmount(), e.getAvailableBalance());
            throw e;
        } catch (Exception e) {
            logger.error("Transaction processing failed: txnId={}", txnId, e);
            throw e;
        } finally {
            ThreadContext.clearAll();
        }
    }

    private void validateTransaction(Transaction transaction) {
        logger.debug("Validating transaction: {}", transaction.getId());

        if (transaction.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            logger.error("Invalid transaction amount: {}", transaction.getAmount());
            throw new IllegalArgumentException("Amount must be positive");
        }

        Account account = accounts.get(transaction.getAccountId());
        if (account == null) {
            logger.error("Account not found: {}", transaction.getAccountId());
            throw new IllegalArgumentException("Account not found");
        }

        logger.debug("Transaction validation passed");
    }

    private void processDeposit(Transaction transaction) {
        logger.debug("Processing deposit");

        Account account = accounts.get(transaction.getAccountId());
        BigDecimal oldBalance = account.getBalance();
        BigDecimal newBalance = oldBalance.add(transaction.getAmount());

        account.setBalance(newBalance);

        logger.info("Deposit completed: account={}, oldBalance={}, newBalance={}, amount={}",
            account.getId(), oldBalance, newBalance, transaction.getAmount());

        if (transaction.getAmount().compareTo(new BigDecimal("10000")) > 0) {
            logger.warn("Large deposit detected: amount={}, account={}",
                transaction.getAmount(), account.getId());
        }
    }

    private void processWithdrawal(Transaction transaction) {
        logger.debug("Processing withdrawal");

        Account account = accounts.get(transaction.getAccountId());
        BigDecimal oldBalance = account.getBalance();

        if (oldBalance.compareTo(transaction.getAmount()) < 0) {
            logger.warn("Insufficient funds: requested={}, available={}",
                transaction.getAmount(), oldBalance);
            throw new InsufficientFundsException("Insufficient funds", oldBalance);
        }

        BigDecimal newBalance = oldBalance.subtract(transaction.getAmount());
        account.setBalance(newBalance);

        logger.info("Withdrawal completed: account={}, oldBalance={}, newBalance={}, amount={}",
            account.getId(), oldBalance, newBalance, transaction.getAmount());

        if (newBalance.compareTo(new BigDecimal("1000")) < 0) {
            logger.warn("Low balance alert: account={}, balance={}",
                account.getId(), newBalance);
        }
    }

    private void processTransfer(Transaction transaction) {
        logger.debug("Processing transfer");
        logger.info("Transfer not yet implemented");
        throw new UnsupportedOperationException("Transfer not implemented");
    }

    public Account getAccount(String accountId) {
        logger.debug("Retrieving account: {}", accountId);
        return accounts.get(accountId);
    }
}

class InsufficientFundsException extends RuntimeException {
    private final BigDecimal availableBalance;

    public InsufficientFundsException(String message, BigDecimal availableBalance) {
        super(message);
        this.availableBalance = availableBalance;
    }

    public BigDecimal getAvailableBalance() {
        return availableBalance;
    }
}

public class BankingApplication {
    private static final Logger logger = LogManager.getLogger(BankingApplication.class);

    public static void main(String[] args) {
        logger.info("=".repeat(60));
        logger.info("Banking Application Starting");
        logger.info("=".repeat(60));

        TransactionService transactionService = new TransactionService();

        // Test scenarios
        try {
            // Scenario 1: Successful deposit
            logger.info("\n--- Scenario 1: Successful Deposit ---");
            Transaction deposit = new Transaction("TXN001", "ACC001",
                new BigDecimal("1000"), "DEPOSIT");
            transactionService.processTransaction(deposit);

            // Scenario 2: Successful withdrawal
            logger.info("\n--- Scenario 2: Successful Withdrawal ---");
            Transaction withdrawal = new Transaction("TXN002", "ACC001",
                new BigDecimal("500"), "WITHDRAWAL");
            transactionService.processTransaction(withdrawal);

            // Scenario 3: Large deposit (warning)
            logger.info("\n--- Scenario 3: Large Deposit ---");
            Transaction largeDeposit = new Transaction("TXN003", "ACC002",
                new BigDecimal("15000"), "DEPOSIT");
            transactionService.processTransaction(largeDeposit);

            // Scenario 4: Insufficient funds
            logger.info("\n--- Scenario 4: Insufficient Funds ---");
            Transaction overdraft = new Transaction("TXN004", "ACC002",
                new BigDecimal("50000"), "WITHDRAWAL");
            try {
                transactionService.processTransaction(overdraft);
            } catch (InsufficientFundsException e) {
                logger.info("Transaction rejected as expected");
            }

            // Scenario 5: Invalid transaction
            logger.info("\n--- Scenario 5: Invalid Transaction ---");
            Transaction invalid = new Transaction("TXN005", "ACC999",
                new BigDecimal("100"), "DEPOSIT");
            try {
                transactionService.processTransaction(invalid);
            } catch (IllegalArgumentException e) {
                logger.info("Invalid transaction rejected as expected");
            }

            // Display final balances
            logger.info("\n--- Final Account Balances ---");
            Account acc1 = transactionService.getAccount("ACC001");
            Account acc2 = transactionService.getAccount("ACC002");
            logger.info("Account {}: Balance = {}", acc1.getId(), acc1.getBalance());
            logger.info("Account {}: Balance = {}", acc2.getId(), acc2.getBalance());

        } catch (Exception e) {
            logger.fatal("Application encountered a fatal error", e);
            System.exit(1);
        }

        logger.info("\n" + "=".repeat(60));
        logger.info("Banking Application Completed Successfully");
        logger.info("=".repeat(60));
    }
}
```

### Create log4j2.xml Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Properties>
        <Property name="LOG_PATTERN">
            %d{yyyy-MM-dd HH:mm:ss.SSS} [%X{transactionId}] [%t] %-5level %logger{36} - %msg%n
        </Property>
    </Properties>

    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout>
                <Pattern>%d{HH:mm:ss.SSS} %highlight{%-5level} [%X{transactionId}] %logger{36} - %msg%n</Pattern>
            </PatternLayout>
        </Console>

        <RollingFile name="AppLog"
                     fileName="logs/banking-app.log"
                     filePattern="logs/banking-app-%d{yyyy-MM-dd}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy />
                <SizeBasedTriggeringPolicy size="10MB"/>
            </Policies>
            <DefaultRolloverStrategy max="30"/>
        </RollingFile>

        <RollingFile name="ErrorLog"
                     fileName="logs/banking-error.log"
                     filePattern="logs/banking-error-%d{yyyy-MM-dd}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy />
                <SizeBasedTriggeringPolicy size="10MB"/>
            </Policies>
            <DefaultRolloverStrategy max="90"/>
            <ThresholdFilter level="WARN" onMatch="ACCEPT" onMismatch="DENY"/>
        </RollingFile>

        <RollingFile name="TransactionLog"
                     fileName="logs/transactions.log"
                     filePattern="logs/transactions-%d{yyyy-MM-dd}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy />
                <SizeBasedTriggeringPolicy size="10MB"/>
            </Policies>
            <DefaultRolloverStrategy max="365"/>
        </RollingFile>
    </Appenders>

    <Loggers>
        <Logger name="TransactionService" level="DEBUG" additivity="false">
            <AppenderRef ref="Console"/>
            <AppenderRef ref="AppLog"/>
            <AppenderRef ref="ErrorLog"/>
            <AppenderRef ref="TransactionLog"/>
        </Logger>

        <Root level="INFO">
            <AppenderRef ref="Console"/>
            <AppenderRef ref="AppLog"/>
            <AppenderRef ref="ErrorLog"/>
        </Root>
    </Loggers>
</Configuration>
```

### Run and Observe

```console
$ mvn compile
$ mvn exec:java -Dexec.mainClass="BankingApplication"

14:30:45.123 INFO  [main] BankingApplication - ============================================================
14:30:45.124 INFO  [main] BankingApplication - Banking Application Starting
14:30:45.125 INFO  [main] BankingApplication - ============================================================
14:30:45.126 INFO  [main] TransactionService - TransactionService initialized with 2 accounts
14:30:45.127 INFO  [main] BankingApplication -
--- Scenario 1: Successful Deposit ---
14:30:45.128 INFO  [TXN001] [main] TransactionService - Processing transaction: type=DEPOSIT, amount=1000
...
```

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered logging with Log4j 2!

### What You've Learned

- ✅ **Logging Levels:** TRACE, DEBUG, INFO, WARN, ERROR, FATAL
- ✅ **Log4j 2 Architecture:** Loggers, Appenders, Layouts
- ✅ **Configuration:** XML and properties formats
- ✅ **Appenders:** Console, File, RollingFile, Async
- ✅ **Patterns:** Custom formatting with timestamps and context
- ✅ **MDC:** Mapped Diagnostic Context for request tracking
- ✅ **Best Practices:** Performance, security, structured logging
- ✅ **Production Setup:** Rolling files, log retention, async logging

### Key Takeaways

1. **Never use System.out** for production logging
2. **Use appropriate log levels** - INFO for production default
3. **Parameterized logging** prevents unnecessary string operations
4. **Always log exceptions** with full stack traces
5. **Never log sensitive data** (passwords, credit cards, etc.)
6. **Use MDC** for request/transaction tracking
7. **Async appenders** improve performance
8. **Rolling files** prevent disk space issues

### Production Checklist

- ✅ Use RollingFile appenders with size/time policies
- ✅ Configure log retention (30-90 days typical)
- ✅ Separate error logs for monitoring
- ✅ Use async appenders for high-throughput
- ✅ Set appropriate log levels per package
- ✅ Include MDC context for tracing
- ✅ Implement log rotation and archiving
- ✅ Monitor log file sizes and disk usage

### Next Steps

Continue to:

- **Codelab 2.5:** IDE Debugging Mastery
- **Codelab 3.1:** Spring Boot (which integrates with Log4j 2)
- **Codelab 4.1:** Microservices with distributed tracing

### Additional Resources

- [Log4j 2 Documentation](https://logging.apache.org/log4j/2.x/)
- [Log4j 2 Configuration](https://logging.apache.org/log4j/2.x/manual/configuration.html)
- [Log4j 2 Performance](https://logging.apache.org/log4j/2.x/performance.html)
- [12-Factor App: Logs](https://12factor.net/logs)

> aside positive
> **Production Ready!** Proper logging is essential for production systems. You now have the skills to implement enterprise-grade logging in any Java application!
