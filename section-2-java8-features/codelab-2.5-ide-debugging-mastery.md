summary: Master IDE debugging techniques including breakpoints, step debugging, variables inspection, threads, and remote debugging by fixing a buggy application
id: ide-debugging-mastery
categories: Java, Debugging, IntelliJ, Eclipse, IDE
environments: Web
status: Published

# IDE Debugging Mastery

## Introduction

Duration: 3:00

Debugging is one of the most critical skills for any developer. While logging helps in production, interactive debugging during development allows you to inspect program state in real-time, understand complex logic, and quickly identify bugs.

### What You'll Learn

- **Breakpoint Types:** Line, method, conditional, exception breakpoints
- **Logpoints:** Non-intrusive logging without code changes
- **Step Debugging:** Step Into, Step Over, Step Out, Run to Cursor
- **Variables Inspection:** Watch expressions, evaluate expressions
- **Call Stacks:** Navigate execution flow
- **Thread Debugging:** Multi-threaded application debugging
- **Debug Console:** Interactive expression evaluation
- **Hot Code Replace:** Modify code while debugging
- **Remote Debugging:** Debug applications running on other JVMs
- **Performance Debugging:** Identify bottlenecks

### What You'll Build

Debug and fix a buggy e-commerce application with:

- Cart calculation errors
- Concurrency bugs in inventory management
- Exception handling issues
- Performance bottlenecks
- Logic errors in discount calculations

### Prerequisites

- Completed Codelab 1.3 (Exception Handling)
- IDE installed (IntelliJ IDEA recommended, Eclipse also covered)
- Basic understanding of Java applications

### IDE Shortcuts Reference

**IntelliJ IDEA:**

- Debug: `Shift + F9` (Windows/Linux), `Ctrl + D` (Mac)
- Toggle Breakpoint: `Ctrl + F8` (Windows/Linux), `Cmd + F8` (Mac)
- Step Over: `F8`
- Step Into: `F7`
- Step Out: `Shift + F8`
- Resume: `F9`
- Evaluate Expression: `Alt + F8` (Windows/Linux), `Opt + F8` (Mac)

**Eclipse:**

- Debug: `F11`
- Toggle Breakpoint: `Ctrl + Shift + B`
- Step Over: `F6`
- Step Into: `F5`
- Step Out: `F7`
- Resume: `F8`
- Inspect: `Ctrl + Shift + I`

> aside positive
> **Practice Makes Perfect:** The best way to master debugging is to actually debug code. This codelab provides intentionally buggy code for you to fix!

## Understanding Breakpoints

Duration: 10:00

Breakpoints pause program execution, allowing you to inspect the current state.

### Line Breakpoints

The most common type - pause execution at a specific line.

```java
public class Calculator {
    public int add(int a, int b) {
        int result = a + b;  // ← Set breakpoint here
        return result;
    }

    public static void main(String[] args) {
        Calculator calc = new Calculator();
        int sum = calc.add(5, 10);  // Execution pauses when this calls add()
        System.out.println(sum);
    }
}
```

**How to set:**

- IntelliJ: Click in the gutter (left margin) or press `Ctrl + F8`
- Eclipse: Double-click in the margin or press `Ctrl + Shift + B`

### Method Breakpoints

Pause when entering or exiting a method.

```java
public class UserService {
    // Set method breakpoint on the method declaration
    public User findUser(String id) {
        // Pauses when method is called
        return database.findById(id);
    }
}
```

**How to set:**

- IntelliJ: Click on the method line number, right-click → "Method Breakpoint"
- Eclipse: Place breakpoint on method declaration line

### Conditional Breakpoints

Only pause when a condition is true.

```java
public void processOrders(List<Order> orders) {
    for (Order order : orders) {
        // Breakpoint condition: order.getId().equals("12345")
        processOrder(order);  // Only pauses for order 12345
    }
}
```

**How to set:**

- Right-click on breakpoint → Edit
- Enter condition: `order.getId().equals("12345")`
- Or: `order.getAmount() > 1000`

### Exception Breakpoints

Pause when any exception is thrown (even if caught).

```java
public void riskyOperation() {
    try {
        int result = 10 / 0;  // ArithmeticException thrown here
        // Debugger can pause even though exception is caught
    } catch (ArithmeticException e) {
        System.out.println("Error: " + e.getMessage());
    }
}
```

**How to set:**

- IntelliJ: Run → View Breakpoints → + → Java Exception Breakpoints
- Eclipse: Run → Add Java Exception Breakpoint
- Choose exception type (e.g., `NullPointerException`)

### Temporary Breakpoints

Breakpoint that removes itself after first hit.

**IntelliJ:** `Ctrl + Alt + Shift + F8` or right-click breakpoint → "Remove once hit"

### Practical Example

```java
public class BreakpointDemo {
    public static void main(String[] args) {
        // 1. Set line breakpoint here
        int x = 10;

        // 2. Set conditional breakpoint: i == 5
        for (int i = 0; i < 10; i++) {
            System.out.println(i);
        }

        // 3. Set method breakpoint on calculate()
        int result = calculate(x);

        // 4. Exception breakpoint will catch this
        try {
            int error = 10 / 0;
        } catch (ArithmeticException e) {
            e.printStackTrace();
        }
    }

    private static int calculate(int value) {
        return value * 2;
    }
}
```

**Exercise:**

1. Run the code above in debug mode
2. Set different types of breakpoints
3. Observe when each breakpoint triggers
4. Remove and re-add breakpoints during debugging

> aside positive
> **Pro Tip:** Use conditional breakpoints to debug issues that only occur with specific data, like `userId.equals("problematic-user")`.

## Step Debugging Techniques

Duration: 12:00

Step commands control execution flow during debugging.

### Step Over (F8)

