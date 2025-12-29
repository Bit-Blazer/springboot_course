summary: Master functional programming with lambdas, functional interfaces, Stream API operations, and collectors by building a sales analytics application
id: functional-programming-streams
categories: Java, Java 8, Functional Programming, Streams API
environments: Web
status: Published
home url: /springboot_course/

# Functional Programming & Streams API

## Introduction

Duration: 5:00

Welcome to the world of functional programming in Java! Java 8 introduced a paradigm shift with lambda expressions and the Stream API, enabling you to write more concise, expressive, and maintainable code.

### What You'll Learn

- Functional programming concepts and paradigm shift
- Lambda expressions syntax and best practices
- Functional interfaces (Predicate, Function, Consumer, Supplier, BiFunction)
- Method references (static, instance, constructor)
- Stream API creation and pipeline operations
- Intermediate operations (filter, map, flatMap, sorted, distinct)
- Terminal operations (collect, forEach, reduce, count)
- Collectors (toList, toSet, toMap, groupingBy, partitioningBy)
- Parallel streams and performance considerations

### What You'll Build

A comprehensive **Sales Analytics Application** featuring:

- Sales data processing with functional style
- Complex filtering and transformations
- Statistical analysis using collectors
- Revenue calculations and grouping
- Performance comparison: imperative vs functional
- Parallel stream processing demonstration

### Prerequisites

- Completed Codelab 1.4 (Collections & Generics)
- Understanding of interfaces and anonymous classes
- Basic knowledge of data structures

## Understanding Functional Programming

Duration: 8:00

Functional programming treats computation as the evaluation of mathematical functions, avoiding changing state and mutable data.

### Imperative vs Functional Style

**Imperative Approach (Traditional Java):**

```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");
List<String> result = new ArrayList<>();

for (String name : names) {
    if (name.length() > 3) {
        result.add(name.toUpperCase());
    }
}

Collections.sort(result);
System.out.println(result);
```

**Functional Approach (Java 8+):**

```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");

List<String> result = names.stream()
    .filter(name -> name.length() > 3)
    .map(String::toUpperCase)
    .sorted()
    .collect(Collectors.toList());

System.out.println(result);
```

> aside positive
> **Key Difference:** Functional style describes **what** you want, not **how** to do it. It's declarative, not imperative.

### Core Principles

**1. Immutability:**

```java
// Immutable approach
List<Integer> numbers = List.of(1, 2, 3, 4, 5);
List<Integer> doubled = numbers.stream()
    .map(n -> n * 2)
    .collect(Collectors.toList());
// Original list unchanged
```

**2. Pure Functions:**

```java
// Pure function - no side effects, same input = same output
Function<Integer, Integer> square = x -> x * x;
System.out.println(square.apply(5));  // Always 25
```

**3. First-Class Functions:**

```java
// Functions as arguments
public static void processData(List<Integer> data, Function<Integer, Integer> operation) {
    data.forEach(item -> System.out.println(operation.apply(item)));
}

// Pass function as argument
processData(Arrays.asList(1, 2, 3), x -> x * 2);
```

### Benefits

- **Conciseness:** Less boilerplate code
- **Readability:** Clear intent, self-documenting
- **Testability:** Pure functions are easy to test
- **Parallelization:** Easy to run operations in parallel
- **Maintainability:** Fewer bugs from mutable state

> aside negative
> **Learning Curve:** Functional style requires a mindset shift. It may feel unfamiliar at first, but becomes natural with practice.

## Lambda Expressions

Duration: 10:00

Lambda expressions provide a clear and concise way to represent a method interface using an expression.

### Syntax

**Basic Structure:**

```java
(parameters) -> expression
(parameters) -> { statements; }
```

**Examples:**

```java
// No parameters
() -> System.out.println("Hello")
() -> 42

// Single parameter (parentheses optional)
x -> x * x
(x) -> x * x

// Multiple parameters
(x, y) -> x + y
(x, y) -> {
    int sum = x + y;
    return sum;
}

// Type declarations (optional)
(int x, int y) -> x + y
(String s) -> s.length()
```

### Lambda vs Anonymous Class

**Anonymous Class (Old Way):**

```java
Runnable runnable = new Runnable() {
    @Override
    public void run() {
        System.out.println("Running...");
    }
};
```

**Lambda Expression (Modern Way):**

```java
Runnable runnable = () -> System.out.println("Running...");
```

### Practical Examples

```java
import java.util.*;
import java.util.function.*;

public class LambdaExamples {
    public static void main(String[] args) {
        // Example 1: Sorting with lambda
        List<String> names = Arrays.asList("Charlie", "Alice", "Bob");
        names.sort((a, b) -> a.compareTo(b));
        System.out.println("Sorted: " + names);

        // Example 2: Filtering with lambda
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6);
        numbers.removeIf(n -> n % 2 == 0);  // Remove even numbers
        System.out.println("Odd numbers: " + numbers);

        // Example 3: forEach with lambda
        Map<String, Integer> ages = new HashMap<>();
        ages.put("Alice", 25);
        ages.put("Bob", 30);
        ages.forEach((name, age) ->
            System.out.println(name + " is " + age + " years old")
        );

        // Example 4: Thread with lambda
        Thread thread = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                System.out.println("Count: " + i);
            }
        });
        thread.start();
    }
}
```

### Variable Capture

Lambdas can access variables from the enclosing scope:

```java
String prefix = "Message: ";
List<String> messages = Arrays.asList("Hello", "World");

messages.forEach(msg -> System.out.println(prefix + msg));
// Outputs: Message: Hello, Message: World
```

> aside negative
> **Important:** Captured variables must be **effectively final** (never reassigned after initialization).

```java
int count = 0;
messages.forEach(msg -> {
    // count++;  // ERROR! Cannot modify captured variable
    System.out.println(msg);
});
```

## Functional Interfaces

Duration: 12:00

