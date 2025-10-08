#!/bin/bash

# ============================================================================
# 🔍 BOOTSTRAP PROJECT VERIFICATION
# ============================================================================
# This script verifies that the bootstrap transformation is complete

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

# Counters
CHECKS_TOTAL=0
CHECKS_PASSED=0
CHECKS_FAILED=0

# Verification function
check_file() {
    local file="$1"
    local description="$2"
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    if [ -f "$file" ]; then
        log_success "$description"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        log_error "$description (missing file: $file)"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

check_directory() {
    local dir="$1"
    local description="$2"
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    if [ -d "$dir" ]; then
        log_success "$description"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        log_error "$description (missing directory: $dir)"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

check_executable() {
    local file="$1"
    local description="$2"
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    if [ -f "$file" ] && [ -x "$file" ]; then
        log_success "$description"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        log_error "$description (not executable: $file)"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

# ============================================================================
# VERIFICATIONS
# ============================================================================

log_title "QUARKUS LAMBDA BOOTSTRAP PROJECT VERIFICATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# === CONFIGURATION FILES ===
log_info "📋 Verifying configuration files"
check_file ".env.template" "Runtime configuration template"
check_file ".env.init-template" "Initialization configuration template"
check_file "pom-template.xml" "Maven template"
check_file "src/main/resources/application-template.properties" "application.properties template"
check_file ".gitignore" "GitIgnore"
check_file ".gitignore.new-project" "GitIgnore for new projects"
echo ""

# === SCRIPTS ===
log_info "🔧 Verifying scripts"
check_directory "scripts" "Scripts directory"
check_executable "scripts/deploy.sh" "Complete deployment script"
check_executable "scripts/build-native.sh" "Native build script"
check_executable "init-project.sh" "Initialization script"
echo ""

# === DOCUMENTATION ===
log_info "📚 Verifying documentation"
check_directory "docs" "Documentation directory"
check_file "README-BOOTSTRAP.md" "Bootstrap README"
check_file "docs/API.md" "API documentation"
check_file "docs/ENDPOINTS.md" "Endpoints guide"
check_file "docs/DEPLOYMENT.md" "Deployment guide"
echo ""

# === CODE EXAMPLES ===
log_info "💻 Verifying code examples"
check_file "src/main/java/org/acme/GreetingResource.java" "Simple greeting endpoint"
echo ""

# === DOCKER CONFIGURATION ===
log_info "🐳 Verifying Docker"
check_file "src/main/docker/Dockerfile.native.lambda" "Lambda Dockerfile"
echo ""

# === MAVEN DEPENDENCIES ===
log_info "🔍 Verifying critical Maven dependencies"
if [ -f "pom.xml" ]; then
    if grep -q "quarkus-amazon-lambda-http" pom.xml; then
        log_success "Lambda HTTP dependency (correct)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "Lambda HTTP dependency missing"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    if grep -q "quarkus-rest-jackson" pom.xml; then
        log_success "Jackson dependency (JSON serialization)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "Jackson dependency missing"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    # Check for common error
    if grep -q "quarkus-amazon-lambda-rest" pom.xml; then
        log_warning "WARNING: 'quarkus-amazon-lambda-rest' dependency detected"
        echo "           For Function URL, use 'quarkus-amazon-lambda-http'"
    fi
else
    log_error "pom.xml not found"
    CHECKS_FAILED=$((CHECKS_FAILED + 2))
fi
# Note: The 2 Maven verifications are already counted in the functions above
echo ""

# === FUNCTIONAL VERIFICATIONS ===
log_info "⚙️  Verifying required tools"

# Java
if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -ge 21 ]; then
        log_success "Java $JAVA_VERSION (compatible)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "Java $JAVA_VERSION (required: 21+)"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    log_error "Java not installed"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

# Maven
if [ -f "./mvnw" ]; then
    log_success "Maven wrapper available"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "Maven wrapper missing"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

# Docker
if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        log_success "Docker functional"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "Docker not started"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    log_error "Docker not installed"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

# AWS CLI
if command -v aws >/dev/null 2>&1; then
    log_success "AWS CLI available"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    
    # Check AWS configuration
    if aws sts get-caller-identity >/dev/null 2>&1; then
        log_success "AWS CLI configured"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "AWS CLI not configured (run 'aws configure')"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    CHECKS_TOTAL=$((CHECKS_TOTAL + 2))  # 2 verifications: available + configured
else
    log_error "AWS CLI not installed"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))   # 1 verification only: not installed
fi
# Note: AWS verifications are already counted in the functions above
echo ""

# === SUMMARY ===
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_title "VERIFICATION SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Successful verifications : $CHECKS_PASSED"
echo "❌ Failed verifications     : $CHECKS_FAILED"
echo "📊 Total                    : $CHECKS_TOTAL"
echo ""

# Calculate percentage
if [ $CHECKS_TOTAL -gt 0 ]; then
    PERCENTAGE=$((CHECKS_PASSED * 100 / CHECKS_TOTAL))
    echo "📈 Success rate            : $PERCENTAGE%"
    echo ""
fi

# === RECOMMENDATIONS ===
if [ $CHECKS_FAILED -eq 0 ]; then
    log_success "🎉 BOOTSTRAP COMPLETE AND READY!"
    echo ""
    echo "Next steps:"
    echo "1️⃣  Fork this project"
    echo "2️⃣  Execute: ./init-project.sh \"My Project\" \"com.mycompany.api\""
    echo "3️⃣  Configure .env with your AWS parameters"
    echo "4️⃣  Deploy: ./scripts/deploy.sh"
    echo ""
else
    log_warning "🔧 INCOMPLETE BOOTSTRAP"
    echo ""
    echo "Recommended actions:"
    
    if [ $CHECKS_FAILED -gt 5 ]; then
        echo "❗ Multiple missing elements. Re-run the bootstrap transformation."
    else
        echo "🔧 Fix the missing elements listed above."
    fi
    
    echo ""
    echo "Tools to install/configure:"
    if ! command -v java >/dev/null 2>&1 || [ "$JAVA_VERSION" -lt 21 ]; then
        echo "  - Java 21+ : brew install openjdk@21"
    fi
    if ! command -v docker >/dev/null 2>&1; then
        echo "  - Docker : https://www.docker.com/products/docker-desktop"
    fi
    if ! command -v aws >/dev/null 2>&1; then
        echo "  - AWS CLI : brew install awscli"
        echo "  - Configuration : aws configure"
    fi
    echo ""
fi

# === ADDITIONAL INFORMATION ===
log_info "📋 System information"
echo "OS          : $(uname -s) $(uname -r)"
echo "Architecture: $(uname -m)"
if command -v java >/dev/null 2>&1; then
    echo "Java        : $(java -version 2>&1 | head -n 1)"
fi
if command -v docker >/dev/null 2>&1; then
    echo "Docker      : $(docker --version 2>/dev/null || echo 'Not available')"
fi
if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI     : $(aws --version 2>/dev/null | cut -d' ' -f1 || echo 'Not available')"
fi
echo ""

# === EXIT CODE ===
if [ $CHECKS_FAILED -eq 0 ]; then
    log_success "Verification completed successfully!"
    exit 0
else
    log_error "Verification completed with errors"
    exit 1
fi