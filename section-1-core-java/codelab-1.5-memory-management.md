summary: Understand JVM memory architecture, garbage collection algorithms, memory leaks, and performance optimization through hands-on profiling and monitoring exercises
id: memory-management
categories: Java, JVM, Memory Management, Performance
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM

# Memory Management & Garbage Collection

## Introduction

Duration: 2:00

Understanding memory management is crucial for building performant Java applications. In this codelab, you'll explore JVM memory architecture, garbage collection mechanisms, and learn to identify and prevent memory leaks using real-world profiling tools.

### What You'll Learn

- JVM memory model (Heap, Stack, Method Area)
- Object lifecycle and memory allocation
- Garbage collection algorithms (Serial, Parallel, G1GC, ZGC)
- Memory leaks: causes and prevention
- JVM monitoring tools (jconsole, VisualVM, JProfiler)
- Memory optimization techniques
- Best practices for memory-efficient code
- Analyzing heap dumps and thread dumps

### What You'll Build

Memory profiling exercises including:

- Memory-intensive applications to observe GC behavior
- Memory leak scenarios and detection
- Performance benchmarks comparing GC algorithms
- Monitoring dashboard using JMX
- Optimization exercises with before/after metrics

### Prerequisites

- Completed Codelabs 1.1 through 1.4
- Understanding of Java objects and collections
- Java JDK 17+ installed
- VisualVM or JConsole (included with JDK)

## JVM Memory Architecture

Duration: 12:00

Let's dive deep into how JVM manages memory.

### Memory Areas Overview

```
JVM Memory Structure
┌────────────────────────────────────────────────────────────┐
│                    Runtime Data Areas                       │
├────────────────────────────────────────────────────────────┤
│ Method Area (Metaspace in Java 8+)                         │
│ - Class metadata                                           │
│ - Static variables                                         │
│ - Constant pool                                            │
├────────────────────────────────────────────────────────────┤
│ Heap (Shared across all threads)                           │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Young Generation                                        ││
│ │ ├─ Eden Space (new objects)                            ││
│ │ ├─ Survivor Space 0 (S0)                               ││
│ │ └─ Survivor Space 1 (S1)                               ││
│ ├─────────────────────────────────────────────────────────┤│
│ │ Old Generation (Tenured)                               ││
│ │ - Long-lived objects                                   ││
│ └─────────────────────────────────────────────────────────┘│
├────────────────────────────────────────────────────────────┤
│ Stack (Per thread)                                         │
│ - Method calls                                             │
│ - Local variables                                          │
│ - Partial results                                          │
├────────────────────────────────────────────────────────────┤
│ PC Register (Per thread)                                   │
│ - Current instruction pointer                              │
├────────────────────────────────────────────────────────────┤
│ Native Method Stack (Per thread)                           │
│ - Native method calls                                      │
└────────────────────────────────────────────────────────────┘
```

### Heap vs Stack Memory

**Stack Memory:**

- Stores primitive local variables and object references
- Fast allocation/deallocation (LIFO)
- Thread-specific (each thread has its own stack)
- Limited size (typically 1MB per thread)
- Automatic cleanup when method exits

**Heap Memory:**

- Stores all objects and instance variables
- Shared across all threads
- Larger size (configured with -Xms and -Xmx)
- Managed by Garbage Collector
- Slower access than stack

### Demonstration: Stack vs Heap

```java
public class MemoryDemo {

    // Class variable (Method Area/Metaspace)
    private static int classCounter = 0;

    // Instance variable (Heap)
    private String name;
    private int value;

    public MemoryDemo(String name, int value) {
        this.name = name;  // Heap
        this.value = value;  // Heap
        classCounter++;  // Method Area
    }

    public void demonstrateMemory() {
        // Local primitive variable (Stack)
        int localNumber = 42;

        // Local object reference (Stack), object itself (Heap)
        String localString = "Hello";

        // Array reference (Stack), array object (Heap)
        int[] localArray = new int[5];

        System.out.println("Method execution:");
        System.out.println("  localNumber (stack): " + localNumber);
        System.out.println("  localString reference (stack), object (heap): " + localString);
        System.out.println("  localArray reference (stack), array (heap): " + localArray.length);
    }

    public static void main(String[] args) {
        // Object reference (Stack), object (Heap)
        MemoryDemo demo = new MemoryDemo("Example", 100);
        demo.demonstrateMemory();

        // After method returns, localNumber, localString reference,
        // and localArray reference are removed from stack
        // But objects remain in heap until GC collects them

        System.out.println("\nClass counter: " + classCounter);
    }
}
```