A functional interface has exactly one abstract method and can be used as the target for lambda expressions.

### Built-in Functional Interfaces

Java provides many functional interfaces in `java.util.function`:

**1. Predicate\<T\> - Boolean Test**

```java
import java.util.function.Predicate;

Predicate<Integer> isEven = n -> n % 2 == 0;
Predicate<String> isLong = s -> s.length() > 5;

System.out.println(isEven.test(4));    // true
System.out.println(isLong.test("Hi")); // false

// Combining predicates
Predicate<Integer> isPositive = n -> n > 0;
Predicate<Integer> isPositiveEven = isEven.and(isPositive);

System.out.println(isPositiveEven.test(4));   // true
System.out.println(isPositiveEven.test(-4));  // false
```

**2. Function<T, R> - Transform Input to Output**

```java
import java.util.function.Function;

Function<String, Integer> strLength = s -> s.length();
Function<Integer, Integer> square = n -> n * n;

System.out.println(strLength.apply("Hello"));  // 5
System.out.println(square.apply(5));           // 25

// Chaining functions
Function<String, Integer> strLengthSquared = strLength.andThen(square);
System.out.println(strLengthSquared.apply("Hi"));  // 4 (length=2, squared=4)
```

**3. Consumer\<T\> - Accept Input, No Return**

```java
import java.util.function.Consumer;

Consumer<String> printer = s -> System.out.println(s);
Consumer<String> upperPrinter = s -> System.out.println(s.toUpperCase());

printer.accept("hello");       // hello
upperPrinter.accept("hello");  // HELLO

// Chaining consumers
Consumer<String> combined = printer.andThen(upperPrinter);
combined.accept("test");
// Output:
// test
// TEST
```

**4. Supplier\<T\> - Provide Value, No Input**

```java
import java.util.function.Supplier;

Supplier<Double> randomValue = () -> Math.random();
Supplier<String> greeting = () -> "Hello, World!";

System.out.println(randomValue.get());  // 0.123456...
System.out.println(greeting.get());     // Hello, World!

// Lazy evaluation
Supplier<List<String>> expensiveOperation = () -> {
    System.out.println("Computing...");
    return Arrays.asList("Result1", "Result2");
};

// Not computed yet
List<String> result = expensiveOperation.get();  // Now computed
```

**5. BiFunction<T, U, R> - Two Inputs, One Output**

```java
import java.util.function.BiFunction;

BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;
BiFunction<String, String, String> concat = (s1, s2) -> s1 + s2;

System.out.println(add.apply(5, 3));           // 8
System.out.println(concat.apply("Hi", "!"));   // Hi!
```

### Custom Functional Interface

```java
@FunctionalInterface
public interface Calculator {
    int calculate(int a, int b);

    // Default methods allowed
    default void printResult(int a, int b) {
        System.out.println("Result: " + calculate(a, b));
    }
}

public class FunctionalInterfaceDemo {
    public static void main(String[] args) {
        Calculator add = (a, b) -> a + b;
        Calculator multiply = (a, b) -> a * b;

        System.out.println(add.calculate(5, 3));       // 8
        System.out.println(multiply.calculate(5, 3));  // 15

        add.printResult(10, 20);  // Result: 30
    }
}
```

> aside positive
> **@FunctionalInterface:** This annotation is optional but recommended. It ensures the interface has exactly one abstract method.

### Functional Interface Reference Table

| Interface           | Method Signature      | Use Case             |
| ------------------- | --------------------- | -------------------- |
| `Predicate<T>`      | `boolean test(T t)`   | Testing conditions   |
| `Function<T,R>`     | `R apply(T t)`        | Transforming data    |
| `Consumer<T>`       | `void accept(T t)`    | Processing/printing  |
| `Supplier<T>`       | `T get()`             | Generating/providing |
| `BiFunction<T,U,R>` | `R apply(T t, U u)`   | Two-arg operations   |
| `UnaryOperator<T>`  | `T apply(T t)`        | Same type transform  |
| `BinaryOperator<T>` | `T apply(T t1, T t2)` | Combining same types |

## Method References

Duration: 8:00

Method references are shorthand notation for lambda expressions that call a specific method.

### Syntax: `::`

**Four Types of Method References:**

### 1. Static Method Reference

```java
// Lambda
Function<String, Integer> parser1 = s -> Integer.parseInt(s);

// Method reference
Function<String, Integer> parser2 = Integer::parseInt;

System.out.println(parser2.apply("123"));  // 123
```

**More Examples:**

```java
// Math static methods
List<Double> numbers = Arrays.asList(-1.5, 2.3, -3.7);
numbers.stream()
    .map(Math::abs)  // Static method reference
    .forEach(System.out::println);

// Custom static method
public class StringUtils {
    public static boolean isNotEmpty(String s) {
        return s != null && !s.isEmpty();
    }
}

List<String> strings = Arrays.asList("", "Hello", null, "World");
long count = strings.stream()
    .filter(StringUtils::isNotEmpty)
    .count();
```

### 2. Instance Method Reference (Specific Object)

```java
String prefix = "Item: ";

// Lambda
Consumer<String> printer1 = s -> System.out.println(prefix + s);

// Method reference
System.out println  // Output stream instance
Consumer<String> printer2 = System.out::println;

List<String> items = Arrays.asList("Apple", "Banana", "Cherry");
items.forEach(System.out::println);
```

### 3. Instance Method Reference (Arbitrary Object)

```java
// Lambda
Function<String, String> upper1 = s -> s.toUpperCase();

// Method reference
Function<String, String> upper2 = String::toUpperCase;

List<String> words = Arrays.asList("hello", "world");
words.stream()
    .map(String::toUpperCase)  // Called on each element
    .forEach(System.out::println);
```

**Comparison Method:**

