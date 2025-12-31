summary: Master Java Collections Framework and Generics by building an inventory management system using List, Set, Map, and Queue with type-safe generic utilities
id: collections-generics
categories: Java, Collections, Generics, Data Structures
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM
feedback link: https://github.com/Bit-Blazer/springboot_course/issues/new

# Collections Framework & Generics

## Introduction

Duration: 2:00

Java's Collections Framework provides powerful data structures for storing and manipulating groups of objects. Combined with Generics for type safety, you can build robust, efficient applications. In this codelab, you'll master all major collection types while building a complete inventory management system.

### What You'll Learn

- Collections Framework architecture and interfaces
- List implementations (ArrayList, LinkedList)
- Set implementations (HashSet, TreeSet, LinkedHashSet)
- Map implementations (HashMap, TreeMap, LinkedHashMap)
- Queue and Deque interfaces (PriorityQueue, ArrayDeque)
- Generics: type parameters, bounded types, wildcards
- Comparable and Comparator for custom sorting
- Iterator and enhanced for-loop
- Collections utility class methods
- Performance characteristics of each collection type

### What You'll Build

An **Inventory Management System** featuring:

- Product catalog with multiple collection types
- Generic utility classes for common operations
- Custom sorting with Comparable and Comparator
- Priority-based order processing with Queue
- Search and filtering capabilities
- Performance comparisons between collection types

### Prerequisites

- Completed Codelabs 1.1, 1.2, and 1.3
- Understanding of OOP, interfaces, and exceptions
- Java JDK 17+ installed

## Collections Framework Overview

Duration: 10:00

The Collections Framework provides a unified architecture for representing and manipulating collections.

### Collection Hierarchy

```
Collection Interface
├── List (ordered, allows duplicates)
│   ├── ArrayList
│   ├── LinkedList
│   └── Vector (legacy)
├── Set (no duplicates)
│   ├── HashSet
│   ├── LinkedHashSet
│   └── TreeSet (sorted)
└── Queue (FIFO or priority-based)
    ├── PriorityQueue
    ├── ArrayDeque
    └── LinkedList

Map Interface (key-value pairs, separate hierarchy)
├── HashMap
├── LinkedHashMap (maintains insertion order)
└── TreeMap (sorted by keys)
```

### Core Interfaces

**Collection Interface:**

```java
public interface Collection<E> {
    boolean add(E element);
    boolean remove(Object element);
    boolean contains(Object element);
    int size();
    boolean isEmpty();
    void clear();
    Iterator<E> iterator();
    Object[] toArray();
}
```

**List Interface (extends Collection):**

```java
public interface List<E> extends Collection<E> {
    E get(int index);
    E set(int index, E element);
    void add(int index, E element);
    E remove(int index);
    int indexOf(Object element);
    int lastIndexOf(Object element);
}
```

**Set Interface (extends Collection):**

```java
public interface Set<E> extends Collection<E> {
    // Same methods as Collection
    // But ensures no duplicates
}
```

**Map Interface (separate hierarchy):**

```java
public interface Map<K, V> {
    V put(K key, V value);
    V get(Object key);
    V remove(Object key);
    boolean containsKey(Object key);
    boolean containsValue(Object value);
    Set<K> keySet();
    Collection<V> values();
    Set<Map.Entry<K, V>> entrySet();
}
```

> aside positive
> **Key Insight:** List maintains order and allows duplicates. Set guarantees uniqueness. Map stores key-value pairs. Choose based on your needs!

### When to Use Each Collection

| Collection        | Use When                                  | Performance                        |
| ----------------- | ----------------------------------------- | ---------------------------------- |
| **ArrayList**     | Frequent reads, rare insertions/deletions | O(1) get, O(n) add/remove          |
| **LinkedList**    | Frequent insertions/deletions at ends     | O(n) get, O(1) add/remove at ends  |
| **HashSet**       | Need uniqueness, order doesn't matter     | O(1) add/remove/contains (average) |
| **TreeSet**       | Need uniqueness AND sorted order          | O(log n) add/remove/contains       |
| **HashMap**       | Fast key-value lookups                    | O(1) get/put (average)             |
| **TreeMap**       | Key-value pairs in sorted key order       | O(log n) get/put                   |
| **PriorityQueue** | Process elements by priority              | O(log n) add/remove                |

## List Collections

Duration: 15:00

Lists are ordered collections that allow duplicate elements.

### ArrayList - Dynamic Array

**Characteristics:**

- Resizable array implementation
- Fast random access: O(1)
- Slow insertions/deletions in middle: O(n)
- Best for: Reading more than writing

