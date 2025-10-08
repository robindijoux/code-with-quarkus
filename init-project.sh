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

# === CONFIGURATION AWS ===
AWS_REGION="eu-west-3"
AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"
ECR_REPOSITORY_NAME="$ECR_REPOSITORY_NAME"
LAMBDA_FUNCTION_NAME="$LAMBDA_FUNCTION_NAME"

# === CONFIGURATION BUILD ===
IMAGE_TAG="latest"
LAMBDA_ARCHITECTURE="arm64"
LAMBDA_MEMORY="512"
LAMBDA_TIMEOUT="30"

# === CONFIGURATION URLS (généré automatiquement) ===
# Sera rempli après le premier déploiement
LAMBDA_FUNCTION_URL=""

# === CONFIGURATION CORS ===
CORS_ALLOW_ORIGINS="*"
CORS_ALLOW_METHODS="GET,POST,PUT,DELETE,OPTIONS"
CORS_ALLOW_HEADERS="*"
CORS_MAX_AGE="86400"

# === CONFIGURATION LOGGING ===
LOG_LEVEL="INFO"
DEBUG_MODE="false"

# === CONFIGURATION NATIVE BUILD ===
NATIVE_DEBUG_ENABLED="false"
NATIVE_ENABLE_REPORTS="false"
NATIVE_ADDITIONAL_BUILD_ARGS="-H:+UnlockExperimentalVMOptions,-H:+UseG1GC,-H:MaxRAMPercentage=80"
EOF

log_success "✅ Fichier .env créé et configuré"

# ============================================================================
# ÉTAPE 2 : TRANSFORMATION DU POM.XML
# ============================================================================

# ============================================================================
# ÉTAPE 2 : MISE À JOUR DU POM.XML
# ============================================================================
log_info "🔧 ÉTAPE 2/6 : Mise à jour du pom.xml"

if [ -f "pom-template.xml" ]; then
    # Utilisation du template paramétrable
    cp pom-template.xml pom.xml
    
    # Remplacement des variables dans le pom.xml
    sed -i.bak "s/\${MAVEN_GROUP_ID:org.acme}/$MAVEN_GROUP_ID/g" pom.xml
    sed -i.bak "s/\${MAVEN_ARTIFACT_ID:quarkus-lambda-bootstrap}/$MAVEN_ARTIFACT_ID/g" pom.xml
    sed -i.bak "s/\${PROJECT_VERSION:1.0.0-SNAPSHOT}/1.0.0-SNAPSHOT/g" pom.xml
    sed -i.bak "s/\${PROJECT_NAME:Quarkus Lambda Bootstrap}/$PROJECT_NAME/g" pom.xml
    sed -i.bak "s/\${PROJECT_DESCRIPTION:Bootstrap project for Quarkus Lambda APIs}/API REST Quarkus native pour AWS Lambda/g" pom.xml
    
    rm pom.xml.bak
else
    # Mise à jour du pom.xml existant
    sed -i.bak "s/<groupId>org\.acme<\/groupId>/<groupId>$MAVEN_GROUP_ID<\/groupId>/g" pom.xml
    sed -i.bak "s/<artifactId>code-with-quarkus<\/artifactId>/<artifactId>$MAVEN_ARTIFACT_ID<\/artifactId>/g" pom.xml
    rm pom.xml.bak
fi

log_success "pom.xml mis à jour"

# ============================================================================
# ÉTAPE 3 : CRÉATION DE LA STRUCTURE DE PACKAGES
# ============================================================================
log_info "📁 ÉTAPE 3/6 : Création de la structure de packages"

# Création des répertoires
NEW_PACKAGE_DIR="src/main/java/$JAVA_PACKAGE_PATH"
mkdir -p "$NEW_PACKAGE_DIR"/{resource,model,service,exception}

# Création des répertoires de test
NEW_TEST_PACKAGE_DIR="src/test/java/$JAVA_PACKAGE_PATH"
mkdir -p "$NEW_TEST_PACKAGE_DIR"/{resource,service}

