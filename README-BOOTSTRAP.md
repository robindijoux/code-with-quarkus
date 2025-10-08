# 🚀 Quarkus Lambda Bootstrap Project

This project is a **template** ready to be forked to quickly create native Quarkus REST APIs deployed on AWS Lambda.

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Project Configuration](#project-configuration)
- [Adding New Endpoints](#adding-new-endpoints)
- [Deployment](#deployment)
- [Advanced Customization](#advanced-customization)
│       └── GreetingResource.java # 📄 Endpoint de base[Troubleshooting](#troubleshooting)

---

## 🎯 Overview

### What is this project?

A **Quarkus bootstrap** configured for:
- ✅ **Native compilation** (cold start < 500ms)
- ✅ **AWS Lambda deployment** with Function URL
- ✅ **REST API** with JAX-RS 
- ✅ **Automatic JSON serialization** 
- ✅ **ARM64 architecture** (more performant and cheaper)

### Architecture

```
┌─────────────────────────────────────────────────┐
│  Lambda Function URL                             │
│  https://xxx.lambda-url.region.on.aws/          │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│           AWS Lambda (ARM64)                     │
│  ┌───────────────────────────────────────────┐  │
│  │  Your Native Quarkus Application          │  │
│  │    ↓                                      │  │
│  │  LambdaHttpHandler                        │  │
│  │    ↓                                      │  │
│  │  Your JAX-RS Endpoints                    │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### 1️⃣ Fork this project

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/YOUR-PROJECT.git
cd YOUR-PROJECT

# Initialize your new project
./init-project.sh "My New Project" "my-package.com"
```

### 2️⃣ Test locally

```bash
# Development mode
./mvnw quarkus:dev

# Tests
curl http://localhost:8080/hello
curl http://localhost:8080/template/count
```

### 3️⃣ Deploy to AWS

```bash
# Native build
./mvnw package -Pnative -Dquarkus.native.container-build=true

# Deployment
./deploy.sh
```

**That's it!** 🎉

---

## ⚙️ Project Configuration

### Files to customize MANDATORY

| File | What to change | Example |
|---------|--------------|---------|
| `pom.xml` | `groupId`, `artifactId`, `name` | `com.mycompany` |
| `application.properties` | Application name | `quarkus.application.name=my-api` |
| Java Package | `org.acme` → your package | `com.mycompany.api` |
| `deploy.sh` | AWS variables | Region, ECR repository name |
| `README.md` | Your project description | Your documentation |

### Environment variables to configure

Create a `.env` file (copied from `.env.template`):

```bash
# === PROJECT CONFIGURATION ===
PROJECT_NAME="my-awesome-project"
PROJECT_PACKAGE="com.mycompany.api"
JAVA_PACKAGE_PATH="com/mycompany/api"

# === AWS CONFIGURATION ===
AWS_REGION="eu-west-3"
AWS_ACCOUNT_ID="123456789012"
ECR_REPOSITORY_NAME="my-project-api"
LAMBDA_FUNCTION_NAME="MyProjectAPI"

# === BUILD CONFIGURATION ===
IMAGE_TAG="latest"
LAMBDA_ARCHITECTURE="arm64"
LAMBDA_MEMORY="512"
LAMBDA_TIMEOUT="30"
```

---

## 🛠️ Adding new endpoints

### 1️⃣ Recommended structure

```
src/main/java/
└── com/mycompany/api/              # Your package
    ├── model/                       # Entities/DTOs
    │   ├── User.java
    │   └── Product.java
    ├── resource/                    # Endpoints REST
    │   ├── UserResource.java
    │   └── ProductResource.java
    ├── service/                     # Logique métier
    │   ├── UserService.java
    │   └── ProductService.java
    └── exception/                   # Error handling
        └── GlobalExceptionHandler.java
```

### 2️⃣ Endpoint template

Create `src/main/java/{YOUR_PACKAGE}/resource/MyResource.java`:

```java
package com.mycompany.api.resource;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

@Path("/my-endpoint")  // ← Base URL: /my-endpoint
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class MyResource {

    @GET
    public List<MyEntity> list() {
        // TODO: Implement your logic
        return List.of();
    }

    @GET
    @Path("/{id}")
    public MonEntity get(@PathParam("id") Long id) {
        // TODO: Implémentez votre logique
        return null;
    }

    @POST
    public Response create(MonEntity entity) {
        // TODO: Implémentez votre logique
        return Response.status(201).entity(entity).build();
    }

    @PUT
    @Path("/{id}")
    public MonEntity update(@PathParam("id") Long id, MonEntity entity) {
        // TODO: Implémentez votre logique
        return entity;
    }

    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) {
        // TODO: Implémentez votre logique
        return Response.noContent().build();
    }

    // Classe interne pour l'entité (ou créez un fichier séparé)
    public static class MonEntity {
        public Long id;
        public String nom;
        public String description;

        // Constructeurs
        public MonEntity() {}
        
        public MonEntity(Long id, String nom, String description) {
            this.id = id;
            this.nom = nom;
            this.description = description;
        }
    }
}
```

### 3️⃣ Test de votre nouvel endpoint

Une fois déployé, votre endpoint sera disponible à :

```bash
# URL Lambda : https://XXXXXX.lambda-url.eu-west-3.on.aws/
LAMBDA_URL="https://XXXXXX.lambda-url.eu-west-3.on.aws"

# Tests CRUD
curl $LAMBDA_URL/mon-endpoint                    # GET (liste)
curl $LAMBDA_URL/mon-endpoint/1                  # GET (item)
curl -X POST $LAMBDA_URL/mon-endpoint -d '{...}' # POST (créer)
curl -X PUT $LAMBDA_URL/mon-endpoint/1 -d '{...}' # PUT (modifier)
curl -X DELETE $LAMBDA_URL/mon-endpoint/1        # DELETE (supprimer)
```

### 4️⃣ Ajout de dépendances

Si vous avez besoin de nouvelles dépendances (base de données, cache, etc.) :

```xml
<!-- Exemple : Base de données PostgreSQL -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-jdbc-postgresql</artifactId>
</dependency>
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-orm-panache</artifactId>
</dependency>

<!-- Exemple : Cache Redis -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-redis-client</artifactId>
</dependency>

<!-- Exemple : Validation -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-validator</artifactId>
</dependency>
```

---

## 🚀 Déploiement

### Scripts de déploiement fournis

| Script | Usage | Description |
|--------|-------|-------------|
| `deploy.sh` | Déploiement complet | Build + Push ECR + Update Lambda |
| `build-native.sh` | Build seulement | Compilation native locale |
| `push-ecr.sh` | Push seulement | Upload vers ECR |
| `update-lambda.sh` | Update seulement | Mise à jour Lambda |

### Déploiement en une commande

```bash
# Déploiement complet (recommandé)
./deploy.sh

# Ou étape par étape
./build-native.sh
./push-ecr.sh
./update-lambda.sh
```

### Première configuration AWS

1. **Créez votre repository ECR** :
   ```bash
   aws ecr create-repository --repository-name mon-projet-api --region eu-west-3
   ```

2. **Configurez vos variables** dans `.env`

3. **Exécutez le déploiement** :
   ```bash
   ./deploy.sh
   ```

Le script créera automatiquement :
- ✅ L'image Docker
- ✅ Le push vers ECR
- ✅ La fonction Lambda
- ✅ La Function URL
- ✅ Les permissions

### URL de votre API

Après déploiement, vous obtiendrez :

```
🎉 Déploiement réussi !
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 URL de votre API : https://xxx.lambda-url.eu-west-3.on.aws/
📊 Fonction Lambda : MonProjetAPI
🏗️  Architecture : arm64
💾 Mémoire : 512 MB
⏱️  Timeout : 30s
```

---

## 🔧 Personnalisation avancée

### Ajout de middleware/intercepteurs

```java
// Intercepteur de logs
@Provider
public class LoggingFilter implements ContainerRequestFilter {
    @Override
    public void filter(ContainerRequestContext context) {
        System.out.println("Request: " + context.getMethod() + " " + context.getUriInfo().getPath());
    }
}

// Gestion globale d'erreurs
@Provider
public class GlobalExceptionHandler implements ExceptionMapper<Exception> {
    @Override
    public Response toResponse(Exception exception) {
        return Response.status(500)
            .entity(Map.of("error", exception.getMessage()))
            .build();
    }
}
```

### Configuration par environnement

Dans `application.properties` :

```properties
# Configuration par profil
%dev.quarkus.log.level=DEBUG
%prod.quarkus.log.level=INFO

# Configuration spécifique Lambda
%prod.quarkus.lambda.enable-polling-jvm-mode=false
%prod.quarkus.native.debug.enabled=false

# Variables d'environnement
app.version=${VERSION:1.0.0}
app.environment=${ENVIRONMENT:production}
```

### Optimisation des performances

```properties
# Build natif optimisé
quarkus.native.additional-build-args=\
    -H:+UnlockExperimentalVMOptions,\
    -H:+UseG1GC,\
    -H:MaxRAMPercentage=80

# Taille d'image réduite
quarkus.native.debug.enabled=false
quarkus.native.enable-reports=false
```

### Monitoring et observabilité

Ajoutez dans `pom.xml` :

```xml
<!-- Métriques -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-micrometer-registry-cloudwatch</artifactId>
</dependency>

<!-- Health checks -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-smallrye-health</artifactId>
</dependency>

<!-- Tracing -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-opentelemetry</artifactId>
</dependency>
```

---

## 🏗️ Structure des fichiers générés

### Après `./init-project.sh`

```
VOTRE-PROJET/
├── .env                              # 🔧 Configuration (à personnaliser)
├── pom.xml                           # 🔧 Dépendances (groupId/artifactId mis à jour)
├── src/main/java/
│   └── com/monentreprise/api/        # 📂 Votre nouveau package
│       ├── resource/
│       │   ├── GreetingResource.java # 📄 Endpoint de base
│       │   └── CarResource.java      # 📄 Exemple CRUD
│       └── Application.java          # 📄 Point d'entrée (optionnel)
├── scripts/
│   ├── deploy.sh                     # 🚀 Déploiement complet
│   ├── build-native.sh               # 🔨 Build natif
│   ├── push-ecr.sh                   # 📤 Push ECR
│   └── update-lambda.sh              # 🔄 Update Lambda
└── docs/
    ├── API.md                        # 📚 Documentation API
    └── DEPLOYMENT.md                 # 📚 Guide de déploiement
```

### Naming conventions

| Type | Convention | Exemple |
|------|------------|---------|
| **Lambda Function** | `${PROJECT_NAME}API` | `MonProjetAPI` |
| **ECR Repository** | `${PROJECT_NAME}-api` | `mon-projet-api` |
| **Container Image** | `${ECR_REPO}:${VERSION}` | `mon-projet-api:v1.0.0` |
| **Package Java** | Reverse domain | `com.monentreprise.api` |

---

## 🐛 Troubleshooting

### Erreurs courantes

#### 1. "Cannot invoke String.hashCode() because name is null"

**Cause** : Mauvaise extension Lambda dans `pom.xml`

**Solution** :
```xml
<!-- ❌ Ne PAS utiliser -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-amazon-lambda-rest</artifactId>
</dependency>

<!-- ✅ Utiliser ceci -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-amazon-lambda-http</artifactId>
</dependency>
```

#### 2. JSON non sérialisé (retourne une représentation d'objet au lieu du JSON)

**Cause** : Extension Jackson manquante

**Solution** :
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-rest-jackson</artifactId>
</dependency>
```

#### 3. "Image manifest not supported"

**Cause** : Build Docker incompatible

**Solution** :
```bash
# Utilisez buildx avec platform explicite
docker buildx build --load --platform linux/arm64 \
  -f src/main/docker/Dockerfile.native.lambda \
  -t mon-app:lambda .
```

#### 4. Cold start trop lent (> 2 secondes)

**Cause** : Configuration Lambda non optimisée

**Solution** :
```bash
# Vérifiez la configuration Lambda
aws lambda get-function-configuration --function-name MonProjetAPI

# Architecture doit être arm64
# Memory recommandée : 512-1024 MB
```

### Commandes de debug

```bash
# Logs Lambda en temps réel
aws logs tail /aws/lambda/MonProjetAPI --region eu-west-3 --follow

# Test local du container
docker run --rm -p 9000:8080 mon-projet-api:latest
curl -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{"rawPath":"/hello","requestContext":{"http":{"method":"GET","path":"/hello"}}}'

# Vérification de l'image
./verify-image.sh

# Test de l'API Gateway
./check-api-gateway-config.sh
```

---

## 📊 Performances attendues

### Métriques de référence

| Métrique | Valeur | Commentaire |
|----------|--------|-------------|
| **Cold Start** | < 500ms | Avec ARM64 + 512MB |
| **Warm Request** | < 10ms | Après warm-up |
| **Taille binaire** | ~60MB | Quarkus native |
| **Mémoire utilisée** | 64-128MB | Runtime |
| **Coût (100k req/mois)** | ~$0.30 | Région eu-west-3 |

### Optimisations recommandées

```bash
# Build optimisé pour la taille
./mvnw package -Pnative \
  -Dquarkus.native.container-build=true \
  -Dquarkus.native.debug.enabled=false \
  -Dquarkus.native.enable-reports=false

# Configuration Lambda optimale
Memory: 512 MB (minimum recommandé)
Architecture: arm64 (plus performant et moins cher)
Timeout: 30s (pour API REST standard)
```

---

## 📚 Ressources et documentation

### Liens utiles

- [Quarkus Guides](https://quarkus.io/guides/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [AWS Lambda Function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html)
- [GraalVM Native Image](https://www.graalvm.org/latest/reference-manual/native-image/)

### Fichiers de documentation inclus

- `docs/API.md` - Documentation complète de l'API
- `docs/DEPLOYMENT.md` - Guide de déploiement détaillé
- `AWS_API_GATEWAY_FORMATS.md` - Formats d'événements Lambda
- `FIX_CLOUDFLARE_521.md` - Solutions pour les erreurs de proxy

### Support et communauté

- [Quarkus Community](https://quarkus.io/community/)
- [Stack Overflow - Quarkus](https://stackoverflow.com/questions/tagged/quarkus)
- [AWS Lambda Community](https://repost.aws/tags/TA4IvCeWI1TE66q4jEj4Z9ZQ/aws-lambda)

---

## 🎉 Prochaines étapes

Une fois votre projet initialisé :

1. ✅ **Personnalisez** les fichiers de configuration (`.env`, `pom.xml`)
2. ✅ **Renommez** les packages Java selon votre organisation
3. ✅ **Ajoutez** vos propres endpoints
4. ✅ **Testez** en local avec `./mvnw quarkus:dev`
5. ✅ **Déployez** avec `./deploy.sh`
6. ✅ **Documentez** votre API dans `docs/API.md`

**Bon développement !** 🚀

---

**Créé avec ❤️ par la communauté Quarkus + AWS Lambda**