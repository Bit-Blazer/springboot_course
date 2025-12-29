summary: Master Optional for null-safety, modern Date/Time API, immutable collections, var keyword, switch expressions, text blocks, and records by building a conference scheduling system
id: optional-datetime-modern-java
categories: Java, Java 8+, Modern Java, Date Time API
environments: Web
status: Published
home url: /springboot_course/

# Optional, Date/Time & Modern Java Features

## Introduction

Duration: 5:00

Modern Java (8+) introduced powerful features that make code safer, more readable, and more maintainable. This codelab covers essential modern Java features you'll use daily.

### What You'll Learn

- **Optional API:** Null-safe programming patterns
- **Date/Time API:** LocalDate, LocalTime, LocalDateTime, ZonedDateTime
- **Period & Duration:** Time-based calculations
- **Date Formatting:** DateTimeFormatter patterns
- **Immutable Collections:** List.of, Set.of, Map.of (Java 9+)
- **Var Keyword:** Local variable type inference (Java 10+)
- **Switch Expressions:** Modern switch syntax (Java 14+)
- **Text Blocks:** Multi-line strings (Java 15+)
- **Records:** Immutable data carriers (Java 16+)

### What You'll Build

A comprehensive **Conference Scheduling System** featuring:

- Event management with time zones
- Speaker profile service with Optional null-safety
- Configuration manager using Records and text blocks
- Schedule conflict detection
- Multi-timezone event coordination
- Immutable data structures for thread-safety

### Prerequisites

- Completed Codelab 2.1 (Functional Programming & Streams)
- JDK 17+ installed
- Understanding of basic Java syntax

## Understanding Optional

Duration: 12:00

Optional is a container object that may or may not contain a non-null value. It helps avoid NullPointerException.

### The Problem with Null

```java
// Traditional null-checking (error-prone)
public String getUserEmail(String userId) {
    User user = userRepository.findById(userId);
    if (user != null) {
        Profile profile = user.getProfile();
        if (profile != null) {
            Email email = profile.getEmail();
            if (email != null) {
                return email.getAddress();
            }
        }
    }
    return "N/A";
}
```

> aside negative
> **The Billion Dollar Mistake:** Tony Hoare, inventor of null references, calls them his "billion-dollar mistake" due to countless bugs and crashes they've caused.

### Optional to the Rescue

```java
// With Optional (clean and safe)
public String getUserEmail(String userId) {
    return userRepository.findById(userId)
        .map(User::getProfile)
        .map(Profile::getEmail)
        .map(Email::getAddress)
        .orElse("N/A");
}
```

### Creating Optional

```java
import java.util.Optional;

// Empty Optional
Optional<String> empty = Optional.empty();
System.out.println(empty.isPresent());  // false

// Optional with non-null value
Optional<String> name = Optional.of("Alice");
System.out.println(name.isPresent());  // true

// Optional.of with null throws exception
// Optional<String> invalid = Optional.of(null);  // NullPointerException!

// Optional with possibly null value
String nullableValue = null;
Optional<String> maybe = Optional.ofNullable(nullableValue);
System.out.println(maybe.isPresent());  // false

String nonNullValue = "Bob";
Optional<String> present = Optional.ofNullable(nonNullValue);
System.out.println(present.isPresent());  // true
```

### Checking for Values

```java
Optional<String> name = Optional.of("Alice");

// Old way (not recommended)
if (name.isPresent()) {
    System.out.println(name.get());
}

// Modern way
name.ifPresent(n -> System.out.println(n));
name.ifPresent(System.out::println);

// If present/else (Java 9+)
name.ifPresentOrElse(
    n -> System.out.println("Found: " + n),
    () -> System.out.println("Not found")
);
```

### Retrieving Values

```java
Optional<String> name = Optional.of("Alice");
Optional<String> empty = Optional.empty();

// get() - throws if empty (avoid!)
String value1 = name.get();  // "Alice"
// String value2 = empty.get();  // NoSuchElementException!

// orElse() - provide default
String value3 = name.orElse("Unknown");   // "Alice"
String value4 = empty.orElse("Unknown");  // "Unknown"

// orElseGet() - lazy default (better for expensive operations)
String value5 = empty.orElseGet(() -> fetchDefaultName());

// orElseThrow() - custom exception
String value6 = empty.orElseThrow(() ->
    new IllegalStateException("Name not found")
);

// or() - provide alternative Optional (Java 9+)
Optional<String> alternative = empty.or(() -> Optional.of("Default"));
```

> aside positive
> **Best Practice:** Prefer `orElse()`, `orElseGet()`, or `orElseThrow()` over `get()`. Never call `get()` without checking `isPresent()`.

### Transforming Optional

```java
// map() - transform value
Optional<String> name = Optional.of("alice");
Optional<String> upper = name.map(String::toUpperCase);
System.out.println(upper.get());  // "ALICE"

Optional<Integer> length = name.map(String::length);
System.out.println(length.get());  // 5

// flatMap() - avoid nested Optionals
class User {
    private String name;
    private Optional<Address> address;

    public Optional<Address> getAddress() {
        return address;
    }
}

class Address {
    private String city;

    public String getCity() {
        return city;
    }
}

Optional<User> user = Optional.of(new User());

// Wrong: returns Optional<Optional<Address>>
// Optional<Optional<Address>> nested = user.map(User::getAddress);

// Right: returns Optional<Address>
Optional<Address> address = user.flatMap(User::getAddress);

// Chain flatMap
Optional<String> city = user
    .flatMap(User::getAddress)
    .map(Address::getCity);
```

