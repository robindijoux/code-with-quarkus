# 🚀 AWS Lambda Deployment Guide

Complete guide to deploy your Quarkus API on AWS Lambda with Function URL.

---

## 📋 Prerequisites

### 🛠️ Required tools

| Tool | Minimum version | Installation |
|-------|------------------|--------------|
| **Java** | 21+ | `brew install openjdk@21` (macOS) |
| **Maven** | 3.8+ | Included with `./mvnw` |
| **Docker** | 20.10+ | [Docker Desktop](https://www.docker.com/products/docker-desktop) |
| **AWS CLI** | 2.0+ | `brew install awscli` (macOS) |

### ☁️ AWS Configuration

```bash
# AWS CLI configuration
aws configure
# AWS Access Key ID: your-access-key
# AWS Secret Access Key: your-secret-key  
# Default region: eu-west-3
# Default output format: json

# Verification
aws sts get-caller-identity
```

### 🏗️ Required AWS services

- **AWS Lambda** (function creation)
- **Amazon ECR** (Docker image storage)
- **AWS IAM** (role management)
- **CloudWatch Logs** (automatic logs)

---

## ⚙️ Initial setup

### 1️⃣ Configuration file

Copy and customize the `.env` file:

```bash
cp .env.template .env
```

**Required variables to configure:**

```bash
# .env
PROJECT_NAME="My Quarkus API"
AWS_REGION="eu-west-3"
AWS_ACCOUNT_ID="123456789012"    # ← REQUIRED
ECR_REPOSITORY_NAME="my-api"
LAMBDA_FUNCTION_NAME="MyAPI"
```

**How to find your Account ID:**
```bash
aws sts get-caller-identity --query Account --output text
```

### 2️⃣ Required IAM permissions

Your AWS user must have these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "lambda:*",
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:GetRole",
        "iam:PassRole",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 🚀 Automatic deployment

### Option 1: Complete deployment (recommended)

```bash
# One-command deployment
./scripts/deploy.sh
```

This script automatically performs:
1. ✅ Quarkus native build
2. ✅ Docker image build 
3. ✅ ECR repository creation (if needed)
4. ✅ Image push to ECR
5. ✅ Lambda function creation/update
6. ✅ Function URL configuration
7. ✅ Permissions configuration

**Expected output:**
```
🎉 DEPLOYMENT SUCCESSFUL!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 Your API URL : https://xxx.lambda-url.eu-west-3.on.aws/
📊 Lambda Function  : MyAPI
🏗️  Architecture    : arm64
💾 Memory         : 512 MB
⏱️  Timeout         : 30s
```

### Option 2: Step-by-step deployment

```bash
# 1. Native build only
./scripts/build-native.sh

# 2. Push to ECR only  
./scripts/push-ecr.sh

# 3. Lambda update only
./scripts/update-lambda.sh
```

---

## 🔧 Manual deployment

### 1️⃣ Native build

```bash
# Native compilation with Docker
./mvnw clean package -Pnative \
  -Dquarkus.native.container-build=true

# Binary verification
ls -la target/*-runner
file target/*-runner
```

### 2️⃣ Docker build

```bash
# Image build
docker buildx build \
  --load \
  --platform linux/arm64 \
  -f src/main/docker/Dockerfile.native.lambda \
  -t my-api:latest \
  .

# Verification
docker images my-api:latest
```

### 3️⃣ ECR repository creation

```bash
# Variables
AWS_REGION="eu-west-3"
AWS_ACCOUNT_ID="123456789012"
REPO_NAME="my-api"

# Repository creation
aws ecr create-repository \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --image-scanning-configuration scanOnPush=true
```

### 4️⃣ Push to ECR

```bash
# ECR URI
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_URI="${ECR_URI}/${REPO_NAME}:latest"

# ECR login
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_URI

# Tag and push
docker tag my-api:latest $IMAGE_URI
docker push $IMAGE_URI
```

### 5️⃣ IAM role creation

```bash
# Role creation
ROLE_NAME="MyAPI-execution-role"

# Trust policy for Lambda
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json

# Attach basic policy
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
```

### 6️⃣ Lambda function creation

```bash
# Variables
FUNCTION_NAME="MyAPI"
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"

# Function creation
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --role $ROLE_ARN \
  --code ImageUri=$IMAGE_URI \
  --package-type Image \
  --architectures arm64 \
  --memory-size 512 \
  --timeout 30 \
  --region $AWS_REGION
```

### 7️⃣ Function URL configuration

```bash
# Function URL creation
FUNCTION_URL=$(aws lambda create-function-url-config \
  --function-name $FUNCTION_NAME \
  --region $AWS_REGION \
  --auth-type NONE \
  --cors "AllowOrigins=*,AllowMethods=GET\\,POST\\,PUT\\,DELETE\\,OPTIONS,AllowHeaders=*,MaxAge=86400" \
  --query 'FunctionUrl' \
  --output text)

echo "🌐 Your API URL: $FUNCTION_URL"
```

---

## 🧪 Post-deployment testing

### Basic tests

```bash
# Variables (replace with your values)
LAMBDA_URL="https://xxx.lambda-url.eu-west-3.on.aws"

# Test basic endpoint
curl $LAMBDA_URL/hello
# Expected: "Hello from Quarkus REST"

# Test CRUD API
curl $LAMBDA_URL/car
# Expected: [{"id":1,"brand":"Tesla","model":"Model 3"}]

# Test creation
curl -X POST $LAMBDA_URL/car \
  -H "Content-Type: application/json" \
  -d '{"brand":"BMW","model":"i4"}'
```

### Performance tests

```bash
# Cold start test (first request)
time curl $LAMBDA_URL/hello

# Warm start test (subsequent requests)
time curl $LAMBDA_URL/hello
time curl $LAMBDA_URL/hello
```

### Log verification

```bash
# Real-time logs
aws logs tail /aws/lambda/$FUNCTION_NAME --region $AWS_REGION --follow

# Logs from last 10 minutes
aws logs tail /aws/lambda/$FUNCTION_NAME --region $AWS_REGION --since 10m
```

---

## 🔄 Mise à jour d'une fonction existante

### Mise à jour automatique

```bash
# Mise à jour complète (code + configuration)
./scripts/deploy.sh

# Mise à jour du code seulement
./scripts/update-lambda.sh
```

### Mise à jour manuelle

```bash
# 1. Nouveau build et push
./mvnw package -Pnative -Dquarkus.native.container-build=true
docker buildx build --load --platform linux/arm64 \
  -f src/main/docker/Dockerfile.native.lambda -t mon-api:latest .
docker tag mon-api:latest $IMAGE_URI
docker push $IMAGE_URI

# 2. Mise à jour de la fonction
aws lambda update-function-code \
  --function-name $FUNCTION_NAME \
  --image-uri $IMAGE_URI \
  --region $AWS_REGION

# 3. Attendre la fin de la mise à jour
aws lambda wait function-updated \
  --function-name $FUNCTION_NAME \
  --region $AWS_REGION
```

---

## 📊 Configuration avancée

### 🎚️ Ajustement des performances

```bash
# Mémoire (128 MB à 10,240 MB)
aws lambda update-function-configuration \
  --function-name $FUNCTION_NAME \
  --memory-size 1024 \
  --region $AWS_REGION

# Timeout (max 15 minutes)
aws lambda update-function-configuration \
  --function-name $FUNCTION_NAME \
  --timeout 60 \
  --region $AWS_REGION
```

### 🌍 Variables d'environnement

```bash
# Configuration des variables d'environnement
aws lambda update-function-configuration \
  --function-name $FUNCTION_NAME \
  --environment Variables='{
    "LOG_LEVEL":"DEBUG",
    "DB_URL":"jdbc:postgresql://...",
    "REDIS_URL":"redis://..."
  }' \
  --region $AWS_REGION
```

### 🏷️ Tags et métadonnées

```bash
# Ajout de tags
aws lambda tag-resource \
  --resource "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$FUNCTION_NAME" \
  --tags Environment=Production,Project=MonAPI,Team=Backend
```

### 🔒 Sécurité Function URL

```bash
# Restriction CORS
aws lambda update-function-url-config \
  --function-name $FUNCTION_NAME \
  --cors "AllowOrigins=https://mondomaine.com,AllowMethods=GET\\,POST,AllowHeaders=Content-Type,MaxAge=3600" \
  --region $AWS_REGION

# Authentification IAM (au lieu de NONE)
aws lambda update-function-url-config \
  --function-name $FUNCTION_NAME \
  --auth-type AWS_IAM \
  --region $AWS_REGION
```

---

## 💰 Optimisation des coûts

### 📊 Architecture recommandée

| Configuration | Cold Start | Coût/mois (100k req) | Usage recommandé |
|---------------|------------|---------------------|------------------|
| **128 MB / x86_64** | ~2s | $0.45 | Dev/test |
| **512 MB / arm64** ⭐ | ~400ms | $0.30 | Production |
| **1024 MB / arm64** | ~300ms | $0.60 | APIs intensives |

### 💡 Conseils d'optimisation

1. **Utilisez ARM64** : 20% moins cher et plus rapide
2. **Mémoire optimale** : 512 MB pour la plupart des APIs
3. **Compilation native** : Réduit drastiquement les cold starts
4. **Keep-alive** : Lambda garde les containers chauds

### 📈 Monitoring des coûts

```bash
# Vérification de la facturation
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

---

## 🐛 Troubleshooting

### Erreurs courantes

#### 1. "Image manifest not supported"

**Cause :** Build Docker incompatible

**Solution :**
```bash
# Utilisez buildx avec platform explicite
docker buildx build --load --platform linux/arm64 \
  -f src/main/docker/Dockerfile.native.lambda \
  -t mon-api:latest .
```

#### 2. "Cannot invoke String.hashCode() because name is null"

**Cause :** Mauvaise extension Lambda dans `pom.xml`

**Solution :** Vérifiez que vous utilisez `quarkus-amazon-lambda-http` (pas `-rest`)

#### 3. "AccessDenied" lors du push ECR

**Cause :** Permissions insuffisantes

**Solution :**
```bash
# Vérifiez vos permissions
aws iam get-user
aws ecr describe-repositories --region $AWS_REGION
```

#### 4. Cold start > 2 secondes

**Cause :** Configuration Lambda non optimisée

**Solution :**
- Augmentez la mémoire (512 MB minimum)
- Vérifiez l'architecture ARM64
- Vérifiez la compilation native

### 🔍 Debug avancé

```bash
# Logs détaillés de la fonction
aws logs filter-log-events \
  --log-group-name /aws/lambda/$FUNCTION_NAME \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --region $AWS_REGION

# Métriques de performance
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=$FUNCTION_NAME \
  --start-time $(date -d '1 hour ago' --iso-8601) \
  --end-time $(date --iso-8601) \
  --period 300 \
  --statistics Average,Maximum \
  --region $AWS_REGION

# Test local de l'image Docker
docker run --rm -p 9000:8080 mon-api:latest
curl -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{"rawPath":"/hello","requestContext":{"http":{"method":"GET","path":"/hello"}}}'
```

---

## 🗑️ Resource cleanup

### Function deletion

```bash
# Function URL deletion
aws lambda delete-function-url-config \
  --function-name $FUNCTION_NAME \
  --region $AWS_REGION

# Function deletion
aws lambda delete-function \
  --function-name $FUNCTION_NAME \
  --region $AWS_REGION

# IAM role deletion
aws iam detach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

aws iam delete-role --role-name $ROLE_NAME
```

### ECR repository deletion

```bash
# Delete all images
aws ecr batch-delete-image \
  --repository-name $REPO_NAME \
  --image-ids "$(aws ecr list-images --repository-name $REPO_NAME --query 'imageIds[*]' --output json)" \
  --region $AWS_REGION

# Delete repository
aws ecr delete-repository \
  --repository-name $REPO_NAME \
  --region $AWS_REGION
```

---

## 📚 Ressources supplémentaires

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [AWS Lambda Function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html)
- [Amazon ECR User Guide](https://docs.aws.amazon.com/ecr/)
- [Quarkus Native Deployment](https://quarkus.io/guides/deploying-to-aws-lambda)

---

**🎉 Congratulations! Your Quarkus API is now deployed on AWS Lambda.**