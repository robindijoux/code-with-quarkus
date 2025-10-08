#!/bin/bash

# ============================================================================
# 🚀 COMPLETE QUARKUS LAMBDA DEPLOYMENT
# ============================================================================
# This script performs a complete deployment:
# 1. Native build
# 2. Docker build 
# 3. Push to ECR
# 4. Lambda creation/update
# 5. Function URL configuration

set -euo pipefail

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Loading configuration
if [ -f ".env" ]; then
    log_info "Loading configuration from .env"
    export $(grep -v '^#' .env | xargs)
else
    log_error ".env file not found. Copy .env.template to .env and configure it."
    exit 1
fi

# Required variables with default values
PROJECT_NAME=${PROJECT_NAME:-"quarkus-lambda-api"}
AWS_REGION=${AWS_REGION:-"eu-west-3"}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-""}
ECR_REPOSITORY_NAME=${ECR_REPOSITORY_NAME:-"$PROJECT_NAME"}
LAMBDA_FUNCTION_NAME=${LAMBDA_FUNCTION_NAME:-"$PROJECT_NAME"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
LAMBDA_ARCHITECTURE=${LAMBDA_ARCHITECTURE:-"arm64"}
LAMBDA_MEMORY=${LAMBDA_MEMORY:-"512"}
LAMBDA_TIMEOUT=${LAMBDA_TIMEOUT:-"30"}

# Validation of required variables
if [ -z "$AWS_ACCOUNT_ID" ]; then
    log_error "AWS_ACCOUNT_ID must be defined in .env"
    exit 1
fi

# Building ECR URI
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_URI="${ECR_URI}/${ECR_REPOSITORY_NAME}:${IMAGE_TAG}"

log_info "=== CONFIGURATION ==="
echo "Project         : $PROJECT_NAME"
echo "AWS Region      : $AWS_REGION"
echo "ECR Repository  : $ECR_REPOSITORY_NAME"
echo "Lambda Function : $LAMBDA_FUNCTION_NAME"
echo "Architecture    : $LAMBDA_ARCHITECTURE"
echo "Image URI       : $IMAGE_URI"
echo ""

# ============================================================================
# STEP 1: NATIVE BUILD
# ============================================================================
log_info "🔨 STEP 1/5: Quarkus native build"

if ! command -v ./mvnw >/dev/null 2>&1; then
    log_error "Maven wrapper (./mvnw) not found"
    exit 1
fi

./mvnw clean package -Pnative \
    -Dquarkus.native.container-build=true \
    -Dquarkus.native.debug.enabled=false \
    -Dquarkus.native.enable-reports=false

if [ ! -f "target/*-runner" ]; then
    log_error "Native binary not found in target/"
    exit 1
fi

log_success "Native build completed"

# ============================================================================
# STEP 2: DOCKER BUILD
# ============================================================================
log_info "🐳 STEP 2/5: Docker image build"

if [ ! -f "src/main/docker/Dockerfile.native.lambda" ]; then
    log_error "Dockerfile.native.lambda not found"
    exit 1
fi

# Build with specific platform
docker buildx build \
    --load \
    --platform "linux/${LAMBDA_ARCHITECTURE}" \
    -f src/main/docker/Dockerfile.native.lambda \
    -t "${ECR_REPOSITORY_NAME}:${IMAGE_TAG}" \
    .

log_success "Docker image created: ${ECR_REPOSITORY_NAME}:${IMAGE_TAG}"

# ============================================================================
# STEP 3: ECR VERIFICATION
# ============================================================================
log_info "📦 STEP 3/5: ECR repository verification"

# Check if repository exists
if ! aws ecr describe-repositories \
    --repository-names "$ECR_REPOSITORY_NAME" \
    --region "$AWS_REGION" >/dev/null 2>&1; then
    
    log_warning "ECR repository '$ECR_REPOSITORY_NAME' not found. Creating..."
    
    aws ecr create-repository \
        --repository-name "$ECR_REPOSITORY_NAME" \
        --region "$AWS_REGION" \
        --image-scanning-configuration scanOnPush=true
    
    log_success "ECR repository created"
else
    log_success "ECR repository already exists"
fi

# ============================================================================
# STEP 4: PUSH TO ECR
# ============================================================================
log_info "⬆️  STEP 4/5: Push to ECR"

# ECR login
log_info "Connecting to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin "$ECR_URI"

# Tag and push
docker tag "${ECR_REPOSITORY_NAME}:${IMAGE_TAG}" "$IMAGE_URI"
docker push "$IMAGE_URI"

log_success "Image pushed to ECR: $IMAGE_URI"

# ============================================================================
# STEP 5: LAMBDA DEPLOYMENT
# ============================================================================
log_info "☁️  STEP 5/5: Lambda deployment"

# Check if function exists
if aws lambda get-function \
    --function-name "$LAMBDA_FUNCTION_NAME" \
    --region "$AWS_REGION" >/dev/null 2>&1; then
    
    log_info "Updating existing function..."
    
    # Update code
    aws lambda update-function-code \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --image-uri "$IMAGE_URI" \
        --region "$AWS_REGION"
    
    # Update configuration
    aws lambda update-function-configuration \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --memory-size "$LAMBDA_MEMORY" \
        --timeout "$LAMBDA_TIMEOUT" \
        --region "$AWS_REGION"
    
    log_success "Lambda function updated"
    
else
    log_info "Creating new Lambda function..."
    
    # Create IAM role if needed
    ROLE_NAME="${LAMBDA_FUNCTION_NAME}-execution-role"
    ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
    
    if ! aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
        log_info "Creating IAM role..."
        
        # Trust policy for Lambda
        cat > /tmp/trust-policy.json << EOF
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
        
        aws iam create-role \
            --role-name "$ROLE_NAME" \
            --assume-role-policy-document file:///tmp/trust-policy.json
        
        # Attach basic Lambda policy
        aws iam attach-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        
        log_success "IAM role created"
        
        # Wait for role to be available
        sleep 10
    fi
    
    # Create function
    aws lambda create-function \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --role "$ROLE_ARN" \
        --code ImageUri="$IMAGE_URI" \
        --package-type Image \
        --architectures "$LAMBDA_ARCHITECTURE" \
        --memory-size "$LAMBDA_MEMORY" \
        --timeout "$LAMBDA_TIMEOUT" \
        --region "$AWS_REGION"
    
    log_success "Lambda function created"
fi

# ============================================================================
# FUNCTION URL CONFIGURATION
# ============================================================================
log_info "🔗 Function URL configuration"

# Check if Function URL exists
FUNCTION_URL=$(aws lambda get-function-url-config \
    --function-name "$LAMBDA_FUNCTION_NAME" \
    --region "$AWS_REGION" \
    --query 'FunctionUrl' \
    --output text 2>/dev/null || echo "None")

if [ "$FUNCTION_URL" = "None" ]; then
    log_info "Creating Function URL..."
    
    FUNCTION_URL=$(aws lambda create-function-url-config \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --region "$AWS_REGION" \
        --auth-type NONE \
        --cors "AllowOrigins=*,AllowMethods=GET\\,POST\\,PUT\\,DELETE\\,OPTIONS,AllowHeaders=*,MaxAge=86400" \
        --query 'FunctionUrl' \
        --output text)
    
    log_success "Function URL created"
else
    log_success "Function URL already exists"
fi

# ============================================================================
# DEPLOYMENT SUMMARY
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "🎉 DEPLOYMENT SUCCESSFUL!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Your API URL          : $FUNCTION_URL"
echo "📊 Lambda Function       : $LAMBDA_FUNCTION_NAME"
echo "🏗️  Architecture         : $LAMBDA_ARCHITECTURE"
echo "💾 Memory               : ${LAMBDA_MEMORY} MB"
echo "⏱️  Timeout              : ${LAMBDA_TIMEOUT}s"
echo "📦 ECR Image            : $IMAGE_URI"
echo "🌍 Region               : $AWS_REGION"
echo ""
echo "🧪 Basic tests:"
echo "curl $FUNCTION_URL/hello"
echo "curl $FUNCTION_URL/car"
echo ""
echo "📋 Real-time logs:"
echo "aws logs tail /aws/lambda/$LAMBDA_FUNCTION_NAME --region $AWS_REGION --follow"
echo ""

# Save URL to .env
if [ -f ".env" ] && ! grep -q "LAMBDA_FUNCTION_URL=" .env; then
    echo "LAMBDA_FUNCTION_URL=\"$FUNCTION_URL\"" >> .env
    log_info "URL saved to .env"
fi

log_success "Deployment completed successfully!"