### Filtering Optional

```java
Optional<Integer> age = Optional.of(25);

// filter() - keep if predicate matches
Optional<Integer> adult = age.filter(a -> a >= 18);
System.out.println(adult.isPresent());  // true

Optional<Integer> senior = age.filter(a -> a >= 65);
System.out.println(senior.isPresent());  // false

// Practical example
Optional<String> email = Optional.of("user@example.com");

Optional<String> validEmail = email
    .filter(e -> e.contains("@"))
    .filter(e -> e.length() > 5);

validEmail.ifPresent(e -> sendEmail(e));
```

### Practical Optional Examples

```java
import java.util.*;

public class OptionalDemo {
    // Repository simulation
    static class UserRepository {
        private Map<String, User> users = new HashMap<>();

        public UserRepository() {
            users.put("1", new User("Alice", "alice@example.com"));
            users.put("2", new User("Bob", null));
        }

        public Optional<User> findById(String id) {
            return Optional.ofNullable(users.get(id));
        }
    }

    static class User {
        private String name;
        private String email;

        public User(String name, String email) {
            this.name = name;
            this.email = email;
        }

        public String getName() { return name; }
        public Optional<String> getEmail() {
            return Optional.ofNullable(email);
        }
    }

    public static void main(String[] args) {
        UserRepository repo = new UserRepository();

        // Example 1: Safe retrieval
        String email1 = repo.findById("1")
            .flatMap(User::getEmail)
            .orElse("no-email@example.com");
        System.out.println("User 1 email: " + email1);

        // Example 2: Chaining with filter
        repo.findById("2")
            .flatMap(User::getEmail)
            .filter(email -> email.contains("@"))
            .ifPresentOrElse(
                email -> System.out.println("Valid email: " + email),
                () -> System.out.println("No valid email found")
            );

        // Example 3: Transformation
        List<String> userNames = Arrays.asList("1", "2", "3").stream()
            .map(repo::findById)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .map(User::getName)
            .toList();  // Java 16+

        System.out.println("User names: " + userNames);
    }
}
```

> aside positive
> **Key Insight:** Optional is designed for return types, not for fields or parameters. Use it to express "this method might not return a value."

## Date and Time API

Duration: 15:00

The modern Date/Time API (java.time package) replaces the old Date and Calendar classes with immutable, thread-safe classes.

### Core Classes

```java
import java.time.*;

// Current date
LocalDate today = LocalDate.now();
System.out.println("Today: " + today);  // 2024-12-24

// Current time
LocalTime now = LocalTime.now();
System.out.println("Now: " + now);  // 14:30:45.123

// Current date and time
LocalDateTime dateTime = LocalDateTime.now();
System.out.println("DateTime: " + dateTime);  // 2024-12-24T14:30:45.123

// Date with time zone
ZonedDateTime zonedNow = ZonedDateTime.now();
System.out.println("Zoned: " + zonedNow);
// 2024-12-24T14:30:45.123+05:30[Asia/Kolkata]

// Instant (timestamp)
Instant instant = Instant.now();
System.out.println("Instant: " + instant);
// 2024-12-24T09:00:45.123Z (UTC)
```

### LocalDate Operations

```java
import java.time.LocalDate;
import java.time.Month;

// Create specific dates
LocalDate date1 = LocalDate.of(2024, 12, 25);
LocalDate date2 = LocalDate.of(2024, Month.DECEMBER, 25);
LocalDate date3 = LocalDate.parse("2024-12-25");

System.out.println(date1);  // 2024-12-25

// Get components
int year = date1.getYear();           // 2024
Month month = date1.getMonth();       // DECEMBER
int monthValue = date1.getMonthValue(); // 12
int day = date1.getDayOfMonth();      // 25
int dayOfYear = date1.getDayOfYear(); // 360

// Date arithmetic
LocalDate tomorrow = date1.plusDays(1);
LocalDate nextWeek = date1.plusWeeks(1);
LocalDate nextMonth = date1.plusMonths(1);
LocalDate nextYear = date1.plusYears(1);

LocalDate yesterday = date1.minusDays(1);
LocalDate lastWeek = date1.minusWeeks(1);

System.out.println("Tomorrow: " + tomorrow);
System.out.println("Next week: " + nextWeek);

// Date comparison
LocalDate date4 = LocalDate.of(2024, 12, 31);
boolean isBefore = date1.isBefore(date4);  // true
boolean isAfter = date1.isAfter(date4);    // false
boolean isEqual = date1.isEqual(date4);    // false

// Check properties
boolean isLeapYear = date1.isLeapYear();
System.out.println("Is 2024 a leap year? " + isLeapYear);  // true
```

### LocalTime Operations

```java
import java.time.LocalTime;

// Create specific times
LocalTime time1 = LocalTime.of(14, 30);          // 14:30
LocalTime time2 = LocalTime.of(14, 30, 45);      // 14:30:45
LocalTime time3 = LocalTime.of(14, 30, 45, 123_000_000); // with nanos
LocalTime time4 = LocalTime.parse("14:30:45");

// Get components
int hour = time1.getHour();       // 14
int minute = time1.getMinute();   // 30
int second = time2.getSecond();   // 45

// Time arithmetic
LocalTime later = time1.plusHours(2);      // 16:30
LocalTime much later = time1.plusMinutes(90); // 16:00
LocalTime earlier = time1.minusHours(1);   // 13:30

// Comparison
boolean isBefore = time1.isBefore(time2);
boolean isAfter = time1.isAfter(time2);

// Special times
LocalTime midnight = LocalTime.MIDNIGHT;  // 00:00
LocalTime noon = LocalTime.NOON;          // 12:00
LocalTime max = LocalTime.MAX;            // 23:59:59.999999999
LocalTime min = LocalTime.MIN;            // 00:00
```

