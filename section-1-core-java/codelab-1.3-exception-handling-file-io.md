summary: Master exception handling, custom exceptions, and file I/O operations by building a contact management system with file persistence
id: exception-handling-file-io
categories: Java, Exception Handling, File I/O
environments: Web
status: Published
home url: /springboot_course/
analytics ga4 account: G-4LV2JBSBPM
feedback link: https://github.com/Bit-Blazer/springboot_course/issues/new

# Exception Handling & File I/O

## Introduction

Duration: 2:00

Robust applications must handle errors gracefully and persist data. In this codelab, you'll master Java's exception handling mechanisms and file I/O operations by building a real-world contact management system.

### What You'll Learn

- Exception hierarchy and types (checked vs unchecked)
- Try-catch-finally blocks and error handling patterns
- Throws clause and throw keyword
- Creating custom exceptions
- File class and file operations
- Reading and writing files (FileReader, FileWriter, BufferedReader, BufferedWriter)
- Try-with-resources for automatic resource management
- Best practices for error handling and recovery

### What You'll Build

A **Contact Management System** featuring:

- Add, update, delete, and search contacts
- CSV file-based persistent storage
- Comprehensive error handling
- Custom exceptions for validation
- Automatic resource management
- Graceful error recovery

### Prerequisites

- Completed Codelab 1.1 and 1.2
- Understanding of OOP concepts
- Java JDK 17+ installed

## Understanding Exceptions

Duration: 10:00

Exceptions are events that disrupt normal program flow. Let's understand how Java handles them.

### Exception Hierarchy

```
Throwable
├── Error (unchecked - system errors)
│   ├── OutOfMemoryError
│   ├── StackOverflowError
│   └── ...
└── Exception
    ├── RuntimeException (unchecked)
    │   ├── NullPointerException
    │   ├── ArrayIndexOutOfBoundsException
    │   ├── IllegalArgumentException
    │   └── ...
    └── Checked Exceptions
        ├── IOException
        ├── SQLException
        ├── ClassNotFoundException
        └── ...
```

### Checked vs Unchecked Exceptions

**Checked Exceptions:**

- Must be handled or declared
- Compiler enforces handling
- Examples: IOException, SQLException
- Represent recoverable conditions

**Unchecked Exceptions (RuntimeException):**

- Not required to be handled
- Indicate programming errors
- Examples: NullPointerException, ArrayIndexOutOfBoundsException
- Should be prevented through better code

> aside positive
> **Rule of Thumb:** If a client can reasonably be expected to recover, use checked exceptions. If nothing can be done, use unchecked exceptions.

### Common Exception Examples

**NullPointerException:**

```java
public class NullPointerDemo {
    public static void main(String[] args) {
        String name = null;
        System.out.println(name.length());  // NullPointerException!
    }
}
```

**ArrayIndexOutOfBoundsException:**

```java
public class ArrayDemo {
    public static void main(String[] args) {
        int[] numbers = {1, 2, 3};
        System.out.println(numbers[5]);  // ArrayIndexOutOfBoundsException!
    }
}
```

**NumberFormatException:**

```java
public class ParseDemo {
    public static void main(String[] args) {
        String text = "abc";
        int number = Integer.parseInt(text);  // NumberFormatException!
    }
}
```

> aside negative
> **Important:** Unchecked exceptions usually indicate bugs in your code. Fix the root cause instead of catching them!

## Try-Catch-Finally

Duration: 12:00

The try-catch-finally block is the foundation of exception handling.

### Basic Try-Catch

```java
public class BasicExceptionHandling {
    public static void main(String[] args) {
        try {
            int result = 10 / 0;  // ArithmeticException
            System.out.println("Result: " + result);
        } catch (ArithmeticException e) {
            System.out.println("Error: Cannot divide by zero!");
            System.out.println("Exception message: " + e.getMessage());
        }

        System.out.println("Program continues...");
    }
}
```

Output:

```console
Error: Cannot divide by zero!
Exception message: / by zero
Program continues...
```

### Multiple Catch Blocks

```java
public class MultipleCatch {
    public static void main(String[] args) {
        String[] data = {"10", "20", "abc", "30"};

        for (String item : data) {
            try {
                int number = Integer.parseInt(item);
                int result = 100 / number;
                System.out.println("Result: " + result);
            } catch (NumberFormatException e) {
                System.out.println("'" + item + "' is not a valid number");
            } catch (ArithmeticException e) {
                System.out.println("Cannot divide by zero for value: " + item);
            }
        }
    }
}
```

