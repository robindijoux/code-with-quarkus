# 🛠️ Guide: Adding endpoints to your API

This guide explains how to add new endpoints to your Quarkus Lambda API.

---

## 🏗️ Recommended architecture

```
src/main/java/YOUR_PACKAGE/
├── resource/          # 🌐 REST Endpoints (controllers)
│   ├── UserResource.java
│   ├── ProductResource.java
│   └── OrderResource.java
├── model/             # 📦 Entities and DTOs
│   ├── User.java
│   ├── Product.java
│   └── CreateUserRequest.java
├── service/           # 🔧 Business logic
│   ├── UserService.java
│   └── EmailService.java
├── repository/        # 💾 Data access
│   └── UserRepository.java
└── exception/         # 🚨 Error handling
    └── GlobalExceptionHandler.java
```

---

## 🚀 Quick method: Copy the template

### 1️⃣ Copy the template

```bash
# Copy the template to your new endpoint
cp src/main/java/YOUR_PACKAGE/resource/TemplateResource.java \
   src/main/java/YOUR_PACKAGE/resource/UserResource.java
```

### 2️⃣ Adapt the class

**Changes to make in `UserResource.java`:**

```java
// Before
@Path("/template")
public class TemplateResource {
    private static List<TemplateEntity> items = new ArrayList<>();
    
    public static class TemplateEntity {
        // ...
    }
}

// After
@Path("/users")  // ← Change the path
public class UserResource {
    private static List<User> users = new ArrayList<>();  // ← Change the type
    
    public static class User {  // ← Rename the class
        public Long id;
        public String name;
        public String email;        // ← Adapt the fields
        public String status;
        
        // Constructors...
    }
}
```

### 3️⃣ Test your new endpoint

```bash
# After deployment
curl https://LAMBDA-URL/users
curl -X POST https://LAMBDA-URL/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

---

## 📋 Complete method: Layered structure

### 1️⃣ Create the entity

**`src/main/java/YOUR_PACKAGE/model/User.java`**

```java
package YOUR_PACKAGE.model;

import java.time.LocalDateTime;

public class User {
    public Long id;
    public String name;
    public String email;
    public String status;
    public LocalDateTime createdAt;
    public LocalDateTime updatedAt;

    // Default constructor (required for Jackson)
    public User() {}

    public User(String name, String email) {
        this.name = name;
        this.email = email;
        this.status = "ACTIVE";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Utility methods
    public void updateTimestamp() {
        this.updatedAt = LocalDateTime.now();
    }
    
    public boolean isActive() {
        return "ACTIVE".equals(status);
    }
}
```

### 2️⃣ Create the DTOs

**`src/main/java/YOUR_PACKAGE/model/CreateUserRequest.java`**

```java
package YOUR_PACKAGE.model;

public class CreateUserRequest {
    public String name;
    public String email;
    
    // Basic validation
    public boolean isValid() {
        return name != null && !name.trim().isEmpty() &&
               email != null && email.contains("@");
    }
}
```

**`src/main/java/YOUR_PACKAGE/model/UpdateUserRequest.java`**

```java
package YOUR_PACKAGE.model;

public class UpdateUserRequest {
    public String name;
    public String email;
    public String status;
}
```

### 3️⃣ Créez le service

**`src/main/java/VOTRE_PACKAGE/service/UserService.java`**

```java
package VOTRE_PACKAGE.service;

import VOTRE_PACKAGE.model.User;
import VOTRE_PACKAGE.model.CreateUserRequest;
import VOTRE_PACKAGE.model.UpdateUserRequest;

import jakarta.enterprise.context.ApplicationScoped;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@ApplicationScoped  // ← CDI pour l'injection de dépendances
public class UserService {

    // Base de données simulée (en production, utilisez JPA/DynamoDB/etc.)
    private final Map<Long, User> users = new ConcurrentHashMap<>();
    private Long nextId = 1L;

    // Initialisation avec quelques données
    public UserService() {
        createInitialData();
    }