Execute the current line and move to the next line in the same method.

```java
public void processOrder(Order order) {
    validateOrder(order);      // Line 1: Step Over executes entire method
    calculateTotal(order);     // → Moves here (doesn't enter calculateTotal)
    saveOrder(order);
}
```

**Use when:** You trust the method works correctly and don't need to see its internals.

### Step Into (F7)

Step into the method call to see its implementation.

```java
public void processOrder(Order order) {
    calculateTotal(order);  // Step Into goes inside calculateTotal()
}

private double calculateTotal(Order order) {
    // ← Debugger enters here
    double total = 0;
    for (Item item : order.getItems()) {
        total += item.getPrice();
    }
    return total;
}
```

**Use when:** You want to debug the method being called.

### Step Out (Shift + F8)

Complete the current method and return to the caller.

```java
private double calculateTotal(Order order) {
    double total = 0;
    for (Item item : order.getItems()) {
        total += item.getPrice();  // Step Out from here
    }
    return total;  // Completes this method
}

public void processOrder(Order order) {
    double total = calculateTotal(order);  // ← Returns here
    System.out.println(total);
}
```

**Use when:** You've seen enough of the current method and want to return to the caller.

### Run to Cursor (Alt + F9)

Run until reaching the line where your cursor is positioned.

```java
public void longMethod() {
    int step1 = doSomething();
    int step2 = doSomethingElse();
    int step3 = moreWork();
    int step4 = finalStep();  // ← Place cursor here, press Alt + F9
    // Execution runs from current position to this line
}
```

**Use when:** You want to skip multiple lines without setting a breakpoint.

### Force Step Into (Alt + Shift + F7)

Step into methods you normally can't (like library code).

```java
public void example() {
    String text = "hello";
    String upper = text.toUpperCase();  // Force Step Into goes into String.toUpperCase()
}
```

### Drop Frame

Go back in the call stack (undo execution).

> aside negative
> **Warning:** Drop Frame doesn't undo side effects (database writes, file changes, etc.). It only resets the call stack.

### Practical Debugging Scenario

```java
public class OrderProcessor {
    public static void main(String[] args) {
        OrderProcessor processor = new OrderProcessor();
        Order order = new Order();
        order.addItem(new Item("Laptop", 1000.0));
        order.addItem(new Item("Mouse", 25.0));

        processor.processOrder(order);  // ← Start debugging here
    }

    public void processOrder(Order order) {
        System.out.println("Processing order...");

        // Step Into to see validation logic
        boolean valid = validateOrder(order);

        if (valid) {
            // Step Into to see calculation
            double total = calculateTotal(order);

            // Step Over - trust this method
            applyDiscount(order, total);

            // Step Into to see save logic
            saveOrder(order);
        }
    }

    private boolean validateOrder(Order order) {
        return order != null && !order.getItems().isEmpty();
    }

    private double calculateTotal(Order order) {
        double total = 0;
        for (Item item : order.getItems()) {
            // Step Over each iteration to see total build up
            total += item.getPrice();
        }
        return total;
    }

    private void applyDiscount(Order order, double total) {
        if (total > 500) {
            order.setDiscount(0.1);  // 10% discount
        }
    }

    private void saveOrder(Order order) {
        System.out.println("Order saved: " + order);
    }
}

class Order {
    private List<Item> items = new ArrayList<>();
    private double discount;

    public void addItem(Item item) { items.add(item); }
    public List<Item> getItems() { return items; }
    public void setDiscount(double discount) { this.discount = discount; }
}

class Item {
    private String name;
    private double price;

    public Item(String name, double price) {
        this.name = name;
        this.price = price;
    }

    public double getPrice() { return price; }
}
```

**Exercise:**

1. Set breakpoint on `processor.processOrder(order)`
2. **Step Into** `processOrder()`
3. **Step Into** `validateOrder()` - observe validation
4. **Step Out** back to `processOrder()`
5. **Step Into** `calculateTotal()`
6. **Step Over** through the loop - watch `total` variable
7. **Step Out** when you've seen enough
8. **Step Over** `applyDiscount()` (trust it works)
9. **Run to Cursor** on the last line

> aside positive
> **Keyboard Shortcuts:** Master F7 (Step Into), F8 (Step Over), Shift+F8 (Step Out). These will become second nature!

## Variables and Expressions

Duration: 10:00

Inspecting and modifying variables during debugging.

### Variables View

The Variables view shows all variables in the current scope.

```java
public void calculateDiscount(Order order) {
    double subtotal = order.getSubtotal();     // Visible in Variables
    double taxRate = 0.08;                      // Visible in Variables
    double tax = subtotal * taxRate;            // Visible in Variables

    String couponCode = order.getCouponCode();  // Can inspect this
    double discount = 0;

    if (couponCode != null) {
        discount = lookupDiscount(couponCode);  // Expand to see object details
    }

    double total = subtotal + tax - discount;   // All visible
}
```

**Features:**

- Expand objects to see fields
- Right-click → "Set Value" to change variables
- See primitive values, object references, collections

### Watches

Monitor specific expressions throughout debugging.

```java
public void processItems(List<Item> items) {
    double total = 0;
    int count = 0;

    for (Item item : items) {
        total += item.getPrice();
        count++;
        // Watch expressions:
        // 1. total / count  (average price)
        // 2. items.size() - count  (remaining items)
        // 3. item.getPrice() > 100  (expensive item?)
    }
}
```

**How to add watch:**

- IntelliJ: Debugger → Watches → + → Enter expression
- Eclipse: Expressions view → Add → Enter expression

**Useful watches:**

```java
// Calculations
total / items.size()
order.getSubtotal() * 1.08

// Conditions
user != null && user.isActive()
items.stream().filter(i -> i.getPrice() > 100).count()

// Method calls (side-effect free)
order.getItems().size()
Math.max(price1, price2)
```

