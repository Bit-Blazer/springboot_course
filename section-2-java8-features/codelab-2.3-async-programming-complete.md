summary: Master asynchronous programming with Callable, Future, ExecutorService, and CompletableFuture by building a multi-threaded data processing system
id: async-programming-complete
categories: Java, Asynchronous Programming, Concurrency, CompletableFuture
environments: Web
status: Published

# Asynchronous Programming Complete

## Introduction

Duration: 5:00

Asynchronous programming enables efficient use of system resources by allowing tasks to run concurrently without blocking. Modern Java provides powerful tools for writing non-blocking, reactive code.

### What You'll Learn

- **Threading Basics:** Runnable vs Callable
- **Future Interface:** get(), isDone(), cancel()
- **ExecutorService:** Thread pools and management
- **CompletableFuture:** Modern async programming
- **Chaining Operations:** thenApply, thenAccept, thenCompose
- **Combining Futures:** thenCombine, allOf, anyOf
- **Error Handling:** exceptionally, handle, whenComplete
- **Timeouts:** orTimeout, completeOnTimeout
- **Best Practices:** Thread safety and performance

### What You'll Build

A comprehensive **Multi-threaded Data Processing System** featuring:

- Parallel data fetching from multiple sources
- Async API calls with CompletableFuture
- Chained transformations and aggregations
- Error handling and fallback strategies
- Performance comparison: blocking vs async
- Real-world microservice orchestration example

### Prerequisites

- Completed Codelab 2.1 (Functional Programming & Streams)
- Understanding of lambdas and functional interfaces
- Basic knowledge of threads

## Threading Basics

Duration: 10:00

Before diving into async programming, let's understand the foundation: threads and executors.

### Runnable vs Callable

**Runnable - No Return Value:**

```java
// Old way: Anonymous class
Runnable task1 = new Runnable() {
    @Override
    public void run() {
        System.out.println("Running in thread: " +
            Thread.currentThread().getName());
    }
};

// Modern way: Lambda
Runnable task2 = () -> {
    System.out.println("Running in thread: " +
        Thread.currentThread().getName());
};

// Execute
Thread thread = new Thread(task2);
thread.start();
```

**Callable - Returns Value, Can Throw Exception:**

```java
import java.util.concurrent.Callable;

// Callable returns a value
Callable<Integer> task = () -> {
    Thread.sleep(1000);
    return 42;
};

// Callable can throw checked exceptions
Callable<String> fetchData = () -> {
    if (Math.random() > 0.5) {
        throw new IOException("Network error");
    }
    return "Data fetched";
};
```

> aside positive
> **Key Difference:** Use Runnable for fire-and-forget tasks. Use Callable when you need a result or might throw exceptions.

### Creating and Managing Threads

```java
public class ThreadBasics {
    public static void main(String[] args) throws InterruptedException {
        // Method 1: Extend Thread
        Thread t1 = new Thread() {
            @Override
            public void run() {
                System.out.println("Thread 1");
            }
        };

        // Method 2: Implement Runnable
        Runnable task = () -> System.out.println("Thread 2");
        Thread t2 = new Thread(task);

        // Start threads
        t1.start();
        t2.start();

        // Wait for completion
        t1.join();
        t2.join();

        System.out.println("All threads completed");
    }
}
```

### Thread States

```java
public class ThreadStates {
    public static void main(String[] args) throws InterruptedException {
        Thread thread = new Thread(() -> {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        System.out.println("State: " + thread.getState());  // NEW

        thread.start();
        System.out.println("State: " + thread.getState());  // RUNNABLE

        Thread.sleep(100);
        System.out.println("State: " + thread.getState());  // TIMED_WAITING

        thread.join();
        System.out.println("State: " + thread.getState());  // TERMINATED
    }
}
```

> aside negative
> **Warning:** Creating threads directly is expensive and doesn't scale. Use thread pools (ExecutorService) for production code.

## ExecutorService and Thread Pools

Duration: 12:00

ExecutorService manages a pool of threads, reusing them efficiently.

### Creating Executors

