#!/bin/bash

echo "🔨 RECONSTRUCTION DE L'ORDER-SERVICE"
echo "==================================="

echo "1. 🗑️ Suppression du déploiement actuel..."
kubectl delete deployment order-service -n microservices 2>/dev/null || true

echo "2. 🐳 Reconstruction de l'image..."
cd microservices/order-service
docker build -t order-service:1.0 .
cd ../..

echo "3. 🚚 Chargement dans Kind..."
kind load docker-image order-service:1.0 --name microservices

echo "4. 🛠️ Création du déploiement corrigé..."
cat > order-service-deployment-fixed.yaml << 'DEPLOYMENT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: order-service:1.0
        ports:
        - containerPort: 3003
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

kubectl apply -f order-service-deployment-fixed.yaml
rm order-service-deployment-fixed.yaml

echo "5. ⏳ Attente du démarrage..."
sleep 20

echo "6. 🔍 Vérification..."
kubectl get pods -n microservices -l app=order-service
kubectl logs -l app=order-service -n microservices --tail=5

echo ""
echo "✅ ORDER-SERVICE RECONSTRUIT"
echo "🌐 Testez avec: kubectl port-forward -n microservices service/order-service 30003:3003"