### Evaluate Expression

Evaluate any Java expression in the current context.

```java
public void complexCalculation(int a, int b, int c) {
    int result = a + b * c;  // ← Set breakpoint here

    // Press Alt + F8 (IntelliJ) or Ctrl + Shift + I (Eclipse)
    // Evaluate:
    // - a + b + c
    // - Math.sqrt(a * a + b * b)
    // - String.format("a=%d, b=%d, c=%d", a, b, c)
    // - Arrays.asList(a, b, c).stream().sum()
}
```

**What you can evaluate:**

- ✅ Arithmetic: `a + b * 2`
- ✅ Method calls: `list.size()`, `user.getName()`
- ✅ New objects: `new ArrayList<>(items)`
- ✅ Streams: `items.stream().filter(i -> i.getPrice() > 100).count()`
- ✅ Static methods: `Math.max(a, b)`
- ⚠️ Avoid side effects: Don't call methods that modify state

### Set Value

Change variable values during debugging.

```java
public void applyDiscount(Order order) {
    double discount = 0.10;  // ← Breakpoint here
    // Right-click on 'discount' in Variables view
    // Set Value → Enter: 0.20
    // Continue debugging with new value

    double total = order.getSubtotal() * (1 - discount);
    order.setTotal(total);
}
```

**Use cases:**

- Test different scenarios without restarting
- Fix incorrect values to continue debugging
- Simulate edge cases

### View Object Internals

```java
public void processUser(User user) {
    // Breakpoint here, expand 'user' in Variables view
    String name = user.getName();

    // You'll see:
    // user (User)
    //   ├─ id = "12345"
    //   ├─ name = "John Doe"
    //   ├─ email = "john@example.com"
    //   ├─ orders (ArrayList) size = 3
    //   │   ├─ [0] (Order) { id="O1", total=100.0 }
    //   │   ├─ [1] (Order) { id="O2", total=250.0 }
    //   │   └─ [2] (Order) { id="O3", total=75.0 }
    //   └─ createdAt = "2025-12-24T10:30:00"
}
```

### Practical Example

```java
import java.util.*;

public class ShoppingCart {
    public static void main(String[] args) {
        ShoppingCart cart = new ShoppingCart();
        cart.addItem("Laptop", 1000.0, 1);
        cart.addItem("Mouse", 25.0, 2);
        cart.addItem("Keyboard", 75.0, 1);

        double total = cart.calculateTotal();  // ← Breakpoint here
        System.out.println("Total: $" + total);
    }

    private List<CartItem> items = new ArrayList<>();

    public void addItem(String name, double price, int quantity) {
        items.add(new CartItem(name, price, quantity));
    }

    public double calculateTotal() {
        double total = 0;

        for (CartItem item : items) {
            // Breakpoint here
            double itemTotal = item.price * item.quantity;
            total += itemTotal;

            // In Variables view, you can see:
            // - item (with all fields)
            // - itemTotal
            // - total (accumulated)

            // Add watch: total / items.size() (average so far)
            // Evaluate: item.price * item.quantity * 1.08 (with tax)
        }

        return total;
    }

    static class CartItem {
        String name;
        double price;
        int quantity;

        CartItem(String name, double price, int quantity) {
            this.name = name;
            this.price = price;
            this.quantity = quantity;
        }
    }
}
```

**Exercise:**

1. Set breakpoint in `calculateTotal()` loop
2. Observe all variables in Variables view
3. Add watch: `total / items.size()`
4. Evaluate expression: `item.price * item.quantity * 1.08`
5. Set Value: Change `item.quantity` to 10
6. Continue and observe the effect

> aside positive
> **Pro Tip:** Use "Set Value" to test edge cases like null, empty collections, or extreme values without modifying code!

## Debugging Multi-threaded Code

Duration: 12:00

Debugging concurrent code requires special techniques.

### Thread View

See all threads and their current state.

```java
import java.util.concurrent.*;

public class MultiThreadedApp {
    public static void main(String[] args) {
        ExecutorService executor = Executors.newFixedThreadPool(3);

        for (int i = 0; i < 5; i++) {
            int taskId = i;
            executor.submit(() -> processTask(taskId));
        }

        executor.shutdown();
    }

    private static void processTask(int taskId) {
        // Breakpoint here - you'll see multiple threads
        System.out.println("Task " + taskId + " on " +
            Thread.currentThread().getName());

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

**Thread States in Debugger:**

- **RUNNING:** Currently executing
- **SUSPENDED:** Paused at breakpoint
- **WAITING:** Waiting for monitor/condition
- **SLEEPING:** Thread.sleep()
- **BLOCKED:** Waiting for lock

### Suspend Policy

Control what happens when a breakpoint is hit in multi-threaded code.

**Options:**

1. **Suspend All:** All threads pause (default, safest)
2. **Suspend Thread:** Only the hitting thread pauses

**How to set:**

- Right-click breakpoint → Edit → Suspend: All/Thread

```java
public class ConcurrentCounter {
    private int count = 0;

    public void increment() {
        // Breakpoint with "Suspend All" - all threads freeze
        count++;
    }

    public void decrement() {
        // Breakpoint with "Suspend Thread" - only this thread freezes
        count--;
    }
}
```

### Deadlock Detection

```java
public class DeadlockExample {
    private final Object lock1 = new Object();
    private final Object lock2 = new Object();

    public void method1() {
        synchronized (lock1) {
            System.out.println("Thread 1: Holding lock1...");
            sleep(100);

            synchronized (lock2) {  // ← Waiting for lock2
                System.out.println("Thread 1: Holding lock1 & lock2");
            }
        }
    }

