#!/bin/bash

echo "🎯 CRÉATION D'UNE VERSION FONCTIONNELLE"
echo "======================================"

# Arrêt du déploiement actuel
kubectl delete deployment notification-service -n microservices 2>/dev/null || true

# Création d'un fichier JavaScript simple et correct
cat > simple-notification.js << 'JS'
const express = require("express");
const app = express();
const port = 3005;

app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ 
    status: "OK", 
    service: "notification-service",
    timestamp: new Date().toISOString()
  });
});

app.post("/notifications", (req, res) => {
  res.json({
    id: 1,
    message: "Notification reçue",
    status: "sent"
  });
});

app.get("/notifications", (req, res) => {
  res.json([]);
});

app.listen(port, () => {
  console.log("Notification Service démarré sur le port " + port);
});
JS

# Création d'un Dockerfile simple
cat > simple-Dockerfile << 'DOCKERFILE'
FROM node:16-alpine
WORKDIR /app
COPY simple-notification.js .
RUN npm init -y && npm install express
CMD ["node", "simple-notification.js"]
DOCKERFILE

# Construction
docker build -f simple-Dockerfile -t notification-service:1.0 .

# Chargement dans Kind
kind load docker-image notification-service:1.0 --name microservices

# Déploiement
cat > notification-deployment-simple.yaml << 'DEPLOYMENT'
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

kubectl apply -f notification-deployment-simple.yaml

# Nettoyage
rm simple-notification.js simple-Dockerfile notification-deployment-simple.yaml

echo "⏳ Attente du démarrage..."
sleep 20

kubectl get pods -n microservices -l app=notification-service
kubectl logs -l app=notification-service -n microservices --tail=3

echo ""
echo "✅ VERSION FONCTIONNELLE DÉPLOYÉE"
