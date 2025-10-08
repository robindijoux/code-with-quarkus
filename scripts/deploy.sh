#!/bin/bash

# ============================================================================
# 🚀 QUARKUS CONTAINER BUILD & ECR DEPLOYMENT
# ============================================================================
# This script performs:
# 1. Native build
# 2. Docker build 
# 3. Push to ECR

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
if [ -f ".env.deployment" ]; then
    log_info "Loading deployment configuration from .env.deployment"
    set -a
    source .env.deployment
    set +a
else
    log_error ".env.deployment file not found. Create .env.deployment with deployment configuration."
    exit 1
fi

# Required variables with default values
PROJECT_NAME=${PROJECT_NAME:-"quarkus-container-api"}
AWS_REGION=${AWS_REGION:-"eu-west-3"}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-""}

# Sanitize names for Docker/ECR compatibility AFTER loading .env
# Docker repository names must be lowercase and contain only: a-z, 0-9, -, _, .
ECR_REPOSITORY_NAME=$(echo "${ECR_REPOSITORY_NAME:-$PROJECT_NAME}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

IMAGE_TAG=${IMAGE_TAG:-"latest"}
DOCKER_PLATFORM=${DOCKER_PLATFORM:-"linux/arm64"}

# Validation of required variables
if [ -z "$AWS_ACCOUNT_ID" ]; then
    log_error "AWS_ACCOUNT_ID must be defined in .env"
    exit 1
fi

# Validate ECR repository name format
if [[ ! "$ECR_REPOSITORY_NAME" =~ ^[a-z0-9._-]+$ ]]; then
    log_error "ECR repository name contains invalid characters: $ECR_REPOSITORY_NAME"
    log_info "ECR names must contain only: lowercase letters, numbers, dots, hyphens, underscores"
    exit 1
fi

# Building ECR URI
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_URI="${ECR_URI}/${ECR_REPOSITORY_NAME}:${IMAGE_TAG}"

log_info "=== CONFIGURATION ==="
echo "Project         : $PROJECT_NAME"
echo "AWS Region      : $AWS_REGION"
echo "ECR Repository  : $ECR_REPOSITORY_NAME"
echo "Docker Platform : $DOCKER_PLATFORM"
echo "Image Tag       : $IMAGE_TAG"
echo "Image URI       : $IMAGE_URI"
if [ "$ECR_REPOSITORY_NAME" != "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')" ]; then
    log_info "ℹ️  Repository name was sanitized for Docker compatibility"
fi
echo ""

# ============================================================================
# STEP 1: NATIVE BUILD
# ============================================================================
log_info "🔨 STEP 1/3: Quarkus native build"

if ! command -v ./mvnw >/dev/null 2>&1; then
    log_error "Maven wrapper (./mvnw) not found"
    exit 1
fi

./mvnw clean package -Pnative \
    -Dquarkus.native.container-build=true \
    -Dquarkus.native.debug.enabled=false \
    -Dquarkus.native.enable-reports=false

# Check if native binary was created
NATIVE_BINARY=$(find target -name "*-runner" -type f 2>/dev/null | head -1)
if [ -z "$NATIVE_BINARY" ]; then
    log_error "Native binary not found in target/"
    log_info "Available files in target/:"
    ls -la target/ 2>/dev/null || echo "target/ directory not found"
    exit 1
fi

log_success "Native build completed: $NATIVE_BINARY"

# ============================================================================
# STEP 2: DOCKER BUILD
# ============================================================================
log_info "🐳 STEP 2/3: Docker image build"

if [ ! -f "src/main/docker/Dockerfile.native.lambda" ]; then
    log_error "Dockerfile.native.lambda not found"
    exit 1
fi

# Build with specific platform
docker buildx build \
    --load \
    --platform "$DOCKER_PLATFORM" \
    -f src/main/docker/Dockerfile.native.lambda \
    -t "${ECR_REPOSITORY_NAME}:${IMAGE_TAG}" \
    .

log_success "Docker image created: ${ECR_REPOSITORY_NAME}:${IMAGE_TAG}"

# ============================================================================
# STEP 3: ECR DEPLOYMENT
# ============================================================================
log_info "📦 STEP 3/3: ECR deployment"

# ECR login
log_info "Logging into ECR..."
TOKEN=$(aws ecr get-login-password --region "$AWS_REGION")
if [ -z "$TOKEN" ]; then
    log_error "Failed to get ECR login token"
    exit 1
fi
echo "$TOKEN" | docker login --username AWS --password-stdin $ECR_URI

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

# ECR login (for push)
log_info "Connecting to ECR for push..."
aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin "$ECR_URI"

# Tag and push
docker tag "${ECR_REPOSITORY_NAME}:${IMAGE_TAG}" "$IMAGE_URI"
docker push "$IMAGE_URI"

log_success "Image pushed to ECR: $IMAGE_URI"

# ============================================================================
# DEPLOYMENT SUMMARY
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "🎉 ECR DEPLOYMENT SUCCESSFUL!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 ECR Image            : $IMAGE_URI"
echo "🏗️  Docker Platform     : $DOCKER_PLATFORM"
echo "🌍 Region               : $AWS_REGION"
echo "🏷️  Tag                 : $IMAGE_TAG"
echo ""
echo "💡 Next steps:"
echo "- Use this image in your container orchestration platform"
echo "- Deploy to ECS, EKS, or other container services"
echo "- Pull the image: docker pull $IMAGE_URI"
echo ""

log_success "Container deployment completed successfully!"