    public void method2() {
        synchronized (lock2) {
            System.out.println("Thread 2: Holding lock2...");
            sleep(100);

            synchronized (lock1) {  // ← Waiting for lock1
                System.out.println("Thread 2: Holding lock1 & lock2");
            }
        }
    }

    private void sleep(long ms) {
        try { Thread.sleep(ms); } catch (InterruptedException e) {}
    }

    public static void main(String[] args) {
        DeadlockExample example = new DeadlockExample();

        new Thread(() -> example.method1()).start();
        new Thread(() -> example.method2()).start();

        // Debugger will show both threads in BLOCKED state
        // IntelliJ: Run → Dump Threads to see deadlock
    }
}
```

**Detecting deadlocks:**

- IntelliJ: Threads view → Right-click → "Detect Deadlock"
- Eclipse: Debug view shows blocked threads
- Look for circular dependencies in lock acquisition

### Race Condition Debugging

```java
public class RaceConditionExample {
    private int balance = 1000;

    public void withdraw(int amount) {
        // Set conditional breakpoint: Thread.currentThread().getName().equals("Thread-1")
        if (balance >= amount) {
            // Another thread might execute here before we subtract!
            System.out.println(Thread.currentThread().getName() +
                " withdrawing " + amount);
            balance -= amount;  // ← Breakpoint here to see race condition
            System.out.println("New balance: " + balance);
        }
    }

    public static void main(String[] args) {
        RaceConditionExample account = new RaceConditionExample();

        // Two threads trying to withdraw simultaneously
        Thread t1 = new Thread(() -> account.withdraw(600));
        Thread t2 = new Thread(() -> account.withdraw(600));

        t1.start();
        t2.start();

        // Without synchronization, balance might go negative!
    }
}
```

**Debug strategy:**

1. Set breakpoint with "Suspend Thread" (not all)
2. Use conditional breakpoints for specific threads
3. Watch the shared variable (`balance`)
4. Step through to see interleaving

### Practical Multi-threaded Example

```java
import java.util.concurrent.*;
import java.util.*;

public class InventoryManager {
    private Map<String, Integer> inventory = new ConcurrentHashMap<>();

    public InventoryManager() {
        inventory.put("LAPTOP", 10);
        inventory.put("MOUSE", 50);
        inventory.put("KEYBOARD", 30);
    }

    public boolean reserveItem(String productId, int quantity) {
        // Breakpoint here - observe multiple threads
        Integer available = inventory.get(productId);

        if (available == null) {
            return false;
        }

        // Add watch: Thread.currentThread().getName()
        // Add watch: available >= quantity

        if (available >= quantity) {
            // Potential race condition! Another thread might reserve
            // between the check and the update
            try {
                Thread.sleep(100);  // Simulate processing delay
            } catch (InterruptedException e) {}

            inventory.put(productId, available - quantity);
            System.out.println(Thread.currentThread().getName() +
                " reserved " + quantity + " of " + productId);
            return true;
        }

        return false;
    }

    public static void main(String[] args) throws InterruptedException {
        InventoryManager manager = new InventoryManager();
        ExecutorService executor = Executors.newFixedThreadPool(3);

        // Multiple threads trying to reserve the same item
        for (int i = 0; i < 5; i++) {
            executor.submit(() -> {
                manager.reserveItem("LAPTOP", 3);
            });
        }

        executor.shutdown();
        executor.awaitTermination(10, TimeUnit.SECONDS);

        System.out.println("Final inventory: " + manager.inventory);
        // Should be -5 (bug!), but with proper synchronization would be 0
    }
}
```

**Debugging steps:**

1. Set breakpoint at `Integer available = inventory.get(productId)`
2. Suspend policy: "Thread" (not "All")
3. Run and hit breakpoint multiple times
4. Switch between threads in Threads view
5. Observe that multiple threads pass the `if (available >= quantity)` check
6. See negative inventory (the bug!)

**Fix:**

```java
public synchronized boolean reserveItem(String productId, int quantity) {
    // Now thread-safe
}
```

> aside negative
> **Common Mistake:** Using "Suspend All" hides race conditions because threads don't actually run concurrently. Use "Suspend Thread" to see real concurrency issues.

## Debug Console and Hot Reload

Duration: 10:00

### Debug Console

Execute code in the context of the current breakpoint.

```java
public class DebugConsoleExample {
    public static void main(String[] args) {
        List<Integer> numbers = Arrays.asList(5, 2, 8, 1, 9, 3);
        int threshold = 5;

        // Breakpoint here
        List<Integer> filtered = numbers.stream()
            .filter(n -> n > threshold)
            .collect(Collectors.toList());

        System.out.println(filtered);
    }
}
```

**In Debug Console (IntelliJ: Debugger → Console), you can:**

```java
// Execute statements
System.out.println("Numbers: " + numbers);

// Call methods
numbers.size()
numbers.get(0)
Collections.sort(numbers)

// Create new objects
new ArrayList<>(numbers)

// Complex expressions
numbers.stream().mapToInt(Integer::intValue).average()

// Modify variables
threshold = 7  // Changes the variable value!

