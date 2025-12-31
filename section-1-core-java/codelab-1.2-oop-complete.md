summary: Master object-oriented programming concepts including classes, inheritance, interfaces, abstract classes, polymorphism, and packages through building a banking system
id: oop-complete
categories: Java, Object-Oriented Programming, OOP
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM
feedback link: https://github.com/Bit-Blazer/springboot_course/issues/new

# Object-Oriented Programming Complete

## Introduction

Duration: 3:00

Object-Oriented Programming (OOP) is the cornerstone of Java development. In this codelab, you'll master all essential OOP concepts by building real-world applications that demonstrate the power of objects, inheritance, and polymorphism.

### What You'll Learn

- Classes, objects, fields, and methods
- Constructors and the `this` keyword
- Inheritance with `extends` and the `super` keyword
- Interfaces and `implements` keyword
- Abstract classes and methods
- Method overloading and overriding
- Polymorphism in action
- Packages and access modifiers
- Encapsulation and data hiding

### What You'll Build

1. **Banking System** - Complete account hierarchy with savings, checking accounts
2. **Animal Simulation** - Abstract classes with multiple interfaces (Flyable, Swimmable)
3. **Multi-package Structure** - Professional project organization

### Prerequisites

- Completed Codelab 1.1 (Java Fundamentals & Control Flow)
- Understanding of variables, methods, and control flow
- Java JDK 17+ installed
- IDE or text editor ready

## Understanding Classes and Objects

Duration: 12:00

Everything in Java is an object (except primitives). Let's understand the building blocks.

### What are Classes and Objects?

**Class:** A blueprint/template for creating objects
**Object:** An instance of a class with actual data

Think of it like:

- **Class = Cookie Cutter** (the template)
- **Object = Cookie** (the actual thing you create)

### Creating Your First Class

Create a file `Person.java`:

```java
public class Person {
    // Fields (instance variables)
    String name;
    int age;
    String email;

    // Method
    void displayInfo() {
        System.out.println("Name: " + name);
        System.out.println("Age: " + age);
        System.out.println("Email: " + email);
    }
}
```

### Creating and Using Objects

Create `PersonDemo.java`:

```java
public class PersonDemo {
    public static void main(String[] args) {
        // Creating objects
        Person person1 = new Person();
        person1.name = "Alice";
        person1.age = 25;
        person1.email = "alice@example.com";

        Person person2 = new Person();
        person2.name = "Bob";
        person2.age = 30;
        person2.email = "bob@example.com";

        // Using objects
        person1.displayInfo();
        System.out.println();
        person2.displayInfo();
    }
}
```

Run it:

```console
$ javac Person.java PersonDemo.java
$ java PersonDemo
Name: Alice
Age: 25
Email: alice@example.com

Name: Bob
Age: 30
Email: bob@example.com
```

> aside positive
> **Key Insight:** Each object has its own copy of instance variables. `person1` and `person2` have independent `name`, `age`, and `email` values!

### Constructors

Constructors initialize objects. They have the same name as the class and no return type.

**Update Person.java:**

```java
public class Person {
    String name;
    int age;
    String email;

    // Default constructor
    public Person() {
        this.name = "Unknown";
        this.age = 0;
        this.email = "not.provided@example.com";
    }

    // Parameterized constructor
    public Person(String name, int age, String email) {
        this.name = name;
        this.age = age;
        this.email = email;
    }

    // Constructor with partial parameters
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
        this.email = "not.provided@example.com";
    }

    void displayInfo() {
        System.out.println("Name: " + name);
        System.out.println("Age: " + age);
        System.out.println("Email: " + email);
    }
}
```

**Using constructors:**

```java
public class PersonDemo {
    public static void main(String[] args) {
        Person p1 = new Person();  // Default constructor
        Person p2 = new Person("Charlie", 28, "charlie@example.com");
        Person p3 = new Person("Diana", 32);

        p1.displayInfo();
        System.out.println();
        p2.displayInfo();
        System.out.println();
        p3.displayInfo();
    }
}
```

### The `this` Keyword

`this` refers to the current object instance:

```java
public Person(String name, int age, String email) {
    this.name = name;      // this.name = instance variable
    this.age = age;        // age = parameter
    this.email = email;
}
```

**Constructor chaining with `this()`:**

```java
public Person(String name, int age) {
    this(name, age, "not.provided@example.com");  // Calls 3-param constructor
}
```

