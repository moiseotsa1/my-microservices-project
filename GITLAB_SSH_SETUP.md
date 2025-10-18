# 🔑 Configuration SSH pour GitLab

Si le push GitLab échoue, configurez votre clé SSH:

## 1. Générer une clé SSH (si pas déjà fait)
ssh-keygen -t ed25519 -C "moiseotsa1@github.com"

## 2. Ajouter la clé à ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

## 3. Copier la clé publique
cat ~/.ssh/id_ed25519.pub

## 4. Ajouter la clé à GitLab
1. Allez sur https://gitlab.com/-/profile/keys
2. Coller votre clé publique
3. Ajouter la clé

## 5. Réessayer le push
git push -u gitlab main

## Alternative: Utiliser HTTPS pour GitLab
git remote set-url gitlab https://gitlab.com/Moise19/my-microservices-project.git
git push -u gitlab main
