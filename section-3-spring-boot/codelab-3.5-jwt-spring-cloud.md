summary: Implement JWT-based authentication for stateless API security and introduce Spring Cloud Config for centralized configuration management
id: jwt-spring-cloud
categories: Spring Boot, JWT, Spring Cloud, Security, Microservices
environments: Web
status: Published

# JWT Authentication & Spring Cloud Config

## Introduction

Duration: 3:00

Replace HTTP Basic authentication with JWT tokens and introduce Spring Cloud Config for centralized configuration.

### What You'll Learn

- **JWT Basics:** JSON Web Token structure and flow
- **JWT Authentication:** Token generation and validation
- **Token Security:** Signing, expiration, refresh tokens
- **JWT Filter:** Custom authentication filter
- **Spring Cloud Config:** Centralized configuration server
- **Config Client:** Connect applications to config server
- **Git Backend:** Store configs in Git repository
- **Profiles:** Environment-specific configurations
- **Encryption:** Secure sensitive properties
- **Service Discovery:** Introduction to Eureka

### What You'll Build

JWT-secured Task Management API with:

- **JWT Token Generation** on login
- **Token Validation** on each request
- **Refresh Token** mechanism
- **Custom JWT Filter** for Spring Security
- **Login & Signup** endpoints
- **Config Server** for centralized properties
- **Task API** as config client
- **Git-backed** configuration storage
- **Profile-specific** configs (dev, prod)
- **Encrypted** database passwords

### Prerequisites

- Completed Codelab 3.4 (JPA Locking & Spring Security)
- Understanding of Spring Security

### New Dependencies

**Task API (pom.xml):**

```xml
<!-- JWT -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>

<!-- Spring Cloud Config Client -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>
```

**Config Server (separate project):**

```xml
<!-- Spring Cloud Config Server -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-config-server</artifactId>
</dependency>
```

**Add to both projects:**

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>2023.0.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

> aside positive
> **Architecture Shift:** We're moving from monolithic configuration to distributed configuration management - a key step toward microservices!

## Understanding JWT

Duration: 8:00

Learn how JSON Web Tokens work for stateless authentication.

### JWT Structure

A JWT has three parts separated by dots:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJqb2huIiwiaWF0IjoxNjE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c

[Header].[Payload].[Signature]
```

### 1. Header

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

Base64URL encoded → `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`

### 2. Payload (Claims)

```json
{
  "sub": "john", // Subject (username)
  "iat": 1616239022, // Issued at
  "exp": 1616242622, // Expiration (1 hour)
  "roles": ["ROLE_USER"]
}
```

Base64URL encoded → `eyJzdWIiOiJqb2huIiwiaWF0IjoxNjE2MjM5MDIyfQ`

### 3. Signature

```javascript
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret_key
);
```

Result → `SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`

### JWT Authentication Flow

```
Client                        Server
  |                              |
  |  POST /auth/login            |
  |  {username, password}        |
  |----------------------------->|
  |                              | 1. Validate credentials
  |                              | 2. Generate JWT token
  |  200 OK                      |
  |  {token: "eyJ..."}           |
  |<-----------------------------|
  |                              |
  |  GET /api/tasks              |
  |  Authorization: Bearer eyJ...|
  |----------------------------->|
  |                              | 3. Extract token
  |                              | 4. Validate signature
  |                              | 5. Extract username & roles
  |                              | 6. Process request
  |  200 OK                      |
  |  [tasks...]                  |
  |<-----------------------------|
