# Codelab Format Specification

This document defines the exact format to use when creating or editing codelab markdown files.

## File Structure

```
[METADATA]

# [TITLE]

## [STEP 1]
Duration: [TIME]

[CONTENT]

## [STEP 2]
Duration: [TIME]

[CONTENT]

...
```

---

## 1. METADATA

Place all metadata at the top of the file, before the title. The metadata block must be continuous with no blank lines between fields. All labels must be lowercase.

**Format:**

```
key: Value
key2: Value2
key3: Value3
```

**Required Fields:**

```
summary: [Brief description of the codelab]
id: [unique-lowercase-identifier]
categories: [Category1, Category2, Category3]
environments: Web
status: [Draft|Published|Deprecated|Hidden]
```

**Example:**

```
summary: Build a Spring Boot REST API with React frontend
id: spring-boot-react-fullstack
categories: Java, Spring Boot, React, Full Stack
environments: Web
status: Published
```

---

## 2. TITLE

Use Header 1 (`#`) for the main title. Place it directly after metadata.

**Format:**

```
# Title of the Codelab
```

**Example:**

```
# Building a Full Stack Application with Spring Boot and React
```

---

## 3. STEPS

Each step uses Header 2 (`##`). Add duration on the next line.

**Format:**

```
## Step Title
Duration: mm:ss

Step content goes here...
```

**Example:**

```
## Setup Development Environment
Duration: 5:00

In this step, we'll install the necessary tools.
```

---

## 4. CODE BLOCKS

Use fenced code blocks with language specification.

**Format:**

````
```language
code here
```
````

**Supported Languages:**

- `java` - Java code
- `javascript` - JavaScript code
- `typescript` - TypeScript code
- `jsx` - React JSX
- `tsx` - React TypeScript JSX
- `json` - JSON files
- `xml` - XML/Maven pom files
- `yaml` - YAML files
- `bash` - Bash scripts
- `console` - Terminal output (no highlighting)
- `sql` - SQL queries

**Examples:**

````
```java
@RestController
public class UserController {
    // Java code
}
```
````

````
```console
$ mvn spring-boot:run
````

---

## 5. INFO BOXES

Info boxes use blockquote syntax with `aside` prefix.

### Positive Info Box (Tips, Best Practices)

**Format:**

```
> aside positive
> Content of the positive info box.
> Can span multiple lines.
```

**Example:**

```
> aside positive
> **Tip:** Spring Boot auto-configures most settings for you!
```

### Negative Info Box (Warnings, Important Notes)

**Format:**

```
> aside negative
> Content of the negative info box.
> Can span multiple lines.
```

**Example:**

```
> aside negative
> **Important:** We'll run TWO development servers simultaneously - one for frontend, one for backend. This is normal in fullstack development!
```

### Multiple Paragraphs in Info Box

```
> aside positive
> **Best Practice:** Always validate user input on the backend.
>
> This prevents security vulnerabilities and ensures data integrity.
```

---

## 6. DOWNLOAD BUTTONS

Wrap download links in `<button>` tags.

**Format:**

```
<button>
  [Download Text](URL)
</button>
```

**Example:**

```
<button>
  [Download Starter Code](https://github.com/example/starter)
</button>
```

---

## 7. IMAGES

Use standard markdown image syntax.

**Format:**

```
![Alt text](image-url)
```

**Example:**

```
![Application Architecture](images/architecture-diagram.png)
```

---

## 8. LISTS

Use standard markdown lists.

**Unordered:**

```
- Item 1
- Item 2
- Item 3
```

**Ordered:**

```
1. First step
2. Second step
3. Third step
```

**Nested:**

```
1. Main item
   - Sub item
   - Sub item
2. Main item
```

---

## 9. TABLES

Use standard markdown tables.

**Format:**

```
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |
```

---

## 10. LINKS

Use standard markdown links.

**Format:**

```
[Link Text](URL)
```

**Example:**

```
[Spring Boot Documentation](https://spring.io/projects/spring-boot)
```

---

## COMPLETE EXAMPLE

````markdown
summary: Build a REST API with Spring Boot and connect it to a React frontend
id: spring-boot-react-api
categories: Java, Spring Boot, React, REST API
environments: Web
status: Published

# Building a Full Stack Application

## Introduction

Duration: 2:00

Welcome! In this codelab, you'll build a complete full stack application.

> aside positive
> **What you'll learn:**
>
> - Creating REST APIs with Spring Boot
> - Building React frontends
> - Connecting frontend to backend

## Prerequisites

Duration: 1:00

Before starting, ensure you have:

- Java 17 or higher
- Node.js 18 or higher
- Maven 3.6+
- Your favorite IDE

> aside negative
> **Important:** Make sure Java and Node.js are properly installed and added to your PATH.

## Setup Backend Project

Duration: 5:00

Create a new Spring Boot project:

```console
$ mvn archetype:generate -DgroupId=com.example -DartifactId=backend
```
````

<button>
  [Download Starter Project](https://start.spring.io)
</button>

## Create REST Controller

Duration: 10:00

Add a simple REST controller:

```java
@RestController
@RequestMapping("/api")
public class HelloController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello from Spring Boot!";
    }
}
```

> aside positive
> **Tip:** The `@RestController` annotation combines `@Controller` and `@ResponseBody`.

## Test Your API

Duration: 3:00

Start the server and test:

```console
$ mvn spring-boot:run
```

Open your browser and navigate to `http://localhost:8080/api/hello`

## Conclusion

Duration: 1:00

Congratulations! You've built your first full stack application.

### Next Steps

- Add database integration
- Implement authentication
- Deploy to production

### Learn More

- [Spring Boot Reference](https://spring.io/projects/spring-boot)
- [React Documentation](https://react.dev)

```

---

## FORMAT RULES SUMMARY

1. ✅ **Metadata first** - Always at the top, continuous block with lowercase labels, no blank lines between fields
2. ✅ **One H1 title** - Only one `#` for the main title
3. ✅ **H2 for steps** - All steps use `##`
4. ✅ **Duration format** - `Duration: mm:ss` or `Duration: hh:mm:ss`
5. ✅ **Code language** - Always specify language in fenced code blocks
6. ✅ **Info boxes** - Use `> aside positive` or `> aside negative`
7. ✅ **Button wrapper** - Downloads must be wrapped in `<button>` tags
8. ✅ **Blank lines** - Use blank lines to separate sections
9. ✅ **Consistent formatting** - Maintain consistent indentation and spacing

---
```
