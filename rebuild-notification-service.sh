#!/bin/bash

echo "🔔 RECONSTRUCTION DU NOTIFICATION-SERVICE"
echo "========================================"

echo "1. 🗑️ Suppression du déploiement actuel..."
kubectl delete deployment notification-service -n microservices 2>/dev/null || true

echo "2. 🐳 Reconstruction de l'image..."
cd microservices/notification-service
docker build -t notification-service:1.0 .
cd ../..

echo "3. 🚚 Chargement dans Kind..."
kind load docker-image notification-service:1.0 --name microservices

echo "4. 🛠️ Création du déploiement corrigé..."
cat > notification-service-deployment-fixed.yaml << 'DEPLOYMENT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notification-service
  namespace: microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: notification-service
  template:
    metadata:
      labels:
        app: notification-service
    spec:
      containers:
      - name: notification-service
        image: notification-service:1.0
        ports:
        - containerPort: 3005
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
DEPLOYMENT

kubectl apply -f notification-service-deployment-fixed.yaml
rm notification-service-deployment-fixed.yaml

echo "5. ⏳ Attente du démarrage..."
sleep 20

echo "6. 🔍 Vérification..."
kubectl get pods -n microservices -l app=notification-service
kubectl logs -l app=notification-service -n microservices --tail=5

echo ""
echo "✅ NOTIFICATION-SERVICE RECONSTRUIT"
echo "🌐 Testez avec: kubectl port-forward -n microservices service/notification-service 30005:3005"