### Multi-Catch (Java 7+)

Handle multiple exceptions in one catch block:

```java
try {
    // risky code
} catch (IOException | SQLException e) {
    System.out.println("Database or file error: " + e.getMessage());
}
```

### Finally Block

**Always executes**, whether exception occurs or not:

```java
public class FinallyDemo {
    public static void main(String[] args) {
        java.util.Scanner scanner = null;

        try {
            scanner = new java.util.Scanner(System.in);
            System.out.print("Enter a number: ");
            int number = scanner.nextInt();
            System.out.println("You entered: " + number);
        } catch (Exception e) {
            System.out.println("Invalid input!");
        } finally {
            if (scanner != null) {
                scanner.close();
                System.out.println("Scanner closed");
            }
        }
    }
}
```

> aside positive
> **Key Insight:** Finally block is perfect for cleanup operations - closing files, database connections, network sockets, etc.

### Complete Try-Catch-Finally Example

```java
import java.io.*;

public class FileReadDemo {
    public static void main(String[] args) {
        BufferedReader reader = null;

        try {
            reader = new BufferedReader(new FileReader("data.txt"));
            String line = reader.readLine();
            System.out.println("First line: " + line);
        } catch (FileNotFoundException e) {
            System.out.println("File not found: " + e.getMessage());
        } catch (IOException e) {
            System.out.println("Error reading file: " + e.getMessage());
        } finally {
            try {
                if (reader != null) {
                    reader.close();
                }
            } catch (IOException e) {
                System.out.println("Error closing file: " + e.getMessage());
            }
        }
    }
}
```

> aside negative
> **Watch Out:** Nested try-catch in finally is verbose! Use try-with-resources instead (next section).

## Try-With-Resources

Duration: 8:00

Try-with-resources automatically closes resources, making code cleaner and safer.

### Syntax

```java
try (ResourceType resource = new ResourceType()) {
    // Use resource
} catch (Exception e) {
    // Handle exception
}
// resource is automatically closed here
```

### File Reading Example

**Old way (verbose):**

```java
BufferedReader reader = null;
try {
    reader = new BufferedReader(new FileReader("file.txt"));
    String line = reader.readLine();
} catch (IOException e) {
    e.printStackTrace();
} finally {
    try {
        if (reader != null) reader.close();
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

**New way (clean):**

```java
try (BufferedReader reader = new BufferedReader(new FileReader("file.txt"))) {
    String line = reader.readLine();
    System.out.println(line);
} catch (IOException e) {
    System.out.println("Error: " + e.getMessage());
}
```

### Multiple Resources

```java
try (
    FileReader fileReader = new FileReader("input.txt");
    BufferedReader bufferedReader = new BufferedReader(fileReader);
    FileWriter fileWriter = new FileWriter("output.txt");
    BufferedWriter bufferedWriter = new BufferedWriter(fileWriter)
) {
    String line;
    while ((line = bufferedReader.readLine()) != null) {
        bufferedWriter.write(line.toUpperCase());
        bufferedWriter.newLine();
    }
} catch (IOException e) {
    System.out.println("Error processing files: " + e.getMessage());
}
```

### AutoCloseable Interface

Any class implementing `AutoCloseable` or `Closeable` can be used with try-with-resources:

```java
public class CustomResource implements AutoCloseable {
    public CustomResource() {
        System.out.println("Resource opened");
    }

    public void doWork() {
        System.out.println("Working...");
    }

    @Override
    public void close() {
        System.out.println("Resource closed");
    }
}

// Usage
try (CustomResource resource = new CustomResource()) {
    resource.doWork();
}
```

> aside positive
> **Best Practice:** Always use try-with-resources for file operations, database connections, and network sockets. It's safer and cleaner!

## Throws and Throw Keywords

Duration: 10:00

The `throws` clause declares exceptions, while `throw` explicitly throws them.

### Throws Clause

Declare that a method might throw exceptions:

```java
public class FileProcessor {

    // Declares it might throw IOException
    public String readFile(String filename) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(filename));
        String content = reader.readLine();
        reader.close();
        return content;
    }

    // Multiple exceptions
    public void processData(String filename)
            throws IOException, SQLException {
        // Method implementation
    }
}
```

**Caller must handle or declare:**

```java
public class Main {
    public static void main(String[] args) {
        FileProcessor processor = new FileProcessor();

        // Option 1: Handle the exception
        try {
            String content = processor.readFile("data.txt");
            System.out.println(content);
        } catch (IOException e) {
            System.out.println("Error reading file: " + e.getMessage());
        }
    }