```java
List<String> names = Arrays.asList("Charlie", "Alice", "Bob");

// Lambda
names.sort((a, b) -> a.compareToIgnoreCase(b));

// Method reference
names.sort(String::compareToIgnoreCase);
```

### 4. Constructor Reference

```java
// Lambda
Supplier<List<String>> listSupplier1 = () -> new ArrayList<>();

// Constructor reference
Supplier<List<String>> listSupplier2 = ArrayList::new;

List<String> list = listSupplier2.get();
```

**With Parameters:**

```java
// Single parameter constructor
Function<String, Integer> intCreator = Integer::new;
Integer num = intCreator.apply("123");  // Creates Integer from String

// Array constructor
IntFunction<int[]> arrayCreator = int[]::new;
int[] array = arrayCreator.apply(10);  // Creates int[10]
```

### Practical Examples

```java
import java.util.*;
import java.util.stream.*;

public class MethodReferenceDemo {
    public static void main(String[] args) {
        List<String> names = Arrays.asList("Alice", "bob", "CHARLIE");

        // 1. Static method reference
        List<Integer> numbers = Arrays.asList("1", "2", "3").stream()
            .map(Integer::parseInt)
            .collect(Collectors.toList());

        // 2. Instance method (specific object)
        names.forEach(System.out::println);

        // 3. Instance method (arbitrary object)
        List<String> upperNames = names.stream()
            .map(String::toUpperCase)
            .collect(Collectors.toList());

        // 4. Constructor reference
        Set<String> nameSet = names.stream()
            .collect(Collectors.toCollection(HashSet::new));

        // Comparison with method reference
        names.sort(String::compareToIgnoreCase);
        System.out.println("Sorted: " + names);
    }
}
```

> aside positive
> **When to Use:** Method references make code more readable when the lambda simply calls an existing method. Use lambdas for more complex logic.

## Stream API Basics

Duration: 12:00

Streams represent a sequence of elements and support various operations to process data in a functional style.

### Stream Creation

```java
import java.util.stream.*;
import java.util.*;

// From collection
List<String> list = Arrays.asList("a", "b", "c");
Stream<String> stream1 = list.stream();

// From array
String[] array = {"a", "b", "c"};
Stream<String> stream2 = Arrays.stream(array);

// Using Stream.of()
Stream<String> stream3 = Stream.of("a", "b", "c");

// Empty stream
Stream<String> empty = Stream.empty();

// Infinite streams
Stream<Integer> infinite = Stream.iterate(0, n -> n + 2);  // 0, 2, 4, 6...
Stream<Double> randoms = Stream.generate(Math::random);

// Numeric streams
IntStream intStream = IntStream.range(1, 10);        // 1 to 9
LongStream longStream = LongStream.rangeClosed(1, 10);  // 1 to 10
DoubleStream doubleStream = DoubleStream.of(1.0, 2.0, 3.0);

// From string
IntStream charStream = "Hello".chars();  // Stream of char codes
```

### Stream Pipeline

A stream pipeline consists of:

1. **Source** - Where data comes from
2. **Intermediate Operations** - Transform the stream (lazy)
3. **Terminal Operation** - Produces result (triggers execution)

```
Source → filter → map → sorted → collect
         (intermediate ops)      (terminal)
```

### Basic Stream Operations

```java
import java.util.*;
import java.util.stream.*;

public class StreamBasics {
    public static void main(String[] args) {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

        // Filter - keep elements matching condition
        List<Integer> evens = numbers.stream()
            .filter(n -> n % 2 == 0)
            .collect(Collectors.toList());
        System.out.println("Evens: " + evens);  // [2, 4, 6, 8, 10]

        // Map - transform each element
        List<Integer> squared = numbers.stream()
            .map(n -> n * n)
            .collect(Collectors.toList());
        System.out.println("Squared: " + squared);

        // Limit - take first N elements
        List<Integer> firstThree = numbers.stream()
            .limit(3)
            .collect(Collectors.toList());
        System.out.println("First 3: " + firstThree);  // [1, 2, 3]

        // Skip - skip first N elements
        List<Integer> afterFive = numbers.stream()
            .skip(5)
            .collect(Collectors.toList());
        System.out.println("After 5: " + afterFive);  // [6, 7, 8, 9, 10]

        // Distinct - remove duplicates
        List<Integer> duplicates = Arrays.asList(1, 2, 2, 3, 3, 3);
        List<Integer> unique = duplicates.stream()
            .distinct()
            .collect(Collectors.toList());
        System.out.println("Unique: " + unique);  // [1, 2, 3]

        // Sorted - natural order
        List<Integer> shuffled = Arrays.asList(5, 2, 8, 1, 9);
        List<Integer> sorted = shuffled.stream()
            .sorted()
            .collect(Collectors.toList());
        System.out.println("Sorted: " + sorted);  // [1, 2, 5, 8, 9]

        // Sorted with comparator
        List<String> names = Arrays.asList("Charlie", "Alice", "Bob");
        List<String> sortedNames = names.stream()
            .sorted(Comparator.reverseOrder())
            .collect(Collectors.toList());
        System.out.println("Reverse: " + sortedNames);
    }
}
```

### Peek - Debugging

```java
List<Integer> result = numbers.stream()
    .peek(n -> System.out.println("Original: " + n))
    .filter(n -> n % 2 == 0)
    .peek(n -> System.out.println("After filter: " + n))
    .map(n -> n * n)
    .peek(n -> System.out.println("After map: " + n))
    .collect(Collectors.toList());
```

> aside positive
> **Peek vs forEach:** Use `peek()` for debugging (intermediate), `forEach()` for final actions (terminal).

### Lazy Evaluation

Intermediate operations are lazy - they don't execute until a terminal operation is called:

```java
Stream<Integer> stream = numbers.stream()
    .filter(n -> {
        System.out.println("Filtering: " + n);
        return n % 2 == 0;
    })
    .map(n -> {
        System.out.println("Mapping: " + n);
        return n * 2;
    });

System.out.println("Stream created, but nothing printed yet!");

// Terminal operation triggers execution
List<Integer> result = stream.collect(Collectors.toList());
```