> aside positive
> **Best Practice:** Use `this` to distinguish between instance variables and parameters with the same name.

### Access Modifiers

Control who can access your class members:

| Modifier              | Class | Package | Subclass | World |
| --------------------- | ----- | ------- | -------- | ----- |
| `public`              | ✅    | ✅      | ✅       | ✅    |
| `protected`           | ✅    | ✅      | ✅       | ❌    |
| default (no modifier) | ✅    | ✅      | ❌       | ❌    |
| `private`             | ✅    | ❌      | ❌       | ❌    |

**Encapsulation with private fields:**

```java
public class Person {
    private String name;
    private int age;
    private String email;

    public Person(String name, int age, String email) {
        this.name = name;
        setAge(age);  // Use setter for validation
        this.email = email;
    }

    // Getters
    public String getName() {
        return name;
    }

    public int getAge() {
        return age;
    }

    public String getEmail() {
        return email;
    }

    // Setters with validation
    public void setName(String name) {
        if (name != null && !name.trim().isEmpty()) {
            this.name = name;
        }
    }

    public void setAge(int age) {
        if (age >= 0 && age <= 150) {
            this.age = age;
        }
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
```

> aside negative
> **Important:** Always make fields `private` and provide `public` getters/setters. This is encapsulation - hiding internal state and controlling access.

## Method Overloading

Duration: 8:00

Method overloading allows multiple methods with the same name but different parameters.

### Overloading Rules

Methods can be overloaded by:

1. **Number of parameters**
2. **Type of parameters**
3. **Order of parameters**

**NOT by return type alone!**

### Practical Example

Create `Calculator.java`:

```java
public class Calculator {

    // Add two integers
    public int add(int a, int b) {
        return a + b;
    }

    // Add three integers
    public int add(int a, int b, int c) {
        return a + b + c;
    }

    // Add two doubles
    public double add(double a, double b) {
        return a + b;
    }

    // Add array of integers
    public int add(int[] numbers) {
        int sum = 0;
        for (int num : numbers) {
            sum += num;
        }
        return sum;
    }

    // Concatenate strings (still called "add")
    public String add(String a, String b) {
        return a + b;
    }
}
```

**Using overloaded methods:**

```java
public class CalculatorDemo {
    public static void main(String[] args) {
        Calculator calc = new Calculator();

        System.out.println(calc.add(5, 3));              // 8
        System.out.println(calc.add(5, 3, 2));           // 10
        System.out.println(calc.add(5.5, 3.2));          // 8.7
        System.out.println(calc.add(new int[]{1, 2, 3, 4})); // 10
        System.out.println(calc.add("Hello", " World")); // Hello World
    }
}
```

> aside positive
> **Compiler Magic:** Java automatically selects the right method based on the arguments you pass. This is called **compile-time polymorphism** or **static binding**.

### Constructor Overloading

You've already seen this with Person class constructors!

```java
public Person() { ... }
public Person(String name, int age) { ... }
public Person(String name, int age, String email) { ... }
```

## Inheritance

Duration: 15:00

Inheritance allows a class to inherit properties and methods from another class, promoting code reuse.

### Basic Inheritance with `extends`

Create the banking system foundation:

**Account.java (Parent/Superclass):**

```java
public class Account {
    protected String accountNumber;
    protected String accountHolder;
    protected double balance;

    public Account(String accountNumber, String accountHolder, double initialBalance) {
        this.accountNumber = accountNumber;
        this.accountHolder = accountHolder;
        this.balance = initialBalance;
    }

    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
            System.out.println("Deposited: $" + amount);
            System.out.println("New balance: $" + balance);
        }
    }

    public void withdraw(double amount) {
        if (amount > 0 && amount <= balance) {
            balance -= amount;
            System.out.println("Withdrawn: $" + amount);
            System.out.println("New balance: $" + balance);
        } else {
            System.out.println("Insufficient funds!");
        }
    }

    public void displayInfo() {
        System.out.println("Account Number: " + accountNumber);
        System.out.println("Account Holder: " + accountHolder);
        System.out.println("Balance: $" + balance);
    }

    public double getBalance() {
        return balance;
    }
}
```

**SavingsAccount.java (Child/Subclass):**