### Object Lifecycle

```java
public class ObjectLifecycle {

    public static void main(String[] args) {
        // 1. Object Creation - allocated in Eden space
        Person person = new Person("Alice", 25);

        // 2. Object in use - lives in heap
        System.out.println(person.getName());

        // 3. Object becomes unreachable - eligible for GC
        person = null;  // No more references to original object

        // 4. Garbage Collection - JVM reclaims memory (eventually)
        // We can suggest GC (but JVM decides when to actually run it)
        System.gc();

        // 5. finalize() called before reclamation (deprecated in Java 9+)
        // Modern alternative: try-with-resources or Cleaner API
    }
}

class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
        System.out.println("Person created: " + name);
    }

    public String getName() { return name; }

    // Deprecated since Java 9 - shown for educational purposes
    @Override
    protected void finalize() throws Throwable {
        System.out.println("Person finalized: " + name);
        super.finalize();
    }
}
```

> aside negative
> **Important:** Never rely on `finalize()` for cleanup! Use try-with-resources for closeable resources or the Cleaner API for explicit cleanup.

### Viewing Memory Usage

```java
public class MemoryUsageDemo {

    public static void printMemoryStats() {
        Runtime runtime = Runtime.getRuntime();

        long maxMemory = runtime.maxMemory();      // -Xmx
        long totalMemory = runtime.totalMemory();  // Current heap size
        long freeMemory = runtime.freeMemory();    // Free heap
        long usedMemory = totalMemory - freeMemory;

        System.out.println("=== MEMORY STATISTICS ===");
        System.out.println("Max Memory:   " + formatBytes(maxMemory));
        System.out.println("Total Memory: " + formatBytes(totalMemory));
        System.out.println("Used Memory:  " + formatBytes(usedMemory));
        System.out.println("Free Memory:  " + formatBytes(freeMemory));
        System.out.println("Used %:       " + (usedMemory * 100 / totalMemory) + "%");
    }

    private static String formatBytes(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return (bytes / 1024) + " KB";
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)) + " MB";
        return (bytes / (1024 * 1024 * 1024)) + " GB";
    }

    public static void main(String[] args) {
        printMemoryStats();

        System.out.println("\nCreating 1 million objects...");
        String[] strings = new String[1_000_000];
        for (int i = 0; i < strings.length; i++) {
            strings[i] = "String " + i;
        }

        printMemoryStats();

        System.out.println("\nClearing references...");
        strings = null;
        System.gc();  // Suggest garbage collection

        try {
            Thread.sleep(100);  // Give GC time to run
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        printMemoryStats();
    }
}
```

## Garbage Collection Basics

Duration: 12:00

Garbage Collection (GC) automatically reclaims memory occupied by unreachable objects.

### When Does GC Run?

GC runs when:

1. Eden space is full (Minor GC)
2. Old generation is full (Major GC / Full GC)
3. `System.gc()` is called (suggestion only)
4. JVM decides based on algorithms

### Generational GC Theory

**Key Observation:** Most objects die young!

**Young Generation (Minor GC):**

- Eden: New objects allocated here
- Survivor S0 and S1: Objects that survive one GC
- Fast, frequent collections
- Uses copying algorithm

**Old Generation (Major GC):**

- Long-lived objects promoted from young generation
- Slower, less frequent collections
- Uses mark-sweep-compact algorithm

### Object Promotion Process