```java
import java.util.*;

public class ArrayListDemo {
    public static void main(String[] args) {
        // Creating ArrayList
        List<String> fruits = new ArrayList<>();

        // Adding elements
        fruits.add("Apple");
        fruits.add("Banana");
        fruits.add("Cherry");
        fruits.add("Apple");  // Duplicates allowed

        System.out.println("Fruits: " + fruits);
        System.out.println("Size: " + fruits.size());

        // Accessing elements
        System.out.println("First fruit: " + fruits.get(0));
        System.out.println("Last fruit: " + fruits.get(fruits.size() - 1));

        // Modifying elements
        fruits.set(1, "Blueberry");
        System.out.println("After modification: " + fruits);

        // Checking existence
        System.out.println("Contains Apple: " + fruits.contains("Apple"));
        System.out.println("Index of Apple: " + fruits.indexOf("Apple"));
        System.out.println("Last index of Apple: " + fruits.lastIndexOf("Apple"));

        // Removing elements
        fruits.remove("Cherry");  // Remove by object
        fruits.remove(0);         // Remove by index
        System.out.println("After removal: " + fruits);

        // Iterating
        System.out.println("\nIterating:");
        for (String fruit : fruits) {
            System.out.println("  - " + fruit);
        }

        // Bulk operations
        List<String> moreFruits = Arrays.asList("Date", "Elderberry");
        fruits.addAll(moreFruits);
        System.out.println("After addAll: " + fruits);

        // Clearing
        fruits.clear();
        System.out.println("After clear, is empty: " + fruits.isEmpty());
    }
}
```

### LinkedList - Doubly Linked List

**Characteristics:**

- Doubly-linked list implementation
- Slow random access: O(n)
- Fast insertions/deletions at ends: O(1)
- Best for: Frequent insertions/deletions
- Also implements Deque interface

```java
import java.util.*;

public class LinkedListDemo {
    public static void main(String[] args) {
        LinkedList<Integer> numbers = new LinkedList<>();

        // Adding elements
        numbers.add(10);
        numbers.add(20);
        numbers.add(30);

        // LinkedList-specific methods
        numbers.addFirst(5);   // Add at beginning
        numbers.addLast(40);   // Add at end

        System.out.println("Numbers: " + numbers);

        // Accessing ends
        System.out.println("First: " + numbers.getFirst());
        System.out.println("Last: " + numbers.getLast());

        // Peek without removing
        System.out.println("Peek first: " + numbers.peekFirst());
        System.out.println("Peek last: " + numbers.peekLast());

        // Remove from ends
        numbers.removeFirst();
        numbers.removeLast();
        System.out.println("After removing ends: " + numbers);

        // Use as Stack (LIFO)
        LinkedList<String> stack = new LinkedList<>();
        stack.push("First");
        stack.push("Second");
        stack.push("Third");
        System.out.println("Stack: " + stack);
        System.out.println("Pop: " + stack.pop());  // Third
        System.out.println("After pop: " + stack);

        // Use as Queue (FIFO)
        LinkedList<String> queue = new LinkedList<>();
        queue.offer("First");
        queue.offer("Second");
        queue.offer("Third");
        System.out.println("Queue: " + queue);
        System.out.println("Poll: " + queue.poll());  // First
        System.out.println("After poll: " + queue);
    }
}
```

### ArrayList vs LinkedList Performance

```java
import java.util.*;

public class ListPerformanceComparison {
    public static void main(String[] args) {
        int n = 100000;

        // ArrayList - Fast random access
        List<Integer> arrayList = new ArrayList<>();
        long start = System.nanoTime();
        for (int i = 0; i < n; i++) {
            arrayList.add(i);
        }
        long end = System.nanoTime();
        System.out.println("ArrayList add: " + (end - start) / 1_000_000 + " ms");

        start = System.nanoTime();
        for (int i = 0; i < n; i++) {
            arrayList.get(i);
        }
        end = System.nanoTime();
        System.out.println("ArrayList get: " + (end - start) / 1_000_000 + " ms");

        // LinkedList - Fast insertions at ends
        List<Integer> linkedList = new LinkedList<>();
        start = System.nanoTime();
        for (int i = 0; i < n; i++) {
            linkedList.add(i);
        }
        end = System.nanoTime();
        System.out.println("LinkedList add: " + (end - start) / 1_000_000 + " ms");

        start = System.nanoTime();
        for (int i = 0; i < n; i++) {
            linkedList.get(i);  // Slow!
        }
        end = System.nanoTime();
        System.out.println("LinkedList get: " + (end - start) / 1_000_000 + " ms");
    }
}
```

> aside negative
> **Performance Warning:** ArrayList.get(i) is O(1), LinkedList.get(i) is O(n). For random access, ArrayList is much faster!

## Set Collections

Duration: 15:00

Sets store unique elements with no duplicates.

### HashSet - Hash Table Based

**Characteristics:**

- No duplicates, no ordering
- Very fast: O(1) average for add/remove/contains
- Uses hashCode() and equals() methods
- Best for: Fast uniqueness checking

```java
import java.util.*;

public class HashSetDemo {
    public static void main(String[] args) {
        Set<String> languages = new HashSet<>();

        // Adding elements
        languages.add("Java");
        languages.add("Python");
        languages.add("JavaScript");
        languages.add("Java");  // Duplicate - ignored!

        System.out.println("Languages: " + languages);  // No duplicates
        System.out.println("Size: " + languages.size());  // 3, not 4

        // Checking existence
        System.out.println("Contains Python: " + languages.contains("Python"));
        System.out.println("Contains C++: " + languages.contains("C++"));

        // Removing
        languages.remove("JavaScript");
        System.out.println("After removal: " + languages);

        // Iterating (order not guaranteed)
        System.out.println("\nIterating:");
        for (String lang : languages) {
            System.out.println("  - " + lang);
        }

        // Set operations
        Set<String> frontend = new HashSet<>(Arrays.asList("JavaScript", "TypeScript", "HTML"));
        Set<String> backend = new HashSet<>(Arrays.asList("Java", "Python", "JavaScript"));

        // Union
        Set<String> union = new HashSet<>(frontend);
        union.addAll(backend);
        System.out.println("\nUnion: " + union);

        // Intersection
        Set<String> intersection = new HashSet<>(frontend);
        intersection.retainAll(backend);
        System.out.println("Intersection: " + intersection);

        // Difference
        Set<String> difference = new HashSet<>(frontend);
        difference.removeAll(backend);
        System.out.println("Difference (frontend - backend): " + difference);
    }
}
```