> aside negative
> **One-Time Use:** Streams can only be used once. After a terminal operation, the stream is consumed and cannot be reused.

## Intermediate Operations

Duration: 10:00

Intermediate operations transform a stream and return another stream, allowing chaining.

### filter()

Keep elements matching a predicate:

```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");

// Single condition
List<String> longNames = names.stream()
    .filter(name -> name.length() > 3)
    .collect(Collectors.toList());

// Multiple filters (can chain or combine)
List<String> filtered = names.stream()
    .filter(name -> name.length() > 3)
    .filter(name -> name.startsWith("C"))
    .collect(Collectors.toList());
// Result: [Charlie]
```

### map()

Transform each element:

```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

// String to Integer
List<Integer> lengths = names.stream()
    .map(String::length)
    .collect(Collectors.toList());
// [5, 3, 7]

// Object transformation
class Person {
    String name;
    int age;
    Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
}

List<Person> people = Arrays.asList(
    new Person("Alice", 25),
    new Person("Bob", 30)
);

List<String> personNames = people.stream()
    .map(p -> p.name)  // or Person::getName if using getter
    .collect(Collectors.toList());
```

### flatMap()

Flatten nested structures:

```java
// List of lists
List<List<Integer>> nested = Arrays.asList(
    Arrays.asList(1, 2, 3),
    Arrays.asList(4, 5),
    Arrays.asList(6, 7, 8, 9)
);

// Flatten to single list
List<Integer> flattened = nested.stream()
    .flatMap(list -> list.stream())
    .collect(Collectors.toList());
// [1, 2, 3, 4, 5, 6, 7, 8, 9]

// Split strings and flatten
List<String> sentences = Arrays.asList(
    "Hello World",
    "Java Streams",
    "Functional Programming"
);

List<String> words = sentences.stream()
    .flatMap(sentence -> Arrays.stream(sentence.split(" ")))
    .collect(Collectors.toList());
// [Hello, World, Java, Streams, Functional, Programming]

// Objects with collections
class Department {
    String name;
    List<String> employees;
    Department(String name, List<String> employees) {
        this.name = name;
        this.employees = employees;
    }
}

List<Department> departments = Arrays.asList(
    new Department("IT", Arrays.asList("Alice", "Bob")),
    new Department("HR", Arrays.asList("Charlie", "David"))
);

List<String> allEmployees = departments.stream()
    .flatMap(dept -> dept.employees.stream())
    .collect(Collectors.toList());
```

### sorted()

```java
List<Integer> numbers = Arrays.asList(5, 2, 8, 1, 9);

// Natural order
List<Integer> sorted = numbers.stream()
    .sorted()
    .collect(Collectors.toList());

// Custom comparator
List<String> names = Arrays.asList("Alice", "bob", "CHARLIE");

// Case-insensitive sort
List<String> sortedNames = names.stream()
    .sorted(String::compareToIgnoreCase)
    .collect(Collectors.toList());

// Complex object sorting
class Product {
    String name;
    double price;
    Product(String name, double price) {
        this.name = name;
        this.price = price;
    }
}

List<Product> products = Arrays.asList(
    new Product("Laptop", 1000),
    new Product("Mouse", 25),
    new Product("Keyboard", 75)
);

// Sort by price
List<Product> byPrice = products.stream()
    .sorted(Comparator.comparingDouble(p -> p.price))
    .collect(Collectors.toList());

// Sort by multiple fields
List<Product> sorted = products.stream()
    .sorted(Comparator.comparing((Product p) -> p.price)
                      .thenComparing(p -> p.name))
    .collect(Collectors.toList());
```

### distinct() and limit()

```java
List<Integer> numbers = Arrays.asList(1, 2, 2, 3, 3, 3, 4, 5, 5);

// Remove duplicates
List<Integer> unique = numbers.stream()
    .distinct()
    .collect(Collectors.toList());
// [1, 2, 3, 4, 5]

// Get top 3 unique values
List<Integer> topThree = numbers.stream()
    .distinct()
    .sorted(Comparator.reverseOrder())
    .limit(3)
    .collect(Collectors.toList());
// [5, 4, 3]

// Pagination simulation
int page = 2;
int pageSize = 10;
List<Integer> paginatedResults = largeList.stream()
    .skip((page - 1) * pageSize)
    .limit(pageSize)
    .collect(Collectors.toList());
```

## Terminal Operations

Duration: 10:00

Terminal operations produce a result or side effect and close the stream.

### collect()

Most versatile terminal operation:

```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

// To List
List<String> list = names.stream()
    .collect(Collectors.toList());

// To Set
Set<String> set = names.stream()
    .collect(Collectors.toSet());

// To specific collection
ArrayList<String> arrayList = names.stream()
    .collect(Collectors.toCollection(ArrayList::new));

// To Map
List<Person> people = /* ... */;
Map<String, Person> map = people.stream()
    .collect(Collectors.toMap(
        p -> p.name,     // key
        p -> p           // value
    ));

// To String
String joined = names.stream()
    .collect(Collectors.joining(", "));
// "Alice, Bob, Charlie"

String withPrefixSuffix = names.stream()
    .collect(Collectors.joining(", ", "[", "]"));
// "[Alice, Bob, Charlie]"
```

### forEach() and forEachOrdered()

```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

// Process each element
names.stream()
    .forEach(name -> System.out.println(name));

// Method reference
names.stream()
    .forEach(System.out::println);

// forEachOrdered (maintains order in parallel streams)
names.parallelStream()
    .forEachOrdered(System.out::println);
```

> aside negative
> **Warning:** `forEach()` order is not guaranteed in parallel streams. Use `forEachOrdered()` when order matters.