```
1. New object → Eden Space
   [Eden: ████░░░░░░] [S0: ] [S1: ]

2. Eden full → Minor GC → Survivors move to S0
   [Eden: ░░░░░░░░░░] [S0: ██] [S1: ]

3. Next Eden full → Minor GC → Survivors move to S1
   [Eden: ░░░░░░░░░░] [S0: ] [S1: ███]

4. After N cycles → Promote to Old Generation
   [Eden: ░░░░░░░░░░] [S0: ] [S1: █] [Old: ██████]
```

### GC Demonstration

```java
public class GCDemo {

    private static final int ITERATIONS = 10;
    private static final int OBJECTS_PER_ITERATION = 100_000;

    public static void main(String[] args) {
        System.out.println("Starting GC demonstration...\n");

        for (int i = 0; i < ITERATIONS; i++) {
            System.out.println("--- Iteration " + (i + 1) + " ---");
            allocateObjects();
            printMemoryAndGC();

            try {
                Thread.sleep(500);  // Pause between iterations
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    private static void allocateObjects() {
        // Create temporary objects
        for (int i = 0; i < OBJECTS_PER_ITERATION; i++) {
            String temp = new String("Temporary object " + i);
            // Object becomes eligible for GC immediately after creation
        }
    }

    private static void printMemoryAndGC() {
        Runtime runtime = Runtime.getRuntime();
        long totalMemory = runtime.totalMemory();
        long freeMemory = runtime.freeMemory();
        long usedMemory = totalMemory - freeMemory;

        System.out.printf("Used: %d MB, Free: %d MB, Total: %d MB%n",
            usedMemory / (1024 * 1024),
            freeMemory / (1024 * 1024),
            totalMemory / (1024 * 1024)
        );
    }
}
```

Run with GC logging:

```console
$ java -Xlog:gc* GCDemo
```

### GC Algorithms Overview

**1. Serial GC (`-XX:+UseSerialGC`)**

- Single-threaded
- Stop-the-world for both young and old generation
- Best for: Small heaps, single-CPU systems

**2. Parallel GC (`-XX:+UseParallelGC`)**

- Multi-threaded for young generation
- Stop-the-world for both generations
- Best for: Throughput-oriented applications

**3. G1 GC (`-XX:+UseG1GC`) - Default since Java 9**

- Divides heap into regions
- Predictable pause times
- Best for: Large heaps, balanced throughput and latency

**4. ZGC (`-XX:+UseZGC`)**

- Concurrent collector
- Very low pause times (<10ms)
- Best for: Low-latency requirements, very large heaps

**5. Shenandoah GC (`-XX:+UseShenandoahGC`)**

- Concurrent collector
- Low pause times
- Best for: Similar to ZGC, alternative implementation

### Comparing GC Algorithms

```java
public class GCComparison {

    private static final int HEAP_SIZE_MB = 512;
    private static final int ITERATIONS = 100;

    public static void main(String[] args) {
        System.out.println("=== GC PERFORMANCE COMPARISON ===");
        System.out.println("Heap Size: " + HEAP_SIZE_MB + " MB");
        System.out.println("Iterations: " + ITERATIONS);
        System.out.println("\nRun with different GC:");
        System.out.println("  java -Xms512m -Xmx512m -XX:+UseSerialGC GCComparison");
        System.out.println("  java -Xms512m -Xmx512m -XX:+UseParallelGC GCComparison");
        System.out.println("  java -Xms512m -Xmx512m -XX:+UseG1GC GCComparison");
        System.out.println();

        long startTime = System.currentTimeMillis();

        for (int i = 0; i < ITERATIONS; i++) {
            createGarbage();
            if (i % 10 == 0) {
                System.out.println("Iteration " + i + " completed");
            }
        }

        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;

        System.out.println("\n=== RESULTS ===");
        System.out.println("Total time: " + duration + " ms");
        System.out.println("Average per iteration: " + (duration / ITERATIONS) + " ms");
    }

    private static void createGarbage() {
        // Create many short-lived objects
        List<String> temp = new ArrayList<>();
        for (int i = 0; i < 10_000; i++) {
            temp.add(new String("Object " + i));
        }
        // temp goes out of scope - all objects eligible for GC
    }
}
```