    // Option 2: Propagate the exception
    public static void anotherMethod() throws IOException {
        FileProcessor processor = new FileProcessor();
        String content = processor.readFile("data.txt");
    }
}
```

### Throw Keyword

Explicitly throw an exception:

```java
public class ValidationExample {

    public void setAge(int age) {
        if (age < 0 || age > 150) {
            throw new IllegalArgumentException(
                "Age must be between 0 and 150, got: " + age
            );
        }
        this.age = age;
    }

    public void processPayment(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        if (amount > 10000) {
            throw new IllegalStateException("Amount exceeds transaction limit");
        }

        // Process payment
    }

    private int age;
}
```

### Re-throwing Exceptions

```java
public void processFile(String filename) throws IOException {
    try {
        // File operations
        BufferedReader reader = new BufferedReader(new FileReader(filename));
        // ... processing ...
    } catch (FileNotFoundException e) {
        System.out.println("File not found: " + filename);
        throw e;  // Re-throw for caller to handle
    } catch (IOException e) {
        System.out.println("Error reading file");
        throw new IOException("Failed to process: " + filename, e);
    }
}
```

> aside positive
> **Tip:** Re-throw exceptions when you want to log/handle locally but still notify the caller.

## Custom Exceptions

Duration: 12:00

Create your own exception classes for domain-specific errors.

### Creating Checked Custom Exceptions

**InvalidContactException.java:**

```java
public class InvalidContactException extends Exception {

    // No-arg constructor
    public InvalidContactException() {
        super("Invalid contact data");
    }

    // Constructor with message
    public InvalidContactException(String message) {
        super(message);
    }

    // Constructor with message and cause
    public InvalidContactException(String message, Throwable cause) {
        super(message, cause);
    }

    // Constructor with cause
    public InvalidContactException(Throwable cause) {
        super(cause);
    }
}
```

**FileOperationException.java:**

```java
public class FileOperationException extends Exception {
    private String filename;
    private String operation;

    public FileOperationException(String filename, String operation) {
        super("Failed to " + operation + " file: " + filename);
        this.filename = filename;
        this.operation = operation;
    }

    public FileOperationException(String filename, String operation, Throwable cause) {
        super("Failed to " + operation + " file: " + filename, cause);
        this.filename = filename;
        this.operation = operation;
    }

    public String getFilename() {
        return filename;
    }

    public String getOperation() {
        return operation;
    }
}
```

### Creating Unchecked Custom Exceptions

**ContactNotFoundException.java:**

```java
public class ContactNotFoundException extends RuntimeException {
    private String contactId;

    public ContactNotFoundException(String contactId) {
        super("Contact not found: " + contactId);
        this.contactId = contactId;
    }

    public String getContactId() {
        return contactId;
    }
}
```

### Using Custom Exceptions

```java
public class ContactValidator {

    public void validateEmail(String email) throws InvalidContactException {
        if (email == null || email.trim().isEmpty()) {
            throw new InvalidContactException("Email cannot be empty");
        }

        if (!email.contains("@")) {
            throw new InvalidContactException("Invalid email format: " + email);
        }
    }

    public void validatePhone(String phone) throws InvalidContactException {
        if (phone == null || phone.trim().isEmpty()) {
            throw new InvalidContactException("Phone cannot be empty");
        }

        // Remove non-digits
        String digitsOnly = phone.replaceAll("[^0-9]", "");

        if (digitsOnly.length() < 10) {
            throw new InvalidContactException(
                "Phone number must have at least 10 digits: " + phone
            );
        }
    }

    public void validateName(String name) throws InvalidContactException {
        if (name == null || name.trim().isEmpty()) {
            throw new InvalidContactException("Name cannot be empty");
        }

        if (name.length() < 2) {
            throw new InvalidContactException("Name too short: " + name);
        }
    }
}
```

> aside positive
> **Design Decision:** Use checked exceptions for recoverable conditions (validation errors), unchecked for programming errors (null references).

## File Operations

Duration: 15:00

Let's explore Java's file I/O capabilities.

### File Class Basics

```java
import java.io.File;