### TreeSet - Red-Black Tree (Sorted)

**Characteristics:**

- No duplicates, sorted order
- O(log n) for add/remove/contains
- Elements must implement Comparable or provide Comparator
- Best for: Maintaining sorted unique elements

```java
import java.util.*;

public class TreeSetDemo {
    public static void main(String[] args) {
        // Natural ordering (alphabetical)
        Set<String> names = new TreeSet<>();
        names.add("Charlie");
        names.add("Alice");
        names.add("Bob");
        names.add("Diana");

        System.out.println("Names (sorted): " + names);
        // Output: [Alice, Bob, Charlie, Diana]

        // Numbers sorted
        Set<Integer> numbers = new TreeSet<>();
        numbers.add(50);
        numbers.add(10);
        numbers.add(30);
        numbers.add(20);

        System.out.println("Numbers (sorted): " + numbers);
        // Output: [10, 20, 30, 50]

        // Custom ordering with Comparator
        Set<String> reversedNames = new TreeSet<>(Comparator.reverseOrder());
        reversedNames.add("Charlie");
        reversedNames.add("Alice");
        reversedNames.add("Bob");

        System.out.println("Names (reversed): " + reversedNames);
        // Output: [Charlie, Bob, Alice]

        // TreeSet specific methods
        TreeSet<Integer> scores = new TreeSet<>(Arrays.asList(85, 92, 78, 95, 88));
        System.out.println("First (lowest): " + scores.first());
        System.out.println("Last (highest): " + scores.last());
        System.out.println("Lower than 90: " + scores.lower(90));
        System.out.println("Higher than 90: " + scores.higher(90));
        System.out.println("Ceiling of 90: " + scores.ceiling(90));
        System.out.println("Floor of 90: " + scores.floor(90));

        // Range views
        System.out.println("Scores >= 85 and < 92: " + scores.subSet(85, 92));
        System.out.println("Scores < 90: " + scores.headSet(90));
        System.out.println("Scores >= 90: " + scores.tailSet(90));
    }
}
```

### LinkedHashSet - Maintains Insertion Order

**Characteristics:**

- No duplicates, maintains insertion order
- Slightly slower than HashSet
- Best for: Unique elements with predictable iteration order

```java
import java.util.*;

public class LinkedHashSetDemo {
    public static void main(String[] args) {
        Set<String> orderedSet = new LinkedHashSet<>();
        orderedSet.add("First");
        orderedSet.add("Second");
        orderedSet.add("Third");
        orderedSet.add("First");  // Duplicate ignored

        System.out.println("LinkedHashSet (insertion order): " + orderedSet);
        // Output: [First, Second, Third]

        // Compare with HashSet (no guaranteed order)
        Set<String> unorderedSet = new HashSet<>();
        unorderedSet.add("First");
        unorderedSet.add("Second");
        unorderedSet.add("Third");

        System.out.println("HashSet (no order guarantee): " + unorderedSet);
        // Output: [First, Second, Third] or [Third, First, Second] etc.
    }
}
```

> aside positive
> **Choosing a Set:** Use HashSet for best performance, TreeSet for sorted elements, LinkedHashSet for insertion order.

## Map Collections

Duration: 15:00

Maps store key-value pairs with unique keys.

### HashMap - Hash Table Based

**Characteristics:**

- Key-value pairs, unique keys
- Very fast: O(1) average for get/put
- No ordering of keys
- Best for: Fast lookups by key

```java
import java.util.*;

public class HashMapDemo {
    public static void main(String[] args) {
        Map<String, Integer> ages = new HashMap<>();

        // Adding key-value pairs
        ages.put("Alice", 25);
        ages.put("Bob", 30);
        ages.put("Charlie", 28);
        ages.put("Alice", 26);  // Updates existing key

        System.out.println("Ages: " + ages);
        System.out.println("Size: " + ages.size());

        // Accessing values
        System.out.println("Alice's age: " + ages.get("Alice"));
        System.out.println("Diana's age: " + ages.get("Diana"));  // null

        // Check existence
        System.out.println("Contains Alice: " + ages.containsKey("Alice"));
        System.out.println("Contains age 30: " + ages.containsValue(30));

        // Default values
        System.out.println("Diana's age (with default): " +
                          ages.getOrDefault("Diana", 0));

        // putIfAbsent - only adds if key doesn't exist
        ages.putIfAbsent("Bob", 35);  // No change, key exists
        ages.putIfAbsent("Diana", 29);  // Adds new entry
        System.out.println("After putIfAbsent: " + ages);

        // Removing
        ages.remove("Charlie");
        System.out.println("After removal: " + ages);

        // Iterating over keys
        System.out.println("\nIterating keys:");
        for (String name : ages.keySet()) {
            System.out.println("  " + name);
        }

        // Iterating over values
        System.out.println("\nIterating values:");
        for (Integer age : ages.values()) {
            System.out.println("  " + age);
        }

        // Iterating over entries
        System.out.println("\nIterating entries:");
        for (Map.Entry<String, Integer> entry : ages.entrySet()) {
            System.out.println("  " + entry.getKey() + " = " + entry.getValue());
        }

        // Java 8+ forEach
        System.out.println("\nUsing forEach:");
        ages.forEach((name, age) ->
            System.out.println("  " + name + " is " + age + " years old")
        );

        // compute methods
        ages.compute("Alice", (name, age) -> age + 1);  // Increment Alice's age
        ages.computeIfAbsent("Eve", name -> 27);  // Add if absent
        ages.computeIfPresent("Bob", (name, age) -> age + 2);  // Update if present

        System.out.println("\nAfter compute operations: " + ages);

        // merge method
        ages.merge("Alice", 5, (oldValue, newValue) -> oldValue + newValue);
        System.out.println("After merge: " + ages);
    }
}
```