> aside positive
> **Modern Choice:** Use G1 GC (default) for most applications. It provides good balance between throughput and latency.

## Memory Leaks

Duration: 12:00

Memory leaks occur when objects are no longer needed but remain referenced, preventing GC from reclaiming them.

### Common Memory Leak Scenarios

**1. Forgotten Collections**

```java
public class LeakExample1 {
    // BAD: Grows forever!
    private static List<User> users = new ArrayList<>();

    public void registerUser(String name) {
        User user = new User(name);
        users.add(user);
        // Even if user logs out, reference remains!
    }
}
```

**Fix:** Remove objects when no longer needed:

```java
public void unregisterUser(User user) {
    users.remove(user);
}
```

**2. Unclosed Resources**

```java
public class LeakExample2 {
    public void processFile(String filename) throws IOException {
        FileInputStream fis = new FileInputStream(filename);
        // Process file
        // FORGOT to close! Memory and file descriptor leak
    }
}
```

**Fix:** Use try-with-resources:

```java
public void processFile(String filename) throws IOException {
    try (FileInputStream fis = new FileInputStream(filename)) {
        // Process file
    }  // Automatically closed
}
```

**3. Static Collections**

```java
public class LeakExample3 {
    // BAD: Static collection never garbage collected
    private static Map<String, byte[]> cache = new HashMap<>();

    public byte[] getData(String key) {
        if (!cache.containsKey(key)) {
            byte[] data = loadFromDatabase(key);
            cache.put(key, data);  // Grows forever!
        }
        return cache.get(key);
    }
}
```

**Fix:** Use bounded cache with eviction:

```java
private static Map<String, byte[]> cache = new LinkedHashMap<String, byte[]>(100, 0.75f, true) {
    @Override
    protected boolean removeEldestEntry(Map.Entry eldest) {
        return size() > 100;  // Max 100 entries
    }
};
```

**4. Anonymous Inner Classes**

```java
public class LeakExample4 {
    private String largeData = "..." ; // Large string

    public ActionListener createListener() {
        // BAD: Anonymous class holds reference to outer class
        return new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                System.out.println("Clicked");
                // This holds reference to LeakExample4 instance
                // and its largeData field!
            }
        };
    }
}
```

**Fix:** Use static inner class or lambda:

```java
public ActionListener createListener() {
    // Lambda doesn't capture 'this' unless needed
    return e -> System.out.println("Clicked");
}
```

**5. ThreadLocal Misuse**

```java
public class LeakExample5 {
    // BAD: ThreadLocal not cleaned up
    private static ThreadLocal<HeavyObject> threadLocal = new ThreadLocal<>();

    public void processRequest() {
        threadLocal.set(new HeavyObject());
        // Process request
        // FORGOT to remove! Stays in thread pool threads
    }
}
```

**Fix:** Always remove ThreadLocal values:

```java
public void processRequest() {
    try {
        threadLocal.set(new HeavyObject());
        // Process request
    } finally {
        threadLocal.remove();  // Always cleanup
    }
}
```

### Detecting Memory Leaks Exercise

```java
import java.util.*;

public class MemoryLeakDetection {

    // Intentional memory leak for demonstration
    private static List<byte[]> leakyList = new ArrayList<>();

    public static void main(String[] args) {
        System.out.println("Starting memory leak demonstration...");
        System.out.println("Monitor with jconsole or VisualVM");
        System.out.println("Watch heap memory grow continuously\n");

        Runtime runtime = Runtime.getRuntime();
        int iteration = 0;

        while (true) {
            // Create 1MB of data each iteration
            byte[] leak = new byte[1024 * 1024];  // 1 MB
            leakyList.add(leak);  // Never removed!

            iteration++;

            if (iteration % 100 == 0) {
                long usedMemory = (runtime.totalMemory() - runtime.freeMemory()) / (1024 * 1024);
                long maxMemory = runtime.maxMemory() / (1024 * 1024);

                System.out.printf("Iteration %d: Used %d MB / %d MB (%.1f%%)%n",
                    iteration, usedMemory, maxMemory,
                    (usedMemory * 100.0 / maxMemory));
            }

            try {
                Thread.sleep(100);  // 100ms delay
            } catch (InterruptedException e) {
                break;
            }

            // Eventually will throw OutOfMemoryError
        }
    }
}
```

