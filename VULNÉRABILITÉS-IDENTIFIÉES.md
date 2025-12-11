# 🔴 VULNÉRABILITÉS IDENTIFIÉES - ANALYSE DÉTAILLÉE

## Résumé exécutif
Bandit a identifié **2 vulnérabilités de sévérité HIGH** dans le code vulnérable qui nécessitent une remédiation immédiate.

---

## VULNÉRABILITÉ #1 : Flask Debug Mode Activé (vulpy.py)

### 📍 Localisation
- **Fichier** : `bad/vulpy.py`
- **Ligne** : 55
- **Test Bandit** : B201 (flask_debug_true)
- **Sévérité** : 🔴 **HIGH**
- **Confiance** : MEDIUM
- **CWE** : [CWE-94 (Code Injection)](https://cwe.mitre.org/data/definitions/94.html)

### 🔍 Description du problème
```python
# ❌ CODE VULNÉRABLE
app.run(debug=True, host='127.0.1.1', port=5000, extra_files='csp.txt')
```

**Risque** : Exécuter une application Flask avec `debug=True` en production expose :
1. **Werkzeug Interactive Debugger** : Permet l'exécution de code Python arbitraire via l'interface de débogage
2. **Fuite d'informations** : Expose la stack trace complète et les variables locales en cas d'erreur
3. **Pas d'authentification** : N'importe qui ayant accès à l'app peut utiliser le debugger

### 💥 Impact
- **Gravité** : CRITIQUE - Exécution de code non autorisée
- **Attaquant** : Accès réseau à l'application
- **Précondition** : Aucune (application accessible)
- **Résultat** : Compromission complète du serveur

### ✅ Remédiation
```python
# ✓ CODE CORRIGÉ
if __name__ == '__main__':
    # Mode debug UNIQUEMENT en développement local
    import os
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    app.run(debug=debug_mode, host='127.0.0.1', port=5000)
```

### 📋 Checklist de correction
- [ ] Définir `debug=False` en production
- [ ] Utiliser une variable d'environnement `FLASK_ENV` pour contrôler le mode
- [ ] Valider que le code corrigé ne contient pas `debug=True`
- [ ] Retester avec Bandit après correction

---

## VULNÉRABILITÉ #2 : Flask Debug Mode Activé (vulpy-ssl.py)

### 📍 Localisation
- **Fichier** : `bad/vulpy-ssl.py`
- **Ligne** : 29
- **Test Bandit** : B201 (flask_debug_true)
- **Sévérité** : 🔴 **HIGH**
- **Confiance** : MEDIUM
- **CWE** : [CWE-94 (Code Injection)](https://cwe.mitre.org/data/definitions/94.html)

### 🔍 Description du problème
```python
# ❌ CODE VULNÉRABLE
app.run(debug=True, host='127.0.1.1', ssl_context=('/tmp/acme.cert', '/tmp/acme.key'))
```

**Risques additionnels** :
1. **Même risque que vulnérabilité #1** : Flask debug mode exposé
2. **Certificats en /tmp** : Les fichiers temporaires ne sont pas sécurisés
3. **Chemins codifiés en dur** : Pas de flexibilité pour configuration sécurisée

### 💥 Impact
- **Gravité** : CRITIQUE - Exécution de code + certificats compromise
- **Attaquant** : Accès réseau ou accès local au serveur
- **Résultat** : Double compromission (code + SSL/TLS)

### ✅ Remédiation
```python
# ✓ CODE CORRIGÉ
if __name__ == '__main__':
    import os
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    
    # Utiliser des chemins configurables
    cert_path = os.environ.get('SSL_CERT_PATH', '/etc/ssl/certs/server.crt')
    key_path = os.environ.get('SSL_KEY_PATH', '/etc/ssl/private/server.key')
    
    # Vérifier l'existence des fichiers
    if not (os.path.exists(cert_path) and os.path.exists(key_path)):
        raise ValueError("Certificats SSL non trouvés")
    
    app.run(
        debug=debug_mode,
        host='0.0.0.0',
        ssl_context=(cert_path, key_path)
    )
```

### 📋 Checklist de correction
- [ ] Définir `debug=False` en production
- [ ] Déplacer les certificats hors de `/tmp` (utiliser `/etc/ssl/` ou volumes Docker)
- [ ] Utiliser des variables d'environnement pour les chemins
- [ ] Ajouter une validation d'existence des fichiers
- [ ] Retester avec Bandit après correction

---

## 📊 Tableau comparatif

| Aspect | Vulnérabilité #1 | Vulnérabilité #2 |
|--------|-----------------|------------------|
| **Fichier** | vulpy.py | vulpy-ssl.py |
| **Ligne** | 55 | 29 |
| **Type** | Flask debug=True | Flask debug=True + SSL |
| **CWE** | CWE-94 | CWE-94 (+ CWE-377) |
| **Impact** | RCE via debugger | RCE + SSL compromise |
| **Fix simple** | `debug=False` | `debug=False` + SSL config |

---

## 🔧 Plan de remédiation

### Phase 1 : Identification ✅
- [x] Identifier vulnérabilités avec Bandit
- [x] Classifier par sévérité
- [x] Analyser l'impact

### Phase 2 : Correction (À faire)
- [ ] Copier les fichiers vulnérables vers `good/`
- [ ] Appliquer les corrections
- [ ] Valider la syntaxe Python
- [ ] Ajouter des commentaires explicatifs

### Phase 3 : Validation (À faire)
- [ ] Re-scanner avec Bandit
- [ ] Vérifier que vulnérabilités disparaissent
- [ ] Générer rapport comparatif
- [ ] Committer avec message de sécurité

### Phase 4 : Documentation (À faire)
- [ ] Documenter les changements
- [ ] Expliquer la remédiation
- [ ] Tester manuellement l'application
- [ ] Soumettre au professeur

---

## 📚 Ressources

- **Bandit B201** : https://bandit.readthedocs.io/en/1.8.6/plugins/b201_flask_debug_true.html
- **CWE-94** : https://cwe.mitre.org/data/definitions/94.html
- **Flask Security** : https://flask.palletsprojects.com/en/2.0.x/security/
- **OWASP** : https://owasp.org/www-community/attacks/Code_Injection

---

## ⏱️ Estimation

| Phase | Durée |
|-------|-------|
| Correction du code | 15 min |
| Re-scan Bandit | 5 min |
| Test manuel | 10 min |
| Documentation | 10 min |
| **Total** | **~40 min** |

---

**Analysé par** : Bandit 1.8.6  
**Date** : 2024  
**Status** : 🔴 CRITIQUE - Correction requise avant la mise en production