log_success "Structure de packages créée"

# ============================================================================
# ÉTAPE 4 : MIGRATION DES FICHIERS SOURCES
# ============================================================================
log_info "🔄 ÉTAPE 4/6 : Migration des fichiers sources"

# Copie et adaptation des exemples vers le nouveau package
if [ -f "src/main/java/org/acme/GreetingResource.java" ]; then
    # Adaptation du GreetingResource
    sed "s/package org.acme;/package $JAVA_PACKAGE.resource;/" \
        src/main/java/org/acme/GreetingResource.java > "$NEW_PACKAGE_DIR/resource/GreetingResource.java"
fi

if [ -f "src/main/java/org/acme/CarResource.java" ]; then
    # Adaptation du CarResource
    sed "s/package org.acme;/package $JAVA_PACKAGE.resource;/" \
        src/main/java/org/acme/CarResource.java > "$NEW_PACKAGE_DIR/resource/CarResource.java"
fi

# Copie du template d'endpoint
if [ -f "src/main/java/org/acme/template/TemplateResource.java" ]; then
    sed "s/package org.acme.template;/package $JAVA_PACKAGE.resource;/" \
        src/main/java/org/acme/template/TemplateResource.java > "$NEW_PACKAGE_DIR/resource/TemplateResource.java"
fi

# Copie des exemples avancés
if [ -f "src/main/java/org/acme/examples/ExamplesResource.java" ]; then
    sed "s/package org.acme.examples;/package $JAVA_PACKAGE.resource;/" \
        src/main/java/org/acme/examples/ExamplesResource.java > "$NEW_PACKAGE_DIR/resource/ExamplesResource.java"
fi

# Migration des tests
if [ -f "src/test/java/org/acme/GreetingResourceTest.java" ]; then
    sed "s/package org.acme;/package $JAVA_PACKAGE.resource;/" \
        src/test/java/org/acme/GreetingResourceTest.java > "$NEW_TEST_PACKAGE_DIR/resource/GreetingResourceTest.java"
fi

if [ -f "src/test/java/org/acme/CarResourceTest.java" ]; then
    sed "s/package org.acme;/package $JAVA_PACKAGE.resource;/" \
        src/test/java/org/acme/CarResourceTest.java > "$NEW_TEST_PACKAGE_DIR/resource/CarResourceTest.java"
fi

log_success "Fichiers sources migrés"

# ============================================================================
# ÉTAPE 5 : MISE À JOUR DE APPLICATION.PROPERTIES
# ============================================================================
log_info "⚙️  ÉTAPE 5/6 : Mise à jour de application.properties"

if [ -f "src/main/resources/application-template.properties" ]; then
    cp src/main/resources/application-template.properties src/main/resources/application.properties
    
    # Remplacement des variables
    sed -i.bak "s/\${PROJECT_NAME:quarkus-lambda-bootstrap}/$MAVEN_ARTIFACT_ID/g" src/main/resources/application.properties
    sed -i.bak "s/\${PROJECT_VERSION:1.0.0-SNAPSHOT}/1.0.0-SNAPSHOT/g" src/main/resources/application.properties
    
    rm src/main/resources/application.properties.bak
else
    # Création d'un application.properties basique
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

log_success "application.properties mis à jour"

# ============================================================================
# ÉTAPE 6 : NETTOYAGE ET FINALISATION
# ============================================================================
log_info "🧹 ÉTAPE 6/6 : Nettoyage et finalisation"

# Suppression des anciens packages
if [ -d "src/main/java/org/acme" ] && [ "$JAVA_PACKAGE" != "org.acme" ]; then
    rm -rf src/main/java/org/acme
fi

if [ -d "src/test/java/org/acme" ] && [ "$JAVA_PACKAGE" != "org.acme" ]; then
    rm -rf src/test/java/org/acme
fi