```

### JWT vs Session-Based Auth

| Aspect          | JWT                            | Session                   |
| --------------- | ------------------------------ | ------------------------- |
| **Storage**     | Client-side (localStorage)     | Server-side (memory/DB)   |
| **Scalability** | Excellent (stateless)          | Limited (stateful)        |
| **Performance** | No DB lookup per request       | DB lookup needed          |
| **Revocation**  | Hard (until expiry)            | Easy (delete session)     |
| **Size**        | Larger (sent in every request) | Smaller (session ID only) |
| **Best for**    | Microservices, APIs            | Traditional web apps      |

### JWT Security Considerations

✅ **Best Practices:**

- Use strong secret keys (256+ bits)
- Set short expiration times (15-60 min)
- Implement refresh tokens for long sessions
- Use HTTPS to prevent token interception
- Store tokens securely (HttpOnly cookies or secure storage)
- Validate signature on every request

❌ **Don't:**

- Store sensitive data in JWT (it's base64, not encrypted!)
- Use weak secrets
- Set very long expiration
- Store tokens in localStorage (XSS vulnerable)
- Trust JWT without signature validation

> aside positive
> **JWT Advantage:** Stateless authentication means no server-side session storage - perfect for distributed systems and microservices!

## Create JWT Utility

Duration: 10:00

Build JWT token generation and validation utility.

### JWT Configuration Properties

```java
package com.example.taskmanager.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "jwt")
@Data
public class JwtProperties {

    private String secret = "myDefaultSecretKeyThatShouldBeChangedInProduction12345678";
    private long expiration = 3600000; // 1 hour in milliseconds
    private long refreshExpiration = 86400000; // 24 hours
    private String tokenPrefix = "Bearer ";
    private String headerString = "Authorization";
}
```

### JWT Utility Class

```java
package com.example.taskmanager.security.jwt;

import com.example.taskmanager.config.JwtProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Component
@Slf4j
public class JwtTokenUtil {

    private final JwtProperties jwtProperties;
    private final SecretKey secretKey;

    public JwtTokenUtil(JwtProperties jwtProperties) {
        this.jwtProperties = jwtProperties;
        this.secretKey = Keys.hmacShaKeyFor(
            jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8)
        );
    }

    // Generate token with user details
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();

        // Add roles to claims
        String roles = userDetails.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .collect(Collectors.joining(","));
        claims.put("roles", roles);

        return createToken(claims, userDetails.getUsername(), jwtProperties.getExpiration());
    }

    // Generate refresh token
    public String generateRefreshToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, userDetails.getUsername(), jwtProperties.getRefreshExpiration());
    }

    // Create token with claims
    private String createToken(Map<String, Object> claims, String subject, long expiration) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);

        return Jwts.builder()
            .setClaims(claims)
            .setSubject(subject)
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(secretKey, SignatureAlgorithm.HS256)
            .compact();
    }

    // Extract username from token
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    // Extract expiration date
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    // Extract specific claim
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // Extract all claims
    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(secretKey)
            .build()
            .parseClaimsJws(token)
            .getBody();
    }

    // Check if token is expired
    public boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    // Validate token
    public boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }

    // Extract roles from token
    public String extractRoles(String token) {
        Claims claims = extractAllClaims(token);
        return claims.get("roles", String.class);
    }
}
```

### Authentication Request/Response DTOs

```java
package com.example.taskmanager.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    @NotBlank(message = "Username is required")
    private String username;

    @NotBlank(message = "Password is required")
    private String password;
}
```

```java
package com.example.taskmanager.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    private String token;
    private String refreshToken;
    private String tokenType = "Bearer";
    private Long expiresIn;
    private String username;
    private Set<String> roles;
}
```

```java
package com.example.taskmanager.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SignupRequest {

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50)
    private String username;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Full name is required")
    private String fullName;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;
}
```

### Update application.yml

```yaml
# JWT Configuration
jwt:
  secret: ${JWT_SECRET:mySecretKeyForDevelopmentOnlyChangeInProduction1234567890}
  expiration: 3600000 # 1 hour
  refresh-expiration: 86400000 # 24 hours
  token-prefix: "Bearer "
  header-string: "Authorization"
```

> aside positive
> **Security Note:** In production, use environment variables for JWT secret and generate a strong random key (256+ bits).

## JWT Authentication Filter

Duration: 10:00

Create custom filter to validate JWT tokens on each request.

### JWT Authentication Filter

```java
package com.example.taskmanager.security.jwt;