### count(), min(), max()

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Count elements
long count = numbers.stream()
    .filter(n -> n % 2 == 0)
    .count();
// 2

// Find minimum
Optional<Integer> min = numbers.stream()
    .min(Integer::compareTo);
System.out.println(min.get());  // 1

// Find maximum
Optional<Integer> max = numbers.stream()
    .max(Integer::compareTo);
System.out.println(max.get());  // 5

// Custom comparator
List<String> words = Arrays.asList("a", "abc", "ab");
Optional<String> longest = words.stream()
    .max(Comparator.comparingInt(String::length));
System.out.println(longest.get());  // "abc"
```

### reduce()

Combine elements into a single result:

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Sum
Optional<Integer> sum = numbers.stream()
    .reduce((a, b) -> a + b);
System.out.println(sum.get());  // 15

// Sum with identity
Integer sum2 = numbers.stream()
    .reduce(0, (a, b) -> a + b);
System.out.println(sum2);  // 15

// Product
Integer product = numbers.stream()
    .reduce(1, (a, b) -> a * b);
System.out.println(product);  // 120

// String concatenation
List<String> words = Arrays.asList("Hello", "World", "!");
String sentence = words.stream()
    .reduce("", (a, b) -> a + " " + b);
System.out.println(sentence.trim());  // "Hello World !"

// Find maximum
Optional<Integer> max = numbers.stream()
    .reduce((a, b) -> a > b ? a : b);

// Complex reduction
class Transaction {
    double amount;
    Transaction(double amount) {
        this.amount = amount;
    }
}

List<Transaction> transactions = Arrays.asList(
    new Transaction(100),
    new Transaction(200),
    new Transaction(300)
);

double total = transactions.stream()
    .map(t -> t.amount)
    .reduce(0.0, Double::sum);
```

### anyMatch(), allMatch(), noneMatch()

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Check if any element matches
boolean hasEven = numbers.stream()
    .anyMatch(n -> n % 2 == 0);
System.out.println(hasEven);  // true

// Check if all elements match
boolean allPositive = numbers.stream()
    .allMatch(n -> n > 0);
System.out.println(allPositive);  // true

// Check if no elements match
boolean noNegative = numbers.stream()
    .noneMatch(n -> n < 0);
System.out.println(noNegative);  // true

// Short-circuit evaluation
boolean found = largeList.stream()
    .anyMatch(item -> expensiveCheck(item));
// Stops as soon as one match is found
```

### findFirst() and findAny()

```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

// Find first element
Optional<String> first = names.stream()
    .filter(name -> name.startsWith("C"))
    .findFirst();
System.out.println(first.get());  // "Charlie"

// Find any element (useful for parallel streams)
Optional<String> any = names.parallelStream()
    .filter(name -> name.length() > 3)
    .findAny();
System.out.println(any.get());  // Any matching name
```

## Advanced Collectors

Duration: 15:00

Collectors provide powerful ways to accumulate stream elements into collections and perform complex aggregations.

### Grouping Operations

**groupingBy() - Group by Property:**

```java
class Employee {
    String name;
    String department;
    double salary;

    Employee(String name, String department, double salary) {
        this.name = name;
        this.department = department;
        this.salary = salary;
    }

    // Getters
    public String getName() { return name; }
    public String getDepartment() { return department; }
    public double getSalary() { return salary; }
}

List<Employee> employees = Arrays.asList(
    new Employee("Alice", "IT", 80000),
    new Employee("Bob", "IT", 75000),
    new Employee("Charlie", "HR", 65000),
    new Employee("David", "HR", 70000),
    new Employee("Eve", "IT", 90000)
);

// Group by department
Map<String, List<Employee>> byDepartment = employees.stream()
    .collect(Collectors.groupingBy(Employee::getDepartment));

System.out.println(byDepartment);
// {IT=[Alice, Bob, Eve], HR=[Charlie, David]}

// Group and count
Map<String, Long> countByDept = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::getDepartment,
        Collectors.counting()
    ));
System.out.println(countByDept);
// {IT=3, HR=2}

// Group and calculate average salary
Map<String, Double> avgSalaryByDept = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::getDepartment,
        Collectors.averagingDouble(Employee::getSalary)
    ));
System.out.println(avgSalaryByDept);
// {IT=81666.67, HR=67500.0}

// Group and collect names
Map<String, List<String>> namesByDept = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::getDepartment,
        Collectors.mapping(Employee::getName, Collectors.toList())
    ));
System.out.println(namesByDept);
// {IT=[Alice, Bob, Eve], HR=[Charlie, David]}

// Multi-level grouping
class Employee {
    String department;
    String level;  // Junior, Senior, etc.
    // ... other fields
}

Map<String, Map<String, List<Employee>>> multiLevel = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::getDepartment,
        Collectors.groupingBy(Employee::getLevel)
    ));
```

### Partitioning

Split stream into two groups based on a predicate:

```java
List<Employee> employees = /* ... */;

// Partition by salary threshold
Map<Boolean, List<Employee>> partitioned = employees.stream()
    .collect(Collectors.partitioningBy(e -> e.getSalary() > 75000));

List<Employee> highPaid = partitioned.get(true);
List<Employee> lowPaid = partitioned.get(false);

// Partition and count
Map<Boolean, Long> counts = employees.stream()
    .collect(Collectors.partitioningBy(
        e -> e.getSalary() > 75000,
        Collectors.counting()
    ));
System.out.println("High paid: " + counts.get(true));
System.out.println("Low paid: " + counts.get(false));
```

### Statistical Collectors

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// Summarizing statistics
IntSummaryStatistics stats = numbers.stream()
    .collect(Collectors.summarizingInt(Integer::intValue));

System.out.println("Count: " + stats.getCount());      // 10
System.out.println("Sum: " + stats.getSum());          // 55
System.out.println("Min: " + stats.getMin());          // 1
System.out.println("Max: " + stats.getMax());          // 10
System.out.println("Average: " + stats.getAverage());  // 5.5

// Double statistics
List<Employee> employees = /* ... */;
DoubleSummaryStatistics salaryStats = employees.stream()
    .collect(Collectors.summarizingDouble(Employee::getSalary));

System.out.println("Avg Salary: " + salaryStats.getAverage());
System.out.println("Total Payroll: " + salaryStats.getSum());
```

