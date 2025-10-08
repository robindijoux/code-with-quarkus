#!/bin/bash

# ============================================================================
# 🚀 QUARKUS LAMBDA BOOTSTRAP PROJECT INITIALIZATION
# ============================================================================
# This script transforms the bootstrap project into a new personalized project
#
# Usage: ./init-project.sh "My Project" "com.mycompany.api"

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_title() { echo -e "${CYAN}🎯 $1${NC}"; }

# ============================================================================
# PARAMETER VALIDATION
# ============================================================================

if [ $# -lt 2 ]; then
    echo ""
    log_title "QUARKUS LAMBDA BOOTSTRAP PROJECT INITIALIZATION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Usage: $0 \"Project Name\" \"java.package\" [aws-account-id]"
    echo ""
    echo "Examples:"
    echo "  $0 \"My E-commerce API\" \"com.mycompany.ecommerce\""
    echo "  $0 \"User Management API\" \"com.mycompany.users\" \"123456789012\""
    echo ""
    echo "Parameters:"
    echo "  1. Project name (use quotes if it contains spaces)"
    echo "  2. Java package (e.g.: com.mycompany.api)"
    echo "  3. AWS Account ID (optional, can be configured later)"
    echo ""
    exit 1
fi

PROJECT_NAME="$1"
JAVA_PACKAGE="$2"
AWS_ACCOUNT_ID="${3:-}"

# Java package validation
if [[ ! "$JAVA_PACKAGE" =~ ^[a-z]+(\.[a-z][a-z0-9]*)*$ ]]; then
    log_error "Invalid Java package: $JAVA_PACKAGE"
    echo "Expected format: com.mycompany.api (lowercase, dots as separators)"
    exit 1
fi

# Package decomposition
IFS='.' read -ra PACKAGE_PARTS <<< "$JAVA_PACKAGE"
MAVEN_GROUP_ID="${PACKAGE_PARTS[0]}.${PACKAGE_PARTS[1]}"
MAVEN_ARTIFACT_ID=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
JAVA_PACKAGE_PATH=${JAVA_PACKAGE//./\/}

# Generated derived names
LAMBDA_FUNCTION_NAME=$(echo "$PROJECT_NAME" | sed 's/ //g')
ECR_REPOSITORY_NAME=$(echo "$MAVEN_ARTIFACT_ID" | tr '[:upper:]' '[:lower:]')

# ============================================================================
# CONFIGURATION DISPLAY
# ============================================================================

log_title "NEW PROJECT CONFIGURATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Project name          : $PROJECT_NAME"
echo "🏷️  Java package          : $JAVA_PACKAGE"
echo "📁 Package path          : src/main/java/$JAVA_PACKAGE_PATH"
echo "🔧 Maven Group ID        : $MAVEN_GROUP_ID"
echo "🔧 Maven Artifact ID     : $MAVEN_ARTIFACT_ID"
echo "☁️  Lambda Function       : $LAMBDA_FUNCTION_NAME"
echo "📦 ECR Repository        : $ECR_REPOSITORY_NAME"
if [ -n "$AWS_ACCOUNT_ID" ]; then
echo "🌍 AWS Account           : $AWS_ACCOUNT_ID"
fi
echo ""

read -p "Continue with this configuration? (y/N) " -r
if [[ ! $REPLY =~ ^[YyOo]$ ]]; then
    log_warning "Initialization cancelled"
    exit 0
fi

# ============================================================================
# STEP 1: CREATE .ENV FILE FROM TEMPLATE
# ============================================================================
log_info "📝 STEP 1/6: Creating .env file"

# Check that template exists
if [ ! -f ".env.template" ]; then
    log_error ".env.template file not found"
    exit 1
fi

# Copy template and replace variables
log_info "Copying .env template..."
cp .env.template .env

# Replace placeholders
log_info "Configuring project-specific variables..."
sed -i.bak "s/__PROJECT_NAME__/$PROJECT_NAME/g" .env
sed -i.bak "s/__PROJECT_VERSION__/1.0.0-SNAPSHOT/g" .env
sed -i.bak "s/__PROJECT_ARTIFACT_ID__/$MAVEN_ARTIFACT_ID/g" .env

# Remove backup file
rm -f .env.bak

# Configure AWS account if provided
if [ -n "$AWS_ACCOUNT_ID" ]; then
    log_info "Configuring AWS account..."
    sed -i.bak "s/AWS_ACCOUNT_ID=\"\"/AWS_ACCOUNT_ID=\"$AWS_ACCOUNT_ID\"/g" .env
    rm -f .env.bak
fi

log_success "✅ .env file created and configured"

# ============================================================================
# STEP 2: POM.XML UPDATE
# ============================================================================
log_info "🔧 STEP 2/6: Updating pom.xml"

if [ -f "pom-template.xml" ]; then
    # Using parameterizable template
    cp pom-template.xml pom.xml
    
    # Variable replacement in pom.xml
    sed -i.bak "s/\${MAVEN_GROUP_ID:org.acme}/$MAVEN_GROUP_ID/g" pom.xml
    sed -i.bak "s/\${MAVEN_ARTIFACT_ID:quarkus-lambda-bootstrap}/$MAVEN_ARTIFACT_ID/g" pom.xml
    sed -i.bak "s/\${PROJECT_VERSION:1.0.0-SNAPSHOT}/1.0.0-SNAPSHOT/g" pom.xml
    sed -i.bak "s/\${PROJECT_NAME:Quarkus Lambda Bootstrap}/$PROJECT_NAME/g" pom.xml
    sed -i.bak "s/\${PROJECT_DESCRIPTION:Bootstrap project for Quarkus Lambda APIs}/Native Quarkus REST API for AWS Lambda/g" pom.xml
    
    rm pom.xml.bak
else
    # Updating existing pom.xml
    sed -i.bak "s/<groupId>org\.acme<\/groupId>/<groupId>$MAVEN_GROUP_ID<\/groupId>/g" pom.xml
    sed -i.bak "s/<artifactId>code-with-quarkus<\/artifactId>/<artifactId>$MAVEN_ARTIFACT_ID<\/artifactId>/g" pom.xml
    rm pom.xml.bak
fi

log_success "pom.xml updated"

# ============================================================================
# STEP 3: PACKAGE STRUCTURE CREATION
# ============================================================================
log_info "📁 STEP 3/6: Creating package structure"

# Creating directories
NEW_PACKAGE_DIR="src/main/java/$JAVA_PACKAGE_PATH"
mkdir -p "$NEW_PACKAGE_DIR"/{resource,model,service,exception}

# Creating test directories
NEW_TEST_PACKAGE_DIR="src/test/java/$JAVA_PACKAGE_PATH"
mkdir -p "$NEW_TEST_PACKAGE_DIR"/{resource,service}

log_success "Package structure created"

# ============================================================================
# STEP 4: SOURCE FILES MIGRATION
# ============================================================================
log_info "🔄 STEP 4/6: Migrating source files"

# Copy and adapt examples to the new package
if [ -f "src/main/java/org/acme/GreetingResource.java" ]; then
    # Adapting GreetingResource
    sed "s/package org.acme;/package $JAVA_PACKAGE.resource;/" \
        src/main/java/org/acme/GreetingResource.java > "$NEW_PACKAGE_DIR/resource/GreetingResource.java"
fi

# Test migration
if [ -f "src/test/java/org/acme/GreetingResourceTest.java" ]; then
    sed "s/package org.acme;/package $JAVA_PACKAGE.resource;/" \
        src/test/java/org/acme/GreetingResourceTest.java > "$NEW_TEST_PACKAGE_DIR/resource/GreetingResourceTest.java"
fi

log_success "Source files migrated"

# ============================================================================
# STEP 5: APPLICATION.PROPERTIES UPDATE
# ============================================================================
log_info "⚙️  STEP 5/6: Updating application.properties"

if [ -f "src/main/resources/application-template.properties" ]; then
    cp src/main/resources/application-template.properties src/main/resources/application.properties
    
    # Variable replacement
    sed -i.bak "s/\${PROJECT_NAME:quarkus-lambda-bootstrap}/$MAVEN_ARTIFACT_ID/g" src/main/resources/application.properties
    sed -i.bak "s/\${PROJECT_VERSION:1.0.0-SNAPSHOT}/1.0.0-SNAPSHOT/g" src/main/resources/application.properties
    
    rm src/main/resources/application.properties.bak
else
    # Creating a basic application.properties
    cat > src/main/resources/application.properties << EOF
# Configuration $PROJECT_NAME
quarkus.application.name=$MAVEN_ARTIFACT_ID
quarkus.application.version=1.0.0-SNAPSHOT

# AWS Lambda Configuration
quarkus.lambda.handler=io.quarkus.amazon.lambda.http.LambdaHttpHandler

# Logging
quarkus.log.level=INFO
%dev.quarkus.log.level=DEBUG
EOF
fi

log_success "application.properties updated"

# ============================================================================
# STEP 6: CLEANUP AND FINALIZATION
# ============================================================================
log_info "🧹 STEP 6/6: Cleanup and finalization"

# Remove old packages
if [ -d "src/main/java/org/acme" ] && [ "$JAVA_PACKAGE" != "org.acme" ]; then
    rm -rf src/main/java/org/acme
fi

if [ -d "src/test/java/org/acme" ] && [ "$JAVA_PACKAGE" != "org.acme" ]; then
    rm -rf src/test/java/org/acme
fi

# Remove template files
rm -f pom-template.xml
rm -f src/main/resources/application-template.properties
rm -f .env.template
rm -f .env.init-template

# Update .gitignore for the new project
log_info "Updating .gitignore..."
if [ -f ".gitignore.new-project" ]; then
    mv .gitignore.new-project .gitignore
    log_success "✅ .gitignore updated for the new project"
else
    log_warning "⚠️  File .gitignore.new-project not found"
fi

# Remove bootstrap files (after transformation)
log_info "Removing bootstrap files..."
rm -f README-BOOTSTRAP.md
rm -f verify-bootstrap.sh
# Note: we keep init-project.sh so the user can see how it was configured
# They can delete it manually if they want

log_success "✅ Project successfully transformed"

# Creating personalized README
cat > README.md << EOF
# 🚀 $PROJECT_NAME

Native Quarkus REST API deployed on AWS Lambda with Function URL.

## 🏗️ Architecture

This API uses:
- **Quarkus** for the REST framework
- **Native compilation** with GraalVM (cold start < 500ms)
- **AWS Lambda** with Function URL
- **ARM64 architecture** for performance

## 🚀 Quick start

### Local development
\`\`\`bash
# Development mode
./mvnw quarkus:dev

# Tests
./mvnw test
\`\`\`

### AWS deployment
\`\`\`bash
# Configuration (first time)
cp .env.template .env
# Edit .env with your AWS parameters

# Complete deployment
./scripts/deploy.sh
\`\`\`

## 📋 Available endpoints

| Endpoint | Method | Description |
|----------|---------|-------------|
| \`/hello\` | GET | Welcome message |
| \`/hello\` | GET | Simple greeting |
| \`/q/health\` | GET | Health check endpoint |

## 🔧 Configuration

Main variables in \`.env\`:
- \`AWS_ACCOUNT_ID\`: Your AWS account
- \`AWS_REGION\`: Deployment region (default: eu-west-3)
- \`LAMBDA_FUNCTION_NAME\`: Lambda function name
- \`ECR_REPOSITORY_NAME\`: ECR repository for the image

## 📚 Documentation

- [Deployment guide](docs/DEPLOYMENT.md)
- [API documentation](docs/API.md)
- [Adding endpoints](docs/ENDPOINTS.md)

---

**Generated with Quarkus Lambda bootstrap on $(date)**
EOF

log_success "Project cleaned and finalized"

# ============================================================================
# FINAL SUMMARY
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "🎉 INITIALIZATION COMPLETED SUCCESSFULLY!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Project configured     : $PROJECT_NAME"
echo "✅ Java package          : $JAVA_PACKAGE"
echo "✅ Structure created     : src/main/java/$JAVA_PACKAGE_PATH"
echo "✅ Configuration         : .env"
echo "✅ Deployment scripts    : scripts/"
echo ""
log_title "NEXT STEPS:"
echo ""
echo "1️⃣  Configure your AWS account in .env:"
echo "   AWS_ACCOUNT_ID=\"your-account-id\""
echo ""
echo "2️⃣  Test locally:"
echo "   ./mvnw quarkus:dev"
echo ""
echo "3️⃣  Deploy to AWS:"
echo "   ./scripts/deploy.sh"
echo ""
echo "4️⃣  Add your endpoints in:"
echo "   src/main/java/$JAVA_PACKAGE_PATH/resource/"
echo ""
echo "📚 Complete documentation in README.md"
echo ""
log_success "Happy coding! 🚀"