```java
import java.util.concurrent.*;

// Fixed thread pool (n threads)
ExecutorService executor1 = Executors.newFixedThreadPool(4);

// Cached thread pool (creates threads as needed)
ExecutorService executor2 = Executors.newCachedThreadPool();

// Single thread executor (sequential execution)
ExecutorService executor3 = Executors.newSingleThreadExecutor();

// Scheduled executor (for periodic tasks)
ScheduledExecutorService executor4 = Executors.newScheduledThreadPool(2);

// Always shutdown when done!
executor1.shutdown();
```

### Submitting Tasks

```java
import java.util.concurrent.*;

public class ExecutorDemo {
    public static void main(String[] args) throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(3);

        // Submit Runnable (no return value)
        executor.submit(() -> {
            System.out.println("Task 1 in " + Thread.currentThread().getName());
        });

        // Submit Callable (returns Future)
        Future<Integer> future = executor.submit(() -> {
            Thread.sleep(1000);
            return 42;
        });

        // Get result (blocks until complete)
        Integer result = future.get();
        System.out.println("Result: " + result);

        // Submit multiple tasks
        for (int i = 0; i < 5; i++) {
            final int taskId = i;
            executor.submit(() -> {
                System.out.println("Task " + taskId + " executed");
            });
        }

        // Shutdown executor
        executor.shutdown();
        executor.awaitTermination(5, TimeUnit.SECONDS);
    }
}
```

### Future Interface

```java
import java.util.concurrent.*;

public class FutureExample {
    public static void main(String[] args) throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(2);

        // Submit long-running task
        Future<String> future = executor.submit(() -> {
            Thread.sleep(3000);
            return "Task completed";
        });

        // Check if done (non-blocking)
        System.out.println("Is done? " + future.isDone());  // false

        // Do other work while task runs
        System.out.println("Doing other work...");
        Thread.sleep(1000);

        // Check again
        System.out.println("Is done? " + future.isDone());  // false

        // Get result (blocks until complete)
        System.out.println("Waiting for result...");
        String result = future.get();  // Blocks here
        System.out.println("Result: " + result);

        // Get with timeout
        Future<String> future2 = executor.submit(() -> {
            Thread.sleep(5000);
            return "Slow task";
        });

        try {
            String result2 = future2.get(2, TimeUnit.SECONDS);
        } catch (TimeoutException e) {
            System.out.println("Task timed out!");
            future2.cancel(true);  // Cancel the task
        }

        executor.shutdown();
    }
}
```

### InvokeAll and InvokeAny

```java
import java.util.*;
import java.util.concurrent.*;

public class BulkOperations {
    public static void main(String[] args) throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(4);

        // Create multiple tasks
        List<Callable<Integer>> tasks = Arrays.asList(
            () -> { Thread.sleep(1000); return 1; },
            () -> { Thread.sleep(2000); return 2; },
            () -> { Thread.sleep(1500); return 3; }
        );

        // invokeAll: Execute all, wait for all
        List<Future<Integer>> futures = executor.invokeAll(tasks);
        for (Future<Integer> future : futures) {
            System.out.println("Result: " + future.get());
        }

        // invokeAny: Execute all, return first completed
        Integer firstResult = executor.invokeAny(tasks);
        System.out.println("First result: " + firstResult);

        executor.shutdown();
    }
}
```

### Practical Example: Parallel Processing

```java
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.*;

public class ParallelProcessor {
    public static void main(String[] args) throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(4);

        // Process 100 items in parallel
        List<Integer> items = IntStream.rangeClosed(1, 100)
            .boxed()
            .collect(Collectors.toList());

        long start = System.currentTimeMillis();

        List<Future<Integer>> futures = new ArrayList<>();
        for (Integer item : items) {
            Future<Integer> future = executor.submit(() -> processItem(item));
            futures.add(future);
        }

        // Collect results
        List<Integer> results = new ArrayList<>();
        for (Future<Integer> future : futures) {
            results.add(future.get());
        }

        long end = System.currentTimeMillis();

        System.out.println("Processed " + results.size() + " items");
        System.out.println("Time taken: " + (end - start) + "ms");

        executor.shutdown();
    }

    private static Integer processItem(Integer item) throws InterruptedException {
        Thread.sleep(100);  // Simulate work
        return item * 2;
    }
}
```

## CompletableFuture Basics

Duration: 15:00