import com.example.taskmanager.config.JwtProperties;
import com.example.taskmanager.security.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenUtil jwtTokenUtil;
    private final CustomUserDetailsService userDetailsService;
    private final JwtProperties jwtProperties;

    public JwtAuthenticationFilter(JwtTokenUtil jwtTokenUtil,
                                   CustomUserDetailsService userDetailsService,
                                   JwtProperties jwtProperties) {
        this.jwtTokenUtil = jwtTokenUtil;
        this.userDetailsService = userDetailsService;
        this.jwtProperties = jwtProperties;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        try {
            String jwt = extractJwtFromRequest(request);

            if (jwt != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                String username = jwtTokenUtil.extractUsername(jwt);

                UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                if (jwtTokenUtil.validateToken(jwt, userDetails)) {
                    UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                            userDetails, null, userDetails.getAuthorities()
                        );

                    authentication.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                    );

                    SecurityContextHolder.getContext().setAuthentication(authentication);
                    log.debug("Set authentication for user: {}", username);
                }
            }
        } catch (Exception e) {
            log.error("Cannot set user authentication: {}", e.getMessage());
        }

        filterChain.doFilter(request, response);
    }

    private String extractJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader(jwtProperties.getHeaderString());

        if (bearerToken != null && bearerToken.startsWith(jwtProperties.getTokenPrefix())) {
            return bearerToken.substring(jwtProperties.getTokenPrefix().length());
        }

        return null;
    }
}
```

### JWT Authentication Entry Point

```java
package com.example.taskmanager.security.jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Component
@Slf4j
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException authException) throws IOException, ServletException {

        log.error("Unauthorized error: {}", authException.getMessage());

        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        Map<String, Object> errorDetails = new HashMap<>();
        errorDetails.put("timestamp", LocalDateTime.now().toString());
        errorDetails.put("status", HttpServletResponse.SC_UNAUTHORIZED);
        errorDetails.put("error", "Unauthorized");
        errorDetails.put("message", authException.getMessage());
        errorDetails.put("path", request.getRequestURI());

        response.getWriter().write(objectMapper.writeValueAsString(errorDetails));
    }
}
```

### Update Security Configuration

```java
package com.example.taskmanager.config;

