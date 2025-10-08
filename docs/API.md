# 📚 API Documentation# 📚 Quarkus Lambda Bootstrap API Documentation



## 🎯 Overview## 🎯 Overview



This REST API uses Quarkus compiled natively and deployed on AWS Lambda with Function URL.This REST API uses Quarkus compiled natively and deployed on AWS Lambda with Function URL.



**Architecture:****Architecture:**

- ⚡ Cold start < 500ms (native compilation)- ⚡ Cold start < 500ms (native compilation)

- 🏗️ ARM64 architecture (optimal performance)- 🏗️ ARM64 architecture (optimal performance)

- 🌐 Single URL for the entire API- 🌐 Single URL for the entire API

- 📦 Containerization with Docker- 📦 Containerization with Docker



------



## 🔗 Available endpoints## 🔗 Available endpoints



### 👋 Simple greeting### 👋 Base endpoint



| Endpoint | Method | Description | Response || Endpoint | Method | Description | Response |

|----------|---------|-------------|---------||----------|---------|-------------|---------|

| `/api/hello` | GET | Welcome message | `"Hello from Quarkus REST"` || `/hello` | GET | Welcome message | `"Hello from Quarkus REST"` |



**Example:****Example:**

```bash```bash

curl https://LAMBDA-URL/api/hellocurl https://LAMBDA-URL/hello

``````



### 🏥 Health checks---



| Endpoint | Method | Description |### 📄 Endpoint template (Development Guide)

|----------|---------|-------------|

| `/q/health` | GET | Application health status || Endpoint | Method | Description |

| `/q/health/live` | GET | Liveness check ||----------|---------|-------------|

| `/q/health/ready` | GET | Readiness check || `/template` | GET | List all template items |

| `/template/{id}` | GET | Get an item by ID |

**Examples:**| `/template` | POST | Create a new item |

```bash| `/template/{id}` | PUT | Update an item |

# Overall health| `/template/{id}` | DELETE | Delete an item |

curl https://LAMBDA-URL/q/health| `/template/search?name=xxx` | GET | Search by name |

| `/template/count` | GET | Count items |

# Liveness probe  

curl https://LAMBDA-URL/q/health/live**Examples:**

```bash

# Readiness probe# List all items

curl https://LAMBDA-URL/q/health/readycurl https://LAMBDA-URL/template

```

# Search by name

---curl https://LAMBDA-URL/template/search?name=item



## 📝 Response formats# Create a new item

curl -X POST https://LAMBDA-URL/template \

### Success responses  -H "Content-Type: application/json" \

  -d '{"name": "My item", "description": "Description of my item"}'

**Simple text:**```

```

Hello from Quarkus REST---

```

### 🚀 Advanced examples

**Health check:**

```jsonEndpoints demonstrating advanced patterns:

{

  "status": "UP",#### 👥 User management

  "checks": []

}| Endpoint | Method | Description | Parameters |

```|----------|---------|-------------|------------|

| `/examples/users` | GET | List with pagination and filters | `page`, `size`, `status`, `search` |

### Error responses| `/examples/users/{id}` | GET | User with their orders | - |

| `/examples/users` | POST | Create a user | `{"name": "...", "email": "..."}` |

**Error 404 (Not Found):**

```json**Examples:**

{```bash

  "error": "Endpoint not found",# List with pagination

  "timestamp": 1705312200000curl "https://LAMBDA-URL/examples/users?page=0&size=5&status=ACTIVE"

}

```# Search users

curl "https://LAMBDA-URL/examples/users?search=alice"

**Error 500 (Internal Server Error):**

```json# Create a user

{curl -X POST https://LAMBDA-URL/examples/users \

  "error": "Internal server error",  -H "Content-Type: application/json" \

  "timestamp": 1705312200000  -d '{"name": "John Doe", "email": "john@example.com"}'

}```

```

#### 🛒 Order management

---

| Endpoint | Method | Description |

## 🔧 HTTP Headers|----------|---------|-------------|

| `/examples/users/{userId}/orders` | GET | Orders for a user |