### TreeMap - Red-Black Tree (Sorted Keys)

**Characteristics:**

- Key-value pairs, sorted by keys
- O(log n) for get/put
- Keys must implement Comparable or provide Comparator
- Best for: Sorted key-value pairs

```java
import java.util.*;

public class TreeMapDemo {
    public static void main(String[] args) {
        // Sorted by keys (alphabetically)
        Map<String, Double> prices = new TreeMap<>();
        prices.put("Laptop", 999.99);
        prices.put("Mouse", 29.99);
        prices.put("Keyboard", 79.99);
        prices.put("Monitor", 299.99);

        System.out.println("Prices (sorted by product name):");
        prices.forEach((product, price) ->
            System.out.println("  " + product + ": $" + price)
        );

        // TreeMap specific methods
        TreeMap<Integer, String> grades = new TreeMap<>();
        grades.put(95, "A");
        grades.put(85, "B");
        grades.put(75, "C");
        grades.put(65, "D");

        System.out.println("\nFirst entry: " + grades.firstEntry());
        System.out.println("Last entry: " + grades.lastEntry());
        System.out.println("Entry for 85: " + grades.floorEntry(85));
        System.out.println("Entry above 85: " + grades.higherEntry(85));

        // Range views
        System.out.println("Grades 70-90: " + grades.subMap(70, 91));
        System.out.println("Grades below 80: " + grades.headMap(80));
        System.out.println("Grades 80+: " + grades.tailMap(80));
    }
}
```

### LinkedHashMap - Maintains Insertion Order

**Characteristics:**

- Key-value pairs, maintains insertion order
- Slightly slower than HashMap
- Can also maintain access order (LRU cache)
- Best for: Predictable iteration order

```java
import java.util.*;

public class LinkedHashMapDemo {
    public static void main(String[] args) {
        // Insertion order
        Map<String, String> capitals = new LinkedHashMap<>();
        capitals.put("USA", "Washington");
        capitals.put("France", "Paris");
        capitals.put("Japan", "Tokyo");
        capitals.put("India", "New Delhi");

        System.out.println("Capitals (insertion order):");
        capitals.forEach((country, capital) ->
            System.out.println("  " + country + " -> " + capital)
        );

        // Access order (LRU cache implementation)
        Map<String, Integer> lruCache = new LinkedHashMap<>(16, 0.75f, true);
        lruCache.put("A", 1);
        lruCache.put("B", 2);
        lruCache.put("C", 3);

        System.out.println("\nBefore access: " + lruCache.keySet());

        lruCache.get("A");  // Access A - moves to end

        System.out.println("After accessing A: " + lruCache.keySet());
        // Output shows A at the end
    }
}
```

> aside positive
> **Map Selection:** HashMap for speed, TreeMap for sorted keys, LinkedHashMap for insertion order. Most common: HashMap!

## Queue and Deque

Duration: 10:00

Queues process elements in specific orders.

### PriorityQueue - Heap Based Priority Queue

**Characteristics:**

- Elements ordered by priority (natural order or Comparator)
- O(log n) for add/remove
- Not thread-safe
- Best for: Processing by priority

```java
import java.util.*;

public class PriorityQueueDemo {
    public static void main(String[] args) {
        // Natural ordering (min heap)
        PriorityQueue<Integer> numbers = new PriorityQueue<>();
        numbers.add(50);
        numbers.add(10);
        numbers.add(30);
        numbers.add(20);

        System.out.println("Priority Queue: " + numbers);
        // Note: toString() doesn't show priority order

        System.out.println("\nPolling (removes in priority order):");
        while (!numbers.isEmpty()) {
            System.out.println("  " + numbers.poll());  // 10, 20, 30, 50
        }

        // Max heap using reverse order
        PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Comparator.reverseOrder());
        maxHeap.addAll(Arrays.asList(50, 10, 30, 20));

        System.out.println("\nMax heap polling:");
        while (!maxHeap.isEmpty()) {
            System.out.println("  " + maxHeap.poll());  // 50, 30, 20, 10
        }

        // Custom objects with priority
        PriorityQueue<Task> tasks = new PriorityQueue<>(
            Comparator.comparingInt(Task::getPriority).reversed()
        );

        tasks.add(new Task("Low priority", 1));
        tasks.add(new Task("High priority", 5));
        tasks.add(new Task("Medium priority", 3));

        System.out.println("\nProcessing tasks by priority:");
        while (!tasks.isEmpty()) {
            Task task = tasks.poll();
            System.out.println("  " + task.getName() + " (priority: " +
                             task.getPriority() + ")");
        }
    }
}

class Task {
    private String name;
    private int priority;

    public Task(String name, int priority) {
        this.name = name;
        this.priority = priority;
    }

    public String getName() { return name; }
    public int getPriority() { return priority; }
}
```