public class FileBasics {
    public static void main(String[] args) {
        File file = new File("contacts.csv");

        // Check file properties
        System.out.println("Exists: " + file.exists());
        System.out.println("Is File: " + file.isFile());
        System.out.println("Is Directory: " + file.isDirectory());
        System.out.println("Can Read: " + file.canRead());
        System.out.println("Can Write: " + file.canWrite());
        System.out.println("Size: " + file.length() + " bytes");
        System.out.println("Absolute Path: " + file.getAbsolutePath());
        System.out.println("Name: " + file.getName());

        // Create new file
        try {
            if (file.createNewFile()) {
                System.out.println("File created: " + file.getName());
            } else {
                System.out.println("File already exists");
            }
        } catch (IOException e) {
            System.out.println("Error creating file: " + e.getMessage());
        }

        // Delete file
        if (file.delete()) {
            System.out.println("File deleted");
        }
    }
}
```

### Directory Operations

```java
import java.io.File;

public class DirectoryOperations {
    public static void main(String[] args) {
        // Create directory
        File dir = new File("contacts_data");
        if (dir.mkdir()) {
            System.out.println("Directory created");
        }

        // Create nested directories
        File nestedDir = new File("data/contacts/archive");
        if (nestedDir.mkdirs()) {
            System.out.println("Nested directories created");
        }

        // List files in directory
        File currentDir = new File(".");
        String[] files = currentDir.list();
        System.out.println("Files in current directory:");
        for (String filename : files) {
            System.out.println("  " + filename);
        }

        // List with File objects
        File[] fileObjects = currentDir.listFiles();
        for (File f : fileObjects) {
            String type = f.isDirectory() ? "[DIR]" : "[FILE]";
            System.out.println(type + " " + f.getName());
        }
    }
}
```

### Writing to Files

**Using FileWriter:**

```java
import java.io.*;

public class FileWriteDemo {
    public static void main(String[] args) {
        // Simple write
        try (FileWriter writer = new FileWriter("output.txt")) {
            writer.write("Hello, World!\n");
            writer.write("This is a test.\n");
        } catch (IOException e) {
            System.out.println("Error writing file: " + e.getMessage());
        }

        // Append mode
        try (FileWriter writer = new FileWriter("output.txt", true)) {
            writer.write("Appended line\n");
        } catch (IOException e) {
            System.out.println("Error appending to file: " + e.getMessage());
        }
    }
}
```

**Using BufferedWriter (More Efficient):**

```java
import java.io.*;