CompletableFuture is a powerful async programming tool introduced in Java 8, enhanced in later versions.

### Creating CompletableFuture

```java
import java.util.concurrent.CompletableFuture;

// 1. Already completed future
CompletableFuture<String> completed = CompletableFuture.completedFuture("Hello");
System.out.println(completed.join());  // Hello

// 2. Run async (no return value)
CompletableFuture<Void> async1 = CompletableFuture.runAsync(() -> {
    System.out.println("Running in: " + Thread.currentThread().getName());
});

// 3. Supply async (returns value)
CompletableFuture<String> async2 = CompletableFuture.supplyAsync(() -> {
    return "Result from async task";
});

String result = async2.join();  // or .get()
System.out.println(result);

// 4. With custom executor
ExecutorService executor = Executors.newFixedThreadPool(4);
CompletableFuture<String> async3 = CompletableFuture.supplyAsync(() -> {
    return "Custom executor result";
}, executor);
```

### Basic Chaining

```java
import java.util.concurrent.CompletableFuture;

public class ChainingDemo {
    public static void main(String[] args) {
        // thenApply: Transform result
        CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> 5)
            .thenApply(n -> n * 2)      // 10
            .thenApply(n -> n + 3);     // 13

        System.out.println(future.join());  // 13

        // thenAccept: Consume result (no return)
        CompletableFuture.supplyAsync(() -> "Hello")
            .thenApply(String::toUpperCase)
            .thenAccept(s -> System.out.println("Result: " + s));

        // thenRun: Execute action (no input, no output)
        CompletableFuture.supplyAsync(() -> "Done")
            .thenRun(() -> System.out.println("Task completed"));

        // Async variants
        CompletableFuture.supplyAsync(() -> "Data")
            .thenApplyAsync(String::toUpperCase)  // Runs in separate thread
            .thenAcceptAsync(System.out::println);
    }
}
```

### Combining CompletableFutures

```java
import java.util.concurrent.CompletableFuture;

public class CombiningFutures {
    public static void main(String[] args) {
        // thenCompose: Flatten nested futures
        CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> "User123")
            .thenCompose(userId -> fetchUserDetails(userId));

        System.out.println(future1.join());

        // thenCombine: Combine two independent futures
        CompletableFuture<Integer> age = CompletableFuture.supplyAsync(() -> 25);
        CompletableFuture<String> name = CompletableFuture.supplyAsync(() -> "Alice");

        CompletableFuture<String> combined = age.thenCombine(name, (a, n) -> {
            return n + " is " + a + " years old";
        });

        System.out.println(combined.join());

        // allOf: Wait for all futures
        CompletableFuture<String> f1 = CompletableFuture.supplyAsync(() -> "Task1");
        CompletableFuture<String> f2 = CompletableFuture.supplyAsync(() -> "Task2");
        CompletableFuture<String> f3 = CompletableFuture.supplyAsync(() -> "Task3");

        CompletableFuture<Void> all = CompletableFuture.allOf(f1, f2, f3);
        all.join();  // Wait for all to complete

        System.out.println("All tasks completed!");
        System.out.println(f1.join() + ", " + f2.join() + ", " + f3.join());

        // anyOf: Wait for first completed
        CompletableFuture<Object> first = CompletableFuture.anyOf(f1, f2, f3);
        System.out.println("First completed: " + first.join());
    }

    static CompletableFuture<String> fetchUserDetails(String userId) {
        return CompletableFuture.supplyAsync(() -> {
            // Simulate API call
            return "User details for " + userId;
        });
    }
}
```

### Error Handling

```java
import java.util.concurrent.CompletableFuture;

public class ErrorHandling {
    public static void main(String[] args) {
        // exceptionally: Handle errors
        CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> {
            if (Math.random() > 0.5) {
                throw new RuntimeException("Something went wrong!");
            }
            return "Success";
        }).exceptionally(ex -> {
            System.out.println("Error: " + ex.getMessage());
            return "Default value";
        });

        System.out.println(future1.join());

        // handle: Handle both success and error
        CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> {
            if (Math.random() > 0.5) {
                throw new RuntimeException("Error!");
            }
            return "Success";
        }).handle((result, ex) -> {
            if (ex != null) {
                return "Error occurred: " + ex.getMessage();
            }
            return result;
        });

        System.out.println(future2.join());

        // whenComplete: Side effect (doesn't transform)
        CompletableFuture.supplyAsync(() -> "Data")
            .whenComplete((result, ex) -> {
                if (ex != null) {
                    System.out.println("Failed: " + ex.getMessage());
                } else {
                    System.out.println("Succeeded: " + result);
                }
            });
    }
}
```