### Custom Collectors

```java
// Joining with custom formatting
String formatted = employees.stream()
    .map(Employee::getName)
    .collect(Collectors.joining(
        ", ",              // delimiter
        "Employees: [",    // prefix
        "]"                // suffix
    ));
// "Employees: [Alice, Bob, Charlie, David, Eve]"

// Collect to Map with collision handling
Map<String, Employee> employeeMap = employees.stream()
    .collect(Collectors.toMap(
        Employee::getName,           // key
        e -> e,                      // value
        (existing, replacement) -> existing  // collision handler
    ));

// toMap with custom value
Map<String, Double> salaryMap = employees.stream()
    .collect(Collectors.toMap(
        Employee::getName,
        Employee::getSalary
    ));

// Collecting then transforming
List<String> upperNames = employees.stream()
    .collect(Collectors.collectingAndThen(
        Collectors.toList(),
        list -> {
            return list.stream()
                .map(Employee::getName)
                .map(String::toUpperCase)
                .collect(Collectors.toList());
        }
    ));
```

## Build Sales Analytics Application

Duration: 20:00

Now let's build a comprehensive sales analytics system using everything we've learned!

### Project Structure

Create `SalesAnalytics.java`:

```java
import java.time.LocalDate;
import java.util.*;
import java.util.stream.*;

class Sale {
    private String id;
    private String product;
    private String category;
    private double amount;
    private int quantity;
    private LocalDate date;
    private String region;
    private String salesperson;

    public Sale(String id, String product, String category, double amount,
                int quantity, LocalDate date, String region, String salesperson) {
        this.id = id;
        this.product = product;
        this.category = category;
        this.amount = amount;
        this.quantity = quantity;
        this.date = date;
        this.region = region;
        this.salesperson = salesperson;
    }

    // Getters
    public String getId() { return id; }
    public String getProduct() { return product; }
    public String getCategory() { return category; }
    public double getAmount() { return amount; }
    public int getQuantity() { return quantity; }
    public LocalDate getDate() { return date; }
    public String getRegion() { return region; }
    public String getSalesperson() { return salesperson; }

    @Override
    public String toString() {
        return String.format("%s: %s ($%.2f)", id, product, amount);
    }
}

public class SalesAnalytics {
    private List<Sale> sales;

    public SalesAnalytics() {
        this.sales = generateSampleData();
    }

    private List<Sale> generateSampleData() {
        return Arrays.asList(
            new Sale("S001", "Laptop", "Electronics", 1200.00, 2,
                     LocalDate.of(2024, 1, 15), "North", "Alice"),
            new Sale("S002", "Mouse", "Electronics", 25.00, 10,
                     LocalDate.of(2024, 1, 16), "South", "Bob"),
            new Sale("S003", "Desk", "Furniture", 450.00, 3,
                     LocalDate.of(2024, 1, 17), "East", "Charlie"),
            new Sale("S004", "Chair", "Furniture", 180.00, 5,
                     LocalDate.of(2024, 1, 18), "West", "Alice"),
            new Sale("S005", "Monitor", "Electronics", 300.00, 4,
                     LocalDate.of(2024, 1, 19), "North", "David"),
            new Sale("S006", "Keyboard", "Electronics", 75.00, 8,
                     LocalDate.of(2024, 1, 20), "South", "Bob"),
            new Sale("S007", "Bookshelf", "Furniture", 200.00, 2,
                     LocalDate.of(2024, 2, 1), "East", "Charlie"),
            new Sale("S008", "Laptop", "Electronics", 1400.00, 1,
                     LocalDate.of(2024, 2, 5), "North", "Alice"),
            new Sale("S009", "Desk Lamp", "Electronics", 40.00, 15,
                     LocalDate.of(2024, 2, 10), "West", "David"),
            new Sale("S010", "Office Chair", "Furniture", 250.00, 6,
                     LocalDate.of(2024, 2, 15), "South", "Bob")
        );
    }

    // 1. Total Revenue
    public double calculateTotalRevenue() {
        return sales.stream()
            .mapToDouble(Sale::getAmount)
            .sum();
    }

    // 2. Revenue by Category
    public Map<String, Double> revenueByCategory() {
        return sales.stream()
            .collect(Collectors.groupingBy(
                Sale::getCategory,
                Collectors.summingDouble(Sale::getAmount)
            ));
    }

    // 3. Top Products by Revenue
    public List<Map.Entry<String, Double>> topProducts(int n) {
        return sales.stream()
            .collect(Collectors.groupingBy(
                Sale::getProduct,
                Collectors.summingDouble(Sale::getAmount)
            ))
            .entrySet()
            .stream()
            .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
            .limit(n)
            .collect(Collectors.toList());
    }

    // 4. Sales by Region
    public Map<String, Long> salesCountByRegion() {
        return sales.stream()
            .collect(Collectors.groupingBy(
                Sale::getRegion,
                Collectors.counting()
            ));
    }

    // 5. Average Sale Amount by Salesperson
    public Map<String, Double> averageSalesBySalesperson() {
        return sales.stream()
            .collect(Collectors.groupingBy(
                Sale::getSalesperson,
                Collectors.averagingDouble(Sale::getAmount)
            ));
    }

    // 6. High-Value Sales (above threshold)
    public List<Sale> getHighValueSales(double threshold) {
        return sales.stream()
            .filter(sale -> sale.getAmount() > threshold)
            .sorted(Comparator.comparingDouble(Sale::getAmount).reversed())
            .collect(Collectors.toList());
    }

    // 7. Monthly Revenue
    public Map<Integer, Double> revenueByMonth() {
        return sales.stream()
            .collect(Collectors.groupingBy(
                sale -> sale.getDate().getMonthValue(),
                Collectors.summingDouble(Sale::getAmount)
            ));
    }

    // 8. Product Performance Statistics
    public void productStatistics() {
        Map<String, DoubleSummaryStatistics> stats = sales.stream()
            .collect(Collectors.groupingBy(
                Sale::getCategory,
                Collectors.summarizingDouble(Sale::getAmount)
            ));

        stats.forEach((category, stat) -> {
            System.out.println("\nCategory: " + category);
            System.out.printf("  Count: %d%n", stat.getCount());
            System.out.printf("  Total: $%.2f%n", stat.getSum());
            System.out.printf("  Average: $%.2f%n", stat.getAverage());
            System.out.printf("  Min: $%.2f%n", stat.getMin());
            System.out.printf("  Max: $%.2f%n", stat.getMax());
        });
    }

    // 9. Top Salesperson
    public Map.Entry<String, Double> topSalesperson() {
        return sales.stream()
            .collect(Collectors.groupingBy(
                Sale::getSalesperson,
                Collectors.summingDouble(Sale::getAmount)
            ))
            .entrySet()
            .stream()
            .max(Map.Entry.comparingByValue())
            .orElse(null);
    }

    // 10. Sales Distribution (Partition by amount)
    public Map<Boolean, List<Sale>> partitionSales(double threshold) {
        return sales.stream()
            .collect(Collectors.partitioningBy(
                sale -> sale.getAmount() >= threshold
            ));
    }

    // 11. Complex Query: Region-Category Matrix
    public Map<String, Map<String, Double>> regionCategoryMatrix() {
        return sales.stream()
            .collect(Collectors.groupingBy(
                Sale::getRegion,
                Collectors.groupingBy(
                    Sale::getCategory,
                    Collectors.summingDouble(Sale::getAmount)
                )
            ));
    }

    // 12. Find sales by multiple criteria
    public List<Sale> findSales(String category, String region, double minAmount) {
        return sales.stream()
            .filter(sale -> sale.getCategory().equals(category))
            .filter(sale -> sale.getRegion().equals(region))
            .filter(sale -> sale.getAmount() >= minAmount)
            .collect(Collectors.toList());
    }

    public void runAnalytics() {
        System.out.println("=== SALES ANALYTICS DASHBOARD ===\n");

        // Total Revenue
        System.out.printf("Total Revenue: $%.2f%n%n", calculateTotalRevenue());

        // Revenue by Category
        System.out.println("Revenue by Category:");
        revenueByCategory().forEach((category, revenue) ->
            System.out.printf("  %s: $%.2f%n", category, revenue)
        );

        // Top 3 Products
        System.out.println("\nTop 3 Products:");
        topProducts(3).forEach(entry ->
            System.out.printf("  %s: $%.2f%n", entry.getKey(), entry.getValue())
        );

        // Sales by Region
        System.out.println("\nSales Count by Region:");
        salesCountByRegion().forEach((region, count) ->
            System.out.printf("  %s: %d sales%n", region, count)
        );

        // Average by Salesperson
        System.out.println("\nAverage Sale by Salesperson:");
        averageSalesBySalesperson().forEach((person, avg) ->
            System.out.printf("  %s: $%.2f%n", person, avg)
        );

        // High-value sales
        System.out.println("\nHigh-Value Sales (>$500):");
        getHighValueSales(500.0).forEach(sale ->
            System.out.println("  " + sale)
        );

        // Monthly revenue
        System.out.println("\nRevenue by Month:");
        revenueByMonth().forEach((month, revenue) ->
            System.out.printf("  Month %d: $%.2f%n", month, revenue)
        );

        // Product statistics
        productStatistics();

        // Top salesperson
        Map.Entry<String, Double> top = topSalesperson();
        System.out.printf("%nTop Salesperson: %s ($%.2f)%n",
            top.getKey(), top.getValue());

        // Sales partition
        System.out.println("\nSales Partition (threshold: $200):");
        Map<Boolean, List<Sale>> partitioned = partitionSales(200.0);
        System.out.println("  High-value sales: " + partitioned.get(true).size());
        System.out.println("  Low-value sales: " + partitioned.get(false).size());

        // Region-Category Matrix
        System.out.println("\nRegion-Category Revenue Matrix:");
        regionCategoryMatrix().forEach((region, categories) -> {
            System.out.println("  " + region + ":");
            categories.forEach((category, revenue) ->
                System.out.printf("    %s: $%.2f%n", category, revenue)
            );
        });
    }

    public static void main(String[] args) {
        SalesAnalytics analytics = new SalesAnalytics();
        analytics.runAnalytics();
    }
}
```

