#!/bin/bash

echo "🔧 RÉPARATION DE MINIKUBE"
echo "========================"

# Arrêt et suppression de l'instance Minikube actuelle
echo "🛑 Arrêt et suppression de Minikube..."
minikube stop 2>/dev/null || true
minikube delete 2>/dev/null || true

# Nettoyage des fichiers résiduels
echo "🧹 Nettoyage des fichiers résiduels..."
rm -rf ~/.minikube ~/.kube

# Démarrage de Minikube avec une version Kubernetes stable
echo "🚀 Démarrage de Minikube avec Kubernetes stable..."
minikube start \
  --driver=docker \
  --memory=4096 \
  --cpus=2 \
  --kubernetes-version=v1.28.8 \
  --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers \
  --force

# Configuration du contexte kubectl
echo "⚙️ Configuration de kubectl..."
minikube update-context

# Vérification
echo "🔍 Vérification de l'installation..."
minikube status
kubectl cluster-info
kubectl get nodes

echo ""
echo "✅ Minikube réparé avec succès !"