### ArrayDeque - Resizable Array Double-Ended Queue

**Characteristics:**

- Fast add/remove at both ends
- No capacity restrictions
- Faster than LinkedList for queue/stack operations
- Best for: General-purpose queue/stack

```java
import java.util.*;

public class ArrayDequeDemo {
    public static void main(String[] args) {
        Deque<String> deque = new ArrayDeque<>();

        // Add to both ends
        deque.addFirst("First");
        deque.addLast("Last");
        deque.addFirst("New First");
        deque.addLast("New Last");

        System.out.println("Deque: " + deque);

        // Peek both ends
        System.out.println("Peek first: " + deque.peekFirst());
        System.out.println("Peek last: " + deque.peekLast());

        // Remove from both ends
        System.out.println("Remove first: " + deque.removeFirst());
        System.out.println("Remove last: " + deque.removeLast());
        System.out.println("After removal: " + deque);

        // Use as Stack (LIFO)
        Deque<Integer> stack = new ArrayDeque<>();
        stack.push(1);
        stack.push(2);
        stack.push(3);
        System.out.println("\nStack: " + stack);
        System.out.println("Pop: " + stack.pop());  // 3

        // Use as Queue (FIFO)
        Deque<Integer> queue = new ArrayDeque<>();
        queue.offer(1);
        queue.offer(2);
        queue.offer(3);
        System.out.println("\nQueue: " + queue);
        System.out.println("Poll: " + queue.poll());  // 1
    }
}
```

## Generics Fundamentals

Duration: 12:00

Generics provide type safety and eliminate casting.

### Why Generics?

**Before Generics (Java 4 and earlier):**

```java
List list = new ArrayList();
list.add("Hello");
list.add(123);  // No compile error!

String s = (String) list.get(0);  // Casting required
String s2 = (String) list.get(1);  // Runtime ClassCastException!
```

**With Generics (Java 5+):**

```java
List<String> list = new ArrayList<>();
list.add("Hello");
// list.add(123);  // Compile error - type safety!

String s = list.get(0);  // No casting needed
```

> aside positive
> **Key Benefit:** Generics catch type errors at compile-time instead of runtime!

### Generic Classes

```java
// Generic Box class
public class Box<T> {
    private T content;

    public void set(T content) {
        this.content = content;
    }

    public T get() {
        return content;
    }

    public boolean isEmpty() {
        return content == null;
    }
}

// Usage
Box<String> stringBox = new Box<>();
stringBox.set("Hello");
String value = stringBox.get();  // No casting

Box<Integer> intBox = new Box<>();
intBox.set(123);
Integer num = intBox.get();
```

### Multiple Type Parameters

```java
public class Pair<K, V> {
    private K key;
    private V value;

    public Pair(K key, V value) {
        this.key = key;
        this.value = value;
    }

    public K getKey() { return key; }
    public V getValue() { return value; }

    @Override
    public String toString() {
        return "(" + key + ", " + value + ")";
    }
}

// Usage
Pair<String, Integer> age = new Pair<>("Alice", 25);
Pair<Integer, String> idName = new Pair<>(101, "Bob");

System.out.println(age);      // (Alice, 25)
System.out.println(idName);   // (101, Bob)
```

### Generic Methods

```java
public class GenericMethods {

    // Generic method
    public static <T> void printArray(T[] array) {
        for (T element : array) {
            System.out.print(element + " ");
        }
        System.out.println();
    }

    // Generic method with return type
    public static <T> T getFirst(List<T> list) {
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }

    // Multiple type parameters
    public static <K, V> boolean containsKeyValue(Map<K, V> map, K key, V value) {
        return value.equals(map.get(key));
    }

    public static void main(String[] args) {
        Integer[] intArray = {1, 2, 3, 4, 5};
        String[] strArray = {"Hello", "World", "Java"};

        printArray(intArray);  // 1 2 3 4 5
        printArray(strArray);  // Hello World Java

        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        String first = getFirst(names);
        System.out.println("First: " + first);  // Alice
    }
}
```

### Bounded Type Parameters

Restrict type parameters to specific types or subclasses:

```java
// Upper bound - T must be Number or subclass
public class NumberBox<T extends Number> {
    private T number;

    public NumberBox(T number) {
        this.number = number;
    }

    public double getDoubleValue() {
        return number.doubleValue();  // Can call Number methods
    }
}

// Usage
NumberBox<Integer> intBox = new NumberBox<>(123);
NumberBox<Double> doubleBox = new NumberBox<>(123.45);
// NumberBox<String> strBox = new NumberBox<>("Hello");  // Compile error!

// Multiple bounds
public class ComparableBox<T extends Number & Comparable<T>> {
    private T value;

    public ComparableBox(T value) {
        this.value = value;
    }

    public boolean isGreaterThan(T other) {
        return value.compareTo(other) > 0;
    }
}
```

### Wildcards

