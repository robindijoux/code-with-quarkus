# 🚀 Quarkus Lambda Bootstrap Project

> **Ready-to-fork template** for quickly creating native Quarkus REST APIs deployed on AWS Lambda

[![Quarkus](https://img.shields.io/badge/Quarkus-3.27.0-blue.svg)](https://quarkus.io/)
[![Java](https://img.shields.io/badge/Java-21+-orange.svg)](https://openjdk.org/)
[![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900.svg)](https://aws.amazon.com/lambda/)
[![Architecture](https://img.shields.io/badge/Architecture-ARM64-green.svg)](https://aws.amazon.com/graviton/)

---

## 🎯 What is this project?

A fully configured **Quarkus bootstrap** for:

- ⚡ **Cold start < 500ms** (GraalVM native compilation)
- 🏗️ **AWS Lambda deployment** with Function URL (single URL for the entire API)
- 🔧 **Automated scripts** for build and deployment
- 📚 **Complete documentation** and endpoint examples
- 🛠️ **Ready-to-use templates** for your new endpoints

### Architecture

```
┌─────────────────────────────────────────────────┐
│  Lambda Function URL                             │
│  https://xxx.lambda-url.region.on.aws/          │ ← Single URL
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│           AWS Lambda (ARM64)                     │
│  ┌───────────────────────────────────────────┐  │
│  │  Your Native Quarkus Application          │  │ ← Cold start < 500ms
│  │    ↓                                      │  │
│  │  LambdaHttpHandler                        │  │
│  │    ↓                                      │  │
│  │  Your JAX-RS Endpoints                    │  │ ← 100% standard code
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

---

## 🚀 Getting started in 3 steps

### 1️⃣ Fork and clone

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/YOUR-PROJECT.git
cd YOUR-PROJECT
```

### 2️⃣ Initialize your project

```bash
# Transform the bootstrap into your project
./init-project.sh "My E-commerce API" "com.mycompany.ecommerce"

# Configure AWS (first time)
cp .env.template .env
# Edit .env with your AWS_ACCOUNT_ID
```

### 3️⃣ Deploy

```bash
# Complete deployment in one command
./scripts/deploy.sh
```

**That's it!** 🎉 Your API is online with a unique URL.

---

## 📋 What you get

### ✅ Ready-to-use example endpoints

| Endpoint | Description | Type |
|----------|-------------|------|
| `/hello` | Welcome message | Simple |
| `/car` | Complete CRUD (cars) | Basic CRUD |
| `/template` | Documented template | Development guide |
| `/examples/*` | Advanced patterns | Pagination, filters, stats |

### 🛠️ Automated scripts

| Script | Usage |
|--------|-------------|
| `./init-project.sh` | Bootstrap transformation |
| `./scripts/deploy.sh` | Complete deployment |
| `./scripts/build-native.sh` | Native build only |
| `./verify-bootstrap.sh` | Project verification |

### 📚 Complete documentation

- **[README-BOOTSTRAP.md](README-BOOTSTRAP.md)** - Complete bootstrap guide
- **[docs/API.md](docs/API.md)** - API documentation
- **[docs/ENDPOINTS.md](docs/ENDPOINTS.md)** - How to add endpoints
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Detailed deployment guide

---

## 🧪 Quick test

```bash
# Variables (after deployment)
LAMBDA_URL="https://your-lambda-url"

# Basic tests
curl $LAMBDA_URL/hello
# → "Hello from Quarkus REST"

curl $LAMBDA_URL/car
# → [{"id":1,"brand":"Tesla","model":"Model 3"}]

# Create a car
curl -X POST $LAMBDA_URL/car \
  -H "Content-Type: application/json" \
  -d '{"brand":"BMW","model":"i4"}'

# Advanced API with pagination
curl "$LAMBDA_URL/examples/users?page=0&size=5&status=ACTIVE"
```

---

## 🔧 Prerequisites

### Required tools

- **Java 21+** (`brew install openjdk@21`)
- **Docker** ([Docker Desktop](https://www.docker.com/products/docker-desktop))
- **AWS CLI** (`brew install awscli` + `aws configure`)

### AWS Services

- AWS Lambda (function creation)
- Amazon ECR (Docker image storage)
- AWS IAM (role management)

### Automatic verification

```bash
# Check that everything is ready
./verify-bootstrap.sh
```

---

## 🏗️ Customization

### Adding a new endpoint

1. **Copy the template:**
   ```bash
   cp src/main/java/YOUR_PACKAGE/resource/TemplateResource.java \
      src/main/java/YOUR_PACKAGE/resource/UserResource.java
   ```

2. **Adapt to your needs:**
   ```java
   @Path("/users")  // ← Change the path
   public class UserResource {
       // Adapt methods and entities
   }
   ```

3. **Deploy:**
   ```bash
   ./scripts/deploy.sh
   ```

**Complete details:** [docs/ENDPOINTS.md](docs/ENDPOINTS.md)

### Advanced configuration

Variables in `.env`:

```bash
# Project
PROJECT_NAME="My API"
PROJECT_PACKAGE="com.mycompany.api"

# AWS
AWS_REGION="eu-west-3"
AWS_ACCOUNT_ID="123456789012"
LAMBDA_FUNCTION_NAME="MyAPI"

# Performance
LAMBDA_MEMORY="512"
LAMBDA_TIMEOUT="30"
```

---

## 📊 Performance

### Reference metrics

| Configuration | Cold Start | Cost/month (100k req) |
|---------------|------------|---------------------|
| **Quarkus Native ARM64** ⭐ | **< 500ms** | **~$0.30** |
| Equivalent JVM | 5-10s | ~$2.00 |

### Advantages

- ✅ **Single URL** for the entire API (vs multiple Lambdas)
- ✅ **No API Gateway** required (Function URL included)
- ✅ **Standard JAX-RS code** (no Lambda-specific code)
- ✅ **Automatic AWS scaling**
- ✅ **Real pay-per-use**

---

## 🤝 Using the bootstrap

### For a new project

1. **Fork this repository**
2. **Initialize:** `./init-project.sh "My Project" "com.mycompany.api"`
3. **Configure:** Edit `.env`
4. **Deploy:** `./scripts/deploy.sh`

### To contribute to the bootstrap

1. **Clone directly** this repository
2. **Add your improvements** (new templates, scripts, etc.)
3. **Test:** `./verify-bootstrap.sh`
4. **Submit a PR**

---

## 🆘 Support and troubleshooting

### Common issues

| Error | Cause | Solution |
|--------|-------|----------|
| `NullPointerException HttpMethod` | Wrong Lambda extension | Use `quarkus-amazon-lambda-http` |
| `Image manifest not supported` | Incompatible Docker build | Use `docker buildx --platform linux/arm64` |
| JSON returns `Car@xxx` | Missing Jackson | Add `quarkus-rest-jackson` |

### Verification

```bash
# Complete bootstrap verification
./verify-bootstrap.sh

# Real-time Lambda logs
aws logs tail /aws/lambda/YOUR-FUNCTION --region YOUR-REGION --follow
```

### Documentation

- **[Complete troubleshooting](docs/DEPLOYMENT.md#-troubleshooting)**
- **[Endpoint addition guide](docs/ENDPOINTS.md)**
- **[API documentation](docs/API.md)**

---

## 📈 Roadmap

### ✅ Current version (1.0)

- Functional bootstrap
- Deployment scripts
- Complete documentation
- Endpoint examples

### 🔄 Next versions

- **1.1**: Templates for DynamoDB/PostgreSQL
- **1.2**: Automatic OpenAPI/Swagger support
- **1.3**: Authentication templates (JWT/Cognito)
- **1.4**: GitHub Actions CI/CD

---

## 🌟 Contributors

Want to contribute? Check [CONTRIBUTING.md](CONTRIBUTING.md)

### How to help

- 🐛 **Report bugs**
- 📝 **Improve documentation**
- 🔧 **Add endpoint templates**
- 🚀 **Optimize deployment scripts**

---

## 📜 License

This project is under MIT license. See [LICENSE](LICENSE) for more details.

---

## 🙏 Acknowledgments

- **[Quarkus](https://quarkus.io/)** for the incredible framework
- **[AWS Lambda](https://aws.amazon.com/lambda/)** for serverless
- **[GraalVM](https://www.graalvm.org/)** for native compilation

---

**Created with ❤️ for the Java/Quarkus community**

*Transform your ideas into deployed APIs in minutes!*

## ✅ Prerequisites

Here's what I needed:

- **Java 21** (compatible with my Quarkus 3.27.0 version)
- **Maven** (I use the included wrapper with `./mvnw`)
- **Docker** (for native build and image creation)
- **AWS CLI** configured with access to ECR and Lambda
- **AWS Account** with ECR and Lambda enabled

---

## 💻 Development

### My REST code remains 100% standard

The big advantage: I didn't change anything in my classic JAX-RS code!

```java
@Path("/hello")
public class GreetingResource {
    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "Hello from Lambda!";
    }
}

@Path("/car")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CarResource {
    @GET
    public List<Car> list() { ... }
    
    @GET
    @Path("/{id}")
    public Car get(@PathParam("id") Long id) { ... }
    
    @POST
    public Response create(Car car) { ... }
    
    @PUT
    @Path("/{id}")
    public Car update(@PathParam("id") Long id, Car updatedCar) { ... }
    
    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) { ... }
}
```

### My local tests

```bash
# Development mode
./mvnw quarkus:dev

# Tests
./mvnw test
```

---

## 🏗️ Native build

### My build command

```bash
./mvnw clean package -Pnative \
  -Dquarkus.native.container-build=true
```

**Duration on my machine**: ~1-2 minutes

**What I get**:
- `target/code-with-quarkus-1.0.0-SNAPSHOT-runner` (my native executable)
- Size: ~56 MB
- Architecture: ARM64 (because I build on Mac M1/M2)

### How I verify my binary

```bash
file target/code-with-quarkus-1.0.0-SNAPSHOT-runner
# Output: ELF 64-bit LSB executable, ARM aarch64...
```

---

## 🐳 Dockerization

### 1️⃣ My Lambda Dockerfile

I created `src/main/docker/Dockerfile.native.lambda`:

```dockerfile
FROM public.ecr.aws/lambda/provided:al2023

# I copy my native binary as bootstrap
COPY target/*-runner ${LAMBDA_RUNTIME_DIR}/bootstrap

# I set execution permissions
RUN chmod 755 ${LAMBDA_RUNTIME_DIR}/bootstrap

# Handler (not used but required by Lambda)
CMD [ "not.used.in.provided.runtime" ]
```

### 2️⃣ Building my image

```bash
docker buildx build \
  --load \
  --platform linux/arm64 \
  -f src/main/docker/Dockerfile.native.lambda \
  -t portfolio-rbndjx:lambda-arm64 \
  .
```

**Important points I learned**:
- `--platform linux/arm64`: I specify the Lambda architecture (ARM64 is more performant and cheaper)
- `--load`: Loads the image into my local Docker (not just the cache)
- I use the official AWS base image: `public.ecr.aws/lambda/provided:al2023`

### 3️⃣ Local testing (optional but useful for debugging)

```bash
# I start my container
docker run --rm -d -p 9000:8080 --name lambda-test portfolio-rbndjx:lambda-arm64

# I test
curl -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{"rawPath":"/hello","requestContext":{"http":{"method":"GET","path":"/hello"}}}'

# I stop
docker stop lambda-test
```

---

## ☁️ AWS Lambda Deployment

### 1️⃣ I push my image to ECR

```bash
# I tag my image for ECR
docker tag portfolio-rbndjx:lambda-arm64 \
  259726931000.dkr.ecr.eu-west-3.amazonaws.com/portfolio-rbndjx:lambda-arm64-v2

# I connect to ECR
aws ecr get-login-password --region eu-west-3 | \
  docker login --username AWS --password-stdin \
  259726931000.dkr.ecr.eu-west-3.amazonaws.com

# I push my image
docker push 259726931000.dkr.ecr.eu-west-3.amazonaws.com/portfolio-rbndjx:lambda-arm64-v2
```

### 2️⃣ I create my Lambda function (via AWS Console)

I used the console because it's simpler for the first time:

1. **I go to Lambda Console**
2. **"Create function"**
3. I choose **Container image**
4. I configure:
   - **Function name**: `testQuarkus`
   - **Container image URI**: My ECR URI above
   - **Architecture**: `arm64` ⚠️ IMPORTANT!
5. **Create function**

### 3️⃣ My Lambda configuration

Here are the parameters I configured:

| Parameter | Value I use | Why |
|-----------|---------------------|---------|
| **Memory** | 512 MB | My native Quarkus is lightweight and this is more than enough |
| **Timeout** | 30 seconds | For my standard REST APIs |
| **Architecture** | arm64 | More performant and **cheaper** than x86_64 |
| **Ephemeral storage** | 512 MB (default) | Sufficient for my needs |

### 4️⃣ I create my Function URL

This is where I configure my unique URL for my entire API:

1. In my Lambda function, **"Configuration"** tab
2. **"Function URL"** > **"Create function URL"**
3. I configure:
   - **Auth type**: `NONE` (no authentication for my tests)
   - **CORS**:
     ```json
     {
       "AllowOrigins": ["*"],
       "AllowMethods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
       "AllowHeaders": ["*"],
       "MaxAge": 86400
     }
     ```
4. **Save**

**I get my unique URL**:
```
https://g7qpptedraqffswj6ti7il7y6e0mrvxw.lambda-url.eu-west-3.on.aws/
```

---

## 🎯 Using my API

### Single URL for all my endpoints!

```bash
# My base URL
LAMBDA_URL="https://g7qpptedraqffswj6ti7il7y6e0mrvxw.lambda-url.eu-west-3.on.aws"

# I test GET /hello
curl $LAMBDA_URL/hello
# → "Hello from Lambda!"

# I list all cars - GET /car
curl $LAMBDA_URL/car
# → [{"id":1,"brand":"Tesla","model":"Model 3"},{"id":2,"brand":"BMW","model":"i4"}]

# I get a specific car - GET /car/{id}
curl $LAMBDA_URL/car/1
# → {"id":1,"brand":"Tesla","model":"Model 3"}

# I create a new car - POST /car
curl -X POST $LAMBDA_URL/car \
  -H "Content-Type: application/json" \
  -d '{"brand":"Audi","model":"e-tron"}'
# → {"id":3,"brand":"Audi","model":"e-tron"}

# I update a car - PUT /car/{id}
curl -X PUT $LAMBDA_URL/car/1 \
  -H "Content-Type: application/json" \
  -d '{"brand":"Tesla","model":"Model S"}'
# → {"id":1,"brand":"Tesla","model":"Model S"}

# I delete a car - DELETE /car/{id}
curl -X DELETE $LAMBDA_URL/car/1
# → 204 No Content
```

**It's magic**: Quarkus handles all the routing automatically! 🎉

---

## 🔍 Understanding the differences between Lambda extensions

**This is the part where I lost the most time**, so I document it here for understanding:

### The two available extensions

| Extension | Artifact ID | Supported event format |
|-----------|-------------|------------------------|
| **Amazon Lambda REST** | `quarkus-amazon-lambda-rest` | API Gateway REST API (v1) only |
| **Amazon Lambda HTTP** | `quarkus-amazon-lambda-http` | API Gateway HTTP API (v2) + **Function URL** ✅ |

### Event formats

#### API Gateway REST API (v1) - what `-rest` expects

```json
{
  "httpMethod": "GET",
  "path": "/hello",
  "requestContext": {
    "requestId": "...",
    "stage": "prod"
  },
  "body": null
}
```

#### API Gateway HTTP API v2 / Function URL - what `-http` expects

```json
{
  "version": "2.0",
  "routeKey": "$default",
  "rawPath": "/hello",
  "requestContext": {
    "http": {
      "method": "GET",
      "path": "/hello"
    }
  }
}
```

### The error I encountered

When I was using `quarkus-amazon-lambda-rest` with Function URL:

```
java.lang.NullPointerException
at io.netty.handler.codec.http.HttpMethod.valueOf(HttpMethod.java:121)
at io.quarkus.amazon.lambda.http.LambdaHttpHandler.nettyDispatch
```

**Why?**
1. Lambda Function URL sends **HTTP API v2** format
2. The `-rest` extension looks for the `httpMethod` field (v1 format)
3. This field doesn't exist in v2 format → `method = null`
4. Result: **NullPointerException** 💥

### My simple rule to remember

| I use | Extension to use |
|-----------|---------------------|
| **Lambda Function URL** ⭐ (my case) | `quarkus-amazon-lambda-http` ✅ |
| **API Gateway HTTP API (v2)** | `quarkus-amazon-lambda-http` ✅ |
| **API Gateway REST API (v1)** | `quarkus-amazon-lambda-rest` ✅ |
| **Application Load Balancer** | `quarkus-amazon-lambda-rest` ✅ |

**For my project with Function URL, I MUST use `quarkus-amazon-lambda-http`!**

---

## 🐛 Troubleshooting

Here are all the problems I encountered and how I solved them:

### 1. Error: "Image manifest not supported"

**My complete error**:
```
The image manifest, config or layer media type for the source image is not supported.
```

**The cause**: Docker manifest format incompatible with Lambda

**My solution**: Use `docker buildx` with explicit `--platform` and `--load`

```bash
# What DIDN'T work
docker build -f src/main/docker/Dockerfile.native.lambda -t myapp:lambda .

# What WORKS
docker buildx build --load --platform linux/arm64 \
  -f src/main/docker/Dockerfile.native.lambda \
  -t myapp:lambda .
```

### 2. Error: `NullPointerException` in `HttpMethod.valueOf`

**My complete error**:
```
java.lang.NullPointerException: Cannot invoke "String.hashCode()" because "name" is null
at io.netty.handler.codec.http.HttpMethod$EnumNameMap.hashCode(HttpMethod.java:217)
at io.netty.handler.codec.http.HttpMethod.valueOf(HttpMethod.java:121)
```

**The cause**: I was using the wrong extension (`quarkus-amazon-lambda-rest` instead of `quarkus-amazon-lambda-http`)

**My solution**: Change in my `pom.xml`

```xml
<!-- ❌ What I had (and that DIDN'T work) -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-amazon-lambda-rest</artifactId>
</dependency>

<!-- ✅ What I put (and that WORKS) -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-amazon-lambda-http</artifactId>
</dependency>
```

### 3. JSON not serialized (returns `org.acme.Car@xxx`)

**My symptom**: My Car objects displayed as `org.acme.CarResource$Car@2e614aa` instead of JSON

**The cause**: Missing Jackson extension

**My solution**: Add to my `pom.xml`

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-rest-jackson</artifactId>
</dependency>
```

### 4. How I check my CloudWatch logs

To debug, I use AWS CLI:

```bash
# I see logs in real time
aws logs tail /aws/lambda/testQuarkus --region eu-west-3 --follow

# I see recent logs (last 10 minutes)
aws logs tail /aws/lambda/testQuarkus --region eu-west-3 --since 10m
```

---

## 📊 Performance I achieve

### Cold Start

Here's what I measure in production:

| Configuration | Cold Start | Image size |
|---------------|-----------|------------|
| **My Quarkus Native (ARM64)** | **< 500ms** ⚡ | ~60 MB |
| If I had used JVM (512 MB) | 5-10s 🐢 | 200-300 MB |

### Warm Requests

When my Lambda is already "warm":
- **< 10ms** on average
- Memory used: **64-128 MB**

### My real cost (eu-west-3 region)

For **100,000 requests/month** with average time of 100ms:
- **Compute**: ~$0.24
- **Requests**: $0.04
- **Total**: **~$0.30/month**

But with the **AWS free tier**, it's **free**! 🎉

---

## ✅ Essential steps

1. **My critical Maven dependencies**
   - `quarkus-rest` (REST API)
   - `quarkus-rest-jackson` ⚠️ (JSON serialization required)
   - `quarkus-amazon-lambda-http` ⚠️ (and definitely **NOT** `-rest`!)

2. **My native build**
   ```bash
   ./mvnw package -Pnative -Dquarkus.native.container-build=true
   ```

3. **My Lambda Dockerfile**
   - Base: `public.ecr.aws/lambda/provided:al2023`
   - My binary → `${LAMBDA_RUNTIME_DIR}/bootstrap`

4. **My Docker image**
   ```bash
   docker buildx build --load --platform linux/arm64 \
     -f src/main/docker/Dockerfile.native.lambda -t app:lambda .
   ```

5. **My deployment**
   - I push to ECR
   - I create my Lambda with Container Image
   - **ARM64 Architecture** ⚠️ (important!)
   - I create my Function URL

### 🚀 The benefits I see

- ✅ **Cold start < 500ms** (vs 5-10s in JVM)
- ✅ **Single URL for my entire API** (no need for API Gateway)
- ✅ **My code remains 100% standard JAX-RS** (no Lambda-specific code)
- ✅ **Minimal cost** (true pay-per-use)
- ✅ **Simplicity** (no API Gateway configuration)
- ✅ **Automatic scaling** (AWS handles everything)

---

## 📚 My useful resources

- [Quarkus - Amazon Lambda](https://quarkus.io/guides/amazon-lambda)
- [Quarkus - Amazon Lambda HTTP](https://quarkus.io/guides/amazon-lambda-http)
- [AWS Lambda Container Images](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html)
- [AWS Lambda Function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html)

---

**Made with ❤️ using Quarkus + AWS Lambda**