    public List<User> findAll() {
        return new ArrayList<>(users.values());
    }

    public Optional<User> findById(Long id) {
        return Optional.ofNullable(users.get(id));
    }

    public List<User> findByStatus(String status) {
        return users.values().stream()
            .filter(user -> status.equals(user.status))
            .collect(Collectors.toList());
    }

    public List<User> search(String query) {
        String lowerQuery = query.toLowerCase();
        return users.values().stream()
            .filter(user -> 
                user.name.toLowerCase().contains(lowerQuery) ||
                user.email.toLowerCase().contains(lowerQuery))
            .collect(Collectors.toList());
    }

    public User create(CreateUserRequest request) {
        // Validation
        if (!request.isValid()) {
            throw new IllegalArgumentException("Données utilisateur invalides");
        }

        // Vérification d'unicité email
        boolean emailExists = users.values().stream()
            .anyMatch(user -> user.email.equalsIgnoreCase(request.email));
        
        if (emailExists) {
            throw new IllegalArgumentException("Email déjà utilisé");
        }

        // Création
        User user = new User(request.name, request.email);
        user.id = nextId++;
        users.put(user.id, user);
        
        return user;
    }

    public User update(Long id, UpdateUserRequest request) {
        User user = findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable"));

        // Mise à jour conditionnelle
        if (request.name != null && !request.name.trim().isEmpty()) {
            user.name = request.name;
        }
        if (request.email != null && !request.email.trim().isEmpty()) {
            user.email = request.email;
        }
        if (request.status != null) {
            user.status = request.status;
        }

        user.updateTimestamp();
        return user;
    }

    public boolean delete(Long id) {
        return users.remove(id) != null;
    }

    public long count() {
        return users.size();
    }

    private void createInitialData() {
        // Quelques utilisateurs de test
        User alice = new User("Alice Dupont", "alice@example.com");
        alice.id = nextId++;
        users.put(alice.id, alice);

        User bob = new User("Bob Martin", "bob@example.com");
        bob.id = nextId++;
        users.put(bob.id, bob);
    }
}
```

### 4️⃣ Créez le contrôleur REST

**`src/main/java/VOTRE_PACKAGE/resource/UserResource.java`**

```java
package VOTRE_PACKAGE.resource;

import VOTRE_PACKAGE.model.User;
import VOTRE_PACKAGE.model.CreateUserRequest;
import VOTRE_PACKAGE.model.UpdateUserRequest;
import VOTRE_PACKAGE.service.UserService;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UserResource {

    @Inject  // ← Injection de dépendance CDI
    UserService userService;

    /**
     * GET /users - Liste tous les utilisateurs
     */
    @GET
    public List<User> list(
            @QueryParam("status") String status,
            @QueryParam("search") String search) {
        
        if (status != null && !status.isEmpty()) {
            return userService.findByStatus(status);
        }
        
        if (search != null && !search.isEmpty()) {
            return userService.search(search);
        }
        
        return userService.findAll();
    }

    /**
     * GET /users/{id} - Récupère un utilisateur
     */
    @GET
    @Path("/{id}")
    public User get(@PathParam("id") Long id) {
        return userService.findById(id)
            .orElseThrow(() -> new NotFoundException("Utilisateur " + id + " introuvable"));
    }

    /**
     * POST /users - Crée un utilisateur
     */
    @POST
    public Response create(CreateUserRequest request) {
        try {
            User user = userService.create(request);
            return Response.status(201).entity(user).build();
        } catch (IllegalArgumentException e) {
            return Response.status(400)
                .entity(new ErrorResponse(e.getMessage()))
                .build();
        }
    }

    /**
     * PUT /users/{id} - Met à jour un utilisateur
     */
    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") Long id, UpdateUserRequest request) {
        try {
            User user = userService.update(id, request);
            return Response.ok(user).build();
        } catch (IllegalArgumentException e) {
            return Response.status(400)
                .entity(new ErrorResponse(e.getMessage()))
                .build();
        }
    }

