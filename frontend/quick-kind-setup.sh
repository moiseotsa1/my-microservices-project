#!/bin/bash

echo "🚀 INSTALLATION RAPIDE DE KIND"
echo "=============================="

# Vérification et installation de Kind
if ! command -v kind &> /dev/null; then
    echo "📥 Installation de Kind..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    echo "✅ Kind installé"
fi

# Création d'un cluster Kind simple et rapide
echo "🐳 Création du cluster Kind..."
cat > kind-simple.yaml << 'KIND_SIMPLE'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: microservices
nodes:
- role: control-plane
  image: kindest/node:v1.27.3
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
KIND_SIMPLE

kind create cluster --config=kind-simple.yaml --wait 5m

# Vérification
echo "🔍 Vérification du cluster..."
kubectl cluster-info --context kind-microservices
kubectl get nodes

echo ""
echo "✅ Cluster Kind prêt en 5 minutes maximum !"
echo "🌐 Votre cluster Kubernetes est opérationnel"