Run and monitor:

```console
$ java -Xmx256m MemoryLeakDetection
```

> aside negative
> **Warning:** This program will eventually crash with OutOfMemoryError! That's the point - to demonstrate a memory leak.

## JVM Monitoring Tools

Duration: 15:00

Let's learn to use professional monitoring tools to diagnose memory issues.

### JConsole - Built-in Monitoring

**Starting JConsole:**

```console
$ jconsole
```

Or connect to a running process:

```console
$ jps  # List Java processes
12345 MyApplication
$ jconsole 12345
```

**What to Monitor:**

- **Memory Tab:** Heap usage over time
- **Threads Tab:** Thread count and state
- **Classes Tab:** Loaded classes
- **VM Summary:** JVM configuration

### VisualVM - Advanced Profiling

**Starting VisualVM:**

```console
$ jvisualvm
```

**Key Features:**

1. **Monitor Tab:** Real-time CPU, memory, classes, threads
2. **Profiler Tab:** CPU and memory profiling
3. **Heap Dump:** Take snapshot of heap
4. **Thread Dump:** Analyze thread states

### Hands-On: Profiling Exercise

**Step 1: Create Application to Profile**

```java
import java.util.*;

public class ProfileMe {
    private static List<Customer> customers = new ArrayList<>();
    private static Random random = new Random();

    public static void main(String[] args) throws InterruptedException {
        System.out.println("Application started. Profile with VisualVM!");
        System.out.println("PID: " + ProcessHandle.current().pid());

        while (true) {
            simulateWork();
            Thread.sleep(1000);
        }
    }

    private static void simulateWork() {
        // Simulate user registration
        for (int i = 0; i < 100; i++) {
            registerCustomer();
        }

        // Simulate some processing
        processOrders();

        // Simulate cleanup (prevents memory leak)
        if (customers.size() > 10000) {
            customers.subList(0, 5000).clear();
        }
    }

    private static void registerCustomer() {
        Customer customer = new Customer(
            "Customer" + random.nextInt(1000000),
            "customer" + random.nextInt(1000000) + "@email.com"
        );
        customers.add(customer);
    }

    private static void processOrders() {
        // Simulate expensive computation
        double sum = 0;
        for (int i = 0; i < 100000; i++) {
            sum += Math.sqrt(i);
        }
    }
}

class Customer {
    private String name;
    private String email;
    private List<Order> orders;

    public Customer(String name, String email) {
        this.name = name;
        this.email = email;
        this.orders = new ArrayList<>();
    }
}

class Order {
    private String orderId;
    private double amount;

    public Order(String orderId, double amount) {
        this.orderId = orderId;
        this.amount = amount;
    }
}
```

**Step 2: Run and Profile**

1. Start the application
2. Open VisualVM
3. Select the process
4. Go to Monitor tab - observe memory pattern
5. Take heap dump - analyze what's using memory
6. Go to Profiler tab - start CPU profiling
7. Identify hot methods

### Heap Dump Analysis

**Taking Heap Dump:**

```console
$ jps  # Find PID
$ jmap -dump:format=b,file=heap.bin <PID>
```

Or use VisualVM: Right-click process → Heap Dump

**Analyzing with VisualVM:**

1. Load heap dump file
2. Classes view - see instances per class
3. Find largest objects
4. Check for unexpected collections
5. Look for patterns indicating leaks

### Thread Dump Analysis

**Taking Thread Dump:**

```console
$ jstack <PID> > threads.txt
```

Or use VisualVM: Right-click process → Thread Dump

**Thread States:**

- **RUNNABLE:** Executing
- **BLOCKED:** Waiting for monitor lock
- **WAITING:** Waiting indefinitely
- **TIMED_WAITING:** Waiting with timeout
- **TERMINATED:** Finished execution