### Run the Application

```console
$ javac SalesAnalytics.java
$ java SalesAnalytics
```

**Expected Output:**

```
=== SALES ANALYTICS DASHBOARD ===

Total Revenue: $4120.00

Revenue by Category:
  Electronics: $3040.00
  Furniture: $1080.00

Top 3 Products:
  Laptop: $2600.00
  Office Chair: $1500.00
  Desk: $1350.00

Sales Count by Region:
  North: 3 sales
  South: 3 sales
  East: 2 sales
  West: 2 sales

...
```

> aside positive
> **Great Job!** You've built a production-quality analytics engine using pure functional programming!

## Parallel Streams

Duration: 8:00

Parallel streams split data into multiple chunks and process them concurrently on multiple CPU cores.

### Creating Parallel Streams

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// Method 1: From sequential stream
Stream<Integer> parallelStream = numbers.stream().parallel();

// Method 2: Direct parallel stream
Stream<Integer> parallelStream2 = numbers.parallelStream();

// Convert back to sequential
Stream<Integer> sequential = parallelStream.sequential();
```

### Performance Comparison

```java
import java.util.*;
import java.util.stream.*;

public class ParallelStreamDemo {
    public static void main(String[] args) {
        List<Integer> numbers = IntStream.rangeClosed(1, 10_000_000)
            .boxed()
            .collect(Collectors.toList());

        // Sequential processing
        long startSeq = System.currentTimeMillis();
        long sumSeq = numbers.stream()
            .filter(n -> n % 2 == 0)
            .mapToLong(n -> n * n)
            .sum();
        long endSeq = System.currentTimeMillis();

        System.out.println("Sequential Result: " + sumSeq);
        System.out.println("Sequential Time: " + (endSeq - startSeq) + "ms");

        // Parallel processing
        long startPar = System.currentTimeMillis();
        long sumPar = numbers.parallelStream()
            .filter(n -> n % 2 == 0)
            .mapToLong(n -> n * n)
            .sum();
        long endPar = System.currentTimeMillis();

        System.out.println("\nParallel Result: " + sumPar);
        System.out.println("Parallel Time: " + (endPar - startPar) + "ms");

        double speedup = (double)(endSeq - startSeq) / (endPar - startPar);
        System.out.printf("\nSpeedup: %.2fx%n", speedup);
    }
}
```

### When to Use Parallel Streams

**Good Candidates:**

- Large datasets (thousands+ elements)
- CPU-intensive operations
- Independent operations (no shared state)
- Operations that benefit from parallelization

```java
// Good: CPU-intensive, large dataset
List<ComplexObject> results = hugeList.parallelStream()
    .map(obj -> expensiveComputation(obj))
    .collect(Collectors.toList());