### LocalDateTime Operations

```java
import java.time.LocalDateTime;

// Combine date and time
LocalDate date = LocalDate.of(2024, 12, 25);
LocalTime time = LocalTime.of(14, 30);
LocalDateTime dateTime1 = LocalDateTime.of(date, time);
LocalDateTime dateTime2 = LocalDateTime.of(2024, 12, 25, 14, 30);

// Get components
LocalDate dateComponent = dateTime1.toLocalDate();
LocalTime timeComponent = dateTime1.toLocalTime();

// Arithmetic
LocalDateTime future = dateTime1
    .plusDays(7)
    .plusHours(3)
    .plusMinutes(30);

// Parse and format
LocalDateTime parsed = LocalDateTime.parse("2024-12-25T14:30:45");
String formatted = dateTime1.toString();  // ISO format
```

### Working with Time Zones

```java
import java.time.*;

// Create ZonedDateTime
ZonedDateTime nyTime = ZonedDateTime.now(ZoneId.of("America/New_York"));
ZonedDateTime tokyoTime = ZonedDateTime.now(ZoneId.of("Asia/Tokyo"));
ZonedDateTime utcTime = ZonedDateTime.now(ZoneId.of("UTC"));

System.out.println("New York: " + nyTime);
System.out.println("Tokyo: " + tokyoTime);
System.out.println("UTC: " + utcTime);

// Convert between time zones
ZonedDateTime istTime = ZonedDateTime.of(
    LocalDateTime.of(2024, 12, 25, 14, 30),
    ZoneId.of("Asia/Kolkata")
);

ZonedDateTime estTime = istTime.withZoneSameInstant(
    ZoneId.of("America/New_York")
);

System.out.println("IST: " + istTime);
System.out.println("EST: " + estTime);

// Get all available zones
Set<String> allZones = ZoneId.getAvailableZoneIds();
System.out.println("Total time zones: " + allZones.size());

// ZoneOffset
ZoneOffset offset = ZoneOffset.of("+05:30");
OffsetDateTime offsetDateTime = OffsetDateTime.now(offset);
```

### Period and Duration

```java
import java.time.*;

// Period - date-based (years, months, days)
LocalDate start = LocalDate.of(2024, 1, 1);
LocalDate end = LocalDate.of(2024, 12, 31);

Period period = Period.between(start, end);
System.out.println("Period: " + period);  // P11M30D
System.out.println("Months: " + period.getMonths());  // 11
System.out.println("Days: " + period.getDays());      // 30

// Create periods
Period oneWeek = Period.ofWeeks(1);
Period twoMonths = Period.ofMonths(2);
Period threeYears = Period.ofYears(3);

LocalDate future = start.plus(Period.ofMonths(6));
System.out.println("6 months later: " + future);

// Duration - time-based (hours, minutes, seconds)
LocalTime startTime = LocalTime.of(9, 0);
LocalTime endTime = LocalTime.of(17, 30);

Duration duration = Duration.between(startTime, endTime);
System.out.println("Duration: " + duration);  // PT8H30M
System.out.println("Hours: " + duration.toHours());      // 8
System.out.println("Minutes: " + duration.toMinutes());  // 510

// Create durations
Duration oneHour = Duration.ofHours(1);
Duration thirtyMinutes = Duration.ofMinutes(30);
Duration fiveSeconds = Duration.ofSeconds(5);

LocalTime later = startTime.plus(Duration.ofHours(2));

// Complex calculations
LocalDateTime meeting = LocalDateTime.of(2024, 12, 25, 14, 0);
LocalDateTime now = LocalDateTime.now();
Duration timeUntilMeeting = Duration.between(now, meeting);

long days = timeUntilMeeting.toDays();
long hours = timeUntilMeeting.toHours();
System.out.println("Meeting in " + days + " days or " + hours + " hours");
```

### Date Formatting

```java
import java.time.format.DateTimeFormatter;
import java.time.*;

LocalDateTime dateTime = LocalDateTime.of(2024, 12, 25, 14, 30, 45);

// Predefined formatters
String iso = dateTime.format(DateTimeFormatter.ISO_DATE_TIME);
System.out.println("ISO: " + iso);  // 2024-12-25T14:30:45

// Custom patterns
DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("dd/MM/yyyy");
String formatted1 = dateTime.format(formatter1);
System.out.println(formatted1);  // 25/12/2024

DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("MMM dd, yyyy");
String formatted2 = dateTime.format(formatter2);
System.out.println(formatted2);  // Dec 25, 2024

DateTimeFormatter formatter3 = DateTimeFormatter.ofPattern(
    "EEEE, MMMM dd, yyyy 'at' hh:mm a"
);
String formatted3 = dateTime.format(formatter3);
System.out.println(formatted3);  // Wednesday, December 25, 2024 at 02:30 PM

// Parsing
String dateStr = "25-12-2024";
DateTimeFormatter parser = DateTimeFormatter.ofPattern("dd-MM-yyyy");
LocalDate parsed = LocalDate.parse(dateStr, parser);
System.out.println("Parsed: " + parsed);

// Common patterns
// yyyy - year (2024)
// MM - month (12)
// dd - day (25)
// HH - hour 24-format (14)
// hh - hour 12-format (02)
// mm - minute (30)
// ss - second (45)
// a - AM/PM marker
// EEEE - day name (Wednesday)
// MMMM - month name (December)
```

