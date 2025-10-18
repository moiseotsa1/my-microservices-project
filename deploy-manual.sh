#!/bin/bash
echo "🚀 Déploiement manuel des microservices..."

# Mettre à jour les images (simulation)
echo "1. Mise à jour des images..."
kubectl set image deployment/user-service user-service=your-registry/user-service:latest -n microservices
kubectl set image deployment/product-service product-service=your-registry/product-service:latest -n microservices
kubectl set image deployment/order-service order-service=your-registry/order-service:latest -n microservices

# Attendre le déploiement
echo "2. Attente du déploiement..."
kubectl rollout status deployment/user-service -n microservices
kubectl rollout status deployment/product-service -n microservices  
kubectl rollout status deployment/order-service -n microservices

# Vérification
echo "3. Vérification..."
kubectl get pods -n microservices
echo "✅ Déploiement terminé !"