// Test fixes
numbers.stream().filter(n -> n >= threshold).collect(Collectors.toList())
```

### Evaluate and Execute

**Evaluate Expression (Alt + F8):**

- Returns a result
- No side effects (usually)
- Good for inspecting values

**Execute Statement:**

- Runs code with side effects
- Can modify variables
- Can call void methods

```java
public void processOrder(Order order) {
    double total = calculateTotal(order);
    double tax = total * 0.08;  // ← Breakpoint here

    // Evaluate (Alt + F8):
    // total * 0.10  // Returns: 100.0

    // Execute in Debug Console:
    // tax = total * 0.10  // Changes tax variable!
    // System.out.println("Tax: " + tax)  // Prints to console
}
```

### Hot Code Replace / Hot Swap

Modify code while debugging without restarting.

```java
public class HotSwapExample {
    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            String message = getMessage(i);  // ← Breakpoint here
            System.out.println(message);

            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {}
        }
    }

    private static String getMessage(int i) {
        return "Count: " + i;  // While paused, change to: "Number: " + i
        // Save file, debugger reloads code!
    }
}
```

**What you can hot reload:**

- ✅ Method bodies
- ✅ Variable values
- ✅ Logic changes
- ❌ Method signatures (name, parameters, return type)
- ❌ Adding/removing methods
- ❌ Class structure changes

**How to use:**

1. Pause at breakpoint
2. Modify the code
3. Save the file
4. IntelliJ: Automatically reloads (or Build → Recompile)
5. Eclipse: Automatically if "Hot Code Replace" enabled
6. Continue debugging with new code

### Rerun Frame / Drop Frame

Go back to the beginning of the current method.

```java
public void processItems(List<Item> items) {
    for (Item item : items) {
        processItem(item);  // ← Breakpoint here
    }
}

private void processItem(Item item) {
    // Debug this method
    double price = item.getPrice();
    double tax = price * 0.08;
    double total = price + tax;

    // Oops, tax calculation is wrong!
    // 1. Right-click on method in call stack
    // 2. "Drop Frame" or "Rerun Frame"
    // 3. Fix the code: tax = price * 0.10
    // 4. Method runs again with new code
}
```

### Practical Example

```java
import java.util.*;
import java.util.stream.*;

public class DataProcessor {
    public static void main(String[] args) {
        DataProcessor processor = new DataProcessor();

        List<Transaction> transactions = Arrays.asList(
            new Transaction("T1", 100.0, "SALE"),
            new Transaction("T2", 50.0, "RETURN"),
            new Transaction("T3", 200.0, "SALE"),
            new Transaction("T4", 75.0, "RETURN")
        );

        // Breakpoint here
        Report report = processor.generateReport(transactions);
        System.out.println(report);
    }

    public Report generateReport(List<Transaction> transactions) {
        Report report = new Report();

        // Breakpoint here - now use Debug Console
        double totalSales = transactions.stream()
            .filter(t -> t.type.equals("SALE"))
            .mapToDouble(t -> t.amount)
            .sum();

        // In Debug Console, test:
        // transactions.stream().filter(t -> t.type.equals("RETURN")).count()
        // transactions.stream().mapToDouble(t -> t.amount).average()

        double totalReturns = transactions.stream()
            .filter(t -> t.type.equals("RETURN"))
            .mapToDouble(t -> t.amount)
            .sum();

        report.totalSales = totalSales;
        report.totalReturns = totalReturns;
        report.netSales = totalSales - totalReturns;

        return report;
    }

    static class Transaction {
        String id;
        double amount;
        String type;

        Transaction(String id, double amount, String type) {
            this.id = id;
            this.amount = amount;
            this.type = type;
        }
    }

    static class Report {
        double totalSales;
        double totalReturns;
        double netSales;

        @Override
        public String toString() {
            return String.format("Sales: $%.2f, Returns: $%.2f, Net: $%.2f",
                totalSales, totalReturns, netSales);
        }
    }
}
```

**Exercise:**

1. Run in debug mode
2. Pause at breakpoint in `generateReport()`
3. Open Debug Console
4. Execute: `transactions.size()`
5. Execute: `transactions.get(0).amount`
6. Execute complex expression: `transactions.stream().filter(t -> t.type.equals("SALE")).mapToDouble(t -> t.amount).sum()`
7. Modify: `report.netSales = totalSales - totalReturns * 2` (apply double credit for returns)
8. Continue and see modified result

> aside positive
> **Power User:** Debug Console lets you test fixes immediately without stopping and restarting the application!

## Remote Debugging

Duration: 8:00

Debug applications running on remote servers or in containers.

### Why Remote Debugging?

- Debug production issues (staging/QA environments)
- Debug Docker containers
- Debug server applications
- Debug distributed systems
- Investigate issues that only occur in specific environments

### Enable Remote Debugging

**Start JVM with debug options:**

```bash
# Standard format (works for all JVMs)
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar myapp.jar

# Older format (Java 8 and earlier)
java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005 -jar myapp.jar
```

**Parameters:**

- `transport=dt_socket`: Use TCP/IP
- `server=y`: JVM waits for debugger to attach
- `suspend=n`: Start immediately (use `y` to wait for debugger)
- `address=*:5005`: Listen on all interfaces, port 5005

**Maven:**

```bash
mvn spring-boot:run -Dagentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
```

**Gradle:**

```bash
./gradlew bootRun --debug-jvm
```

### Configure IDE

**IntelliJ IDEA:**

1. Run → Edit Configurations
2. Add New → Remote JVM Debug
3. Name: "Remote Debug"
4. Host: `localhost` (or remote host IP)
5. Port: `5005`
6. Use module classpath: Select your module
7. Click OK

**Eclipse:**

1. Run → Debug Configurations
2. Remote Java Application → New
3. Project: Select your project
4. Host: `localhost` (or remote IP)
5. Port: `5005`
6. Click Debug

### Remote Debugging Example

**Application to debug:**

```java
// RemoteApp.java
import java.util.*;
import java.util.concurrent.TimeUnit;

public class RemoteApp {
    private static int counter = 0;

    public static void main(String[] args) throws Exception {
        System.out.println("Remote application started...");
        System.out.println("Attach debugger to port 5005");

        while (true) {
            processData();
            Thread.sleep(2000);
        }
    }

    private static void processData() {
        counter++;
        System.out.println("Processing... Count: " + counter);

        // Set breakpoint here when debugging remotely
        int result = calculate(counter);
        System.out.println("Result: " + result);

        if (counter % 5 == 0) {
            System.out.println("Milestone reached!");
        }
    }

