# 📚 Quarkus Lambda Bootstrap API Documentation

## 🎯 Overview

This REST API uses Quarkus compiled natively and deployed on AWS Lambda with Function URL.

**Architecture:**
- ⚡ Cold start < 500ms (native compilation)
- 🏗️ ARM64 architecture (optimal performance)
- 🌐 Single URL for the entire API
- 📦 Containerization with Docker

---

## 🔗 Available endpoints

### 👋 Base endpoint

| Endpoint | Method | Description | Response |
|----------|---------|-------------|---------|
| `/hello` | GET | Welcome message | `"Hello from Quarkus REST"` |

**Example:**
```bash
curl https://LAMBDA-URL/hello
```

---

### 🚗 Car management (CRUD Example)

| Endpoint | Method | Description | Request Body |
|----------|---------|-------------|--------------|
| `/car` | GET | List all cars | - |
| `/car/{id}` | GET | Get a car | - |
| `/car` | POST | Create a new car | `{"brand": "Tesla", "model": "Model 3"}` |
| `/car/{id}` | PUT | Update a car | `{"brand": "Tesla", "model": "Model S"}` |
| `/car/{id}` | DELETE | Delete a car | - |

**Examples:**
```bash
# List all cars
curl https://LAMBDA-URL/car

# Get car with ID 1
curl https://LAMBDA-URL/car/1

# Create a new car
curl -X POST https://LAMBDA-URL/car \
  -H "Content-Type: application/json" \
  -d '{"brand": "Tesla", "model": "Model 3"}'

# Update car with ID 1
curl -X PUT https://LAMBDA-URL/car/1 \
  -H "Content-Type: application/json" \
  -d '{"brand": "Tesla", "model": "Model S"}'

# Delete car with ID 1
curl -X DELETE https://LAMBDA-URL/car/1
```

---

### 📄 Endpoint template (Development Guide)

| Endpoint | Method | Description |
|----------|---------|-------------|
| `/template` | GET | List all template items |
| `/template/{id}` | GET | Get an item by ID |
| `/template` | POST | Create a new item |
| `/template/{id}` | PUT | Update an item |
| `/template/{id}` | DELETE | Delete an item |
| `/template/search?name=xxx` | GET | Search by name |
| `/template/count` | GET | Count items |

**Examples:**
```bash
# List all items
curl https://LAMBDA-URL/template

# Search by name
curl https://LAMBDA-URL/template/search?name=item

# Create a new item
curl -X POST https://LAMBDA-URL/template \
  -H "Content-Type: application/json" \
  -d '{"name": "My item", "description": "Description of my item"}'
```

---

### 🚀 Advanced examples

Endpoints demonstrating advanced patterns:

#### 👥 User management

| Endpoint | Method | Description | Parameters |
|----------|---------|-------------|------------|
| `/examples/users` | GET | List with pagination and filters | `page`, `size`, `status`, `search` |
| `/examples/users/{id}` | GET | User with their orders | - |
| `/examples/users` | POST | Create a user | `{"name": "...", "email": "..."}` |

**Examples:**
```bash
# List with pagination
curl "https://LAMBDA-URL/examples/users?page=0&size=5&status=ACTIVE"

# Search users
curl "https://LAMBDA-URL/examples/users?search=alice"

# Create a user
curl -X POST https://LAMBDA-URL/examples/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

#### 🛒 Order management

| Endpoint | Method | Description |
|----------|---------|-------------|
| `/examples/users/{userId}/orders` | GET | Orders for a user |
| `/examples/users/{userId}/orders` | POST | New order |

**Examples:**
```bash
# User orders
curl https://LAMBDA-URL/examples/users/1/orders

# New order
curl -X POST https://LAMBDA-URL/examples/users/1/orders \
  -H "Content-Type: application/json" \
  -d '{"items": [{"name": "Laptop", "quantity": 1, "price": 999.99}]}'
```

#### 📊 Statistics and monitoring

| Endpoint | Method | Description |
|----------|---------|-------------|
| `/examples/stats` | GET | Global statistics |
| `/examples/users/top` | GET | Top 5 users |
| `/examples/health` | GET | Detailed health check |

**Examples:**
```bash
# Statistics
curl https://LAMBDA-URL/examples/stats

# Top users
curl https://LAMBDA-URL/examples/users/top