# Suppression des fichiers template
rm -f pom-template.xml
rm -f src/main/resources/application-template.properties
rm -f .env.template
rm -f .env.init-template

# Mise à jour du .gitignore pour le nouveau projet
log_info "Mise à jour du .gitignore..."
if [ -f ".gitignore.new-project" ]; then
    mv .gitignore.new-project .gitignore
    log_success "✅ .gitignore mis à jour pour le nouveau projet"
else
    log_warning "⚠️  Fichier .gitignore.new-project non trouvé"
fi

# Suppression des fichiers bootstrap (après transformation)
log_info "Suppression des fichiers bootstrap..."
rm -f README-BOOTSTRAP.md
rm -f verify-bootstrap.sh
# Note: on garde init-project.sh pour que l'utilisateur puisse voir comment il a été configuré
# Il peut le supprimer manuellement s'il le souhaite

log_success "✅ Projet transformé avec succès"

# Création du README personnalisé
cat > README.md << EOF
# 🚀 $PROJECT_NAME

API REST Quarkus native déployée sur AWS Lambda avec Function URL.

## 🏗️ Architecture

Cette API utilise :
- **Quarkus** pour le framework REST
- **Compilation native** avec GraalVM (cold start < 500ms)
- **AWS Lambda** avec Function URL
- **Architecture ARM64** pour les performances

## 🚀 Démarrage rapide

### Développement local
\`\`\`bash
# Mode développement
./mvnw quarkus:dev

# Tests
./mvnw test
\`\`\`

### Déploiement sur AWS
\`\`\`bash
# Configuration (première fois)
cp .env.template .env
# Éditez .env avec vos paramètres AWS

# Déploiement complet
./scripts/deploy.sh
\`\`\`

## 📋 Endpoints disponibles

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| \`/hello\` | GET | Message de bienvenue |
| \`/car\` | GET, POST | Gestion des voitures (exemple) |
| \`/template\` | GET, POST, PUT, DELETE | Template d'endpoint CRUD |
| \`/examples/*\` | Variées | Exemples d'endpoints avancés |

## 🔧 Configuration

Principales variables dans \`.env\` :
- \`AWS_ACCOUNT_ID\` : Votre compte AWS
- \`AWS_REGION\` : Région de déploiement (défaut: eu-west-3)
- \`LAMBDA_FUNCTION_NAME\` : Nom de la fonction Lambda
- \`ECR_REPOSITORY_NAME\` : Repository ECR pour l'image

## 📚 Documentation

- [Guide de déploiement](docs/DEPLOYMENT.md)
- [Documentation API](docs/API.md)
- [Ajout d'endpoints](docs/ENDPOINTS.md)

---

**Généré avec le bootstrap Quarkus Lambda le $(date)**
EOF

log_success "Projet nettoyé et finalisé"

# ============================================================================
# RÉSUMÉ FINAL
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "🎉 INITIALISATION TERMINÉE AVEC SUCCÈS !"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Projet configuré      : $PROJECT_NAME"
echo "✅ Package Java          : $JAVA_PACKAGE"
echo "✅ Structure créée       : src/main/java/$JAVA_PACKAGE_PATH"
echo "✅ Configuration         : .env"
echo "✅ Scripts de déploiement : scripts/"
echo ""
log_title "PROCHAINES ÉTAPES :"
echo ""
echo "1️⃣  Configurez votre compte AWS dans .env :"
echo "   AWS_ACCOUNT_ID=\"votre-compte-id\""
echo ""
echo "2️⃣  Testez en local :"
echo "   ./mvnw quarkus:dev"
echo ""
echo "3️⃣  Déployez sur AWS :"
echo "   ./scripts/deploy.sh"
echo ""
echo "4️⃣  Ajoutez vos endpoints dans :"
echo "   src/main/java/$JAVA_PACKAGE_PATH/resource/"
echo ""
echo "📚 Documentation complète dans README.md"
echo ""
log_success "Bon développement ! 🚀"