```java
public class ThreadDumpDemo {

    public static void main(String[] args) throws InterruptedException {
        // Runnable thread
        Thread worker = new Thread(() -> {
            while (true) {
                try {
                    Thread.sleep(1000);
                    System.out.println("Working...");
                } catch (InterruptedException e) {
                    break;
                }
            }
        }, "Worker-Thread");
        worker.start();

        // Blocked thread (deadlock example)
        final Object lock1 = new Object();
        final Object lock2 = new Object();

        Thread thread1 = new Thread(() -> {
            synchronized (lock1) {
                System.out.println("Thread1 locked lock1");
                try { Thread.sleep(100); } catch (InterruptedException e) {}
                synchronized (lock2) {
                    System.out.println("Thread1 locked lock2");
                }
            }
        }, "Deadlock-Thread-1");

        Thread thread2 = new Thread(() -> {
            synchronized (lock2) {
                System.out.println("Thread2 locked lock2");
                try { Thread.sleep(100); } catch (InterruptedException e) {}
                synchronized (lock1) {
                    System.out.println("Thread2 locked lock1");
                }
            }
        }, "Deadlock-Thread-2");

        thread1.start();
        thread2.start();

        System.out.println("Take thread dump to see deadlock!");
        System.out.println("PID: " + ProcessHandle.current().pid());

        // Keep main thread alive
        Thread.sleep(Long.MAX_VALUE);
    }
}
```

> aside positive
> **Profiling Best Practice:** Always profile in conditions similar to production. Use realistic data volumes and load patterns.

## Memory Optimization Techniques

Duration: 10:00

Let's explore strategies to write memory-efficient code.

### 1. Object Pooling

Reuse expensive objects instead of creating new ones:

```java
import java.util.concurrent.*;

public class ObjectPoolDemo {

    // Thread pool - reuses threads
    private static ExecutorService executor = Executors.newFixedThreadPool(10);

    // Custom object pool
    static class ExpensiveObject {
        private byte[] data = new byte[1024 * 1024];  // 1 MB

        public void reset() {
            // Reset state for reuse
            Arrays.fill(data, (byte) 0);
        }
    }

    static class ObjectPool {
        private BlockingQueue<ExpensiveObject> pool;

        public ObjectPool(int size) {
            pool = new ArrayBlockingQueue<>(size);
            for (int i = 0; i < size; i++) {
                pool.offer(new ExpensiveObject());
            }
        }

        public ExpensiveObject borrow() throws InterruptedException {
            return pool.take();
        }

        public void returnObject(ExpensiveObject obj) {
            obj.reset();
            pool.offer(obj);
        }
    }

    public static void main(String[] args) throws InterruptedException {
        ObjectPool pool = new ObjectPool(10);

        // Reuse objects instead of creating new ones
        for (int i = 0; i < 100; i++) {
            ExpensiveObject obj = pool.borrow();
            // Use object
            pool.returnObject(obj);
        }

        System.out.println("Created only 10 objects, reused 100 times!");
    }
}
```

### 2. Lazy Initialization

Create objects only when needed:

```java
public class LazyInitialization {

    private HeavyResource resource;  // Not initialized yet

    public HeavyResource getResource() {
        if (resource == null) {
            resource = new HeavyResource();  // Create only when needed
        }
        return resource;
    }

    // Thread-safe lazy initialization
    private volatile HeavyResource threadSafeResource;

    public HeavyResource getThreadSafeResource() {
        if (threadSafeResource == null) {
            synchronized (this) {
                if (threadSafeResource == null) {  // Double-check
                    threadSafeResource = new HeavyResource();
                }
            }
        }
        return threadSafeResource;
    }

    // Best: Initialization-on-demand holder
    private static class ResourceHolder {
        private static final HeavyResource INSTANCE = new HeavyResource();
    }

    public static HeavyResource getInstance() {
        return ResourceHolder.INSTANCE;  // Lazy + thread-safe
    }
}

class HeavyResource {
    private byte[] data = new byte[10 * 1024 * 1024];  // 10 MB

    public HeavyResource() {
        System.out.println("HeavyResource created");
    }
}
```

