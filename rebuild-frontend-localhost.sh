#!/bin/bash

echo "🎨 RECONSTRUCTION DU FRONTEND AVEC URLs LOCALHOST"
echo "================================================"

# Sauvegarde du fichier original
cp frontend/src/App.jsx frontend/src/App.jsx.backup

# Modification directe du fichier App.jsx pour utiliser localhost
sed -i 's|http://user-service:3001|http://localhost:30001|g' frontend/src/App.jsx
sed -i 's|http://product-service:3002|http://localhost:30002|g' frontend/src/App.jsx  
sed -i 's|http://order-service:3003|http://localhost:30003|g' frontend/src/App.jsx
sed -i 's|http://payment-service:3004|http://localhost:30004|g' frontend/src/App.jsx
sed -i 's|http://notification-service:3005|http://localhost:30005|g' frontend/src/App.jsx

echo "1. 🐳 Reconstruction de l'image..."
cd frontend
docker build -t frontend:1.0 .
cd ..

echo "2. 🚚 Rechargement dans Kind..."
kind load docker-image frontend:1.0 --name microservices

echo "3. 🔄 Redéploiement..."
kubectl rollout restart deployment/frontend -n microservices

echo "4. ⏳ Attente..."
sleep 25

echo "5. 🔍 Vérification..."
kubectl get pods -n microservices -l app=frontend

echo ""
echo "✅ FRONTEND RECONSTRUIT AVEC URLs LOCALHOST"
echo "🌐 Accédez à: http://localhost:30000"