## Modern Java Features

Duration: 15:00

Java 9+ introduced several features that make code cleaner and more expressive.

### Immutable Collections (Java 9+)

```java
import java.util.*;

// Old way (mutable)
List<String> oldList = new ArrayList<>();
oldList.add("Apple");
oldList.add("Banana");
List<String> unmodifiable = Collections.unmodifiableList(oldList);

// New way (immutable)
List<String> fruits = List.of("Apple", "Banana", "Cherry");
// fruits.add("Orange");  // UnsupportedOperationException!

// Empty immutable lists
List<String> emptyList = List.of();

// Set
Set<Integer> numbers = Set.of(1, 2, 3, 4, 5);
// Set<Integer> duplicates = Set.of(1, 2, 2);  // IllegalArgumentException!

// Map
Map<String, Integer> ages = Map.of(
    "Alice", 25,
    "Bob", 30,
    "Charlie", 35
);

// Map with more than 10 entries
Map<String, String> config = Map.ofEntries(
    Map.entry("host", "localhost"),
    Map.entry("port", "8080"),
    Map.entry("timeout", "30"),
    Map.entry("retries", "3")
);

// Benefits
// 1. Thread-safe (immutable)
// 2. Memory efficient
// 3. Null-safe (nulls not allowed)

// Copying collections
List<String> mutableList = new ArrayList<>(fruits);  // Create mutable copy
List<String> immutableCopy = List.copyOf(mutableList);
```

> aside positive
> **Performance:** Immutable collections are more memory-efficient and faster than their mutable counterparts. Use them whenever you don't need to modify the collection.

### Var Keyword (Java 10+)

```java
// Type inference for local variables
var message = "Hello";  // String
var count = 42;         // int
var price = 99.99;      // double
var active = true;      // boolean

// With collections
var names = List.of("Alice", "Bob", "Charlie");  // List<String>
var ages = Map.of("Alice", 25, "Bob", 30);       // Map<String, Integer>

// With streams
var filtered = names.stream()
    .filter(name -> name.startsWith("A"))
    .toList();  // List<String>

// Complex types made simple
var result = someMethodReturningComplexType();  // Let compiler figure it out

// Cannot use var without initializer
// var x;  // ERROR: Cannot infer type

// Cannot use var with null
// var y = null;  // ERROR: Cannot infer type

// Good use cases
for (var name : names) {
    System.out.println(name);
}

try (var reader = new BufferedReader(new FileReader("file.txt"))) {
    // ...
}

// When NOT to use var
// var obscure = calculate();  // What type is this?
int clear = calculate();     // Much better!
```

> aside negative
> **Use Judiciously:** var reduces boilerplate but can harm readability. Use it when the type is obvious from the right-hand side.

### Switch Expressions (Java 14+)

```java
// Old switch statement
String dayType;
int day = 3;
switch (day) {
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
        dayType = "Weekday";
        break;
    case 6:
    case 7:
        dayType = "Weekend";
        break;
    default:
        dayType = "Invalid";
}

// New switch expression
String dayType = switch (day) {
    case 1, 2, 3, 4, 5 -> "Weekday";
    case 6, 7 -> "Weekend";
    default -> "Invalid";
};

// With multiple statements
String result = switch (day) {
    case 1 -> {
        System.out.println("Monday!");
        yield "Start of week";
    }
    case 5 -> {
        System.out.println("Friday!");
        yield "End of week";
    }
    default -> "Regular day";
};

// Pattern matching example
Object obj = "Hello";
String formatted = switch (obj) {
    case Integer i -> String.format("int: %d", i);
    case String s -> String.format("String: %s", s);
    case null -> "null value";
    default -> "Unknown type";
};

// Practical example: HTTP status
int statusCode = 404;
String message = switch (statusCode) {
    case 200 -> "OK";
    case 201 -> "Created";
    case 400 -> "Bad Request";
    case 401 -> "Unauthorized";
    case 404 -> "Not Found";
    case 500 -> "Internal Server Error";
    default -> "Unknown Status";
};
```

### Text Blocks (Java 15+)

```java
// Old way (painful!)
String json = "{\n" +
              "  \"name\": \"Alice\",\n" +
              "  \"age\": 25,\n" +
              "  \"email\": \"alice@example.com\"\n" +
              "}";

// New way (beautiful!)
String json = """
    {
      "name": "Alice",
      "age": 25,
      "email": "alice@example.com"
    }
    """;

// SQL query
String sql = """
    SELECT u.name, u.email, o.total
    FROM users u
    INNER JOIN orders o ON u.id = o.user_id
    WHERE o.status = 'COMPLETED'
    ORDER BY o.created_at DESC
    LIMIT 10
    """;

// HTML
String html = """
    <html>
        <head>
            <title>Welcome</title>
        </head>
        <body>
            <h1>Hello, World!</h1>
        </body>
    </html>
    """;

// String interpolation with formatted()
String name = "Alice";
int age = 25;
String greeting = """
    Hello, %s!
    You are %d years old.
    """.formatted(name, age);

// Escaping special characters
String escaped = """
    Line 1
    Line 2 with \"""quotes\"""
    Line 3
    """;

// Preserve formatting
String code = """
    public class Hello {
        public static void main(String[] args) {
            System.out.println("Hello, World!");
        }
    }
    """;
```

> aside positive
> **Readability Win:** Text blocks make multi-line strings readable and maintainable. Perfect for JSON, SQL, HTML, and code templates!