```java
public class SavingsAccount extends Account {
    private double interestRate;
    private int withdrawalLimit;
    private int withdrawalCount;

    public SavingsAccount(String accountNumber, String accountHolder,
                          double initialBalance, double interestRate) {
        super(accountNumber, accountHolder, initialBalance);  // Call parent constructor
        this.interestRate = interestRate;
        this.withdrawalLimit = 3;
        this.withdrawalCount = 0;
    }

    // Method overriding
    @Override
    public void withdraw(double amount) {
        if (withdrawalCount >= withdrawalLimit) {
            System.out.println("Withdrawal limit reached for this period!");
            return;
        }

        super.withdraw(amount);  // Call parent method
        withdrawalCount++;
    }

    // New method specific to SavingsAccount
    public void applyInterest() {
        double interest = balance * (interestRate / 100);
        balance += interest;
        System.out.println("Interest applied: $" + interest);
        System.out.println("New balance: $" + balance);
    }

    public void resetWithdrawalCount() {
        withdrawalCount = 0;
        System.out.println("Withdrawal count reset.");
    }

    @Override
    public void displayInfo() {
        super.displayInfo();  // Call parent method
        System.out.println("Interest Rate: " + interestRate + "%");
        System.out.println("Withdrawals: " + withdrawalCount + "/" + withdrawalLimit);
    }
}
```

**CheckingAccount.java:**

```java
public class CheckingAccount extends Account {
    private double overdraftLimit;
    private double overdraftFee;

    public CheckingAccount(String accountNumber, String accountHolder,
                           double initialBalance, double overdraftLimit) {
        super(accountNumber, accountHolder, initialBalance);
        this.overdraftLimit = overdraftLimit;
        this.overdraftFee = 35.0;
    }

    @Override
    public void withdraw(double amount) {
        if (amount > 0 && amount <= (balance + overdraftLimit)) {
            balance -= amount;
            System.out.println("Withdrawn: $" + amount);

            if (balance < 0) {
                balance -= overdraftFee;
                System.out.println("Overdraft fee charged: $" + overdraftFee);
                System.out.println("You are in overdraft!");
            }

            System.out.println("New balance: $" + balance);
        } else {
            System.out.println("Transaction denied - exceeds overdraft limit!");
        }
    }

    public void displayOverdraftInfo() {
        System.out.println("Overdraft Limit: $" + overdraftLimit);
        System.out.println("Overdraft Fee: $" + overdraftFee);
    }

    @Override
    public void displayInfo() {
        super.displayInfo();
        displayOverdraftInfo();
    }
}
```

### Using the Inheritance Hierarchy

**BankDemo.java:**

```java
public class BankDemo {
    public static void main(String[] args) {
        // Create accounts
        SavingsAccount savings = new SavingsAccount("SAV-001", "Alice", 1000.0, 3.5);
        CheckingAccount checking = new CheckingAccount("CHK-001", "Bob", 500.0, 200.0);

        System.out.println("=== SAVINGS ACCOUNT ===");
        savings.displayInfo();
        System.out.println();

        savings.deposit(500);
        System.out.println();

        savings.withdraw(200);
        savings.withdraw(100);
        savings.withdraw(50);
        savings.withdraw(25);  // Should exceed limit
        System.out.println();

        savings.applyInterest();
        System.out.println();

        System.out.println("=== CHECKING ACCOUNT ===");
        checking.displayInfo();
        System.out.println();

        checking.withdraw(600);  // Goes into overdraft
        System.out.println();

        checking.displayInfo();
    }
}
```

### The `super` Keyword

`super` refers to the parent class:

1. **Call parent constructor:** `super(accountNumber, accountHolder, initialBalance);`
2. **Call parent method:** `super.withdraw(amount);`
3. **Access parent field:** `super.balance` (if not private)

> aside negative
> **Important:** `super()` must be the first statement in a constructor if used.

### Method Overriding

**Rules for overriding:**

1. Same method signature (name, parameters, return type)
2. Cannot reduce access level (can increase)
3. Use `@Override` annotation (recommended)
4. Cannot override `final`, `static`, or `private` methods

```java
@Override
public void withdraw(double amount) {
    // Custom implementation
}
```

> aside positive
> **Best Practice:** Always use `@Override` annotation. It helps catch errors at compile-time if you accidentally change the signature.

## Abstract Classes and Methods

Duration: 12:00

Abstract classes provide a template for subclasses but cannot be instantiated themselves.

### When to Use Abstract Classes

Use abstract classes when:

