#!/bin/bash

echo "🔨 RECONSTRUCTION DU USER-SERVICE"
echo "================================"

echo "1. 🗑️ Suppression du déploiement actuel..."
kubectl delete deployment user-service -n microservices

echo "2. 🐳 Reconstruction de l'image..."
cd microservices/user-service
docker build -t user-service:1.0 .
cd ../..

echo "3. 🚚 Chargement dans Kind..."
kind load docker-image user-service:1.0 --name microservices

echo "4. 🛠️ Création du déploiement corrigé..."
cat > user-service-deployment-fixed.yaml << 'DEPLOYMENT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: user-service:1.0
        ports:
        - containerPort: 3001
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

kubectl apply -f user-service-deployment-fixed.yaml
rm user-service-deployment-fixed.yaml

echo "5. ⏳ Attente du démarrage..."
sleep 20

echo "6. 🔍 Vérification..."
kubectl get pods -n microservices -l app=user-service
kubectl logs -l app=user-service -n microservices --tail=5

echo ""
echo "✅ RECONSTRUCTION TERMINÉE - Testez: curl http://localhost:30001/health"