### Timeouts (Java 9+)

```java
import java.util.concurrent.*;

public class TimeoutDemo {
    public static void main(String[] args) {
        // orTimeout: Fail if not completed in time
        CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return "Slow result";
        }).orTimeout(2, TimeUnit.SECONDS)
          .exceptionally(ex -> "Timeout!");

        System.out.println(future1.join());

        // completeOnTimeout: Provide default if timeout
        CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return "Slow result";
        }).completeOnTimeout("Default value", 2, TimeUnit.SECONDS);

        System.out.println(future2.join());
    }
}
```

## Advanced CompletableFuture Patterns

Duration: 15:00

Let's explore advanced patterns for real-world async programming.

### Async API Calls

```java
import java.util.concurrent.CompletableFuture;
import java.net.http.*;
import java.net.URI;

public class AsyncApiCalls {
    private static final HttpClient client = HttpClient.newHttpClient();

    public static CompletableFuture<String> fetchUser(String userId) {
        return CompletableFuture.supplyAsync(() -> {
            simulateDelay(1000);
            return "{\"id\": \"" + userId + "\", \"name\": \"User" + userId + "\"}";
        });
    }

    public static CompletableFuture<String> fetchOrders(String userId) {
        return CompletableFuture.supplyAsync(() -> {
            simulateDelay(800);
            return "[{\"id\": \"O1\", \"amount\": 100}]";
        });
    }

    public static CompletableFuture<String> fetchRecommendations(String userId) {
        return CompletableFuture.supplyAsync(() -> {
            simulateDelay(1200);
            return "[\"Product1\", \"Product2\"]";
        });
    }

    public static void main(String[] args) {
        long start = System.currentTimeMillis();

        String userId = "123";

        // Sequential approach (slow)
        // Total: 1000 + 800 + 1200 = 3000ms

        // Parallel approach (fast)
        CompletableFuture<String> userFuture = fetchUser(userId);
        CompletableFuture<String> ordersFuture = fetchOrders(userId);
        CompletableFuture<String> recommendationsFuture = fetchRecommendations(userId);

        // Combine all results
        CompletableFuture<String> combined = userFuture.thenCombine(ordersFuture, (user, orders) -> {
            return user + ", " + orders;
        }).thenCombine(recommendationsFuture, (combined1, recommendations) -> {
            return combined1 + ", " + recommendations;
        });

        String result = combined.join();
        long end = System.currentTimeMillis();

        System.out.println("Result: " + result);
        System.out.println("Time taken: " + (end - start) + "ms");  // ~1200ms (slowest)
    }

    private static void simulateDelay(int ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

### Retry Pattern

```java
import java.util.concurrent.CompletableFuture;
import java.util.function.Supplier;

public class RetryPattern {
    public static <T> CompletableFuture<T> retry(Supplier<CompletableFuture<T>> action, int maxAttempts) {
        CompletableFuture<T> future = action.get();

        for (int i = 1; i < maxAttempts; i++) {
            final int attempt = i;
            future = future.exceptionally(ex -> {
                System.out.println("Attempt " + attempt + " failed: " + ex.getMessage());
                return null;
            }).thenCompose(result -> {
                if (result == null) {
                    return action.get();
                }
                return CompletableFuture.completedFuture(result);
            });
        }

        return future;
    }

    public static void main(String[] args) {
        int[] attempts = {0};

        Supplier<CompletableFuture<String>> unreliableService = () -> {
            return CompletableFuture.supplyAsync(() -> {
                attempts[0]++;
                System.out.println("Calling service (attempt " + attempts[0] + ")");

                if (attempts[0] < 3) {
                    throw new RuntimeException("Service unavailable");
                }
                return "Success!";
            });
        };

        CompletableFuture<String> result = retry(unreliableService, 5);
        System.out.println("Final result: " + result.join());
    }
}
```

### Fallback Pattern

```java
import java.util.concurrent.CompletableFuture;