```java
public class WildcardDemo {

    // Upper bounded wildcard - read only
    public static double sumNumbers(List<? extends Number> list) {
        double sum = 0;
        for (Number num : list) {
            sum += num.doubleValue();
        }
        return sum;
    }

    // Lower bounded wildcard - write only
    public static void addNumbers(List<? super Integer> list) {
        for (int i = 1; i <= 5; i++) {
            list.add(i);
        }
    }

    // Unbounded wildcard
    public static void printList(List<?> list) {
        for (Object element : list) {
            System.out.println(element);
        }
    }

    public static void main(String[] args) {
        List<Integer> integers = Arrays.asList(1, 2, 3);
        List<Double> doubles = Arrays.asList(1.5, 2.5, 3.5);

        System.out.println("Sum of integers: " + sumNumbers(integers));
        System.out.println("Sum of doubles: " + sumNumbers(doubles));

        List<Number> numbers = new ArrayList<>();
        addNumbers(numbers);
        System.out.println("Numbers: " + numbers);

        printList(integers);
        printList(doubles);
    }
}
```

> aside positive
> **PECS Principle:** Producer Extends, Consumer Super. Use `<? extends T>` for reading, `<? super T>` for writing.

## Comparable and Comparator

Duration: 12:00

Sort custom objects using natural ordering or custom comparisons.

### Comparable Interface

Define natural ordering for a class:

```java
public class Product implements Comparable<Product> {
    private String name;
    private double price;
    private int quantity;

    public Product(String name, double price, int quantity) {
        this.name = name;
        this.price = price;
        this.quantity = quantity;
    }

    @Override
    public int compareTo(Product other) {
        // Natural ordering by price
        return Double.compare(this.price, other.price);
    }

    @Override
    public String toString() {
        return name + " ($" + price + ", qty: " + quantity + ")";
    }

    // Getters
    public String getName() { return name; }
    public double getPrice() { return price; }
    public int getQuantity() { return quantity; }
}

// Usage
List<Product> products = new ArrayList<>();
products.add(new Product("Laptop", 999.99, 5));
products.add(new Product("Mouse", 29.99, 50));
products.add(new Product("Keyboard", 79.99, 20));

Collections.sort(products);  // Sorts by price (natural ordering)
System.out.println("Sorted by price: " + products);
```

### Comparator Interface

Define alternative orderings:

```java
import java.util.*;

public class ComparatorDemo {
    public static void main(String[] args) {
        List<Product> products = new ArrayList<>();
        products.add(new Product("Laptop", 999.99, 5));
        products.add(new Product("Mouse", 29.99, 50));
        products.add(new Product("Keyboard", 79.99, 20));
        products.add(new Product("Monitor", 299.99, 10));

        // Sort by name
        Collections.sort(products, new Comparator<Product>() {
            @Override
            public int compare(Product p1, Product p2) {
                return p1.getName().compareTo(p2.getName());
            }
        });
        System.out.println("Sorted by name: " + products);

        // Sort by quantity (lambda)
        products.sort((p1, p2) -> Integer.compare(p1.getQuantity(), p2.getQuantity()));
        System.out.println("Sorted by quantity: " + products);

        // Sort by price (method reference)
        products.sort(Comparator.comparingDouble(Product::getPrice));
        System.out.println("Sorted by price: " + products);

        // Reverse order
        products.sort(Comparator.comparingDouble(Product::getPrice).reversed());
        System.out.println("Sorted by price (descending): " + products);

        // Multiple criteria - by price, then by name
        products.sort(
            Comparator.comparingDouble(Product::getPrice)
                      .thenComparing(Product::getName)
        );
        System.out.println("Sorted by price, then name: " + products);

        // Natural order with nulls
        List<Product> withNulls = new ArrayList<>(products);
        withNulls.add(null);
        withNulls.sort(Comparator.nullsLast(Comparator.naturalOrder()));
        System.out.println("With null handling: " + withNulls);
    }
}
```

> aside positive
> **Modern Java:** Use Comparator static methods and lambdas instead of anonymous classes. Much cleaner!

## Build Inventory Management System

Duration: 20:00

Now let's build a complete inventory system using all collection types!

### Complete Product Class

```java
public class Product implements Comparable<Product> {
    private String id;
    private String name;
    private String category;
    private double price;
    private int quantity;

    public Product(String id, String name, String category, double price, int quantity) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.quantity = quantity;
    }

    @Override
    public int compareTo(Product other) {
        return this.name.compareTo(other.name);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Product product = (Product) obj;
        return id.equals(product.id);
    }

    @Override
    public int hashCode() {
        return id.hashCode();
    }

    @Override
    public String toString() {
        return String.format("%-8s %-20s %-15s $%-8.2f qty:%-4d",
                           id, name, category, price, quantity);
    }

    // Getters and setters
    public String getId() { return id; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public double getPrice() { return price; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}
```

### Inventory Manager

**InventoryManager.java:**

