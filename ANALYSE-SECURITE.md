# 📊 RAPPORT D'ANALYSE DE SÉCURITÉ - VULPY

## Exécutif

Ce projet contient une analyse complète des vulnérabilités de sécurité dans l'application **VulpY** en utilisant :
- **SAST** (Static Application Security Testing) : Bandit 1.8.6
- **SCA** (Software Composition Analysis) : Trivy v0.48.0+
- **DAST** (Dynamic Application Security Testing) : À compléter avec OWASP ZAP

**Date** : $(date)  
**Scope** : Analyse comparative entre code vulnérable (`bad/`) et code corrigé (`good/`)

---

## 📋 Résultats SAST (Bandit)

### Vue d'ensemble
| Métrique | Valeur |
|----------|--------|
| Outil | Bandit 1.8.6 |
| Python | 3.13.5 |
| Rapports | 2 fichiers HTML |

### Rapports générés
1. **bandit-bad.html** (20.7 KB)
   - Analyse du code vulnérable dans le répertoire `bad/`
   - Contient tous les problèmes de sécurité détectés
   - À consulter pour identifier les vulnérabilités à corriger

2. **bandit-good.html** (11.1 KB)
   - Analyse du code corrigé dans le répertoire `good/`
   - Baseline pour évaluation des améliorations
   - Moins de findings attendus (code sécurisé)

### Instructions d'analyse
1. Ouvrir `bandit-bad.html` dans un navigateur
2. Identifier les vulnérabilités avec sévérité **CRITICAL** ou **HIGH**
3. Sélectionner 2 vulnérabilités pour analyse détaillée
4. Comparer avec `bandit-good.html` pour voir les corrections

---

## 📦 Résultats SCA (Trivy)

### Vue d'ensemble
| Métrique | Fichier | Taille |
|----------|---------|--------|
| Dépendances directes | trivy-requirements.json | 373 B |
| Secrets/Config | trivy-secrets-config.json | 15.9 KB |
| Dépendances transitives | trivy-transitive.json | 356 B |
| Supply Chain | trivy-supply-chain.json | 137.6 KB |

### Analyse
- **trivy-requirements.json** : Scanne `requirements.txt` pour CVEs connues
- **trivy-secrets-config.json** : Détecte les secrets codifiés (clés API, tokens, mots de passe)
- **trivy-transitive.json** : Analyse les dépendances imbriquées
- **trivy-supply-chain.json** : Scanne l'image de base `python:3.11-slim` pour vulnérabilités

### Sévérité élevée
Les résultats complets sont disponibles dans les fichiers JSON pour intégration CI/CD.

---

## 🔍 Prochaines étapes

### Phase DAST (À faire)
1. Déployer OWASP ZAP
2. Scanner l'application en http://localhost:5000
3. Identifier 2 vulnérabilités critiques de runtime
4. Comparer avec résultats SAST

### Remédiation
1. Corriger le code basé sur les vulnérabilités identifiées
2. Re-scanner avec Bandit
3. Valider que les corrections réduisent la sévérité

### Documentation
1. Générer rapport comparatif avant/après
2. Committer les corrections avec commentaires de sécurité
3. Soumettre au professeur

---

## 📂 Structure du dépôt

```
vulpy/
├── bad/                      # Code vulnérable (intentionnel)
│   ├── *.py                  # Fichiers Python avec vulnérabilités
│   └── templates/            # Templates HTML vulnérables
├── good/                     # Code corrigé
│   ├── *.py                  # Fichiers Python sécurisés
│   └── templates/            # Templates HTML sécurisés
├── utils/                    # Outils et scripts de test
├── Dockerfile                # Image application
├── Dockerfile.jenkins        # Image Jenkins avec outils
├── docker-compose.yml        # Orchestration multi-conteneurs
├── Jenkinsfile              # Pipeline CI/CD
├── bandit-bad.html          # Rapport SAST - Code vulnérable
├── bandit-good.html         # Rapport SAST - Code corrigé
├── trivy-*.json             # Rapports SCA (5 fichiers)
└── ANALYSE-SECURITE.md      # Ce rapport
```

---

## 🛠️ Infrastructure

### Conteneurs disponibles
- **Jenkins LTS** (port 8081)
  - Mot de passe : Voir logs de démarrage
  - Docker socket mappé (DinD)
  - Bandit 1.8.6 installé (venv)
  - Prêt pour pipeline d'automatisation

- **VulpY App** (port 5000)
  - Flask application
  - Répertoires bad/ et good/ accessibles
  - Prêt pour test fonctionnel et DAST

### Lancer l'analyse
```bash
# Démarrer les conteneurs
docker compose up -d

# Exécuter Bandit manuellement
docker exec jenkins-vulpy bandit -r /vulpy/bad/ -f html -o /vulpy/bandit-bad.html

# Copier les rapports
docker cp jenkins-vulpy:/vulpy/bandit-bad.html .
docker cp jenkins-vulpy:/vulpy/bandit-good.html .
```

---

## ✅ Statut

- ✅ Bandit SAST : Complet
- ✅ Trivy SCA : Complet
- ⏳ DAST (OWASP ZAP) : À faire
- ⏳ Remédiation : À faire
- ⏳ Validation : À faire

---

**Rapport généré automatiquement par le pipeline CI/CD**