- You want to share code among related classes
- You expect subclasses to have common methods but different implementations
- You want to define non-public members (interfaces can't)

### Creating an Abstract Animal Hierarchy

**Animal.java (Abstract Base Class):**

```java
public abstract class Animal {
    protected String name;
    protected int age;
    protected double weight;

    public Animal(String name, int age, double weight) {
        this.name = name;
        this.age = age;
        this.weight = weight;
    }

    // Abstract method - no implementation
    public abstract void makeSound();

    // Abstract method
    public abstract void move();

    // Concrete method - has implementation
    public void eat(String food) {
        System.out.println(name + " is eating " + food);
        weight += 0.1;
    }

    public void sleep() {
        System.out.println(name + " is sleeping... Zzz");
    }

    public void displayInfo() {
        System.out.println("Name: " + name);
        System.out.println("Age: " + age + " years");
        System.out.println("Weight: " + weight + " kg");
    }

    // Getters
    public String getName() { return name; }
    public int getAge() { return age; }
    public double getWeight() { return weight; }
}
```

**Dog.java:**

```java
public class Dog extends Animal {
    private String breed;

    public Dog(String name, int age, double weight, String breed) {
        super(name, age, weight);
        this.breed = breed;
    }

    @Override
    public void makeSound() {
        System.out.println(name + " says: Woof! Woof!");
    }

    @Override
    public void move() {
        System.out.println(name + " is running on four legs!");
    }

    public void fetch() {
        System.out.println(name + " is fetching the ball!");
    }

    @Override
    public void displayInfo() {
        super.displayInfo();
        System.out.println("Breed: " + breed);
    }
}
```

**Cat.java:**

```java
public class Cat extends Animal {
    private boolean isIndoor;

    public Cat(String name, int age, double weight, boolean isIndoor) {
        super(name, age, weight);
        this.isIndoor = isIndoor;
    }

    @Override
    public void makeSound() {
        System.out.println(name + " says: Meow! Meow!");
    }

    @Override
    public void move() {
        System.out.println(name + " is walking gracefully!");
    }

    public void scratch() {
        System.out.println(name + " is scratching the furniture!");
    }

    @Override
    public void displayInfo() {
        super.displayInfo();
        System.out.println("Indoor cat: " + (isIndoor ? "Yes" : "No"));
    }
}
```

**Bird.java:**

```java
public class Bird extends Animal {
    private double wingSpan;

    public Bird(String name, int age, double weight, double wingSpan) {
        super(name, age, weight);
        this.wingSpan = wingSpan;
    }

    @Override
    public void makeSound() {
        System.out.println(name + " says: Tweet! Tweet!");
    }

    @Override
    public void move() {
        System.out.println(name + " is flying through the sky!");
    }

    public void fly() {
        System.out.println(name + " spreads wings (" + wingSpan + "m) and takes off!");
    }

    @Override
    public void displayInfo() {
        super.displayInfo();
        System.out.println("Wing Span: " + wingSpan + " meters");
    }
}
```

### Using Abstract Classes

**AnimalDemo.java:**

```java
public class AnimalDemo {
    public static void main(String[] args) {
        // Cannot do: Animal animal = new Animal(...); // ERROR!

        Dog dog = new Dog("Buddy", 3, 25.5, "Golden Retriever");
        Cat cat = new Cat("Whiskers", 2, 4.2, true);
        Bird bird = new Bird("Tweety", 1, 0.05, 0.3);

        System.out.println("=== DOG ===");
        dog.displayInfo();
        dog.makeSound();
        dog.move();
        dog.fetch();
        dog.eat("dog food");
        dog.sleep();
        System.out.println();

        System.out.println("=== CAT ===");
        cat.displayInfo();
        cat.makeSound();
        cat.move();
        cat.scratch();
        cat.eat("fish");
        System.out.println();

        System.out.println("=== BIRD ===");
        bird.displayInfo();
        bird.makeSound();
        bird.move();
        bird.fly();
        bird.eat("seeds");
    }
}
```

> aside positive
> **Key Point:** Abstract classes can't be instantiated, but you can have references of abstract type pointing to concrete objects (polymorphism).

## Interfaces

Duration: 15:00

Interfaces define a contract - what a class can do, not how it does it.

### Interface Basics

**Syntax:**

```java
public interface InterfaceName {
    // Abstract methods (public abstract by default)
    void method1();
    int method2(String param);

    // Default methods (Java 8+)
    default void defaultMethod() {
        System.out.println("Default implementation");
    }

    // Static methods (Java 8+)
    static void staticMethod() {
        System.out.println("Static method");
    }

    // Constants (public static final by default)
    int CONSTANT = 100;
}
```

### Creating Ability Interfaces

**Flyable.java:**

```java
public interface Flyable {
    void fly();
    void land();

    default void displayFlyingStatus() {
        System.out.println("This creature can fly!");
    }
}
```

**Swimmable.java:**

```java
public interface Swimmable {
    void swim();
    void dive();

    default void displaySwimmingStatus() {
        System.out.println("This creature can swim!");
    }
}
```

**Walkable.java:**

```java
public interface Walkable {
    void walk();
    void run();
}
```

### Implementing Multiple Interfaces

**Duck.java (implements multiple interfaces):**

```java
public class Duck extends Animal implements Flyable, Swimmable, Walkable {

    public Duck(String name, int age, double weight) {
        super(name, age, weight);
    }

    @Override
    public void makeSound() {
        System.out.println(name + " says: Quack! Quack!");
    }

    @Override
    public void move() {
        System.out.println(name + " can walk, swim, and fly!");
    }

    // Flyable interface methods
    @Override
    public void fly() {
        System.out.println(name + " is flying!");
    }

    @Override
    public void land() {
        System.out.println(name + " is landing on water!");
    }

    // Swimmable interface methods
    @Override
    public void swim() {
        System.out.println(name + " is swimming gracefully!");
    }

    @Override
    public void dive() {
        System.out.println(name + " is diving for fish!");
    }

    // Walkable interface methods
    @Override
    public void walk() {
        System.out.println(name + " is waddling on land!");
    }

    @Override
    public void run() {
        System.out.println(name + " is running (waddling quickly)!");
    }
}
```

**Fish.java:**

```java
public class Fish extends Animal implements Swimmable {
    private String species;

    public Fish(String name, int age, double weight, String species) {
        super(name, age, weight);
        this.species = species;
    }

    @Override
    public void makeSound() {
        System.out.println(name + " makes bubbles... glub glub!");
    }

    @Override
    public void move() {
        swim();
    }

    @Override
    public void swim() {
        System.out.println(name + " is swimming through water!");
    }

    @Override
    public void dive() {
        System.out.println(name + " is diving deeper!");
    }

    @Override
    public void displayInfo() {
        super.displayInfo();
        System.out.println("Species: " + species);
    }
}
```

**Penguin.java:**

```java
public class Penguin extends Animal implements Swimmable, Walkable {

    public Penguin(String name, int age, double weight) {
        super(name, age, weight);
    }

    @Override
    public void makeSound() {
        System.out.println(name + " says: Honk! Honk!");
    }

    @Override
    public void move() {
        System.out.println(name + " waddles and swims!");
    }

    @Override
    public void swim() {
        System.out.println(name + " is swimming super fast underwater!");
    }

    @Override
    public void dive() {
        System.out.println(name + " is diving deep for fish!");
    }

    @Override
    public void walk() {
        System.out.println(name + " is waddling on ice!");
    }

    @Override
    public void run() {
        System.out.println(name + " is sliding on its belly!");
    }
}
```

### Interface Demo

**InterfaceDemo.java:**

```java
public class InterfaceDemo {
    public static void main(String[] args) {
        Duck duck = new Duck("Donald", 2, 1.5);
        Fish fish = new Fish("Nemo", 1, 0.2, "Clownfish");
        Penguin penguin = new Penguin("Pingu", 3, 15.0);

        System.out.println("=== DUCK (Flies, Swims, Walks) ===");
        duck.displayInfo();
        duck.makeSound();
        duck.fly();
        duck.swim();
        duck.walk();
        duck.displayFlyingStatus();
        duck.displaySwimmingStatus();
        System.out.println();

        System.out.println("=== FISH (Swims only) ===");
        fish.displayInfo();
        fish.makeSound();
        fish.swim();
        fish.dive();
        fish.displaySwimmingStatus();
        System.out.println();

        System.out.println("=== PENGUIN (Swims, Walks, no flying) ===");
        penguin.displayInfo();
        penguin.makeSound();
        penguin.swim();
        penguin.walk();
        penguin.run();
        System.out.println();

        // Polymorphism with interfaces
        System.out.println("=== POLYMORPHISM DEMO ===");
        Swimmable[] swimmers = {duck, fish, penguin};

        for (Swimmable swimmer : swimmers) {
            if (swimmer instanceof Animal) {
                System.out.println(((Animal) swimmer).getName() + " can swim:");
            }
            swimmer.swim();
        }
    }
}
```

### Abstract Class vs Interface

| Feature              | Abstract Class      | Interface                   |
| -------------------- | ------------------- | --------------------------- |
| Multiple inheritance | No (single)         | Yes (multiple)              |
| Constructor          | Yes                 | No                          |
| Fields               | All types           | Only public static final    |
| Method types         | Abstract + Concrete | Abstract + Default + Static |
| Access modifiers     | All                 | Public only (methods)       |
| When to use          | IS-A relationship   | CAN-DO behavior             |

> aside positive
> **Rule of Thumb:** Use abstract classes for shared code and common state. Use interfaces for defining capabilities/contracts.

## Polymorphism in Action

Duration: 12:00

Polymorphism means "many forms" - the ability of objects to take multiple forms.

### Types of Polymorphism

1. **Compile-time (Static):** Method overloading
2. **Runtime (Dynamic):** Method overriding

### Runtime Polymorphism Demo

**Create a Zoo Management System:**

```java
public class Zoo {
    public static void main(String[] args) {
        // Polymorphism: Parent reference, child objects
        Animal[] animals = {
            new Dog("Max", 4, 30.0, "Labrador"),
            new Cat("Luna", 3, 5.0, true),
            new Bird("Sky", 1, 0.1, 0.4),
            new Duck("Daffy", 2, 1.8),
            new Fish("Bubbles", 1, 0.3, "Goldfish"),
            new Penguin("Skipper", 5, 18.0)
        };

        System.out.println("=== ZOO FEEDING TIME ===\n");

        for (Animal animal : animals) {
            System.out.println("--- " + animal.getName() + " ---");
            animal.displayInfo();
            animal.makeSound();  // Polymorphic call
            animal.move();       // Polymorphic call
            animal.eat("food");

            // Type checking and casting
            if (animal instanceof Flyable) {
                System.out.println(animal.getName() + " is a flyer!");
                ((Flyable) animal).fly();
            }

            if (animal instanceof Swimmable) {
                System.out.println(animal.getName() + " is a swimmer!");
                ((Swimmable) animal).swim();
            }

            System.out.println();
        }

        // Demonstrate polymorphic behavior
        System.out.println("=== POLYMORPHIC METHOD CALLS ===\n");
        feedAnimal(new Dog("Rover", 2, 20.0, "Beagle"));
        feedAnimal(new Cat("Mittens", 1, 4.0, false));
        feedAnimal(new Bird("Chirpy", 1, 0.08, 0.25));
    }

    // Polymorphic method - accepts any Animal
    public static void feedAnimal(Animal animal) {
        System.out.println("Feeding " + animal.getName() + "...");
        animal.eat("nutritious food");
        System.out.println();
    }
}
```

### The `instanceof` Operator

Check object type at runtime:

```java
if (animal instanceof Dog) {
    Dog dog = (Dog) animal;
    dog.fetch();
}

// Java 16+ pattern matching
if (animal instanceof Dog dog) {
    dog.fetch();  // Automatically cast!
}
```

> aside positive
> **Modern Java:** Use pattern matching with `instanceof` (Java 16+) to avoid explicit casting.

### Polymorphism Benefits

1. **Flexibility:** Write code that works with parent types
2. **Extensibility:** Add new subclasses without changing existing code
3. **Maintainability:** Single interface for multiple implementations
4. **Code Reuse:** Write once, use with many types

## Packages and Organization

Duration: 10:00

Packages organize classes into namespaces and prevent naming conflicts.

### Creating Package Structure

**Project structure:**

```
banking-system/
├── com/
│   └── bank/
│       ├── accounts/
│       │   ├── Account.java
│       │   ├── SavingsAccount.java
│       │   └── CheckingAccount.java
│       ├── services/
│       │   ├── BankingService.java
│       │   └── TransactionService.java
│       └── models/
│           ├── Customer.java
│           └── Transaction.java
└── Main.java
```

### Package Declaration and Import

**com/bank/accounts/Account.java:**

```java
package com.bank.accounts;

public class Account {
    protected String accountNumber;
    protected String accountHolder;
    protected double balance;

    public Account(String accountNumber, String accountHolder, double initialBalance) {
        this.accountNumber = accountNumber;
        this.accountHolder = accountHolder;
        this.balance = initialBalance;
    }

    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        }
    }

    public boolean withdraw(double amount) {
        if (amount > 0 && amount <= balance) {
            balance -= amount;
            return true;
        }
        return false;
    }

    public double getBalance() {
        return balance;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public String getAccountHolder() {
        return accountHolder;
    }
}
```

**com/bank/models/Customer.java:**

```java
package com.bank.models;

import com.bank.accounts.Account;
import java.util.ArrayList;
import java.util.List;

public class Customer {
    private String customerId;
    private String name;
    private String email;
    private List<Account> accounts;

    public Customer(String customerId, String name, String email) {
        this.customerId = customerId;
        this.name = name;
        this.email = email;
        this.accounts = new ArrayList<>();
    }

    public void addAccount(Account account) {
        accounts.add(account);
    }

    public List<Account> getAccounts() {
        return accounts;
    }

    public double getTotalBalance() {
        double total = 0;
        for (Account account : accounts) {
            total += account.getBalance();
        }
        return total;
    }

    // Getters
    public String getCustomerId() { return customerId; }
    public String getName() { return name; }
    public String getEmail() { return email; }
}
```

**Main.java:**

```java
import com.bank.accounts.*;
import com.bank.models.Customer;

public class Main {
    public static void main(String[] args) {
        Customer customer = new Customer("CUST-001", "John Doe", "john@example.com");

        SavingsAccount savings = new SavingsAccount("SAV-001", "John Doe", 5000.0, 3.5);
        CheckingAccount checking = new CheckingAccount("CHK-001", "John Doe", 2000.0, 500.0);

        customer.addAccount(savings);
        customer.addAccount(checking);

        System.out.println("Customer: " + customer.getName());
        System.out.println("Total Balance: $" + customer.getTotalBalance());
    }
}
```

### Compiling with Packages

```console
javac com/bank/accounts/*.java
javac com/bank/models/*.java
javac Main.java
java Main
```

> aside positive
> **Best Practice:** Use reverse domain name convention for packages: `com.company.project.module`

### Import Statements

```java
// Import specific class
import com.bank.accounts.Account;

// Import all classes from package
import com.bank.accounts.*;

// Import static members
import static java.lang.Math.PI;
import static java.lang.Math.sqrt;
```

## Complete Banking System

Duration: 8:00

Let's integrate everything into a complete, professional banking system.

### Enhanced BankingService

**com/bank/services/BankingService.java:**

```java
package com.bank.services;

import com.bank.accounts.*;
import com.bank.models.Customer;
import java.util.HashMap;
import java.util.Map;

public class BankingService {
    private Map<String, Customer> customers;
    private Map<String, Account> accounts;

    public BankingService() {
        this.customers = new HashMap<>();
        this.accounts = new HashMap<>();
    }

    public void registerCustomer(Customer customer) {
        customers.put(customer.getCustomerId(), customer);
        System.out.println("Customer registered: " + customer.getName());
    }

    public void openAccount(String customerId, Account account) {
        Customer customer = customers.get(customerId);
        if (customer != null) {
            customer.addAccount(account);
            accounts.put(account.getAccountNumber(), account);
            System.out.println("Account opened: " + account.getAccountNumber());
        }
    }

    public void transfer(String fromAccountNum, String toAccountNum, double amount) {
        Account fromAccount = accounts.get(fromAccountNum);
        Account toAccount = accounts.get(toAccountNum);

        if (fromAccount != null && toAccount != null) {
            if (fromAccount.withdraw(amount)) {
                toAccount.deposit(amount);
                System.out.println("Transfer successful: $" + amount);
                System.out.println("From " + fromAccountNum + " to " + toAccountNum);
            } else {
                System.out.println("Transfer failed: Insufficient funds");
            }
        }
    }

    public void displayCustomerInfo(String customerId) {
        Customer customer = customers.get(customerId);
        if (customer != null) {
            System.out.println("\n=== CUSTOMER INFO ===");
            System.out.println("ID: " + customer.getCustomerId());
            System.out.println("Name: " + customer.getName());
            System.out.println("Email: " + customer.getEmail());
            System.out.println("Total Balance: $" + customer.getTotalBalance());
            System.out.println("\nAccounts:");
            for (Account account : customer.getAccounts()) {
                System.out.println("  - " + account.getAccountNumber() +
                                   ": $" + account.getBalance());
            }
        }
    }
}
```

### Complete Demo

**BankingSystemDemo.java:**

```java
import com.bank.accounts.*;
import com.bank.models.Customer;
import com.bank.services.BankingService;

public class BankingSystemDemo {
    public static void main(String[] args) {
        BankingService bank = new BankingService();

        // Create customers
        Customer alice = new Customer("CUST-001", "Alice Johnson", "alice@email.com");
        Customer bob = new Customer("CUST-002", "Bob Smith", "bob@email.com");

        bank.registerCustomer(alice);
        bank.registerCustomer(bob);

        // Open accounts
        SavingsAccount aliceSavings = new SavingsAccount("SAV-001", "Alice Johnson", 10000.0, 4.0);
        CheckingAccount aliceChecking = new CheckingAccount("CHK-001", "Alice Johnson", 3000.0, 1000.0);
        CheckingAccount bobChecking = new CheckingAccount("CHK-002", "Bob Smith", 5000.0, 500.0);

        bank.openAccount("CUST-001", aliceSavings);
        bank.openAccount("CUST-001", aliceChecking);
        bank.openAccount("CUST-002", bobChecking);

        // Perform transactions
        System.out.println("\n=== TRANSACTIONS ===");
        aliceSavings.deposit(2000);
        aliceSavings.applyInterest();
        aliceChecking.withdraw(500);

        // Transfer money
        System.out.println();
        bank.transfer("CHK-001", "CHK-002", 1000);

        // Display customer info
        bank.displayCustomerInfo("CUST-001");
        bank.displayCustomerInfo("CUST-002");
    }
}
```

Compile and run:

```console
javac -d bin com/bank/**/*.java BankingSystemDemo.java
java -cp bin BankingSystemDemo
```

## Conclusion

Duration: 3:00

Congratulations! 🎉 You've mastered Object-Oriented Programming in Java!

### What You've Learned

- ✅ **Classes and Objects:** Creating blueprints and instances
- ✅ **Constructors:** Initializing objects with `this` keyword
- ✅ **Encapsulation:** Private fields with public getters/setters
- ✅ **Inheritance:** Code reuse with `extends` and `super`
- ✅ **Abstract Classes:** Templates for related classes
- ✅ **Interfaces:** Contracts and multiple inheritance
- ✅ **Polymorphism:** Writing flexible, extensible code
- ✅ **Packages:** Organizing code professionally
- ✅ **Method Overloading:** Same name, different parameters
- ✅ **Method Overriding:** Customizing inherited behavior

### Key Takeaways

1. **Encapsulation:** Hide data, expose behavior
2. **Inheritance:** IS-A relationship (Dog IS-A Animal)
3. **Interfaces:** CAN-DO relationship (Duck CAN Fly)
4. **Polymorphism:** Write once, use with many types
5. **Abstraction:** Hide complexity, show essentials
6. **Packages:** Organize and namespace your code

### Design Principles Applied

- **Single Responsibility:** Each class has one job
- **Open/Closed:** Open for extension, closed for modification
- **Liskov Substitution:** Subclass objects can replace parent objects
- **Interface Segregation:** Multiple specific interfaces > one general
- **Dependency Inversion:** Depend on abstractions, not concretions

### Next Steps

Continue your journey:

- **Codelab 1.3:** Exception Handling & File I/O
- **Codelab 1.4:** Collections Framework & Generics
- **Codelab 1.5:** Memory Management & Garbage Collection

### Practice Exercises

Strengthen your OOP skills:

1. **Vehicle System:** Create Car, Motorcycle, Truck with Engine, Driveable interface
2. **Shape Calculator:** Abstract Shape class with Circle, Rectangle, Triangle
3. **University System:** Student, Professor, Course with enrollment
4. **E-Commerce:** Product, ElectronicsProduct, ClothingProduct with shopping cart
5. **Library System:** Book, Member, Librarian with borrowing functionality

### Additional Resources

- [Oracle Java OOP Tutorial](https://docs.oracle.com/javase/tutorial/java/concepts/)
- [Effective Java by Joshua Bloch](https://www.oreilly.com/library/view/effective-java/9780134686097/)
- [Head First Design Patterns](https://www.oreilly.com/library/view/head-first-design/0596007124/)
- [Clean Code by Robert Martin](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

> aside positive
> **Excellent Work!** OOP is the foundation of Java development. Master these concepts, and you'll write better, more maintainable code!