import com.example.taskmanager.security.CustomUserDetailsService;
import com.example.taskmanager.security.jwt.JwtAuthenticationEntryPoint;
import com.example.taskmanager.security.jwt.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(CustomUserDetailsService userDetailsService,
                          JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint,
                          JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.userDetailsService = userDetailsService;
        this.jwtAuthenticationEntryPoint = jwtAuthenticationEntryPoint;
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .exceptionHandling(exception ->
                exception.authenticationEntryPoint(jwtAuthenticationEntryPoint)
            )
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/h2-console/**").permitAll()
                .requestMatchers("/swagger-ui/**", "/api-docs/**").permitAll()
                .requestMatchers("/api/auth/**").permitAll()

                // Admin only endpoints
                .requestMatchers("/api/users/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/tasks/**").hasRole("ADMIN")

                // Authenticated endpoints
                .requestMatchers("/api/tasks/**").authenticated()
                .requestMatchers("/api/categories/**").authenticated()

                .anyRequest().authenticated()
            )
            .headers(headers -> headers.frameOptions(frame -> frame.disable()));

        // Add JWT filter
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }
}
```

> aside positive
> **Filter Order Matters:** JWT filter runs before UsernamePasswordAuthenticationFilter to intercept and validate tokens on every request.

## Authentication Controller

Duration: 8:00

Create login, signup, and token refresh endpoints.

### Authentication Service

```java
package com.example.taskmanager.service;

import com.example.taskmanager.dto.AuthResponse;
import com.example.taskmanager.dto.LoginRequest;
import com.example.taskmanager.dto.SignupRequest;
import com.example.taskmanager.model.User;
import com.example.taskmanager.repository.UserRepository;
import com.example.taskmanager.security.jwt.JwtTokenUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenUtil jwtTokenUtil;

    public AuthService(AuthenticationManager authenticationManager,
                       UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenUtil jwtTokenUtil) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenUtil = jwtTokenUtil;
    }

    public AuthResponse login(LoginRequest loginRequest) {
        log.debug("Authenticating user: {}", loginRequest.getUsername());

        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                loginRequest.getUsername(),
                loginRequest.getPassword()
            )
        );

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();

        String token = jwtTokenUtil.generateToken(userDetails);
        String refreshToken = jwtTokenUtil.generateRefreshToken(userDetails);

        User user = userRepository.findByUsername(loginRequest.getUsername())
            .orElseThrow(() -> new RuntimeException("User not found"));

        log.info("User logged in: {}", loginRequest.getUsername());

        return new AuthResponse(
            token,
            refreshToken,
            "Bearer",
            3600L, // 1 hour
            user.getUsername(),
            user.getRoles()
        );
    }

    @Transactional
    public AuthResponse signup(SignupRequest signupRequest) {
        log.debug("Registering new user: {}", signupRequest.getUsername());

        if (userRepository.existsByUsername(signupRequest.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        if (userRepository.existsByEmail(signupRequest.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        User user = new User();
        user.setUsername(signupRequest.getUsername());
        user.setEmail(signupRequest.getEmail());
        user.setFullName(signupRequest.getFullName());
        user.setPassword(passwordEncoder.encode(signupRequest.getPassword()));
        user.getRoles().add("ROLE_USER");

        userRepository.save(user);

        log.info("User registered: {}", signupRequest.getUsername());

        // Auto-login after signup
        LoginRequest loginRequest = new LoginRequest(
            signupRequest.getUsername(),
            signupRequest.getPassword()
        );

        return login(loginRequest);
    }

    public AuthResponse refreshToken(String refreshToken) {
        String username = jwtTokenUtil.extractUsername(refreshToken);

        UserDetails userDetails = userRepository.findByUsername(username)
            .map(user -> org.springframework.security.core.userdetails.User.builder()
                .username(user.getUsername())
                .password(user.getPassword())
                .authorities(user.getRoles().toArray(new String[0]))
                .build())
            .orElseThrow(() -> new RuntimeException("User not found"));

        if (jwtTokenUtil.validateToken(refreshToken, userDetails)) {
            String newToken = jwtTokenUtil.generateToken(userDetails);

            User user = userRepository.findByUsername(username).get();

            return new AuthResponse(
                newToken,
                refreshToken,
                "Bearer",
                3600L,
                user.getUsername(),
                user.getRoles()
            );
        }

        throw new RuntimeException("Invalid refresh token");
    }
}
```

### Authentication Controller

```java
package com.example.taskmanager.controller;

import com.example.taskmanager.dto.AuthResponse;
import com.example.taskmanager.dto.LoginRequest;
import com.example.taskmanager.dto.SignupRequest;
import com.example.taskmanager.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication")
@Slf4j
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "User login - Get JWT token")
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest loginRequest) {
        log.info("POST /api/auth/login - User: {}", loginRequest.getUsername());
        AuthResponse response = authService.login(loginRequest);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "User signup - Register and get JWT token")
    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@Valid @RequestBody SignupRequest signupRequest) {
        log.info("POST /api/auth/signup - User: {}", signupRequest.getUsername());
        AuthResponse response = authService.signup(signupRequest);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Refresh JWT token")
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@RequestBody Map<String, String> request) {
        log.info("POST /api/auth/refresh");
        String refreshToken = request.get("refreshToken");
        AuthResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(response);
    }
}
```

## Spring Cloud Config Server

Duration: 10:00

Create centralized configuration server.

### Create Config Server Project

Create a new Spring Boot project:

**config-server/pom.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>config-server</artifactId>
    <version>1.0.0</version>
    <name>Config Server</name>

    <properties>
        <java.version>17</java.version>
        <spring-cloud.version>2023.0.0</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-server</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

### Config Server Application

```java
package com.example.configserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
```

### Config Server Configuration

**config-server/src/main/resources/application.yml:**

```yaml
server:
  port: 8888

spring:
  application:
    name: config-server

  cloud:
    config:
      server:
        git:
          uri: ${CONFIG_REPO_URI:file://${user.home}/config-repo}
          default-label: main
          clone-on-start: true
        # Alternative: Use local filesystem
        # native:
        #   search-locations: classpath:/configs

management:
  endpoints:
    web:
      exposure:
        include: health,info,refresh
```

### Create Configuration Repository

Create a Git repository for configurations:

```bash
# Create config repository
mkdir ~/config-repo
cd ~/config-repo
git init

# Create configuration files
```

**~/config-repo/task-manager.yml (default profile):**

```yaml
# Default configuration for Task Manager
spring:
  jpa:
    show-sql: true
    hibernate:
      ddl-auto: update

jwt:
  expiration: 3600000 # 1 hour
  refresh-expiration: 86400000 # 24 hours

logging:
  level:
    com.example.taskmanager: INFO
```

**~/config-repo/task-manager-dev.yml:**

```yaml
# Development profile
spring:
  datasource:
    url: jdbc:h2:mem:taskdb
    driver-class-name: org.h2.Driver
    username: sa
    password:

  h2:
    console:
      enabled: true

  jpa:
    show-sql: true
    hibernate:
      ddl-auto: create-drop

logging:
  level:
    com.example.taskmanager: DEBUG
    org.hibernate.SQL: DEBUG
```

**~/config-repo/task-manager-prod.yml:**

```yaml
# Production profile
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/taskdb
    driver-class-name: org.postgresql.Driver
    username: postgres
    password: "{cipher}AQA1234..." # Encrypted password

  jpa:
    show-sql: false
    hibernate:
      ddl-auto: validate

jwt:
  secret: "{cipher}AQB5678..." # Encrypted JWT secret

logging:
  level:
    com.example.taskmanager: WARN
```

**Commit configurations:**

```bash
git add .
git commit -m "Initial configuration"
```

### Directory Structure

```
config-repo/
├── task-manager.yml          # Default config
├── task-manager-dev.yml      # Dev profile
├── task-manager-prod.yml     # Prod profile
└── task-manager-test.yml     # Test profile (optional)
```

## Configure Task API as Config Client

Duration: 6:00

Connect Task Manager API to Config Server.

### Update Task API Dependencies

Already added in earlier step:

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>
```

### Create bootstrap.yml

**task-manager/src/main/resources/bootstrap.yml:**

```yaml
spring:
  application:
    name: task-manager

  cloud:
    config:
      uri: http://localhost:8888
      fail-fast: true
      retry:
        initial-interval: 1000
        max-attempts: 6
        max-interval: 2000
        multiplier: 1.1

  profiles:
    active: dev
```

### Update application.yml

**task-manager/src/main/resources/application.yml:**

```yaml
# Local overrides (will be overridden by config server)
server:
  port: 8080

spring:
  application:
    name: task-manager

# Actuator for refresh endpoint
management:
  endpoints:
    web:
      exposure:
        include: health,info,refresh
```

### Configuration Priority

```
1. Config Server (highest priority)
2. application.yml in project
3. Default values in code
```

### Refresh Configuration at Runtime

Add @RefreshScope to components that need dynamic config:

```java
package com.example.taskmanager.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "jwt")
@RefreshScope  // Enable runtime refresh
@Data
public class JwtProperties {
    private String secret;
    private long expiration;
    private long refreshExpiration;
    private String tokenPrefix = "Bearer ";
    private String headerString = "Authorization";
}
```

### Refresh Configuration

```bash
# Update configuration in Git repo
cd ~/config-repo
# Edit task-manager-dev.yml
git add .
git commit -m "Update JWT expiration"

# Refresh application configuration
curl -X POST http://localhost:8080/actuator/refresh
```

> aside positive
> **Centralized Config Benefits:** Change configurations for all microservices from one place without redeploying applications!

## Testing JWT & Config

Duration: 5:00

Test JWT authentication and configuration management.

### Start Config Server

```bash
cd config-server
mvn spring-boot:run
```

Verify: http://localhost:8888/task-manager/dev

### Start Task Manager

```bash
cd task-manager
mvn spring-boot:run
```

Check logs for:

```
Fetching config from server at: http://localhost:8888
Located environment: name=task-manager, profiles=[dev], ...
```

### Test JWT Authentication

**1. Signup:**

```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "fullName": "Test User",
    "password": "password123"
  }'
```

**Response:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "username": "testuser",
  "roles": ["ROLE_USER"]
}
```

**2. Login:**

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

**3. Use Token:**

```bash
TOKEN="eyJhbGciOiJIUzI1NiJ9..."

curl -X POST http://localhost:8080/api/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "JWT Test Task",
    "description": "Testing JWT authentication"
  }'
```

**4. Get My Tasks:**

```bash
curl -X GET http://localhost:8080/api/tasks/my-tasks \
  -H "Authorization: Bearer $TOKEN"
```

**5. Refresh Token:**

```bash
REFRESH_TOKEN="eyJhbGciOiJIUzI1NiJ9..."

curl -X POST http://localhost:8080/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\": \"$REFRESH_TOKEN\"}"
```

### Test Config Changes

**1. Check current config:**

```bash
curl http://localhost:8888/task-manager/dev
```

**2. Update config:**

```bash
cd ~/config-repo
# Edit task-manager-dev.yml - change jwt.expiration
git add . && git commit -m "Update expiration"
```

**3. Refresh application:**

```bash
curl -X POST http://localhost:8080/actuator/refresh
```

### Test in Swagger

1. Visit: http://localhost:8080/swagger-ui.html
2. Try `/api/auth/signup` or `/api/auth/login`
3. Copy the `token` from response
4. Click **Authorize** button
5. Enter: `Bearer <your-token>`
6. Test protected endpoints

## Conclusion

Duration: 2:00

Congratulations! 🎉 You've implemented JWT authentication and Spring Cloud Config!

### What You've Learned

- ✅ **JWT Basics:** Token structure and flow
- ✅ **Token Generation:** Creating signed JWT tokens
- ✅ **Token Validation:** Verifying signature and expiration
- ✅ **Custom Filter:** JWT authentication filter
- ✅ **Refresh Tokens:** Long-lived token renewal
- ✅ **Config Server:** Centralized configuration management
- ✅ **Git Backend:** Version-controlled configurations
- ✅ **Profile Support:** Environment-specific configs
- ✅ **Runtime Refresh:** Dynamic configuration updates

### Task Management API v1.4

JWT & Config features:

- ✅ JWT token-based authentication
- ✅ Stateless API (no server-side sessions)
- ✅ Login and signup endpoints
- ✅ Refresh token mechanism
- ✅ Custom JWT authentication filter
- ✅ Spring Cloud Config Server
- ✅ Externalized configuration
- ✅ Profile-specific configurations
- ✅ Runtime configuration refresh
- ✅ Git-backed configuration storage

### Microservices Foundation

You've now built the foundation for microservices:

- **Stateless Authentication:** JWT enables horizontal scaling
- **Centralized Config:** Easy multi-service management
- **Service Communication:** Ready for inter-service calls

### Git Branching

```bash
git add .
git commit -m "Codelab 3.5: JWT & Spring Cloud Config complete"
git tag codelab-3.5
```

### Next Steps

- **Codelab 3.6:** Reactive Programming & R2DBC

### Additional Resources

- [JWT.io](https://jwt.io/) - JWT debugger and information
- [Spring Cloud Config](https://spring.io/projects/spring-cloud-config)
- [JJWT Library](https://github.com/jwtk/jjwt)

> aside positive
> **Production Ready!** Your API now has stateless JWT authentication and centralized configuration - key requirements for cloud-native microservices!
