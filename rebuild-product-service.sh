#!/bin/bash

echo "🔨 RECONSTRUCTION DU PRODUCT-SERVICE"
echo "==================================="

echo "1. 🗑️ Suppression du déploiement actuel..."
kubectl delete deployment product-service -n microservices 2>/dev/null || true

echo "2. 🐳 Reconstruction de l'image..."
cd microservices/product-service
docker build -t product-service:1.0 .
cd ../..

echo "3. 🚚 Chargement dans Kind..."
kind load docker-image product-service:1.0 --name microservices

echo "4. 🛠️ Création du déploiement corrigé..."
cat > product-service-deployment-fixed.yaml << 'DEPLOYMENT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
  namespace: microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: product-service
  template:
    metadata:
      labels:
        app: product-service
    spec:
      containers:
      - name: product-service
        image: product-service:1.0
        ports:
        - containerPort: 3002
        env:
        - name: DB_HOST
          value: "postgres-primary.microservices.svc.cluster.local"
        - name: DB_PORT
          value: "5432"
        - name: DB_USER
          value: "admin"
        - name: DB_PASSWORD
          value: "password123"
        - name: DB_NAME
          value: "ecommerce"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
DEPLOYMENT

kubectl apply -f product-service-deployment-fixed.yaml
rm product-service-deployment-fixed.yaml

echo "5. ⏳ Attente du démarrage..."
sleep 20

echo "6. 🔍 Vérification..."
kubectl get pods -n microservices -l app=product-service
kubectl logs -l app=product-service -n microservices --tail=5

echo ""
echo "✅ PRODUCT-SERVICE RECONSTRUIT - Port-forward sur le port 30002"