```java
import java.util.*;

public class InventoryManager {
    // Primary storage - fast lookups by ID
    private Map<String, Product> productsById;

    // Category index - products grouped by category
    private Map<String, Set<Product>> productsByCategory;

    // Low stock priority queue
    private PriorityQueue<Product> lowStockQueue;

    // Order history
    private Deque<Order> orderHistory;

    private static final int LOW_STOCK_THRESHOLD = 10;

    public InventoryManager() {
        this.productsById = new HashMap<>();
        this.productsByCategory = new HashMap<>();
        this.lowStockQueue = new PriorityQueue<>(
            Comparator.comparingInt(Product::getQuantity)
        );
        this.orderHistory = new ArrayDeque<>();
    }

    public void addProduct(Product product) {
        productsById.put(product.getId(), product);

        // Add to category index
        productsByCategory
            .computeIfAbsent(product.getCategory(), k -> new HashSet<>())
            .add(product);

        // Add to low stock queue if applicable
        if (product.getQuantity() <= LOW_STOCK_THRESHOLD) {
            lowStockQueue.offer(product);
        }

        System.out.println("Product added: " + product.getId());
    }

    public Product getProduct(String id) {
        return productsById.get(id);
    }

    public List<Product> getAllProducts() {
        return new ArrayList<>(productsById.values());
    }

    public Set<Product> getProductsByCategory(String category) {
        return productsByCategory.getOrDefault(category, new HashSet<>());
    }

    public List<Product> searchByName(String keyword) {
        List<Product> results = new ArrayList<>();
        String lowerKeyword = keyword.toLowerCase();

        for (Product product : productsById.values()) {
            if (product.getName().toLowerCase().contains(lowerKeyword)) {
                results.add(product);
            }
        }

        return results;
    }

    public void updateStock(String productId, int quantity) {
        Product product = productsById.get(productId);
        if (product == null) {
            System.out.println("Product not found: " + productId);
            return;
        }

        int oldQuantity = product.getQuantity();
        product.setQuantity(product.getQuantity() + quantity);

        // Update low stock queue
        if (oldQuantity > LOW_STOCK_THRESHOLD &&
            product.getQuantity() <= LOW_STOCK_THRESHOLD) {
            lowStockQueue.offer(product);
        }

        System.out.println("Stock updated for " + productId +
                         ": " + oldQuantity + " -> " + product.getQuantity());
    }

    public boolean placeOrder(String productId, int quantity) {
        Product product = productsById.get(productId);
        if (product == null) {
            System.out.println("Product not found: " + productId);
            return false;
        }

        if (product.getQuantity() < quantity) {
            System.out.println("Insufficient stock for " + productId);
            return false;
        }

        product.setQuantity(product.getQuantity() - quantity);

        Order order = new Order(
            "ORD-" + System.currentTimeMillis(),
            productId,
            product.getName(),
            quantity,
            product.getPrice() * quantity
        );

        orderHistory.addFirst(order);  // Most recent first

        // Check low stock
        if (product.getQuantity() <= LOW_STOCK_THRESHOLD) {
            lowStockQueue.offer(product);
        }

        System.out.println("Order placed: " + order.getId());
        return true;
    }

    public List<Product> getLowStockProducts() {
        List<Product> lowStock = new ArrayList<>();
        for (Product product : productsById.values()) {
            if (product.getQuantity() <= LOW_STOCK_THRESHOLD) {
                lowStock.add(product);
            }
        }
        lowStock.sort(Comparator.comparingInt(Product::getQuantity));
        return lowStock;
    }

    public List<Order> getRecentOrders(int count) {
        List<Order> recent = new ArrayList<>();
        int added = 0;
        for (Order order : orderHistory) {
            if (added >= count) break;
            recent.add(order);
            added++;
        }
        return recent;
    }

    public Map<String, Integer> getCategoryStats() {
        Map<String, Integer> stats = new TreeMap<>();  // Sorted by category

        for (Map.Entry<String, Set<Product>> entry : productsByCategory.entrySet()) {
            stats.put(entry.getKey(), entry.getValue().size());
        }

        return stats;
    }

    public void displayInventory() {
        System.out.println("\n=== INVENTORY ===");
        System.out.println("ID       Name                 Category        Price    Quantity");
        System.out.println("-".repeat(80));

        List<Product> sorted = getAllProducts();
        Collections.sort(sorted);  // Sort by name

        for (Product product : sorted) {
            System.out.println(product);
        }
    }

    public void displayLowStock() {
        List<Product> lowStock = getLowStockProducts();

        if (lowStock.isEmpty()) {
            System.out.println("\nNo low stock products.");
            return;
        }

        System.out.println("\n=== LOW STOCK ALERT ===");
        System.out.println("Products with quantity <= " + LOW_STOCK_THRESHOLD + ":");
        System.out.println("ID       Name                 Category        Price    Quantity");
        System.out.println("-".repeat(80));

        for (Product product : lowStock) {
            System.out.println(product);
        }
    }
}

class Order {
    private String id;
    private String productId;
    private String productName;
    private int quantity;
    private double totalPrice;

    public Order(String id, String productId, String productName,
                int quantity, double totalPrice) {
        this.id = id;
        this.productId = productId;
        this.productName = productName;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
    }

    public String getId() { return id; }
    public String getProductId() { return productId; }
    public String getProductName() { return productName; }
    public int getQuantity() { return quantity; }
    public double getTotalPrice() { return totalPrice; }

    @Override
    public String toString() {
        return String.format("%s: %s x%d ($%.2f)",
                           id, productName, quantity, totalPrice);
    }
}
```

### Main Application