// Good: Simple aggregation
long sum = largeList.parallelStream()
    .mapToLong(Integer::longValue)
    .sum();
```

**Poor Candidates:**

- Small datasets (overhead > benefit)
- I/O operations (thread contention)
- Order-dependent operations
- Shared mutable state

```java
// Bad: Small dataset
List<Integer> small = Arrays.asList(1, 2, 3, 4, 5);
small.parallelStream().forEach(System.out::println);  // Overkill

// Bad: Order matters
List<String> ordered = list.parallelStream()
    .sorted()
    .collect(Collectors.toList());  // Use sequential

// Bad: Shared mutable state
List<Integer> result = new ArrayList<>();  // Not thread-safe!
numbers.parallelStream()
    .forEach(n -> result.add(n * 2));  // WRONG! Race condition
```

> aside negative
> **Warning:** Parallel streams use the common ForkJoinPool. Blocking operations can starve other parallel streams in your application.

### Thread-Safe Operations

```java
// Safe: Collectors are thread-safe
List<Integer> safe = numbers.parallelStream()
    .map(n -> n * 2)
    .collect(Collectors.toList());

// Safe: Reduction operations
int sum = numbers.parallelStream()
    .reduce(0, Integer::sum);

// Unsafe: Shared mutable state
List<Integer> unsafe = new ArrayList<>();
numbers.parallelStream()
    .forEach(unsafe::add);  // Race condition!

// Safe alternative: Use thread-safe collection
List<Integer> safe = Collections.synchronizedList(new ArrayList<>());
numbers.parallelStream()
    .forEach(safe::add);

// Better: Use collectors
List<Integer> best = numbers.parallelStream()
    .collect(Collectors.toList());
```

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered functional programming and the Stream API!

### What You've Learned

- ✅ **Functional Programming:** Paradigm shift from imperative to declarative
- ✅ **Lambda Expressions:** Concise syntax for functional interfaces
- ✅ **Functional Interfaces:** Predicate, Function, Consumer, Supplier, BiFunction
- ✅ **Method References:** Shorthand for lambdas (::)
- ✅ **Stream API:** Powerful data processing pipelines
- ✅ **Intermediate Operations:** filter, map, flatMap, sorted, distinct
- ✅ **Terminal Operations:** collect, forEach, reduce, count, min, max
- ✅ **Advanced Collectors:** groupingBy, partitioningBy, statistics
- ✅ **Parallel Streams:** Multi-core processing for performance

### Key Takeaways

1. **Functional style** is declarative - describe **what**, not **how**
2. **Lambdas** make code concise and expressive
3. **Streams** enable powerful data transformations
4. **Collectors** provide sophisticated aggregation capabilities
5. **Parallel streams** can boost performance but require careful use
6. **Immutability** prevents bugs and enables safe parallelization

### Best Practices

- Use method references when lambdas just call existing methods
- Chain stream operations for readability
- Avoid side effects in stream operations
- Use parallel streams only for large datasets and CPU-intensive tasks
- Prefer collectors over manual accumulation
- Keep lambda expressions short and focused

### Next Steps

Ready for more modern Java? Continue to:

- **Codelab 2.2:** Optional, Date/Time & Modern Java Features
- **Codelab 2.3:** Asynchronous Programming with CompletableFuture
- **Codelab 2.4:** Logging with Log4j

### Practice Exercises

1. **Order Processing:** Process orders with discounts, tax calculations, and grouping
2. **Log Analyzer:** Parse log files and generate statistics by severity
3. **Student Grading:** Calculate grades, averages, and rankings
4. **E-commerce Reports:** Product recommendations based on purchase history
5. **Performance Benchmark:** Compare sequential vs parallel for various datasets

### Additional Resources

- [Java Stream API Documentation](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/stream/package-summary.html)
- [Java Functional Interfaces](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/function/package-summary.html)
- [Effective Java by Joshua Bloch](https://www.oreilly.com/library/view/effective-java/9780134686097/) - Chapter on Lambdas and Streams

> aside positive
> **Excellent Work!** You now have the skills to write modern, efficient Java code. The functional programming techniques you learned are used extensively in Spring Boot and microservices!
