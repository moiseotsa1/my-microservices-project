#!/bin/bash

set -e

echo "🚀 Déploiement de l'application microservices..."

# Vérification que kubectl est configuré
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ kubectl n'est pas configuré ou ne peut pas se connecter au cluster"
    exit 1
fi

# Construction des images
echo "🐳 Construction des images Docker..."
cd microservices/user-service
docker build -t user-service:1.0 .
cd ../..

# Création des namespaces
echo "📁 Création des namespaces..."
kubectl create namespace microservices --dry-run=client -o yaml | kubectl apply -f -

# Déploiement des secrets
echo "🔐 Déploiement des secrets..."
kubectl apply -f kubernetes/secrets/db-secret.yaml

# Déploiement des ConfigMaps
echo "📋 Déploiement des ConfigMaps..."
kubectl apply -f kubernetes/configs/db-init-script.yaml

# Déploiement du stockage
echo "💾 Déploiement du stockage..."
kubectl apply -f kubernetes/volumes/postgres-pvc.yaml

# Déploiement de la base de données
echo "🗄️ Déploiement de la base de données..."
kubectl apply -f kubernetes/manifests/database/

# Attente que PostgreSQL soit prêt
echo "⏳ Attente du démarrage de PostgreSQL..."
kubectl wait --for=condition=ready pod -l app=postgres-primary --timeout=120s

# Déploiement des microservices
echo "🛠️ Déploiement des microservices..."
kubectl apply -f kubernetes/manifests/microservices/

# Vérification du déploiement
echo "🔍 Vérification du déploiement..."
kubectl get all

echo "✅ Déploiement terminé!"
echo "🌐 Pour accéder à l'application, utilisez les commandes suivantes:"
echo "   kubectl port-forward service/user-service 3001:3001"
echo "   curl http://localhost:3001/health"