### Records (Java 16+)

```java
// Old way: POJO with boilerplate
class PersonOld {
    private final String name;
    private final int age;

    public PersonOld(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String getName() { return name; }
    public int getAge() { return age; }

    @Override
    public boolean equals(Object o) { /* ... */ }

    @Override
    public int hashCode() { /* ... */ }

    @Override
    public String toString() { /* ... */ }
}

// New way: Record (one line!)
record Person(String name, int age) {}

// Usage
Person alice = new Person("Alice", 25);
System.out.println(alice.name());  // Accessor methods
System.out.println(alice.age());
System.out.println(alice);  // Person[name=Alice, age=25]

Person alice2 = new Person("Alice", 25);
System.out.println(alice.equals(alice2));  // true
System.out.println(alice.hashCode() == alice2.hashCode());  // true

// Custom methods in records
record Rectangle(double width, double height) {
    // Compact constructor (validation)
    public Rectangle {
        if (width <= 0 || height <= 0) {
            throw new IllegalArgumentException("Dimensions must be positive");
        }
    }

    // Custom method
    public double area() {
        return width * height;
    }

    // Static factory method
    public static Rectangle square(double side) {
        return new Rectangle(side, side);
    }
}

Rectangle rect = new Rectangle(5, 10);
System.out.println("Area: " + rect.area());  // 50.0

Rectangle square = Rectangle.square(5);
System.out.println("Square: " + square);

// Records with other records
record Address(String street, String city, String country) {}
record Employee(String name, int id, Address address) {}

Address addr = new Address("123 Main St", "New York", "USA");
Employee emp = new Employee("Alice", 101, addr);
System.out.println(emp.address().city());  // New York

// Records in collections
List<Person> people = List.of(
    new Person("Alice", 25),
    new Person("Bob", 30),
    new Person("Charlie", 35)
);

var adults = people.stream()
    .filter(p -> p.age() >= 18)
    .toList();
```

## Build Conference Scheduling System

Duration: 35:00

Let's build a complete conference scheduling system using all the modern Java features!

### Project Structure

Create `ConferenceScheduler.java`:

```java
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.*;

// Records for data modeling
record Speaker(String id, String name, Optional<String> email,
               Optional<String> bio, String expertise) {

    public Speaker {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Speaker name cannot be blank");
        }
    }

    public String displayInfo() {
        var emailStr = email.orElse("No email provided");
        var bioStr = bio.orElse("No bio available");
        return """
            Speaker: %s
            Email: %s
            Expertise: %s
            Bio: %s
            """.formatted(name, emailStr, expertise, bioStr);
    }
}

record Session(String id, String title, Speaker speaker,
               LocalDateTime startTime, Duration duration,
               String room, String track) {

    public Session {
        if (duration.isNegative() || duration.isZero()) {
            throw new IllegalArgumentException("Duration must be positive");
        }
    }

    public LocalDateTime endTime() {
        return startTime.plus(duration);
    }

    public boolean overlapsWith(Session other) {
        return !this.endTime().isBefore(other.startTime) &&
               !other.endTime().isBefore(this.startTime);
    }

    public String formatSchedule() {
        var formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");
        return """
            %s
            Speaker: %s
            Time: %s - %s
            Duration: %d minutes
            Room: %s | Track: %s
            """.formatted(
                title,
                speaker.name(),
                startTime.format(formatter),
                endTime().format(formatter),
                duration.toMinutes(),
                room,
                track
            );
    }
}

record Conference(String name, LocalDate startDate, LocalDate endDate,
                 ZoneId timeZone, String venue) {

    public Period duration() {
        return Period.between(startDate, endDate);
    }

    public boolean isActive(LocalDate date) {
        return !date.isBefore(startDate) && !date.isAfter(endDate);
    }

    public String formatInfo() {
        var formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
        return """
            Conference: %s
            Dates: %s - %s
            Duration: %d days
            Venue: %s
            Time Zone: %s
            """.formatted(
                name,
                startDate.format(formatter),
                endDate.format(formatter),
                duration().getDays() + 1,
                venue,
                timeZone
            );
    }
}

record Attendee(String id, String name, String email,
                Set<String> registeredSessions, String category) {

    public Attendee {
        registeredSessions = Set.copyOf(registeredSessions);  // Immutable
    }

    public boolean isRegistered(String sessionId) {
        return registeredSessions.contains(sessionId);
    }
}

public class ConferenceScheduler {
    private final Conference conference;
    private final List<Speaker> speakers;
    private final List<Session> sessions;
    private final List<Attendee> attendees;

    public ConferenceScheduler() {
        this.conference = createConference();
        this.speakers = createSpeakers();
        this.sessions = createSessions();
        this.attendees = createAttendees();
    }

    private Conference createConference() {
        return new Conference(
            "Java Developer Conference 2024",
            LocalDate.of(2024, 12, 15),
            LocalDate.of(2024, 12, 17),
            ZoneId.of("America/New_York"),
            "Convention Center, New York"
        );
    }

    private List<Speaker> createSpeakers() {
        return List.of(
            new Speaker("S1", "Alice Johnson",
                Optional.of("alice@example.com"),
                Optional.of("10+ years in Java development"),
                "Spring Boot"),
            new Speaker("S2", "Bob Smith",
                Optional.of("bob@example.com"),
                Optional.empty(),
                "Microservices"),
            new Speaker("S3", "Charlie Davis",
                Optional.empty(),
                Optional.of("Cloud architecture expert"),
                "Cloud Native"),
            new Speaker("S4", "Diana Miller",
                Optional.of("diana@example.com"),
                Optional.of("Performance optimization specialist"),
                "JVM Internals"),
            new Speaker("S5", "Eve Wilson",
                Optional.of("eve@example.com"),
                Optional.empty(),
                "Reactive Programming")
        );
    }

    private List<Session> createSessions() {
        var day1 = LocalDate.of(2024, 12, 15);
        var day2 = LocalDate.of(2024, 12, 16);
        var day3 = LocalDate.of(2024, 12, 17);

        return List.of(
            new Session("SE1", "Spring Boot Best Practices",
                findSpeaker("S1").orElseThrow(),
                LocalDateTime.of(day1, LocalTime.of(9, 0)),
                Duration.ofMinutes(90),
                "Room A", "Backend"),

            new Session("SE2", "Microservices Architecture",
                findSpeaker("S2").orElseThrow(),
                LocalDateTime.of(day1, LocalTime.of(11, 0)),
                Duration.ofMinutes(90),
                "Room B", "Architecture"),

            new Session("SE3", "Cloud Native Java",
                findSpeaker("S3").orElseThrow(),
                LocalDateTime.of(day1, LocalTime.of(14, 0)),
                Duration.ofMinutes(60),
                "Room A", "Cloud"),

            new Session("SE4", "JVM Performance Tuning",
                findSpeaker("S4").orElseThrow(),
                LocalDateTime.of(day2, LocalTime.of(9, 0)),
                Duration.ofMinutes(120),
                "Room A", "Performance"),

            new Session("SE5", "Reactive Programming with Spring",
                findSpeaker("S5").orElseThrow(),
                LocalDateTime.of(day2, LocalTime.of(11, 30)),
                Duration.ofMinutes(90),
                "Room B", "Backend"),

            new Session("SE6", "Advanced Spring Boot",
                findSpeaker("S1").orElseThrow(),
                LocalDateTime.of(day2, LocalTime.of(14, 0)),
                Duration.ofMinutes(90),
                "Room A", "Backend"),

            new Session("SE7", "Kubernetes for Java Developers",
                findSpeaker("S3").orElseThrow(),
                LocalDateTime.of(day3, LocalTime.of(9, 0)),
                Duration.ofMinutes(120),
                "Room B", "Cloud"),

            new Session("SE8", "Monitoring and Observability",
                findSpeaker("S2").orElseThrow(),
                LocalDateTime.of(day3, LocalTime.of(11, 30)),
                Duration.ofMinutes(60),
                "Room A", "DevOps")
        );
    }

    private List<Attendee> createAttendees() {
        return List.of(
            new Attendee("A1", "John Doe", "john@example.com",
                Set.of("SE1", "SE3", "SE4"), "Developer"),
            new Attendee("A2", "Jane Smith", "jane@example.com",
                Set.of("SE2", "SE5", "SE7"), "Architect"),
            new Attendee("A3", "Mike Brown", "mike@example.com",
                Set.of("SE1", "SE4", "SE6", "SE8"), "Senior Developer")
        );
    }

    // 1. Find speaker by ID
    public Optional<Speaker> findSpeaker(String speakerId) {
        return speakers.stream()
            .filter(s -> s.id().equals(speakerId))
            .findFirst();
    }

    // 2. Find sessions by speaker
    public List<Session> findSessionsBySpeaker(String speakerName) {
        return sessions.stream()
            .filter(s -> s.speaker().name().equalsIgnoreCase(speakerName))
            .sorted(Comparator.comparing(Session::startTime))
            .toList();
    }

    // 3. Find sessions by track
    public Map<String, List<Session>> groupByTrack() {
        return sessions.stream()
            .collect(Collectors.groupingBy(
                Session::track,
                Collectors.collectingAndThen(
                    Collectors.toList(),
                    list -> list.stream()
                        .sorted(Comparator.comparing(Session::startTime))
                        .toList()
                )
            ));
    }

    // 4. Find sessions by date
    public List<Session> findSessionsByDate(LocalDate date) {
        return sessions.stream()
            .filter(s -> s.startTime().toLocalDate().equals(date))
            .sorted(Comparator.comparing(Session::startTime))
            .toList();
    }

    // 5. Check for schedule conflicts
    public List<Session> findConflictingSessions(Session session) {
        return sessions.stream()
            .filter(s -> !s.id().equals(session.id()))
            .filter(s -> s.room().equals(session.room()))
            .filter(session::overlapsWith)
            .toList();
    }

    // 6. Get sessions in time range
    public List<Session> findSessionsInRange(LocalDateTime start, LocalDateTime end) {
        return sessions.stream()
            .filter(s -> !s.endTime().isBefore(start) && !s.startTime().isAfter(end))
            .sorted(Comparator.comparing(Session::startTime))
            .toList();
    }

    // 7. Calculate total session duration
    public Duration calculateTotalDuration() {
        return sessions.stream()
            .map(Session::duration)
            .reduce(Duration.ZERO, Duration::plus);
    }

    // 8. Find sessions by duration
    public List<Session> findSessionsByDuration(int minMinutes, int maxMinutes) {
        return sessions.stream()
            .filter(s -> s.duration().toMinutes() >= minMinutes)
            .filter(s -> s.duration().toMinutes() <= maxMinutes)
            .toList();
    }

    // 9. Get speaker statistics
    public Map<Speaker, Long> getSpeakerSessionCounts() {
        return sessions.stream()
            .collect(Collectors.groupingBy(
                Session::speaker,
                Collectors.counting()
            ));
    }

    // 10. Find popular sessions (most registered)
    public List<Map.Entry<Session, Long>> findPopularSessions(int topN) {
        Map<String, Long> registrationCounts = attendees.stream()
            .flatMap(a -> a.registeredSessions().stream())
            .collect(Collectors.groupingBy(
                sessionId -> sessionId,
                Collectors.counting()
            ));

        return sessions.stream()
            .map(session -> Map.entry(
                session,
                registrationCounts.getOrDefault(session.id(), 0L)
            ))
            .sorted(Map.Entry.<Session, Long>comparingByValue().reversed())
            .limit(topN)
            .toList();
    }

    // 11. Convert to different time zone
    public ZonedDateTime convertToTimeZone(LocalDateTime localTime, ZoneId targetZone) {
        return ZonedDateTime.of(localTime, conference.timeZone())
            .withZoneSameInstant(targetZone);
    }

    // 12. Generate daily schedule
    public String generateDailySchedule(LocalDate date) {
        var sessionsForDay = findSessionsByDate(date);

        if (sessionsForDay.isEmpty()) {
            return "No sessions scheduled for " + date;
        }

        var schedule = new StringBuilder();
        schedule.append("""

            =====================================
            SCHEDULE FOR %s
            =====================================

            """.formatted(date.format(DateTimeFormatter.ofPattern("EEEE, MMMM dd, yyyy"))));

        sessionsForDay.forEach(session ->
            schedule.append(session.formatSchedule()).append("\n")
        );

        return schedule.toString();
    }

    // 13. Find attendee's personalized schedule
    public String generateAttendeeSchedule(String attendeeId) {
        var attendee = attendees.stream()
            .filter(a -> a.id().equals(attendeeId))
            .findFirst()
            .orElseThrow(() -> new IllegalArgumentException("Attendee not found"));

        var registeredSessions = sessions.stream()
            .filter(s -> attendee.isRegistered(s.id()))
            .sorted(Comparator.comparing(Session::startTime))
            .toList();

        var schedule = new StringBuilder();
        schedule.append("""

            =====================================
            PERSONAL SCHEDULE FOR %s
            =====================================
            Email: %s
            Category: %s
            Registered Sessions: %d

            """.formatted(
                attendee.name(),
                attendee.email(),
                attendee.category(),
                registeredSessions.size()
            ));

        registeredSessions.forEach(session ->
            schedule.append(session.formatSchedule()).append("\n")
        );

        return schedule.toString();
    }

    // 14. Validate schedule (find conflicts)
    public List<String> validateSchedule() {
        var conflicts = new ArrayList<String>();

        for (var session : sessions) {
            var conflicting = findConflictingSessions(session);
            if (!conflicting.isEmpty()) {
                conflicts.add("Conflict: %s overlaps with %d other session(s) in %s"
                    .formatted(session.title(), conflicting.size(), session.room()));
            }
        }

        return conflicts;
    }

    public void runScheduler() {
        System.out.println("\n" + "=".repeat(60));
        System.out.println("CONFERENCE SCHEDULING SYSTEM");
        System.out.println("=".repeat(60));

        // Conference info
        System.out.println(conference.formatInfo());

        // Speaker statistics
        System.out.println("\n--- SPEAKER STATISTICS ---");
        getSpeakerSessionCounts().forEach((speaker, count) ->
            System.out.printf("%s: %d session(s)%n", speaker.name(), count)
        );

        // Sessions by track
        System.out.println("\n--- SESSIONS BY TRACK ---");
        groupByTrack().forEach((track, trackSessions) -> {
            System.out.printf("\n%s Track (%d sessions):%n", track, trackSessions.size());
            trackSessions.forEach(s ->
                System.out.printf("  - %s (%d min)%n", s.title(), s.duration().toMinutes())
            );
        });

        // Daily schedules
        var confDates = conference.startDate().datesUntil(
            conference.endDate().plusDays(1)
        ).toList();

        confDates.forEach(date ->
            System.out.println(generateDailySchedule(date))
        );

        // Popular sessions
        System.out.println("\n--- TOP 3 POPULAR SESSIONS ---");
        findPopularSessions(3).forEach(entry ->
            System.out.printf("%s - %d registrations%n",
                entry.getKey().title(), entry.getValue())
        );

        // Total duration
        var totalDuration = calculateTotalDuration();
        System.out.printf("%nTotal content duration: %d hours %d minutes%n",
            totalDuration.toHours(), totalDuration.toMinutesPart());

        // Time zone conversion example
        var firstSession = sessions.get(0);
        var istTime = convertToTimeZone(firstSession.startTime(), ZoneId.of("Asia/Kolkata"));
        System.out.printf("%nFirst session in IST: %s%n", istTime);

        // Attendee schedule
        System.out.println(generateAttendeeSchedule("A1"));

        // Validate schedule
        var conflicts = validateSchedule();
        if (conflicts.isEmpty()) {
            System.out.println("\n✓ No scheduling conflicts found!");
        } else {
            System.out.println("\n✗ Scheduling conflicts detected:");
            conflicts.forEach(System.out::println);
        }
    }

    public static void main(String[] args) {
        var scheduler = new ConferenceScheduler();
        scheduler.runScheduler();
    }
}
```

