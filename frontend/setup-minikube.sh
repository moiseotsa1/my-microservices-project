#!/bin/bash

echo "🚀 INSTALLATION ET CONFIGURATION DE MINIKUBE"
echo "============================================"

# Vérification si Minikube est déjà installé
if ! command -v minikube &> /dev/null; then
    echo "📥 Installation de Minikube..."
    
    # Téléchargement de Minikube
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    
    echo "✅ Minikube installé"
else
    echo "✅ Minikube est déjà installé"
fi

# Vérification si kubectl est installé
if ! command -v kubectl &> /dev/null; then
    echo "📥 Installation de kubectl..."
    
    # Installation de kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    
    echo "✅ kubectl installé"
else
    echo "✅ kubectl est déjà installé"
fi

# Démarrage de Minikube
echo "🔧 Démarrage de Minikube..."
minikube start --driver=docker --memory=4096 --cpus=2

# Configuration de l'environnement Docker pour Minikube
echo "🐳 Configuration de l'environnement Docker..."
eval $(minikube docker-env)

# Vérification
echo "🔍 Vérification de l'installation..."
minikube status
kubectl cluster-info
kubectl get nodes

echo ""
echo "✅ Minikube est prêt !"
echo "🌐 Dashboard Minikube: minikube dashboard"
echo "🔧 Environnement Docker configuré pour Minikube"
