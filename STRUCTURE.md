# 📁 Quarkus Lambda Bootstrap Structure

This documentation describes the complete project tree of the bootstrap after cleanup.

## 🗂️ Final structure

```
code-with-quarkus/                    # 🏠 Bootstrap root
├── 📋 Configuration
│   ├── .env.template                 # Environment variables template
│   ├── .gitignore                    # Gitignore for the bootstrap
│   ├── .gitignore.new-project        # Gitignore for new projects
│   ├── pom.xml                       # Current Maven POM
│   └── pom-template.xml              # POM template with variables
│
├── 🔧 Automation scripts
│   ├── init-project.sh               # 🎯 Main initialization script
│   ├── verify-bootstrap.sh           # Bootstrap verification
│   ├── clean-bootstrap.sh            # Bootstrap cleanup
│   └── scripts/
│       ├── deploy.sh                 # Complete deployment
│       ├── build-native.sh           # Build natif seul
│       ├── push-ecr.sh               # Push ECR seul
│       └── update-lambda.sh          # Mise à jour Lambda seule
│
├── 📚 Documentation
│   ├── README.md                     # Guide principal (accueil)
│   ├── README-BOOTSTRAP.md           # Guide complet du bootstrap
│   └── docs/
│       ├── API.md                    # Documentation de l'API
│       ├── ENDPOINTS.md              # Guide d'ajout d'endpoints
│       └── DEPLOYMENT.md             # Guide de déploiement détaillé
│
├── 💻 Code source
│   ├── src/main/
│   │   ├── java/org/acme/
│   │   │   └── resource/
│   │   │       ├── GreetingResource.java    # Endpoint simple
│   │   │       ├── TemplateResource.java    # 🎯 Template documenté
│   │   │       └── ExamplesResource.java    # Patterns avancés
│   │   ├── resources/
│   │   │   ├── application.properties       # Config actuelle
│   │   │   └── application-template.properties  # Config template
│   │   └── docker/
│   │       └── Dockerfile.native.lambda     # Dockerfile pour Lambda
│   └── src/test/                     # Tests unitaires
│
├── 🛠️ Outils Maven
│   ├── mvnw                          # Maven wrapper (Unix)
│   ├── mvnw.cmd                      # Maven wrapper (Windows)
│   └── .mvn/                         # Configuration Maven wrapper
│
└── 📄 Autres
    ├── .dockerignore                 # Exclusions Docker
    └── .github/                      # Workflows GitHub (si applicable)
```

## 🎯 Fichiers clés du bootstrap

### 🔧 Scripts d'automatisation

| Script | Rôle | Utilisation |
|--------|------|-------------|
| `init-project.sh` | **🎯 Principal** | Transforme le bootstrap en nouveau projet |
| `verify-bootstrap.sh` | Validation | Vérifie que le bootstrap est complet |
| `clean-bootstrap.sh` | Maintenance | Nettoie le bootstrap avant commit |
| `scripts/deploy.sh` | Déploiement | Déploiement complet automatisé |

### 📋 Configuration

| Fichier | Rôle | Transformé en |
|---------|------|---------------|
| `.env.template` | Variables d'environnement | `.env` |
| `pom-template.xml` | Maven avec variables | `pom.xml` |
| `application-template.properties` | Config Quarkus | `application.properties` |
| `.gitignore.new-project` | Gitignore clean | `.gitignore` |

### 📚 Documentation

| Fichier | Audience | Contenu |
|---------|----------|---------|
| `README.md` | **Utilisateurs finaux** | Guide d'accueil et usage |
| `README-BOOTSTRAP.md` | Développeurs bootstrap | Guide complet du bootstrap |
| `docs/API.md` | Développeurs API | Documentation des endpoints |
| `docs/ENDPOINTS.md` | Développeurs | Comment ajouter des endpoints |
| `docs/DEPLOYMENT.md` | DevOps | Guide de déploiement avancé |

### 💻 Code template

| Fichier | Type | Rôle |
|---------|------|------|
| `TemplateResource.java` | **🎯 Template** | Modèle pour nouveaux endpoints |
| `ExamplesResource.java` | Exemples | Patterns avancés et bonnes pratiques |
| `GreetingResource.java` | Simple | Endpoint de base |

## 🔄 Processus de transformation

Quand un utilisateur exécute `./init-project.sh "Mon Projet" "com.example.api"` :

### 1️⃣ Fichiers supprimés
- `pom-template.xml`
- `application-template.properties`
- `.env.template`
- `README-BOOTSTRAP.md`
- `verify-bootstrap.sh`

### 2️⃣ Fichiers transformés
- `.gitignore.new-project` → `.gitignore`
- Structure de packages : `org.acme` → `com.example.api`
- Variables remplacées dans tous les fichiers

### 3️⃣ Fichiers créés
- `.env` (avec configuration utilisateur)
- `README.md` (personnalisé pour le nouveau projet)

## 🧹 Scripts de nettoyage

### `clean-bootstrap.sh`
Nettoie le bootstrap avant commit :
- Supprime `target/`, logs, fichiers temporaires
- Vérifie la structure complète
- Valide les permissions des scripts

### `verify-bootstrap.sh`
Valide que le bootstrap est complet :
- 25+ vérifications automatiques
- Contrôle des dépendances Maven
- Validation des outils système
- Rapport détaillé

## 🎯 Utilisation recommandée

### Pour créer un nouveau projet
1. **Forkez** le repository
2. **Clonez** votre fork
3. **Initialisez** : `./init-project.sh "Mon Projet" "com.example.api"`
4. **Configurez** : Éditez `.env`
5. **Déployez** : `./scripts/deploy.sh`

### Pour contribuer au bootstrap
1. **Clonez** directement ce repository
2. **Modifiez** les templates et scripts
3. **Nettoyez** : `./clean-bootstrap.sh`
4. **Vérifiez** : `./verify-bootstrap.sh`
5. **Committez** et créez une PR

---

**Cette structure garantit un bootstrap professionnel, maintenable et facile à utiliser ! 🚀**