public class BufferedWriteDemo {
    public static void main(String[] args) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter("data.txt"))) {
            writer.write("Line 1");
            writer.newLine();  // Platform-independent newline
            writer.write("Line 2");
            writer.newLine();
            writer.write("Line 3");
            writer.newLine();

            // Write multiple lines
            String[] lines = {"Line 4", "Line 5", "Line 6"};
            for (String line : lines) {
                writer.write(line);
                writer.newLine();
            }
        } catch (IOException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
```

### Reading from Files

**Using FileReader:**

```java
import java.io.*;

public class FileReadDemo {
    public static void main(String[] args) {
        try (FileReader reader = new FileReader("data.txt")) {
            int character;
            while ((character = reader.read()) != -1) {
                System.out.print((char) character);
            }
        } catch (FileNotFoundException e) {
            System.out.println("File not found: " + e.getMessage());
        } catch (IOException e) {
            System.out.println("Error reading file: " + e.getMessage());
        }
    }
}
```

**Using BufferedReader (More Efficient):**

```java
import java.io.*;

public class BufferedReadDemo {
    public static void main(String[] args) {
        try (BufferedReader reader = new BufferedReader(new FileReader("data.txt"))) {
            String line;
            int lineNumber = 1;

            while ((line = reader.readLine()) != null) {
                System.out.println(lineNumber + ": " + line);
                lineNumber++;
            }
        } catch (FileNotFoundException e) {
            System.out.println("File not found: " + e.getMessage());
        } catch (IOException e) {
            System.out.println("Error reading file: " + e.getMessage());
        }
    }
}
```

> aside positive
> **Performance Tip:** Always use BufferedReader/BufferedWriter for text files. They're significantly faster than FileReader/FileWriter for large files!

### CSV File Operations

```java
import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class CSVOperations {

    public static void writeCSV(String filename, List<String[]> data) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filename))) {
            for (String[] row : data) {
                writer.write(String.join(",", row));
                writer.newLine();
            }
        }
    }

    public static List<String[]> readCSV(String filename) throws IOException {
        List<String[]> data = new ArrayList<>();

        try (BufferedReader reader = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] fields = line.split(",");
                data.add(fields);
            }
        }

        return data;
    }

    public static void main(String[] args) {
        // Write CSV
        List<String[]> contacts = new ArrayList<>();
        contacts.add(new String[]{"Name", "Email", "Phone"});
        contacts.add(new String[]{"Alice", "alice@email.com", "555-0001"});
        contacts.add(new String[]{"Bob", "bob@email.com", "555-0002"});

        try {
            writeCSV("contacts.csv", contacts);
            System.out.println("CSV file created");

            // Read CSV
            List<String[]> readData = readCSV("contacts.csv");
            for (String[] row : readData) {
                System.out.println(String.join(" | ", row));
            }
        } catch (IOException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
```

## Build Contact Management System

Duration: 25:00

Now let's build the complete Contact Management System integrating all concepts!

### Contact Model

**Contact.java:**

```java
public class Contact {
    private String id;
    private String name;
    private String email;
    private String phone;
    private String address;

    public Contact(String id, String name, String email, String phone, String address) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.address = address;
    }

    // Convert to CSV format
    public String toCSV() {
        return id + "," + name + "," + email + "," + phone + "," +
               address.replace(",", ";");  // Replace commas in address
    }

    // Create from CSV format
    public static Contact fromCSV(String csvLine) throws InvalidContactException {
        String[] parts = csvLine.split(",");

        if (parts.length != 5) {
            throw new InvalidContactException("Invalid CSV format: " + csvLine);
        }

        return new Contact(
            parts[0].trim(),
            parts[1].trim(),
            parts[2].trim(),
            parts[3].trim(),
            parts[4].trim().replace(";", ",")
        );
    }

    @Override
    public String toString() {
        return "Contact{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", address='" + address + '\'' +
                '}';
    }

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
}
```

### Contact Manager Service

**ContactManager.java:**

```java
import java.io.*;
import java.util.*;

public class ContactManager {
    private static final String DATA_FILE = "contacts.csv";
    private Map<String, Contact> contacts;
    private ContactValidator validator;
    private int nextId;

    public ContactManager() {
        this.contacts = new HashMap<>();
        this.validator = new ContactValidator();
        this.nextId = 1;
        loadContacts();
    }

    public void addContact(String name, String email, String phone, String address)
            throws InvalidContactException, FileOperationException {
        // Validate inputs
        validator.validateName(name);
        validator.validateEmail(email);
        validator.validatePhone(phone);

        // Create contact
        String id = "C" + String.format("%04d", nextId++);
        Contact contact = new Contact(id, name, email, phone, address);

        // Add to map
        contacts.put(id, contact);

        // Save to file
        saveContacts();

        System.out.println("Contact added successfully: " + id);
    }

    public Contact getContact(String id) {
        Contact contact = contacts.get(id);
        if (contact == null) {
            throw new ContactNotFoundException(id);
        }
        return contact;
    }

    public void updateContact(String id, String name, String email,
                             String phone, String address)
            throws InvalidContactException, FileOperationException {
        Contact contact = getContact(id);

        // Validate new values
        validator.validateName(name);
        validator.validateEmail(email);
        validator.validatePhone(phone);

        // Update contact
        contact.setName(name);
        contact.setEmail(email);
        contact.setPhone(phone);
        contact.setAddress(address);

        // Save to file
        saveContacts();

        System.out.println("Contact updated successfully: " + id);
    }

    public void deleteContact(String id) throws FileOperationException {
        Contact contact = contacts.remove(id);

        if (contact == null) {
            throw new ContactNotFoundException(id);
        }

        // Save to file
        saveContacts();

        System.out.println("Contact deleted successfully: " + id);
    }

    public List<Contact> searchByName(String name) {
        List<Contact> results = new ArrayList<>();
        String searchLower = name.toLowerCase();

        for (Contact contact : contacts.values()) {
            if (contact.getName().toLowerCase().contains(searchLower)) {
                results.add(contact);
            }
        }

        return results;
    }

    public List<Contact> getAllContacts() {
        return new ArrayList<>(contacts.values());
    }

    private void loadContacts() {
        File file = new File(DATA_FILE);

        if (!file.exists()) {
            System.out.println("No existing contacts file. Starting fresh.");
            return;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;

            while ((line = reader.readLine()) != null) {
                try {
                    Contact contact = Contact.fromCSV(line);
                    contacts.put(contact.getId(), contact);

                    // Update nextId
                    int contactNum = Integer.parseInt(contact.getId().substring(1));
                    if (contactNum >= nextId) {
                        nextId = contactNum + 1;
                    }
                } catch (InvalidContactException e) {
                    System.out.println("Skipping invalid contact: " + e.getMessage());
                }
            }

            System.out.println("Loaded " + contacts.size() + " contacts from file.");

        } catch (FileNotFoundException e) {
            System.out.println("Contacts file not found: " + e.getMessage());
        } catch (IOException e) {
            System.out.println("Error loading contacts: " + e.getMessage());
        }
    }

    private void saveContacts() throws FileOperationException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(DATA_FILE))) {
            for (Contact contact : contacts.values()) {
                writer.write(contact.toCSV());
                writer.newLine();
            }
        } catch (IOException e) {
            throw new FileOperationException(DATA_FILE, "save", e);
        }
    }

    public void exportToFile(String filename) throws FileOperationException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filename))) {
            // Write header
            writer.write("ID,Name,Email,Phone,Address");
            writer.newLine();

            // Write contacts
            for (Contact contact : contacts.values()) {
                writer.write(contact.toCSV());
                writer.newLine();
            }

            System.out.println("Contacts exported to: " + filename);

        } catch (IOException e) {
            throw new FileOperationException(filename, "export", e);
        }
    }

    public void displayAllContacts() {
        if (contacts.isEmpty()) {
            System.out.println("No contacts found.");
            return;
        }

        System.out.println("\n=== ALL CONTACTS ===");
        System.out.printf("%-8s %-20s %-30s %-15s %-30s%n",
                         "ID", "Name", "Email", "Phone", "Address");
        System.out.println("-".repeat(100));

        for (Contact contact : contacts.values()) {
            System.out.printf("%-8s %-20s %-30s %-15s %-30s%n",
                contact.getId(),
                contact.getName(),
                contact.getEmail(),
                contact.getPhone(),
                contact.getAddress()
            );
        }
    }
}
```

### Main Application

**ContactManagementApp.java:**

```java
import java.util.*;