public class FallbackPattern {
    public static CompletableFuture<String> fetchFromPrimary() {
        return CompletableFuture.supplyAsync(() -> {
            if (Math.random() > 0.7) {
                return "Data from primary";
            }
            throw new RuntimeException("Primary failed");
        });
    }

    public static CompletableFuture<String> fetchFromSecondary() {
        return CompletableFuture.supplyAsync(() -> {
            return "Data from secondary (fallback)";
        });
    }

    public static CompletableFuture<String> fetchFromCache() {
        return CompletableFuture.completedFuture("Data from cache");
    }

    public static void main(String[] args) {
        // Try primary, fallback to secondary, then cache
        CompletableFuture<String> result = fetchFromPrimary()
            .exceptionally(ex -> {
                System.out.println("Primary failed, trying secondary...");
                return null;
            })
            .thenCompose(data -> {
                if (data != null) {
                    return CompletableFuture.completedFuture(data);
                }
                return fetchFromSecondary();
            })
            .exceptionally(ex -> {
                System.out.println("Secondary failed, using cache...");
                return fetchFromCache().join();
            });

        System.out.println("Result: " + result.join());
    }
}
```

### Parallel Aggregation

```java
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

public class ParallelAggregation {
    public static void main(String[] args) {
        List<String> userIds = Arrays.asList("1", "2", "3", "4", "5");

        long start = System.currentTimeMillis();

        // Fetch all users in parallel
        List<CompletableFuture<User>> futures = userIds.stream()
            .map(id -> fetchUserAsync(id))
            .collect(Collectors.toList());

        // Wait for all to complete
        CompletableFuture<Void> allOf = CompletableFuture.allOf(
            futures.toArray(new CompletableFuture[0])
        );

        // Collect results
        CompletableFuture<List<User>> allUsers = allOf.thenApply(v -> {
            return futures.stream()
                .map(CompletableFuture::join)
                .collect(Collectors.toList());
        });

        List<User> users = allUsers.join();
        long end = System.currentTimeMillis();

        System.out.println("Fetched " + users.size() + " users");
        users.forEach(System.out::println);
        System.out.println("Time taken: " + (end - start) + "ms");
    }

    static class User {
        String id;
        String name;

        User(String id, String name) {
            this.id = id;
            this.name = name;
        }

        @Override
        public String toString() {
            return "User{id='" + id + "', name='" + name + "'}";
        }
    }

    static CompletableFuture<User> fetchUserAsync(String id) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(500);  // Simulate API call
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return new User(id, "User" + id);
        });
    }
}
```

## Build Data Processing System

Duration: 25:00

Let's build a comprehensive async data processing system!

Create `DataProcessingSystem.java`:

```java
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.Collectors;
import java.time.*;

record DataSource(String name, String url, int latencyMs) {
    CompletableFuture<List<String>> fetch() {
        return CompletableFuture.supplyAsync(() -> {
            System.out.println("[" + name + "] Fetching data...");
            simulateLatency(latencyMs);

            // Simulate data
            List<String> data = new ArrayList<>();
            for (int i = 1; i <= 5; i++) {
                data.add(name + "-Data" + i);
            }

            System.out.println("[" + name + "] Fetched " + data.size() + " items");
            return data;
        });
    }

