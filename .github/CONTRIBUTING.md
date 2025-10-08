# 🤝 Contributing to Quarkus Lambda Bootstrap

Thank you for your interest in contributing to this project! This guide helps you contribute effectively.

## 🎯 Types of contributions

### 🐛 Report bugs
- Use [GitHub Issues](https://github.com/robindijoux/code-with-quarkus/issues)
- Describe the problem with context
- Include error logs if applicable

### 🔧 Improve scripts
- Deployment scripts (`scripts/`)
- Initialization script (`init-project.sh`)
- Verification script (`verify-bootstrap.sh`)

### 📚 Improve documentation
- Guides in `docs/`
- README and API documentation
- Examples and tutorials

### 💻 Ajouter des templates d'endpoints
- Nouveaux patterns dans `ExamplesResource.java`
- Templates d'intégration (DB, API externes, etc.)
- Optimisations de performance

## 🚀 Processus de contribution

### 1️⃣ Configuration de l'environnement

```bash
# Clonez le projet
git clone https://github.com/robindijoux/code-with-quarkus.git
cd code-with-quarkus

# Vérifiez que le bootstrap est complet
./verify-bootstrap.sh

# Nettoyez si nécessaire
./clean-bootstrap.sh
```

### 2️⃣ Développement

```bash
# Créez une branche pour votre feature
git checkout -b feature/nom-de-votre-feature

# Faites vos modifications...

# Testez vos changements
./verify-bootstrap.sh

# Testez l'initialisation (optionnel)
./init-project.sh "Test Feature" "com.test.feature"
```

### 3️⃣ Tests et validation

Avant de soumettre votre PR :

```bash
# 1. Nettoyez le bootstrap
./clean-bootstrap.sh

# 2. Vérifiez la complétude
./verify-bootstrap.sh

# 3. Testez l'initialisation
./init-project.sh "Test PR" "com.test.pr"

# 4. Vérifiez que le nouveau projet fonctionne
cd ../test-pr  # si vous avez testé l'initialisation
./mvnw quarkus:dev
# Testez quelques endpoints manuellement
```

### 4️⃣ Soumission

```bash
# Commitez vos changements
git add .
git commit -m "feat: description de votre amélioration"

# Pushez votre branche
git push origin feature/nom-de-votre-feature
```

Puis créez une **Pull Request** sur GitHub.

## 📋 Guidelines de développement

### 🔧 Scripts

- **Utilisez bash** pour la compatibilité
- **Ajoutez des logs colorés** (voir exemples existants)
- **Gérez les erreurs** avec `set -e`
- **Documentez les paramètres** et options

```bash
# Exemple de structure
#!/bin/bash
set -e

# Couleurs
readonly GREEN='\033[0;32m'
readonly NC='\033[0m'

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Votre code...
log_success "Opération réussie"
```

### 📚 Documentation

- **Format Markdown** avec émojis pour la lisibilité
- **Exemples concrets** avec commandes complètes
- **Structure cohérente** avec les autres docs
- **Liens relatifs** entre documents

### 💻 Code Java

- **JAX-RS standard** (pas de code spécifique Lambda)
- **Documentation JavaDoc** pour les templates
- **Exemples commentés** dans `ExamplesResource.java`
- **Respect des conventions** Quarkus

### 🎯 Templates

Quand vous ajoutez un template d'endpoint :

1. **Copiez la structure** de `TemplateResource.java`
2. **Documentez** chaque méthode avec des commentaires
3. **Incluez des exemples** d'utilisation
4. **Testez** la génération et l'utilisation

## 🔍 Checklist avant PR

- [ ] `./verify-bootstrap.sh` passe avec succès
- [ ] `./clean-bootstrap.sh` exécuté
- [ ] Tests d'initialisation réalisés
- [ ] Documentation mise à jour si nécessaire
- [ ] Respect des conventions de code
- [ ] Commit messages descriptifs

## 🐛 Debugging

### Logs de déploiement
```bash
# Vérifiez les logs des scripts
tail -f deploy-*.log
tail -f build-*.log
```

### Problèmes fréquents

| Problème | Cause probable | Solution |
|----------|----------------|----------|
| `verify-bootstrap.sh` échoue | Fichier manquant | Vérifiez `STRUCTURE.md` |
| Scripts non exécutables | Permissions | `chmod +x script.sh` |
| Variables non remplacées | Erreur dans template | Vérifiez les `${VARIABLE}` |

## 🌟 Idées de contributions

### 🔄 Prochaines versions planifiées

- **1.1** : Templates pour DynamoDB/PostgreSQL
- **1.2** : Support OpenAPI/Swagger automatique
- **1.3** : Templates d'authentification (JWT/Cognito)
- **1.4** : CI/CD GitHub Actions

### 💡 Suggestions d'amélioration

- **Performance** : Optimisations de cold start
- **Sécurité** : Templates d'authentification
- **Monitoring** : Intégration CloudWatch/Grafana
- **Tests** : Templates de tests d'intégration
- **Multi-cloud** : Support Azure Functions/Google Cloud Functions

## 📞 Support

- **Issues GitHub** : Pour bugs et demandes de features
- **Discussions** : Pour questions générales
- **Wiki** : Documentation technique approfondie

## 📜 Code of Conduct

Ce projet suit un code de conduite simple :

- 🤝 **Soyez respectueux** envers tous les contributeurs
- 💬 **Communiquez clairement** dans les issues et PR
- 🎯 **Restez constructif** dans les critiques
- 🚀 **Aidez les autres** à contribuer

---

**Merci d'aider à améliorer ce bootstrap ! Ensemble, rendons le développement Quarkus/Lambda plus accessible ! 🚀**