# 📋 Environment Variables Guide

This guide explains the **clear separation** between initialization variables and runtime variables.

## 🗂️ New Organization (separated)

### 1. 🔧 **Initialization variables** (`.env.init-template`)
**Usage**: Used ONLY by `init-project.sh`, then deleted
**Content**: Configuration of the new project to create

```bash
PROJECT_NAME="my-awesome-project"         # Project name
PROJECT_PACKAGE="com.mycompany.api"       # Java package
MAVEN_GROUP_ID="com.mycompany"            # Maven Group ID
MAVEN_ARTIFACT_ID="my-quarkus-api"        # Maven Artifact ID

# Default values for runtime
DEFAULT_AWS_REGION="eu-west-3"
DEFAULT_LAMBDA_MEMORY="512"
# etc...
```

### 2. 🐳 **Runtime variables** (`.env.template`)
**Usage**: Present in the final project, used by the Quarkus container
**Content**: Configuration for production execution

```bash
# AWS configuration (for deployment)
AWS_REGION="eu-west-3"
AWS_ACCOUNT_ID=""                         # ⚠️ REQUIRED

# Configuration application (for Quarkus)
LOG_LEVEL="INFO"
APP_NAME="__PROJECT_NAME__"              # Replaced during init
APP_VERSION="__PROJECT_VERSION__"        # Replaced during init

# Native build configuration
NATIVE_DEBUG_ENABLED="false"
```

## 🔄 Transformation Flow

### Before initialization (Bootstrap)
```
📁 code-with-quarkus/
├── .env.init-template      # Initialization variables
├── .env.template           # Runtime variables (with placeholders)
└── init-project.sh         # Transformation script
```

### During initialization
```bash
./init-project.sh "My API" "com.example.api"
```

1. **Reading** `.env.init-template` for project parameters
2. **Copying** `.env.template` to `.env`
3. **Replacing** placeholders `__XXX__` in `.env`
4. **Deleting** `.env.init-template` and `.env.template`

### After initialization (New project)
```
📁 my-api/
├── .env                    # Configured runtime variables
├── src/main/java/com/example/api/  # Transformed code
└── scripts/deploy.sh       # Deployment scripts
```

## � Détail des Variables

### 🔧 Variables d'initialisation (`.env.init-template`)

| Variable | Rôle | Exemple |
|----------|------|---------|
| `PROJECT_NAME` | Nom du projet | `"Mon API E-commerce"` |
| `PROJECT_PACKAGE` | Package Java cible | `"com.monentreprise.ecommerce"` |
| `MAVEN_GROUP_ID` | Group ID Maven | `"com.monentreprise"` |
| `MAVEN_ARTIFACT_ID` | Artifact ID Maven | `"ecommerce-api"` |
| `DEFAULT_*` | Valeurs par défaut | Copiées dans `.env` |

### 🐳 Variables runtime (`.env.template` → `.env`)

| Variable | Type | Rôle | Obligatoire |
|----------|------|------|-------------|
| `AWS_ACCOUNT_ID` | AWS | Déploiement ECR/Lambda | ✅ **OUI** |
| `AWS_REGION` | AWS | Région de déploiement | ❌ (défaut: eu-west-3) |
| `LOG_LEVEL` | Quarkus | Niveau de logging | ❌ (défaut: INFO) |
| `APP_NAME` | Quarkus | Nom dans l'application | ❌ (auto-généré) |
| `LAMBDA_MEMORY` | Lambda | Mémoire allouée | ❌ (défaut: 512) |
| `NATIVE_DEBUG_ENABLED` | Build | Debug natif | ❌ (défaut: false) |

## 🎯 Avantages de cette Séparation

### ✅ **Clarté**
- Variables d'init **ne polluent pas** le container final
- Variables runtime **clairement identifiées**
- **Responsabilités séparées**

### ✅ **Sécurité**
- Fichiers d'init **supprimés** après transformation
- Variables sensibles **seulement dans .env final**
- **Pas de fuite** d'info de bootstrap

### ✅ **Maintenabilité**
- Template runtime **focalisé sur l'usage**
- Template init **focalisé sur la transformation**
- **Évolution indépendante**

## 📋 Practical Examples

### Initializing a new project
```bash
# 1. Variables in .env.init-template
PROJECT_NAME="E-commerce API"
PROJECT_PACKAGE="com.mycompany.ecommerce"

# 2. Execution
./init-project.sh "E-commerce API" "com.mycompany.ecommerce"

# 3. Result in .env
APP_NAME="E-commerce API"                # Replaced
ECR_REPOSITORY_NAME="ecommerce-api"      # Deduced
AWS_ACCOUNT_ID=""                        # To be configured by user
```

### User configuration
```bash
# In .env (after init)
AWS_ACCOUNT_ID="123456789012"            # ⚠️ REQUIRED
AWS_REGION="us-east-1"                   # If not EU
LAMBDA_MEMORY="1024"                     # If need more RAM
LOG_LEVEL="DEBUG"                        # For debugging
```

### Variables in container
```properties
# In application.properties
quarkus.application.name=${APP_NAME}
quarkus.log.level=${LOG_LEVEL}
# These variables come from the final .env
```

## 🔍 Validation

```bash
# Bootstrap verification
./verify-bootstrap.sh
# ✅ Runtime configuration template
# ✅ Initialization configuration template

# Initialization test
./init-project.sh "Test API" "com.test.api"
# ✅ .env created with runtime variables
# ✅ Init files deleted
```

---

**This separation ensures a clear distinction between initialization configuration and runtime configuration! 🚀**