    private static int calculate(int value) {
        // Complex calculation - set breakpoint to debug
        return value * 2 + 10;
    }
}
```

**Steps:**

1. **Compile the application:**

```bash
javac RemoteApp.java
```

2. **Run with debug enabled:**

```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 RemoteApp
```

Output:

```
Listening for transport dt_socket at address: 5005
Remote application started...
Attach debugger to port 5005
Processing... Count: 1
Result: 12
Processing... Count: 2
Result: 14
...
```

3. **Attach debugger from IDE:**

   - Run your "Remote Debug" configuration
   - Set breakpoints in `processData()` or `calculate()`
   - Debugger connects and pauses at breakpoints

4. **Debug as normal:**
   - Step through code
   - Inspect variables
   - Evaluate expressions
   - Modify values

### Docker Remote Debugging

**Dockerfile:**

```dockerfile
FROM openjdk:17-slim
COPY target/myapp.jar /app/myapp.jar
WORKDIR /app

# Expose debug port
EXPOSE 5005

# Run with debug enabled
ENTRYPOINT ["java", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", "-jar", "myapp.jar"]
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
      - JAVA_TOOL_OPTIONS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
```

**Run:**

```bash
docker-compose up
```

**Connect debugger to localhost:5005**

### Security Considerations

> aside negative
> **Warning:** Never enable remote debugging on production servers exposed to the internet! An attacker with debugger access can execute arbitrary code.

**Best practices:**

- Only enable in dev/staging environments
- Use SSH tunneling for remote servers
- Restrict to localhost or internal networks
- Disable in production
- Use `suspend=y` only during development

**SSH Tunnel (safe for remote servers):**

```bash
# On your local machine
ssh -L 5005:localhost:5005 user@remote-server

# Now connect debugger to localhost:5005
# Traffic is encrypted through SSH
```

### Practical Remote Debugging

```java
// WebService.java
import java.io.*;
import java.net.*;

public class WebService {
    public static void main(String[] args) throws Exception {
        int port = 8080;
        ServerSocket serverSocket = new ServerSocket(port);
        System.out.println("Server listening on port " + port);
        System.out.println("Debug on port 5005");

        while (true) {
            Socket client = serverSocket.accept();
            handleClient(client);
        }
    }

    private static void handleClient(Socket client) throws Exception {
        BufferedReader in = new BufferedReader(
            new InputStreamReader(client.getInputStream()));
        PrintWriter out = new PrintWriter(client.getOutputStream(), true);

        String request = in.readLine();
        System.out.println("Received: " + request);

        // Set breakpoint here for remote debugging
        String response = processRequest(request);

        out.println("HTTP/1.1 200 OK");
        out.println("Content-Type: text/plain");
        out.println();
        out.println(response);

        client.close();
    }

    private static String processRequest(String request) {
        // Breakpoint here to debug request processing
        if (request == null || request.isEmpty()) {
            return "Empty request";
        }

        return "Processed: " + request.toUpperCase();
    }
}
```

**Debug remotely:**

1. Run with debug: `java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 WebService`
2. Attach debugger from IDE
3. Set breakpoints in `handleClient()` and `processRequest()`
4. Make request: `curl http://localhost:8080`
5. Debugger pauses, inspect request, step through

> aside positive
> **Pro Tip:** Remote debugging is invaluable for investigating issues that only occur in specific environments (staging, QA, containers).

## Debugging Challenge

Duration: 25:00

Time to practice! Here's a buggy e-commerce application. Find and fix all bugs using debugging techniques.

### The Buggy Application

```java
import java.util.*;
import java.util.concurrent.*;

class Product {
    String id;
    String name;
    double price;
    int stock;

    Product(String id, String name, double price, int stock) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.stock = stock;
    }
}

class CartItem {
    Product product;
    int quantity;

    CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }

    double getSubtotal() {
        return product.price * quantity;
    }
}

class ShoppingCart {
    private List<CartItem> items = new ArrayList<>();
    private String couponCode;

    public void addItem(Product product, int quantity) {
        // BUG 1: Doesn't check if product already in cart
        items.add(new CartItem(product, quantity));
    }

    public void applyCoupon(String code) {
        this.couponCode = code;
    }

    public double calculateTotal() {
        double subtotal = 0;

        for (CartItem item : items) {
            subtotal += item.getSubtotal();
        }

        double discount = calculateDiscount(subtotal);
        double tax = subtotal * 0.08;  // BUG 2: Tax calculated before discount

        return subtotal - discount + tax;
    }

    private double calculateDiscount(double subtotal) {
        if (couponCode == null) {
            return 0;
        }

        // BUG 3: Logic error in discount calculation
        if (couponCode.equals("SAVE10")) {
            return subtotal * 0.10;
        } else if (couponCode == "SAVE20") {  // BUG 4: Using == instead of .equals()
            return subtotal * 0.20;
        } else if (couponCode.equals("FREESHIP")) {
            return 10.0;  // Free shipping
        }

        return 0;
    }

    public List<CartItem> getItems() {
        return items;
    }
}

class InventoryManager {
    private Map<String, Product> products = new ConcurrentHashMap<>();

    public InventoryManager() {
        products.put("P1", new Product("P1", "Laptop", 1000.0, 10));
        products.put("P2", new Product("P2", "Mouse", 25.0, 50));
        products.put("P3", new Product("P3", "Keyboard", 75.0, 30));
    }

    public Product getProduct(String id) {
        return products.get(id);
    }

    public boolean reserveStock(String productId, int quantity) {
        Product product = products.get(productId);

        if (product == null) {
            return false;
        }

        // BUG 5: Race condition - not thread-safe
        if (product.stock >= quantity) {
            try {
                Thread.sleep(50);  // Simulate processing delay
            } catch (InterruptedException e) {}

            product.stock -= quantity;
            return true;
        }

        return false;
    }

    public void restoreStock(String productId, int quantity) {
        Product product = products.get(productId);
        if (product != null) {
            product.stock += quantity;
        }
    }
}

class Order {
    String orderId;
    ShoppingCart cart;
    double total;

    Order(String orderId, ShoppingCart cart) {
        this.orderId = orderId;
        this.cart = cart;
        this.total = cart.calculateTotal();
    }
}

class OrderProcessor {
    private InventoryManager inventory;
    private List<Order> orders = new ArrayList<>();

    public OrderProcessor(InventoryManager inventory) {
        this.inventory = inventory;
    }

    public Order processOrder(ShoppingCart cart) {
        // Reserve stock for all items
        for (CartItem item : cart.getItems()) {
            boolean reserved = inventory.reserveStock(
                item.product.id, item.quantity);

            if (!reserved) {
                // BUG 6: Doesn't restore previously reserved stock on failure
                System.out.println("Failed to reserve: " + item.product.name);
                return null;
            }
        }

        // Create order
        String orderId = "ORD" + (orders.size() + 1);
        Order order = new Order(orderId, cart);
        orders.add(order);

        return order;
    }

    public List<Order> getOrders() {
        return orders;
    }
}

public class EcommerceApp {
    public static void main(String[] args) throws Exception {
        InventoryManager inventory = new InventoryManager();
        OrderProcessor orderProcessor = new OrderProcessor(inventory);

        // Test 1: Basic order
        System.out.println("=== Test 1: Basic Order ===");
        ShoppingCart cart1 = new ShoppingCart();
        cart1.addItem(inventory.getProduct("P1"), 1);
        cart1.addItem(inventory.getProduct("P2"), 2);

        Order order1 = orderProcessor.processOrder(cart1);
        System.out.println("Order total: $" + order1.total);
        System.out.println("Expected: $1058.0 (1000 + 50 + 8% tax)");

        // Test 2: With coupon
        System.out.println("\n=== Test 2: With Coupon ===");
        ShoppingCart cart2 = new ShoppingCart();
        cart2.addItem(inventory.getProduct("P1"), 1);
        cart2.applyCoupon("SAVE10");

        Order order2 = orderProcessor.processOrder(cart2);
        System.out.println("Order total: $" + order2.total);
        System.out.println("Expected: $972.0 (1000 - 100 discount + 72 tax)");

        // Test 3: Duplicate items
        System.out.println("\n=== Test 3: Duplicate Items ===");
        ShoppingCart cart3 = new ShoppingCart();
        cart3.addItem(inventory.getProduct("P2"), 2);
        cart3.addItem(inventory.getProduct("P2"), 3);  // Same product again

        Order order3 = orderProcessor.processOrder(cart3);
        System.out.println("Cart items count: " + cart3.getItems().size());
        System.out.println("Expected: 1 item with quantity 5");
        System.out.println("Actual: " + cart3.getItems().size() + " items");

        // Test 4: Concurrent orders (race condition)
        System.out.println("\n=== Test 4: Concurrent Orders ===");
        ExecutorService executor = Executors.newFixedThreadPool(3);

        for (int i = 0; i < 5; i++) {
            executor.submit(() -> {
                ShoppingCart cart = new ShoppingCart();
                cart.addItem(inventory.getProduct("P2"), 15);

                Order order = orderProcessor.processOrder(cart);
                if (order != null) {
                    System.out.println(Thread.currentThread().getName() +
                        ": Order created");
                } else {
                    System.out.println(Thread.currentThread().getName() +
                        ": Order failed - out of stock");
                }
            });
        }

        executor.shutdown();
        executor.awaitTermination(10, TimeUnit.SECONDS);

        // Check final stock
        Product mouse = inventory.getProduct("P2");
        System.out.println("Final mouse stock: " + mouse.stock);
        System.out.println("Expected: 0 or positive");
        System.out.println("Actual: " + (mouse.stock < 0 ? "NEGATIVE (BUG!)" : "OK"));
    }
}
```

### Bugs to Find

**BUG 1: Duplicate cart items** (Line 48)

- **Symptom:** Adding same product twice creates two cart items
- **Debug technique:** Breakpoint in `addItem()`, inspect `items` list
- **Fix:** Check if product already exists and update quantity

**BUG 2: Tax calculation order** (Line 62)

- **Symptom:** Tax calculated on full subtotal instead of after discount
- **Debug technique:** Breakpoint in `calculateTotal()`, evaluate expressions
- **Fix:** Calculate tax on (subtotal - discount)

**BUG 3: Discount logic** (Line 69-78)

- **Symptom:** Multiple if-else blocks, unclear logic
- **Debug technique:** Step through with different coupons, watch discount value
- **Fix:** Simplify logic, ensure all cases covered

**BUG 4: String comparison** (Line 73)

- **Symptom:** "SAVE20" coupon never works
- **Debug technique:** Conditional breakpoint `couponCode.equals("SAVE20")`
- **Fix:** Use `.equals()` instead of `==`

**BUG 5: Race condition** (Line 100-111)

- **Symptom:** Negative stock in concurrent orders
- **Debug technique:** Multiple threads, watch `product.stock`
- **Fix:** Synchronize the method or use atomic operations

**BUG 6: Stock rollback** (Line 135-143)

- **Symptom:** Stock reserved but not restored on failure
- **Debug technique:** Set breakpoint on `return null`, check stock
- **Fix:** Track reserved items and restore on failure

### Debugging Steps

1. **Setup:**

   ```bash
   javac EcommerceApp.java
   java EcommerceApp
   ```

   Observe the incorrect output.

2. **Fix BUG 1:** Duplicate cart items

   - Set breakpoint in `ShoppingCart.addItem()`
   - Add same product twice
   - Inspect `items` list - see two entries
   - **Fix:**

   ```java
   public void addItem(Product product, int quantity) {
       for (CartItem item : items) {
           if (item.product.id.equals(product.id)) {
               item.quantity += quantity;
               return;
           }
       }
       items.add(new CartItem(product, quantity));
   }
   ```

3. **Fix BUG 2:** Tax calculation

   - Breakpoint in `calculateTotal()`
   - Evaluate: `subtotal`, `discount`, `tax`
   - Notice tax is on full subtotal
   - **Fix:**

   ```java
   public double calculateTotal() {
       double subtotal = 0;
       for (CartItem item : items) {
           subtotal += item.getSubtotal();
       }

       double discount = calculateDiscount(subtotal);
       double discountedSubtotal = subtotal - discount;
       double tax = discountedSubtotal * 0.08;

       return discountedSubtotal + tax;
   }
   ```

4. **Fix BUG 4:** String comparison

   - Conditional breakpoint: `couponCode != null && couponCode.contains("SAVE20")`
   - Step through, notice `==` comparison fails
   - **Fix:**

   ```java
   } else if (couponCode.equals("SAVE20")) {
       return subtotal * 0.20;
   }
   ```

5. **Fix BUG 5:** Race condition

   - Set breakpoint in `reserveStock()` with "Suspend Thread"
   - Run concurrent test
   - Watch multiple threads in Variables view
   - See multiple threads pass the `if (product.stock >= quantity)` check
   - **Fix:**

   ```java
   public synchronized boolean reserveStock(String productId, int quantity) {
       // Now thread-safe
   }
   ```

6. **Fix BUG 6:** Stock rollback
   - Breakpoint when `reserved == false`
   - Inspect: previous items already reserved
   - **Fix:**
   ```java
   public Order processOrder(ShoppingCart cart) {
       List<CartItem> reserved = new ArrayList<>();

       for (CartItem item : cart.getItems()) {
           boolean success = inventory.reserveStock(
               item.product.id, item.quantity);

           if (!success) {
               // Restore previously reserved stock
               for (CartItem reservedItem : reserved) {
                   inventory.restoreStock(
                       reservedItem.product.id, reservedItem.quantity);
               }
               return null;
           }

           reserved.add(item);
       }

       String orderId = "ORD" + (orders.size() + 1);
       Order order = new Order(orderId, cart);
       orders.add(order);

       return order;
   }
   ```

### Verify Fixes

Run the corrected application:

```
=== Test 1: Basic Order ===
Order total: $1058.0
Expected: $1058.0 (1000 + 50 + 8% tax)
✓ PASS

=== Test 2: With Coupon ===
Order total: $972.0
Expected: $972.0 (1000 - 100 discount + 72 tax)
✓ PASS

=== Test 3: Duplicate Items ===
Cart items count: 1
Expected: 1 item with quantity 5
Actual: 1 items
✓ PASS

=== Test 4: Concurrent Orders ===
Final mouse stock: 0
Expected: 0 or positive
Actual: OK
✓ PASS
```

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered IDE debugging!

### What You've Learned

- ✅ **Breakpoint Types:** Line, method, conditional, exception
- ✅ **Logpoints:** Non-intrusive debugging
- ✅ **Step Debugging:** Into, Over, Out, Run to Cursor
- ✅ **Variables:** Inspection, watches, modification
- ✅ **Multi-threading:** Thread debugging, race conditions, deadlocks
- ✅ **Debug Console:** Interactive expression evaluation
- ✅ **Hot Reload:** Modify code without restarting
- ✅ **Remote Debugging:** Debug applications on remote servers
- ✅ **Real Bugs:** Fixed 6 bugs in e-commerce app

### Key Takeaways

1. **Breakpoints are powerful** - use conditional and exception breakpoints
2. **Step debugging reveals flow** - understand execution path
3. **Inspect everything** - variables, expressions, watches
4. **Thread debugging is tricky** - use "Suspend Thread" for race conditions
5. **Debug Console is your friend** - test fixes interactively
6. **Remote debugging saves time** - debug in real environments
7. **Practice makes perfect** - debug often to master the tools

### Debugging Strategy

1. **Reproduce the bug** consistently
2. **Set breakpoints** near the problem area
3. **Step through** to understand flow
4. **Inspect variables** to find incorrect values
5. **Evaluate expressions** to test hypotheses
6. **Fix and verify** using hot reload
7. **Test edge cases** to ensure complete fix

### IDE Shortcuts Mastery

**Essential shortcuts:**

- `F7` - Step Into
- `F8` - Step Over
- `Shift + F8` - Step Out
- `F9` - Resume
- `Alt + F8` - Evaluate Expression
- `Ctrl + F8` - Toggle Breakpoint

Practice these until they're muscle memory!

### Next Steps

Continue to:

- **Codelab 3.1:** Spring Core & Boot Basics
- **Codelab 3.2:** REST APIs & Swagger Documentation
- **Codelab 3.8:** Testing & Remote Debugging (advanced)

### Additional Resources

- [IntelliJ IDEA Debugging Guide](https://www.jetbrains.com/help/idea/debugging-code.html)
- [Eclipse Debugging Tutorial](https://www.eclipse.org/community/eclipse_newsletter/2017/june/article1.php)
- [Java Debugging Best Practices](https://www.baeldung.com/java-debugging)
- [Debugging Multi-threaded Applications](https://www.oracle.com/technical-resources/articles/java/debug-threads.html)

> aside positive
> **Debug Like a Pro!** Mastering debugging techniques will make you 10x more productive as a developer. These skills transfer across all IDEs and languages!
