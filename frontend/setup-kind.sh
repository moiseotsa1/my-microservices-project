#!/bin/bash

echo "🐳 INSTALLATION ET CONFIGURATION DE KIND"
echo "========================================"

# Vérification si Kind est installé
if ! command -v kind &> /dev/null; then
    echo "📥 Installation de Kind..."
    
    # Téléchargement de Kind
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    
    echo "✅ Kind installé"
else
    echo "✅ Kind est déjà installé"
fi

# Création d'un cluster Kind
echo "🚀 Création du cluster Kind..."
cat > kind-config.yaml << 'KIND_CONFIG'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: microservices-cluster
nodes:
- role: control-plane
  image: kindest/node:v1.28.0
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
  - containerPort: 30001
    hostPort: 30001
    protocol: TCP
  - containerPort: 30002
    hostPort: 30002
    protocol: TCP
  - containerPort: 30003
    hostPort: 30003
    protocol: TCP
  - containerPort: 30004
    hostPort: 30004
    protocol: TCP
  - containerPort: 30005
    hostPort: 30005
    protocol: TCP
KIND_CONFIG

kind create cluster --config=kind-config.yaml

# Configuration de kubectl
echo "⚙️ Configuration de kubectl..."
kubectl cluster-info --context kind-microservices-cluster

# Vérification
echo "🔍 Vérification du cluster..."
kubectl get nodes
kubectl get all -A

echo ""
echo "✅ Cluster Kind créé avec succès !"
echo "🌐 Les ports 30000-30005 sont exposés pour vos services"