### Run the Application

```console
$ javac ConferenceScheduler.java
$ java ConferenceScheduler
```

> aside positive
> **Production Ready:** This scheduler demonstrates real-world use of modern Java features with proper null-safety, immutability, and time zone handling!

## Testing Modern Features

Duration: 5:00

Let's create test cases for our modern Java code:

```java
import java.util.*;
import java.time.*;

public class ModernJavaTests {
    public static void main(String[] args) {
        testOptional();
        testDateTime();
        testRecords();
        testSwitchExpressions();
        System.out.println("\n✓ All tests passed!");
    }

    static void testOptional() {
        // Test 1: Optional creation
        var present = Optional.of("Hello");
        var empty = Optional.empty();
        var nullable = Optional.ofNullable(null);

        assert present.isPresent();
        assert !empty.isPresent();
        assert nullable.isEmpty();

        // Test 2: Optional transformation
        var result = present
            .map(String::toUpperCase)
            .filter(s -> s.length() > 3)
            .orElse("DEFAULT");
        assert result.equals("HELLO");

        // Test 3: Optional chaining
        var length = present
            .map(String::length)
            .orElse(0);
        assert length == 5;

        System.out.println("✓ Optional tests passed");
    }

    static void testDateTime() {
        // Test 1: Date creation
        var date = LocalDate.of(2024, 12, 25);
        assert date.getYear() == 2024;
        assert date.getMonthValue() == 12;
        assert date.getDayOfMonth() == 25;

        // Test 2: Date arithmetic
        var tomorrow = date.plusDays(1);
        assert tomorrow.getDayOfMonth() == 26;

        // Test 3: Period calculation
        var start = LocalDate.of(2024, 1, 1);
        var end = LocalDate.of(2024, 12, 31);
        var period = Period.between(start, end);
        assert period.getMonths() == 11;

        // Test 4: Time zones
        var nyTime = ZonedDateTime.of(
            LocalDateTime.of(2024, 12, 25, 12, 0),
            ZoneId.of("America/New_York")
        );
        var tokyoTime = nyTime.withZoneSameInstant(ZoneId.of("Asia/Tokyo"));
        assert tokyoTime.getHour() != nyTime.getHour();

        System.out.println("✓ DateTime tests passed");
    }

    static void testRecords() {
        // Test 1: Record creation
        record Point(int x, int y) {}
        var p1 = new Point(1, 2);
        var p2 = new Point(1, 2);
        var p3 = new Point(2, 3);

        // Test 2: Auto-generated equals
        assert p1.equals(p2);
        assert !p1.equals(p3);

        // Test 3: Auto-generated hashCode
        assert p1.hashCode() == p2.hashCode();

        // Test 4: Auto-generated toString
        assert p1.toString().contains("Point");

        // Test 5: Immutability
        var list = List.of(p1, p2, p3);
        assert list.size() == 3;

        System.out.println("✓ Record tests passed");
    }

    static void testSwitchExpressions() {
        // Test 1: Basic switch expression
        var day = 3;
        var type = switch (day) {
            case 1, 2, 3, 4, 5 -> "Weekday";
            case 6, 7 -> "Weekend";
            default -> "Invalid";
        };
        assert type.equals("Weekday");

        // Test 2: Switch with yield
        var result = switch (day) {
            case 1 -> "Monday";
            case 3 -> {
                var msg = "Wednesday";
                yield msg;
            }
            default -> "Other";
        };
        assert result.equals("Wednesday");

        System.out.println("✓ Switch expression tests passed");
    }
}
```