    private void simulateLatency(int ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

record ProcessedData(String source, String value, Instant timestamp) {
    @Override
    public String toString() {
        return String.format("%s: %s (processed at %s)",
            source, value, timestamp);
    }
}

class DataProcessor {
    private final ExecutorService executor;

    public DataProcessor(int threadPoolSize) {
        this.executor = Executors.newFixedThreadPool(threadPoolSize);
    }

    public CompletableFuture<ProcessedData> process(String source, String data) {
        return CompletableFuture.supplyAsync(() -> {
            // Simulate processing
            try {
                Thread.sleep(200);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }

            String processed = data.toUpperCase() + "-PROCESSED";
            return new ProcessedData(source, processed, Instant.now());
        }, executor);
    }

    public void shutdown() {
        executor.shutdown();
    }
}

class DataAggregator {
    public CompletableFuture<Map<String, List<ProcessedData>>> aggregate(
            List<ProcessedData> data) {
        return CompletableFuture.supplyAsync(() -> {
            return data.stream()
                .collect(Collectors.groupingBy(ProcessedData::source));
        });
    }

    public CompletableFuture<Statistics> calculateStatistics(List<ProcessedData> data) {
        return CompletableFuture.supplyAsync(() -> {
            Map<String, Long> countBySource = data.stream()
                .collect(Collectors.groupingBy(
                    ProcessedData::source,
                    Collectors.counting()
                ));

            return new Statistics(
                data.size(),
                countBySource.size(),
                countBySource
            );
        });
    }
}

record Statistics(int totalItems, int totalSources, Map<String, Long> countBySource) {
    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("Statistics:\n");
        sb.append("  Total items: ").append(totalItems).append("\n");
        sb.append("  Total sources: ").append(totalSources).append("\n");
        sb.append("  Breakdown:\n");
        countBySource.forEach((source, count) ->
            sb.append("    ").append(source).append(": ").append(count).append("\n")
        );
        return sb.toString();
    }
}

public class DataProcessingSystem {
    private final List<DataSource> dataSources;
    private final DataProcessor processor;
    private final DataAggregator aggregator;

    public DataProcessingSystem() {
        this.dataSources = List.of(
            new DataSource("API-1", "http://api1.example.com", 1000),
            new DataSource("API-2", "http://api2.example.com", 800),
            new DataSource("API-3", "http://api3.example.com", 1200),
            new DataSource("Database", "jdbc:mysql://localhost/db", 600),
            new DataSource("Cache", "redis://localhost:6379", 300)
        );
        this.processor = new DataProcessor(10);
        this.aggregator = new DataAggregator();
    }

    // Scenario 1: Sequential processing (slow)
    public List<ProcessedData> processSequentially() {
        System.out.println("\n=== SEQUENTIAL PROCESSING ===");
        long start = System.currentTimeMillis();

        List<ProcessedData> allProcessed = new ArrayList<>();

        for (DataSource source : dataSources) {
            List<String> data = source.fetch().join();
            for (String item : data) {
                ProcessedData processed = processor.process(source.name(), item).join();
                allProcessed.add(processed);
            }
        }

        long end = System.currentTimeMillis();
        System.out.println("Sequential time: " + (end - start) + "ms");

        return allProcessed;
    }

    // Scenario 2: Parallel processing (fast)
    public CompletableFuture<List<ProcessedData>> processParallel() {
        System.out.println("\n=== PARALLEL PROCESSING ===");
        long start = System.currentTimeMillis();

        // Fetch from all sources in parallel
        List<CompletableFuture<List<String>>> fetchFutures = dataSources.stream()
            .map(DataSource::fetch)
            .collect(Collectors.toList());

        // Wait for all fetches to complete
        CompletableFuture<Void> allFetches = CompletableFuture.allOf(
            fetchFutures.toArray(new CompletableFuture[0])
        );

        // Process all fetched data
        return allFetches.thenCompose(v -> {
            List<CompletableFuture<ProcessedData>> processFutures = new ArrayList<>();

            for (int i = 0; i < dataSources.size(); i++) {
                DataSource source = dataSources.get(i);
                List<String> data = fetchFutures.get(i).join();

                for (String item : data) {
                    CompletableFuture<ProcessedData> processFuture =
                        processor.process(source.name(), item);
                    processFutures.add(processFuture);
                }
            }

            CompletableFuture<Void> allProcessed = CompletableFuture.allOf(
                processFutures.toArray(new CompletableFuture[0])
            );

            return allProcessed.thenApply(v2 -> {
                long end = System.currentTimeMillis();
                System.out.println("Parallel time: " + (end - start) + "ms");

                return processFutures.stream()
                    .map(CompletableFuture::join)
                    .collect(Collectors.toList());
            });
        });
    }

