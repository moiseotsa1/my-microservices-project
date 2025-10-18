# 🔧 Variables GitLab CI/CD à Configurer

## Variables Requises (Settings → CI/CD → Variables)

### 1. Accès Kubernetes
- KUBECONFIG_BASE64: [Votre configuration Kubernetes encodée en base64]

### 2. Registry Docker (optionnel)
- DOCKER_REGISTRY_URL: registry.gitlab.com
- CI_REGISTRY_USER: $CI_REGISTRY_USER (automatique)
- CI_REGISTRY_PASSWORD: $CI_REGISTRY_PASSWORD (automatique)

### 3. Base de données
- DB_PASSWORD: password123

## Comment obtenir KUBECONFIG_BASE64:

\`\`\`bash
# Encoder votre fichier kubeconfig
cat ~/.kube/config | base64 -w 0
# Copier le résultat dans la variable KUBECONFIG_BASE64
\`\`\`

## Sécurité:
- ✅ Cochez "Mask variable" pour les secrets
- ✅ Cochez "Protect variable" pour les environnements protégés