public class ContactManagementApp {
    private static ContactManager manager;
    private static Scanner scanner;

    public static void main(String[] args) {
        manager = new ContactManager();
        scanner = new Scanner(System.in);

        System.out.println("========================================");
        System.out.println("   CONTACT MANAGEMENT SYSTEM v1.0");
        System.out.println("========================================\n");

        boolean running = true;

        while (running) {
            printMenu();
            int choice = getIntInput("Enter your choice: ");
            System.out.println();

            try {
                switch (choice) {
                    case 1 -> addContact();
                    case 2 -> viewAllContacts();
                    case 3 -> searchContact();
                    case 4 -> updateContact();
                    case 5 -> deleteContact();
                    case 6 -> exportContacts();
                    case 7 -> {
                        System.out.println("Thank you for using Contact Manager!");
                        running = false;
                    }
                    default -> System.out.println("Invalid choice! Try again.");
                }
            } catch (ContactNotFoundException e) {
                System.out.println("Error: " + e.getMessage());
            } catch (InvalidContactException e) {
                System.out.println("Validation Error: " + e.getMessage());
            } catch (FileOperationException e) {
                System.out.println("File Error: " + e.getMessage());
                System.out.println("Operation: " + e.getOperation());
                System.out.println("File: " + e.getFilename());
            } catch (Exception e) {
                System.out.println("Unexpected error: " + e.getMessage());
                e.printStackTrace();
            }

            System.out.println();
        }

        scanner.close();
    }

    private static void printMenu() {
        System.out.println("=== MENU ===");
        System.out.println("1. Add Contact");
        System.out.println("2. View All Contacts");
        System.out.println("3. Search Contact");
        System.out.println("4. Update Contact");
        System.out.println("5. Delete Contact");
        System.out.println("6. Export Contacts");
        System.out.println("7. Exit");
    }

    private static void addContact() throws InvalidContactException, FileOperationException {
        System.out.println("=== ADD NEW CONTACT ===");

        String name = getStringInput("Name: ");
        String email = getStringInput("Email: ");
        String phone = getStringInput("Phone: ");
        String address = getStringInput("Address: ");

        manager.addContact(name, email, phone, address);
    }

