#!/bin/bash

echo "🧹 NETTOYAGE COMPLET ET REDÉMARRAGE"
echo "=================================="

# Arrêt de tous les processus en cours
echo "🛑 Arrêt de tous les clusters..."
minikube stop 2>/dev/null || true
kind delete cluster --name microservices-cluster 2>/dev/null || true

# Nettoyage des conteneurs Docker
echo "🗑️ Nettoyage des conteneurs Docker..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Nettoyage des configurations
echo "📁 Nettoyage des configurations..."
rm -rf ~/.minikube ~/.kube /tmp/hostpath-provisioner

echo "✅ Nettoyage terminé !"