### Required headers| `/examples/users/{userId}/orders` | POST | New order |



For requests with body (POST, PUT):**Examples:**

``````bash

Content-Type: application/json# User orders

```curl https://LAMBDA-URL/examples/users/1/orders



### Response headers# New order

curl -X POST https://LAMBDA-URL/examples/users/1/orders \

All responses include:  -H "Content-Type: application/json" \

```  -d '{"items": [{"name": "Laptop", "quantity": 1, "price": 999.99}]}'

Content-Type: application/json```

```

#### 📊 Statistics and monitoring

---

| Endpoint | Method | Description |

## 🧪 Testing|----------|---------|-------------|

| `/examples/stats` | GET | Global statistics |

### Basic tests| `/examples/users/top` | GET | Top 5 users |

| `/examples/health` | GET | Detailed health check |

```bash

# Set base URL**Examples:**

export LAMBDA_URL="https://your-lambda-url"```bash

# Statistics

# Test greetingcurl https://LAMBDA-URL/examples/stats

curl $LAMBDA_URL/api/hello

# Top users

# Test healthcurl https://LAMBDA-URL/examples/users/top

curl $LAMBDA_URL/q/health

```# Health check

curl https://LAMBDA-URL/examples/health

### Test script```



Use the provided test script:---

```bash

./scripts/test_lambda_requests.sh## 📝 Response formats

```

### Success responses

---

**Simple list:**

## 📊 Performance```json

[

### Benchmark metrics  {"id": 1, "name": "Item 1"},

  {"id": 2, "name": "Item 2"}

| Metric | Value | Notes |]

|----------|--------|-------|```

| **Cold Start** | < 500ms | First invocation |

| **Warm Request** | < 10ms | Subsequent requests |**Pagination:**

| **Memory size** | 64-128 MB | Runtime |```json

| **Configured timeout** | 30s | Adjustable |{

  "content": [

### Optimizations    {"id": 1, "name": "User 1"}

  ],

1. **Lambda memory**: 512 MB recommended  "page": 0,

2. **Architecture**: ARM64 (better performance)  "size": 10,

3. **Keep-alive**: Lambda keeps containers warm  "totalElements": 25,

4. **Native compilation**: Drastically reduces cold start  "totalPages": 3

}

---```



## 🚨 Error handling**Creation (status 201):**

```json

### HTTP status codes{

  "id": 3,

| Code | Meaning | Usage |  "name": "New item",

|------|---------------|-------|  "createdAt": "2024-01-15T10:30:00"

| 200 | OK | Success |}

| 404 | Not Found | Endpoint not found |```

| 500 | Internal Server Error | Server error |

### Error responses

### Debugging

**Error 400 (Bad Request):**

To check error logs:```json

{

```bash  "error": "Name is required",

# Real-time logs  "timestamp": 1705312200000

aws logs tail /aws/lambda/YOUR-FUNCTION --region YOUR-REGION --follow}

```

# Logs from last 10 minutes  

aws logs tail /aws/lambda/YOUR-FUNCTION --region YOUR-REGION --since 10m**Error 404 (Not Found):**

``````json

{

---  "error": "Element with ID 999 not found",

  "timestamp": 1705312200000

## 🔐 Security}

```

### CORS

**Error 409 (Conflict):**

CORS is automatically configured for Function URLs:```json

- Origins: `*` (should be restricted in production){

- Methods: `GET, POST, PUT, DELETE, OPTIONS`  "error": "Email already in use",

- Headers: `*`  "timestamp": 1705312200000

}

---```



## 🆘 Support**Validation error (400):**

```json

### Frequent issues{

  "errors": [

1. **Error 502**: Check CloudWatch logs    "Name is required",

2. **Timeout**: Increase Lambda timeout    "Invalid email format"

3. **Cold start**: Use provisioned concurrency if needed  ],

  "timestamp": 1705312200000

### Contact}

```

- 📚 Documentation: README.md

- 🐛 Issues: Create a GitHub issue---

- 💬 Discussions: GitHub Discussions
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