# Health check
curl https://LAMBDA-URL/examples/health
```

---

## 📝 Response formats

### Success responses

**Simple list:**
```json
[
  {"id": 1, "name": "Item 1"},
  {"id": 2, "name": "Item 2"}
]
```

**Pagination:**
```json
{
  "content": [
    {"id": 1, "name": "User 1"}
  ],
  "page": 0,
  "size": 10,
  "totalElements": 25,
  "totalPages": 3
}
```

**Creation (status 201):**
```json
{
  "id": 3,
  "name": "New item",
  "createdAt": "2024-01-15T10:30:00"
}
```

### Error responses

**Error 400 (Bad Request):**
```json
{
  "error": "Name is required",
  "timestamp": 1705312200000
}
```

**Error 404 (Not Found):**
```json
{
  "error": "Element with ID 999 not found",
  "timestamp": 1705312200000
}
```

**Error 409 (Conflict):**
```json
{
  "error": "Email already in use",
  "timestamp": 1705312200000
}
```

**Validation error (400):**
```json
{
  "errors": [
    "Name is required",
    "Invalid email format"
  ],
  "timestamp": 1705312200000
}
```

---

## 🔧 Headers HTTP

### Headers requis

Pour les requêtes avec corps (POST, PUT) :
```
Content-Type: application/json
```

### Headers de réponse

Toutes les réponses incluent :
```
Content-Type: application/json
```

---

## 🧪 Tests et validation

### Collection Postman

You can import this Postman collection to test all endpoints:

```json
{
  "info": {
    "name": "Quarkus Lambda API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "base_url",
      "value": "https://YOUR-LAMBDA-URL",
      "type": "string"
    }
  ],
  "item": [
    {
      "name": "Hello",
      "request": {
        "method": "GET",
        "url": "{{base_url}}/hello"
      }
    },
    {
      "name": "List Cars",
      "request": {
        "method": "GET",
        "url": "{{base_url}}/car"
      }
    }
  ]
}
```

### Test scripts

You can use the provided test script:

```bash
# Set base URL
export LAMBDA_URL="https://your-lambda-url"

# Basic tests
curl $LAMBDA_URL/hello
curl $LAMBDA_URL/car
curl $LAMBDA_URL/examples/health
```

---

## 📊 Performance

### Benchmark metrics

| Metric | Value | Notes |
|----------|--------|-------|
| **Cold Start** | < 500ms | First invocation |
| **Warm Request** | < 10ms | Subsequent requests |
| **Memory size** | 64-128 MB | Runtime |
| **Configured timeout** | 30s | Adjustable |

### Optimizations

1. **Lambda memory**: 512 MB recommended
2. **Architecture**: ARM64 (better performance)
3. **Keep-alive**: Lambda keeps containers warm
4. **Native compilation**: Drastically reduces cold start

---

## 🚨 Error handling

### HTTP status codes

| Code | Meaning | Usage |
|------|---------------|-------|
| 200 | OK | Success (GET, PUT) |
| 201 | Created | Resource created (POST) |
| 204 | No Content | Success without content (DELETE) |
| 400 | Bad Request | Validation error |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Conflict (email already used) |
| 500 | Internal Server Error | Server error |

### Debugging

To check error logs:

```bash
# Real-time logs
aws logs tail /aws/lambda/YOUR-FUNCTION --region YOUR-REGION --follow

# Logs from last 10 minutes
aws logs tail /aws/lambda/YOUR-FUNCTION --region YOUR-REGION --since 10m
```

---

## 🔐 Security

### Authentication (to implement)

The bootstrap doesn't include authentication by default. Here are recommended options:

1. **JWT with Quarkus Security**
2. **AWS Cognito**
3. **API Keys with AWS API Gateway**

### CORS

CORS is automatically configured for Function URLs:
- Origins: `*` (should be restricted in production)
- Methods: `GET, POST, PUT, DELETE, OPTIONS`
- Headers: `*`

---

## 📋 Changelog API

### Version 1.0.0
- ✅ Endpoints de base (hello, car)
- ✅ Template d'endpoint CRUD
- ✅ Exemples avancés (pagination, filtres)
- ✅ Health check
- ✅ Gestion d'erreurs standardisée

---

## 🆘 Support

### Frequent issues

1. **Error 502**: Check CloudWatch logs
2. **Timeout**: Increase Lambda timeout
3. **JSON serialization error**: Check jackson dependency

### Contact

- 📚 Documentation: README.md
- 🐛 Issues: Create a GitHub issue
- 💬 Discussions: GitHub Discussions