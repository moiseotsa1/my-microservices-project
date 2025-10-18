#!/bin/bash

echo "💰 RECONSTRUCTION DU PAYMENT-SERVICE"
echo "==================================="

echo "1. 🗑️ Suppression du déploiement actuel..."
kubectl delete deployment payment-service -n microservices 2>/dev/null || true

echo "2. 🐳 Reconstruction de l'image..."
cd microservices/payment-service
docker build -t payment-service:1.0 .
cd ../..

echo "3. 🚚 Chargement dans Kind..."
kind load docker-image payment-service:1.0 --name microservices

echo "4. 🛠️ Création du déploiement corrigé..."
cat > payment-service-deployment-fixed.yaml << 'DEPLOYMENT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
    spec:
      containers:
      - name: payment-service
        image: payment-service:1.0
        ports:
        - containerPort: 3004
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

kubectl apply -f payment-service-deployment-fixed.yaml
rm payment-service-deployment-fixed.yaml

echo "5. ⏳ Attente du démarrage..."
sleep 20

echo "6. 🔍 Vérification..."
kubectl get pods -n microservices -l app=payment-service
kubectl logs -l app=payment-service -n microservices --tail=5

echo ""
echo "✅ PAYMENT-SERVICE RECONSTRUIT"
echo "🌐 Testez avec: kubectl port-forward -n microservices service/payment-service 30004:3004"