    private static void viewAllContacts() {
        manager.displayAllContacts();
    }

    private static void searchContact() {
        System.out.println("=== SEARCH CONTACT ===");
        String searchTerm = getStringInput("Enter name to search: ");

        List<Contact> results = manager.searchByName(searchTerm);

        if (results.isEmpty()) {
            System.out.println("No contacts found matching: " + searchTerm);
        } else {
            System.out.println("\nFound " + results.size() + " contact(s):\n");
            for (Contact contact : results) {
                displayContact(contact);
                System.out.println();
            }
        }
    }

    private static void updateContact() throws InvalidContactException, FileOperationException {
        System.out.println("=== UPDATE CONTACT ===");
        String id = getStringInput("Enter contact ID: ");

        Contact contact = manager.getContact(id);
        displayContact(contact);

        System.out.println("\nEnter new values (press Enter to keep current):");

        String name = getStringInput("Name [" + contact.getName() + "]: ");
        if (name.isEmpty()) name = contact.getName();

        String email = getStringInput("Email [" + contact.getEmail() + "]: ");
        if (email.isEmpty()) email = contact.getEmail();

        String phone = getStringInput("Phone [" + contact.getPhone() + "]: ");
        if (phone.isEmpty()) phone = contact.getPhone();

        String address = getStringInput("Address [" + contact.getAddress() + "]: ");
        if (address.isEmpty()) address = contact.getAddress();

        manager.updateContact(id, name, email, phone, address);
    }

    private static void deleteContact() throws FileOperationException {
        System.out.println("=== DELETE CONTACT ===");
        String id = getStringInput("Enter contact ID: ");

        Contact contact = manager.getContact(id);
        displayContact(contact);

        String confirm = getStringInput("\nAre you sure you want to delete this contact? (yes/no): ");

        if (confirm.equalsIgnoreCase("yes")) {
            manager.deleteContact(id);
        } else {
            System.out.println("Deletion cancelled.");
        }
    }

    private static void exportContacts() throws FileOperationException {
        System.out.println("=== EXPORT CONTACTS ===");
        String filename = getStringInput("Enter filename (e.g., backup.csv): ");
        manager.exportToFile(filename);
    }

    private static void displayContact(Contact contact) {
        System.out.println("ID:      " + contact.getId());
        System.out.println("Name:    " + contact.getName());
        System.out.println("Email:   " + contact.getEmail());
        System.out.println("Phone:   " + contact.getPhone());
        System.out.println("Address: " + contact.getAddress());
    }

    private static String getStringInput(String prompt) {
        System.out.print(prompt);
        return scanner.nextLine().trim();
    }

    private static int getIntInput(String prompt) {
        System.out.print(prompt);
        while (!scanner.hasNextInt()) {
            scanner.next();
            System.out.print("Invalid input. " + prompt);
        }
        int value = scanner.nextInt();
        scanner.nextLine();  // Consume newline
        return value;
    }
}
```

## Testing and Error Scenarios

Duration: 8:00

Let's test our system with various scenarios including error cases.

### Test Scenarios

**1. Normal Operations:**

```console
1. Add contacts with valid data
2. View all contacts
3. Search by name
4. Update contact information
5. Delete a contact
6. Export to backup file
```

**2. Validation Errors:**

Try adding contacts with:

- Empty name
- Invalid email (no @ symbol)
- Phone with less than 10 digits

**3. File Errors:**

- Delete `contacts.csv` while app is running
- Try exporting to a read-only directory
- Corrupt the CSV file (add invalid lines)

**4. Not Found Errors:**

- Try to update non-existent contact ID
- Try to delete non-existent contact ID

### Sample Test Session

```console
========================================
   CONTACT MANAGEMENT SYSTEM v1.0
========================================

Loaded 0 contacts from file.

=== MENU ===
...
Enter your choice: 1

=== ADD NEW CONTACT ===
Name: Alice Johnson
Email: alice@email.com
Phone: 555-1234-5678
Address: 123 Main St, City
Contact added successfully: C0001

=== MENU ===
...
Enter your choice: 1

Name: Bob
Email: bob-email.com
Phone: 123
Address: Test
Validation Error: Invalid email format: bob-email.com

=== MENU ===
...
Enter your choice: 2

