#!/bin/bash

# ============================================================================
# 🔨 QUARKUS NATIVE BUILD
# ============================================================================
# Script to compile only the native binary

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Loading configuration
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

NATIVE_DEBUG_ENABLED=${NATIVE_DEBUG_ENABLED:-"false"}
NATIVE_ENABLE_REPORTS=${NATIVE_ENABLE_REPORTS:-"false"}

log_info "🔨 Quarkus native compilation"
echo "Debug enabled    : $NATIVE_DEBUG_ENABLED"
echo "Reports enabled  : $NATIVE_ENABLE_REPORTS"
echo ""

./mvnw clean package -Pnative \
    -Dquarkus.native.container-build=true \
    -Dquarkus.native.debug.enabled="$NATIVE_DEBUG_ENABLED" \
    -Dquarkus.native.enable-reports="$NATIVE_ENABLE_REPORTS"

if [ -f target/*-runner ]; then
    BINARY_SIZE=$(du -h target/*-runner | cut -f1)
    log_success "Native build completed"
    echo "📦 Binary size: $BINARY_SIZE"
    echo "📁 Location: target/*-runner"
else
    log_error "Error during native build"
    exit 1
fi