```java
import java.util.*;

public class InventoryApp {
    public static void main(String[] args) {
        InventoryManager manager = new InventoryManager();

        // Add products
        manager.addProduct(new Product("P001", "Laptop", "Electronics", 999.99, 15));
        manager.addProduct(new Product("P002", "Mouse", "Electronics", 29.99, 50));
        manager.addProduct(new Product("P003", "Keyboard", "Electronics", 79.99, 8));
        manager.addProduct(new Product("P004", "Monitor", "Electronics", 299.99, 20));
        manager.addProduct(new Product("P005", "Desk Chair", "Furniture", 199.99, 5));
        manager.addProduct(new Product("P006", "Desk", "Furniture", 349.99, 3));
        manager.addProduct(new Product("P007", "Notebook", "Stationery", 4.99, 100));
        manager.addProduct(new Product("P008", "Pen Set", "Stationery", 12.99, 75));

        // Display inventory
        manager.displayInventory();

        // Search products
        System.out.println("\n=== SEARCH RESULTS (keyword: 'desk') ===");
        List<Product> searchResults = manager.searchByName("desk");
        for (Product product : searchResults) {
            System.out.println(product);
        }

        // Get products by category
        System.out.println("\n=== ELECTRONICS CATEGORY ===");
        Set<Product> electronics = manager.getProductsByCategory("Electronics");
        for (Product product : electronics) {
            System.out.println(product);
        }

        // Place orders
        System.out.println("\n=== PLACING ORDERS ===");
        manager.placeOrder("P001", 5);  // Laptop
        manager.placeOrder("P003", 3);  // Keyboard
        manager.placeOrder("P006", 2);  // Desk

        // Display recent orders
        System.out.println("\n=== RECENT ORDERS ===");
        List<Order> recentOrders = manager.getRecentOrders(5);
        for (Order order : recentOrders) {
            System.out.println(order);
        }

        // Display low stock alert
        manager.displayLowStock();

        // Category statistics
        System.out.println("\n=== CATEGORY STATISTICS ===");
        Map<String, Integer> stats = manager.getCategoryStats();
        stats.forEach((category, count) ->
            System.out.println(category + ": " + count + " products")
        );

        // Update stock
        System.out.println("\n=== RESTOCKING ===");
        manager.updateStock("P003", 20);  // Restock keyboard
        manager.updateStock("P006", 10);  // Restock desk

        // Final inventory
        manager.displayInventory();
        manager.displayLowStock();
    }
}
```

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered the Java Collections Framework and Generics!

### What You've Learned

- ✅ **Collections Framework:** Complete understanding of List, Set, Map, Queue
- ✅ **ArrayList vs LinkedList:** Performance trade-offs and use cases
- ✅ **HashSet vs TreeSet:** Uniqueness with and without ordering
- ✅ **HashMap vs TreeMap:** Fast lookups vs sorted keys
- ✅ **PriorityQueue:** Processing elements by priority
- ✅ **Generics:** Type-safe collections and methods
- ✅ **Bounded Types:** Restricting generic type parameters
- ✅ **Wildcards:** Flexible generic APIs (PECS principle)
- ✅ **Comparable/Comparator:** Natural and custom sorting
- ✅ **Real-World Application:** Complete inventory management system

### Key Takeaways

1. **Choose the right collection** - Performance matters
2. **Use Generics** - Type safety eliminates runtime errors
3. **Prefer interfaces** - Code to interfaces (List, Set, Map), not implementations
4. **ArrayList is default** - Unless you have specific needs
5. **HashMap is default** - Fast lookups for key-value pairs
6. **TreeSet/TreeMap for sorting** - When you need ordered elements
7. **PriorityQueue for priorities** - Process most important first
8. **Comparator for flexibility** - Multiple sorting strategies

### Performance Summary

| Operation | ArrayList | LinkedList | HashSet | TreeSet  | HashMap | TreeMap  |
| --------- | --------- | ---------- | ------- | -------- | ------- | -------- |
| Add       | O(1)\*    | O(1)       | O(1)    | O(log n) | O(1)    | O(log n) |
| Remove    | O(n)      | O(1)\*\*   | O(1)    | O(log n) | O(1)    | O(log n) |
| Get       | O(1)      | O(n)       | N/A     | N/A      | O(1)    | O(log n) |
| Contains  | O(n)      | O(n)       | O(1)    | O(log n) | O(1)    | O(log n) |

\*Amortized, \*\*At ends

### Next Steps

- **Codelab 1.5:** Memory Management & Garbage Collection
- **Section 2:** Java 8+ Features (Streams, Lambdas, Optional)

### Practice Exercises

Enhance the Inventory System:

1. **Supplier Management:** Add Supplier class with products
2. **Order Analytics:** Calculate total sales, most popular products
3. **Price History:** Track price changes over time (TreeMap with dates)
4. **Bulk Operations:** Import/export from CSV files
5. **Recommendations:** Suggest products based on order history
6. **Generic Repository:** Create generic CRUD repository pattern
7. **Cache Implementation:** Build LRU cache using LinkedHashMap

### Additional Resources

- [Java Collections Tutorial](https://docs.oracle.com/javase/tutorial/collections/)
- [Java Generics FAQ](http://www.angelikalanger.com/GenericsFAQ/JavaGenericsFAQ.html)
- [Effective Java - Chapter on Generics](https://www.oreilly.com/library/view/effective-java/9780134686097/)
- [Java Collections Performance](https://www.baeldung.com/java-collections-complexity)

> aside positive
> **Outstanding!** Collections and Generics are fundamental to Java programming. You now have the tools to build efficient, type-safe applications!