## Conclusion

Duration: 3:00

Congratulations! 🎉 You've mastered modern Java features!

### What You've Learned

- ✅ **Optional API:** Null-safe programming with proper error handling
- ✅ **Date/Time API:** Modern temporal handling with time zones
- ✅ **Period & Duration:** Time-based calculations
- ✅ **Immutable Collections:** Thread-safe, efficient collections
- ✅ **Var Keyword:** Type inference for cleaner code
- ✅ **Switch Expressions:** Pattern matching and cleaner syntax
- ✅ **Text Blocks:** Multi-line strings made readable
- ✅ **Records:** Concise immutable data classes

### Key Takeaways

1. **Optional** prevents NullPointerException and makes APIs clearer
2. **java.time** is immutable and thread-safe (unlike old Date/Calendar)
3. **Records** eliminate boilerplate for data classes
4. **Text blocks** improve readability for multi-line strings
5. **Switch expressions** reduce boilerplate and errors
6. **Immutable collections** are safer and more efficient

### Best Practices

- Use Optional for return types, not for fields or parameters
- Always specify time zones when dealing with timestamps
- Prefer immutable collections when data doesn't change
- Use var when the type is obvious from the right-hand side
- Use records for simple data carriers
- Use text blocks for SQL, JSON, HTML, and multi-line text

### Next Steps

Ready for more? Continue to:

- **Codelab 2.3:** Asynchronous Programming with CompletableFuture
- **Codelab 2.4:** Logging with Log4j
- **Codelab 2.5:** IDE Debugging Mastery

### Practice Exercises

1. **Event Management:** Build an event booking system with time zones
2. **User Profile Service:** Implement profile management with Optional
3. **Configuration Manager:** Parse JSON/YAML using records and text blocks
4. **Time Tracker:** Build time tracking with different time zones
5. **Data Transfer Objects:** Convert legacy POJOs to records

### Additional Resources

- [Optional JavaDoc](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/Optional.html)
- [Date/Time API Guide](https://docs.oracle.com/javase/tutorial/datetime/)
- [Records Tutorial](https://openjdk.org/jeps/395)
- [Text Blocks](https://openjdk.org/jeps/378)
- [Pattern Matching](https://openjdk.org/projects/amber/)

> aside positive
> **Excellent Progress!** You're now equipped with modern Java features used in production applications worldwide. These skills are essential for Spring Boot development!