=== ALL CONTACTS ===
ID       Name                 Email                          Phone           Address
----------------------------------------------------------------------------------------------------
C0001    Alice Johnson        alice@email.com                555-1234-5678   123 Main St, City
```

> aside positive
> **Testing Tip:** Always test both happy paths (normal operations) and edge cases (errors, invalid data) to ensure robust error handling.

## Best Practices and Patterns

Duration: 5:00

Let's review best practices for exception handling and file operations.

### Exception Handling Best Practices

**1. Be Specific:**

```java
// Bad - too generic
catch (Exception e) {
    e.printStackTrace();
}

// Good - specific handling
catch (FileNotFoundException e) {
    System.out.println("File not found: " + e.getMessage());
} catch (IOException e) {
    System.out.println("Error reading file: " + e.getMessage());
}
```

**2. Don't Swallow Exceptions:**

```java
// Bad - silent failure
try {
    riskyOperation();
} catch (Exception e) {
    // Do nothing
}

// Good - at least log it
try {
    riskyOperation();
} catch (Exception e) {
    System.err.println("Error: " + e.getMessage());
    // Or use logging framework
}
```

**3. Clean Up Resources:**

```java
// Always use try-with-resources for AutoCloseable
try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
    // Use reader
}  // Automatically closed
```

**4. Provide Context:**

```java
// Good - helpful error messages
throw new InvalidContactException(
    "Invalid email format: " + email + ". Must contain @ symbol."
);
```

### File I/O Best Practices

**1. Check File Existence:**

```java
File file = new File("data.txt");
if (!file.exists()) {
    file.createNewFile();
}
```

**2. Use Absolute Paths When Possible:**

```java
File file = new File(System.getProperty("user.home") + "/data/contacts.csv");
```

**3. Handle Large Files Efficiently:**

```java
// Read line by line, don't load entire file
try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
    String line;
    while ((line = reader.readLine()) != null) {
        processLine(line);
    }
}
```

**4. Use Proper Character Encoding:**

```java
try (BufferedWriter writer = new BufferedWriter(
        new OutputStreamWriter(new FileOutputStream(file), StandardCharsets.UTF_8))) {
    writer.write("Content with special chars: üñíçödé");
}
```

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've mastered exception handling and file I/O in Java!

### What You've Learned

- ✅ **Exception Hierarchy:** Understanding checked vs unchecked exceptions
- ✅ **Try-Catch-Finally:** Handling errors gracefully
- ✅ **Try-With-Resources:** Automatic resource management
- ✅ **Custom Exceptions:** Domain-specific error handling
- ✅ **Throws/Throw:** Declaring and throwing exceptions
- ✅ **File Operations:** Reading, writing, and managing files
- ✅ **CSV Processing:** Structured data storage
- ✅ **Error Recovery:** Building robust applications

### Key Takeaways

1. **Always handle exceptions** - Never let them crash your application
2. **Use try-with-resources** - Automatic cleanup is safer
3. **Be specific** - Catch specific exceptions, provide helpful messages
4. **Validate input** - Prevent errors before they occur
5. **Clean up resources** - Close files, connections, streams
6. **Custom exceptions** - Create meaningful error types for your domain
7. **Fail gracefully** - Provide users with actionable error messages

### Next Steps

Continue building on these skills:

- **Codelab 1.4:** Collections Framework & Generics
- **Codelab 1.5:** Memory Management & Garbage Collection

### Practice Exercises

Enhance your Contact Manager:

1. **Import from CSV** - Allow importing contacts from external CSV files
2. **Data Validation** - Add more validation rules (unique emails, phone format)
3. **Backup/Restore** - Automatic backups with timestamps
4. **Search Enhancement** - Search by email, phone, or any field
5. **Logging** - Add proper logging instead of System.out.println
6. **JSON Support** - Support JSON format in addition to CSV
7. **Duplicate Detection** - Warn when adding similar contacts

### Additional Resources

- [Java Exception Handling Guide](https://docs.oracle.com/javase/tutorial/essential/exceptions/)
- [Java I/O Tutorial](https://docs.oracle.com/javase/tutorial/essential/io/)
- [Effective Java - Chapter on Exceptions](https://www.oreilly.com/library/view/effective-java/9780134686097/)
- [Java NIO (New I/O)](https://docs.oracle.com/javase/tutorial/essential/io/fileio.html)

> aside positive
> **Excellent Work!** You've built a production-quality application with robust error handling and file persistence. These skills are essential for real-world Java development!
