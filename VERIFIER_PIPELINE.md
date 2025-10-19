# 🔍 Comment Vérifier Votre Pipeline GitLab CI/CD

## Étape 1: Accéder aux Pipelines
1. **Ouvrez** : https://gitlab.com/Moise19/my-microservices-project
2. **Cliquez** sur "CI/CD" dans le menu de gauche
3. **Puis** "Pipelines"

## Étape 2: Analyser le Pipeline
- 🟢 **Cercle vert** = Réussi
- 🟡 **Cercle orange** = En cours  
- 🔴 **Cercle rouge** = Échec
- ⚪ **Cercle gris** = En attente

## Étape 3: Voir les Détails
- **Cliquez** sur le pipeline
- **Cliquez** sur chaque job pour voir les logs
- **Vérifiez** que tous les jobs passent

## Étape 4: Jobs Attendus
1. **k8s_validation** : Valide les configurations Kubernetes
2. **security_scan** : Scan de sécurité basique

## Dépannage Rapide
### Si le pipeline ne se déclenche pas :
- Vérifiez que .gitlab-ci.yml est présent
- Vérifiez la syntaxe YAML

### Si un job échoue :
- Cliquez sur le job pour voir les logs d'erreur
- Vérifiez les messages dans les logs