    /**
     * DELETE /users/{id} - Supprime un utilisateur
     */
    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) {
        boolean deleted = userService.delete(id);
        
        if (deleted) {
            return Response.noContent().build();
        } else {
            throw new NotFoundException("Utilisateur " + id + " introuvable");
        }
    }

    /**
     * GET /users/count - Compte les utilisateurs
     */
    @GET
    @Path("/count")
    public CountResponse count() {
        return new CountResponse(userService.count());
    }

    // Classes utilitaires
    public static class ErrorResponse {
        public String error;
        public long timestamp;

        public ErrorResponse(String error) {
            this.error = error;
            this.timestamp = System.currentTimeMillis();
        }
    }

    public static class CountResponse {
        public long count;

        public CountResponse(long count) {
            this.count = count;
        }
    }
}
```

---

## 🧪 Tests de votre nouvel endpoint

### Tests manuels

```bash
# Variables
LAMBDA_URL="https://votre-lambda-url"

# 1. Liste vide au début
curl $LAMBDA_URL/users

# 2. Créer un utilisateur
curl -X POST $LAMBDA_URL/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice Dupont", "email": "alice@example.com"}'

# 3. Lister les utilisateurs
curl $LAMBDA_URL/users

# 4. Récupérer un utilisateur
curl $LAMBDA_URL/users/1

# 5. Mettre à jour
curl -X PUT $LAMBDA_URL/users/1 \
  -H "Content-Type: application/json" \
  -d '{"status": "INACTIVE"}'

# 6. Recherche
curl "$LAMBDA_URL/users?search=alice"

# 7. Filtrage par statut
curl "$LAMBDA_URL/users?status=ACTIVE"

# 8. Comptage
curl $LAMBDA_URL/users/count

# 9. Suppression
curl -X DELETE $LAMBDA_URL/users/1
```

### Tests unitaires

**`src/test/java/VOTRE_PACKAGE/resource/UserResourceTest.java`**

```java
package VOTRE_PACKAGE.resource;

import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
public class UserResourceTest {

    @Test
    public void testListUsers() {
        given()
            .when().get("/users")
            .then()
            .statusCode(200)
            .contentType(ContentType.JSON);
    }

    @Test
    public void testCreateUser() {
        given()
            .contentType(ContentType.JSON)
            .body("{\"name\": \"Test User\", \"email\": \"test@example.com\"}")
            .when().post("/users")
            .then()
            .statusCode(201)
            .body("name", is("Test User"))
            .body("email", is("test@example.com"));
    }

    @Test
    public void testCreateUserWithInvalidData() {
        given()
            .contentType(ContentType.JSON)
            .body("{\"name\": \"\", \"email\": \"invalid-email\"}")
            .when().post("/users")
            .then()
            .statusCode(400);
    }
}
```

---

## 🔧 Patterns avancés

### 1️⃣ Pagination

```java
@GET
public PagedResponse<User> list(
        @QueryParam("page") @DefaultValue("0") int page,
        @QueryParam("size") @DefaultValue("10") int size) {
    
    // Validation
    if (page < 0) page = 0;
    if (size < 1 || size > 100) size = 10;
    
    List<User> allUsers = userService.findAll();
    
    // Calculs pagination
    int totalElements = allUsers.size();
    int totalPages = (int) Math.ceil((double) totalElements / size);
    int start = page * size;
    int end = Math.min(start + size, totalElements);
    
    List<User> pageContent = allUsers.subList(start, end);
    
    return new PagedResponse<>(pageContent, page, size, totalElements, totalPages);
}
```

### 2️⃣ Validation avec Bean Validation

Ajoutez dans `pom.xml` :
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-validator</artifactId>
</dependency>
```

Dans votre DTO :
```java
import jakarta.validation.constraints.*;

public class CreateUserRequest {
    @NotBlank(message = "Le nom est obligatoire")
    @Size(max = 100, message = "Le nom ne peut pas dépasser 100 caractères")
    public String name;
    
    @NotBlank(message = "L'email est obligatoire")
    @Email(message = "Format d'email invalide")
    public String email;
}
```