### 3. Weak References

Allow objects to be garbage collected when memory is low:

```java
import java.lang.ref.*;
import java.util.*;

public class WeakReferenceDemo {

    // Strong reference - never GC'd while referenced
    private Object strongRef = new Object();

    // Weak reference - GC'd when memory needed
    private WeakReference<Object> weakRef = new WeakReference<>(new Object());

    // Soft reference - GC'd only when memory critically low
    private SoftReference<Object> softRef = new SoftReference<>(new Object());

    public static void main(String[] args) {
        // Example: Image cache with soft references
        Map<String, SoftReference<byte[]>> imageCache = new HashMap<>();

        // Load images
        for (int i = 0; i < 100; i++) {
            byte[] image = new byte[1024 * 1024];  // 1 MB image
            imageCache.put("image" + i, new SoftReference<>(image));
        }

        // Images stay in cache until memory pressure
        // Then GC can reclaim them

        System.out.println("Cache size: " + imageCache.size());

        // Force GC
        System.gc();

        // Check what survived
        int survived = 0;
        for (SoftReference<byte[]> ref : imageCache.values()) {
            if (ref.get() != null) {
                survived++;
            }
        }

        System.out.println("Images survived GC: " + survived);
    }
}
```

### 4. String Optimization

```java
public class StringOptimization {

    public static void main(String[] args) {
        // BAD: String concatenation in loop
        String result = "";
        long start = System.nanoTime();
        for (int i = 0; i < 10000; i++) {
            result += "x";  // Creates new String each time!
        }
        long end = System.nanoTime();
        System.out.println("String concat: " + (end - start) / 1_000_000 + " ms");

        // GOOD: StringBuilder
        StringBuilder sb = new StringBuilder();
        start = System.nanoTime();
        for (int i = 0; i < 10000; i++) {
            sb.append("x");  // Reuses buffer
        }
        String result2 = sb.toString();
        end = System.nanoTime();
        System.out.println("StringBuilder: " + (end - start) / 1_000_000 + " ms");

        // String interning (use carefully)
        String s1 = new String("Hello").intern();
        String s2 = new String("Hello").intern();
        System.out.println("Same instance: " + (s1 == s2));  // true
    }
}
```

### 5. Collection Sizing

```java
public class CollectionSizing {

    public static void main(String[] args) {
        // BAD: Default size, many resizes
        List<Integer> list1 = new ArrayList<>();  // Initial capacity: 10
        for (int i = 0; i < 10000; i++) {
            list1.add(i);  // Resizes multiple times!
        }

        // GOOD: Pre-sized
        List<Integer> list2 = new ArrayList<>(10000);  // No resizing needed
        for (int i = 0; i < 10000; i++) {
            list2.add(i);  // Efficient
        }

        // HashMap sizing
        // Default: 16 capacity, 0.75 load factor
        // If you know size, specify: new HashMap<>(expectedSize / 0.75)
        Map<String, String> map = new HashMap<>((int) (1000 / 0.75));
    }
}
```

> aside positive
> **Performance Tip:** Pre-size collections when you know the approximate size. Saves time from resizing operations.

## Best Practices and Checklist

Duration: 5:00

Follow these guidelines for optimal memory management.

### Memory Best Practices

**1. Resource Management:**

- ✅ Always use try-with-resources for closeable resources
- ✅ Remove objects from collections when no longer needed
- ✅ Clear ThreadLocal values in finally blocks
- ✅ Close database connections, streams, sockets

**2. Object Creation:**

- ✅ Reuse immutable objects (String, Integer cache)
- ✅ Use object pools for expensive objects
- ✅ Prefer primitive arrays over object arrays when possible
- ✅ Consider lazy initialization for heavy objects

**3. Collections:**

- ✅ Pre-size collections when size is known
- ✅ Use appropriate collection types
- ✅ Clear references when removing from collections
- ✅ Consider WeakHashMap for caches

**4. Static Members:**

- ✅ Minimize use of static collections
- ✅ Implement bounded caches
- ✅ Document lifecycle of static data

**5. Monitoring:**