    // Scenario 3: Fastest source wins
    public CompletableFuture<List<String>> fetchFastest() {
        System.out.println("\n=== FETCH FROM FASTEST SOURCE ===");
        long start = System.currentTimeMillis();

        @SuppressWarnings("unchecked")
        CompletableFuture<List<String>>[] futures = dataSources.stream()
            .map(DataSource::fetch)
            .toArray(CompletableFuture[]::new);

        return (CompletableFuture<List<String>>) CompletableFuture.anyOf(futures)
            .thenApply(result -> {
                long end = System.currentTimeMillis();
                System.out.println("Fastest source responded in: " + (end - start) + "ms");
                return (List<String>) result;
            });
    }

    // Scenario 4: Error handling and fallbacks
    public CompletableFuture<List<String>> fetchWithFallback() {
        System.out.println("\n=== FETCH WITH FALLBACK ===");

        DataSource primary = new DataSource("Primary", "http://primary.com", 500);
        DataSource secondary = new DataSource("Secondary", "http://secondary.com", 700);
        DataSource cache = new DataSource("Cache", "cache://local", 100);

        return primary.fetch()
            .exceptionally(ex -> {
                System.out.println("Primary failed: " + ex.getMessage());
                return null;
            })
            .thenCompose(data -> {
                if (data != null && !data.isEmpty()) {
                    System.out.println("✓ Using primary data");
                    return CompletableFuture.completedFuture(data);
                }

                System.out.println("Trying secondary...");
                return secondary.fetch();
            })
            .exceptionally(ex -> {
                System.out.println("Secondary failed: " + ex.getMessage());
                return null;
            })
            .thenCompose(data -> {
                if (data != null && !data.isEmpty()) {
                    System.out.println("✓ Using secondary data");
                    return CompletableFuture.completedFuture(data);
                }

                System.out.println("Using cache...");
                return cache.fetch();
            })
            .thenApply(data -> {
                System.out.println("✓ Retrieved data successfully");
                return data;
            });
    }

    // Scenario 5: Timeout handling
    public CompletableFuture<List<String>> fetchWithTimeout(int timeoutSeconds) {
        System.out.println("\n=== FETCH WITH TIMEOUT ===");

        DataSource slowSource = new DataSource("SlowAPI", "http://slow.com", 3000);

        return slowSource.fetch()
            .orTimeout(timeoutSeconds, TimeUnit.SECONDS)
            .exceptionally(ex -> {
                if (ex instanceof TimeoutException) {
                    System.out.println("✗ Request timed out!");
                    return List.of("TIMEOUT-DATA");
                }
                throw new RuntimeException(ex);
            });
    }

    // Scenario 6: Complete pipeline
    public void runCompletePipeline() {
        System.out.println("\n=== COMPLETE PROCESSING PIPELINE ===");
        long start = System.currentTimeMillis();

        CompletableFuture<Statistics> pipeline = processParallel()
            .thenCompose(processedData -> {
                System.out.println("\n✓ Processing complete, aggregating...");
                return aggregator.aggregate(processedData)
                    .thenCombine(
                        aggregator.calculateStatistics(processedData),
                        (aggregated, stats) -> {
                            System.out.println("\n--- AGGREGATED DATA ---");
                            aggregated.forEach((source, items) -> {
                                System.out.println(source + ": " + items.size() + " items");
                            });
                            return stats;
                        }
                    );
            })
            .whenComplete((stats, ex) -> {
                if (ex != null) {
                    System.err.println("Pipeline failed: " + ex.getMessage());
                } else {
                    long end = System.currentTimeMillis();
                    System.out.println("\n" + stats);
                    System.out.println("Total pipeline time: " + (end - start) + "ms");
                }
            });

        pipeline.join();
    }

    public void shutdown() {
        processor.shutdown();
    }

    public static void main(String[] args) {
        DataProcessingSystem system = new DataProcessingSystem();

        try {
            // Demonstrate different scenarios

            // 1. Sequential vs Parallel comparison
            system.processSequentially();
            system.processParallel().join();

            // 2. Fastest source
            List<String> fastestData = system.fetchFastest().join();
            System.out.println("Got " + fastestData.size() + " items from fastest source");

            // 3. Fallback mechanism
            system.fetchWithFallback().join();

            // 4. Timeout handling
            system.fetchWithTimeout(2).join();

            // 5. Complete pipeline
            system.runCompletePipeline();

        } finally {
            system.shutdown();
        }
    }
}
```

## Best Practices

Duration: 8:00

### Thread Safety

```java
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

// Bad: Not thread-safe
class UnsafeCounter {
    private int count = 0;

