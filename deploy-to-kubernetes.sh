#!/bin/bash

echo "🚀 Déploiement sur Kubernetes..."

# Vérification de l'accès Kubernetes
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ Kubernetes n'est pas accessible"
    echo "💡 Essayez d'abord: minikube start"
    exit 1
fi

# Construction de l'image dans l'environnement Minikube si nécessaire
if command -v minikube > /dev/null 2>&1; then
    echo "🔨 Construction de l'image dans Minikube..."
    eval $(minikube docker-env)
    cd microservices/user-service
    docker build -t user-service:1.0 .
    cd ../..
fi

# Application des configurations Kubernetes
echo "📋 Application des manifests Kubernetes..."

kubectl apply -f kubernetes/secrets/db-secret.yaml
kubectl apply -f kubernetes/configs/db-init-script.yaml
kubectl apply -f kubernetes/volumes/postgres-pvc.yaml

# Déploiement de la base de données
kubectl apply -f kubernetes/manifests/database/

echo "⏳ Attente du démarrage de PostgreSQL..."
kubectl wait --for=condition=ready pod -l app=postgres-primary --timeout=120s

# Déploiement du user-service
kubectl apply -f kubernetes/manifests/microservices/

echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérification
echo "🔍 État du déploiement:"
kubectl get all

echo ""
echo "🌐 Accès au service:"
echo "   kubectl port-forward service/user-service 3001:3001"
echo "   curl http://localhost:3001/health"