- ✅ Profile application regularly
- ✅ Monitor production heap usage
- ✅ Set up alerts for memory thresholds
- ✅ Analyze heap dumps for memory leaks

### JVM Tuning Options

```bash
# Heap size
-Xms2g          # Initial heap size (2 GB)
-Xmx4g          # Maximum heap size (4 GB)

# GC selection
-XX:+UseG1GC              # G1 Garbage Collector (default Java 9+)
-XX:+UseZGC               # Z Garbage Collector (low latency)
-XX:+UseSerialGC          # Serial GC (single-threaded)
-XX:+UseParallelGC        # Parallel GC (throughput)

# GC logging
-Xlog:gc*:file=gc.log     # GC log to file

# Heap dump on OutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/path/to/dumps

# Performance tuning
-XX:MaxGCPauseMillis=200  # Target GC pause time (G1 only)
-XX:G1HeapRegionSize=16m  # G1 region size

# Metaspace (class metadata)
-XX:MetaspaceSize=256m
-XX:MaxMetaspaceSize=512m
```

### Memory Leak Checklist

When investigating memory issues:

- [ ] Check static collections - are they bounded?
- [ ] Verify all resources are closed (files, connections, streams)
- [ ] Look for ThreadLocal usage - are values removed?
- [ ] Check for listeners - are they unregistered?
- [ ] Review cache implementations - do they have eviction?
- [ ] Examine inner classes - do they hold unnecessary references?
- [ ] Profile with VisualVM - identify growing objects
- [ ] Analyze heap dump - find unexpected object retention
- [ ] Review GC logs - is Old Gen growing continuously?

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered JVM memory management!

### What You've Learned

- ✅ **JVM Memory Model:** Heap, Stack, Method Area architecture
- ✅ **Object Lifecycle:** Creation, usage, garbage collection
- ✅ **Garbage Collection:** Algorithms, generations, tuning
- ✅ **Memory Leaks:** Common causes and prevention
- ✅ **Monitoring Tools:** JConsole, VisualVM, heap/thread dumps
- ✅ **Optimization:** Object pooling, lazy init, weak references
- ✅ **Best Practices:** Resource management, collection sizing
- ✅ **JVM Tuning:** Heap sizing, GC selection, monitoring

### Key Takeaways

1. **Understand memory layout** - Know where your objects live
2. **Trust the GC** - But understand how it works
3. **Close resources** - Always use try-with-resources
4. **Monitor production** - Catch issues before they become critical
5. **Profile regularly** - Find bottlenecks and leaks early
6. **Size appropriately** - Right-size heap and collections
7. **Use modern GCs** - G1 GC is excellent default choice
8. **Prevent leaks** - Review code for common leak patterns

### Next Steps

Congratulations on completing Section 1! Continue to:

- **Section 2:** Java 8+ Features (Functional Programming, Streams, Async)
- **Section 3:** Spring Boot & IoC
- **Section 4:** Microservices Architecture

### Practice Exercises

Master memory management:

1. **Memory Leak Hunt:** Find and fix leaks in provided code
2. **GC Comparison:** Benchmark different GCs with your application
3. **Heap Analysis:** Analyze heap dumps, identify optimization opportunities
4. **Custom Profiler:** Build JMX-based monitoring dashboard
5. **Cache Implementation:** Create LRU cache with SoftReferences
6. **Performance Tuning:** Optimize application memory footprint by 50%

### Additional Resources

- [Java Performance by Scott Oaks](https://www.oreilly.com/library/view/java-performance-2nd/9781492056102/)
- [JVM Garbage Collection Guide](https://docs.oracle.com/en/java/javase/17/gctuning/)
- [VisualVM Documentation](https://visualvm.github.io/)
- [Java Memory Management (Baeldung)](https://www.baeldung.com/java-memory-management-interview-questions)
- [G1 GC Tuning Guide](https://www.oracle.com/technical-resources/articles/java/g1gc.html)

> aside positive
> **Excellent Work!** Understanding memory management separates good Java developers from great ones. You now have the knowledge to build efficient, scalable applications!