    public void increment() {
        count++;  // Race condition!
    }
}

// Good: Thread-safe
class SafeCounter {
    private final AtomicInteger count = new AtomicInteger(0);

    public void increment() {
        count.incrementAndGet();
    }
}

// Good: Using synchronized
class SynchronizedCounter {
    private int count = 0;

    public synchronized void increment() {
        count++;
    }
}
```

### Executor Management

```java
// Bad: Not shutting down executor
ExecutorService bad = Executors.newFixedThreadPool(10);
bad.submit(() -> System.out.println("Task"));
// Executor never shuts down!

// Good: Proper shutdown
ExecutorService good = Executors.newFixedThreadPool(10);
try {
    good.submit(() -> System.out.println("Task"));
} finally {
    good.shutdown();
    try {
        if (!good.awaitTermination(60, TimeUnit.SECONDS)) {
            good.shutdownNow();
        }
    } catch (InterruptedException e) {
        good.shutdownNow();
    }
}

// Better: Try-with-resources (Java 19+)
// ExecutorService will auto-close
```

### Exception Handling

```java
// Always handle exceptions in CompletableFuture
CompletableFuture.supplyAsync(() -> {
    if (Math.random() > 0.5) {
        throw new RuntimeException("Error!");
    }
    return "Success";
})
.exceptionally(ex -> {
    System.err.println("Error occurred: " + ex.getMessage());
    return "Fallback value";
})
.thenAccept(System.out::println);
```

### Performance Tips

```java
// 1. Choose appropriate executor size
int cores = Runtime.getRuntime().availableProcessors();

// CPU-bound tasks: cores or cores + 1
ExecutorService cpuBound = Executors.newFixedThreadPool(cores);

// I/O-bound tasks: larger pool
ExecutorService ioBound = Executors.newFixedThreadPool(cores * 2);

// 2. Reuse executors
// Don't create new executor for each task!
ExecutorService shared = Executors.newFixedThreadPool(10);

// 3. Use appropriate methods
// thenApply vs thenApplyAsync
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> "data")
    .thenApply(String::toUpperCase)  // Same thread
    .thenApplyAsync(String::trim);    // Different thread (when needed)
```

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered asynchronous programming in Java!

### What You've Learned

- ✅ **Threading Basics:** Runnable, Callable, Thread management
- ✅ **ExecutorService:** Thread pools and task submission
- ✅ **Future Interface:** Blocking async operations
- ✅ **CompletableFuture:** Modern non-blocking async
- ✅ **Chaining:** thenApply, thenAccept, thenCompose
- ✅ **Combining:** thenCombine, allOf, anyOf
- ✅ **Error Handling:** exceptionally, handle, whenComplete
- ✅ **Timeouts:** orTimeout, completeOnTimeout
- ✅ **Advanced Patterns:** Retry, fallback, aggregation

### Key Takeaways

1. **CompletableFuture** is more powerful and flexible than Future
2. **Async operations** improve performance by not blocking threads
3. **Always handle exceptions** in async code
4. **Use thread pools** instead of creating threads directly
5. **Shutdown executors** properly to prevent resource leaks
6. **Choose appropriate parallelism** based on task type

### Best Practices

- Use CompletableFuture for async operations
- Always provide error handlers (exceptionally, handle)
- Shutdown executors in finally blocks
- Use timeouts for external calls
- Prefer async variants when operations are independent
- Monitor thread pool sizes and adjust as needed

### Next Steps

Continue to:

- **Codelab 2.4:** Logging with Log4j
- **Codelab 2.5:** IDE Debugging Mastery
- **Codelab 3.1:** Spring Boot (which uses async extensively)

### Practice Exercises

1. **Async Web Scraper:** Fetch and parse multiple URLs in parallel
2. **Order Processing:** Async order validation, payment, and fulfillment
3. **Batch Processor:** Process large files using parallel streams
4. **API Gateway:** Aggregate data from multiple microservices
5. **Cache Warmer:** Pre-load cache asynchronously on startup

> aside positive
> **Excellent Work!** Async programming is crucial for building high-performance, scalable applications. These skills are essential for modern Spring Boot and microservices development!