Dans votre contrôleur :
```java
import jakarta.validation.Valid;

@POST
public Response create(@Valid CreateUserRequest request) {
    // La validation est automatique
    User user = userService.create(request);
    return Response.status(201).entity(user).build();
}
```

### 3️⃣ Gestion d'erreurs globale

**`src/main/java/VOTRE_PACKAGE/exception/GlobalExceptionHandler.java`**

```java
package VOTRE_PACKAGE.exception;

import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class GlobalExceptionHandler implements ExceptionMapper<Exception> {

    @Override
    public Response toResponse(Exception exception) {
        if (exception instanceof IllegalArgumentException) {
            return Response.status(400)
                .entity(new ErrorResponse(exception.getMessage()))
                .build();
        }
        
        // Erreur générique
        return Response.status(500)
            .entity(new ErrorResponse("Erreur interne du serveur"))
            .build();
    }

    public static class ErrorResponse {
        public String error;
        public long timestamp;

        public ErrorResponse(String error) {
            this.error = error;
            this.timestamp = System.currentTimeMillis();
        }
    }
}
```

---

## 💾 Intégration avec une base de données

### PostgreSQL avec Hibernate ORM

**1. Ajoutez les dépendances :**
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-jdbc-postgresql</artifactId>
</dependency>
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-orm-panache</artifactId>
</dependency>
```

**2. Configuration dans `application.properties` :**
```properties
# Base de données
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=${DB_USERNAME:postgres}
quarkus.datasource.password=${DB_PASSWORD:password}
quarkus.datasource.jdbc.url=${DB_URL:jdbc:postgresql://localhost:5432/mydb}

# Hibernate
quarkus.hibernate-orm.database.generation=update
quarkus.hibernate-orm.log.sql=true
```

**3. Entité JPA :**
```java
import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User extends PanacheEntity {
    
    @Column(nullable = false)
    public String name;
    
    @Column(nullable = false, unique = true)
    public String email;
    
    public String status = "ACTIVE";
    
    // Méthodes Panache automatiques :
    // User.findAll(), User.findById(), User.persist(), etc.
    
    public static List<User> findByStatus(String status) {
        return find("status", status).list();
    }
}
```

### DynamoDB avec AWS SDK

**1. Dépendance :**
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-amazon-dynamodb</artifactId>
</dependency>
```

**2. Configuration :**
```properties
quarkus.dynamodb.endpoint-override=${DYNAMODB_ENDPOINT:}
quarkus.dynamodb.aws.region=${AWS_REGION:eu-west-3}
```

**3. Service DynamoDB :**
```java
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.*;

@ApplicationScoped
public class UserDynamoService {
    
    @Inject
    DynamoDbClient dynamoDb;
    
    private static final String TABLE_NAME = "Users";
    
    public void createUser(User user) {
        PutItemRequest request = PutItemRequest.builder()
            .tableName(TABLE_NAME)
            .item(Map.of(
                "id", AttributeValue.builder().s(user.id.toString()).build(),
                "name", AttributeValue.builder().s(user.name).build(),
                "email", AttributeValue.builder().s(user.email).build()
            ))
            .build();
            
        dynamoDb.putItem(request);
    }
}
```

---

## 🚀 Redéploiement

Après avoir ajouté vos endpoints :

```bash
# 1. Test en local
./mvnw quarkus:dev

# 2. Build et déploiement
./scripts/deploy.sh

# 3. Tests sur Lambda
curl https://LAMBDA-URL/users
```

---

## 📚 Ressources supplémentaires

- [Quarkus REST Guide](https://quarkus.io/guides/rest)
- [Quarkus CDI Guide](https://quarkus.io/guides/cdi)
- [Quarkus Validation Guide](https://quarkus.io/guides/validation)
- [Quarkus Database Guide](https://quarkus.io/guides/datasource)

---

**🎉 Congratulations! You now know how to add endpoints to your Quarkus Lambda API.**