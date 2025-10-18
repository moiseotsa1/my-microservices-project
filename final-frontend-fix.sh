#!/bin/bash

echo "🎯 SOLUTION FINALE POUR LE FRONTEND"
echo "=================================="

# Récupération des IPs de cluster des services
echo "🔍 Récupération des IPs des services..."
USER_IP=$(kubectl get service user-service -n microservices -o jsonpath='{.spec.clusterIP}')
PRODUCT_IP=$(kubectl get service product-service -n microservices -o jsonpath='{.spec.clusterIP}')
ORDER_IP=$(kubectl get service order-service -n microservices -o jsonpath='{.spec.clusterIP}')
PAYMENT_IP=$(kubectl get service payment-service -n microservices -o jsonpath='{.spec.clusterIP}')
NOTIFICATION_IP=$(kubectl get service notification-service -n microservices -o jsonpath='{.spec.clusterIP}')

echo "User Service: $USER_IP"
echo "Product Service: $PRODUCT_IP"
echo "Order Service: $ORDER_IP"
echo "Payment Service: $PAYMENT_IP"
echo "Notification Service: $NOTIFICATION_IP"

# Reconstruction du frontend avec les bonnes URLs
echo "🔨 Reconstruction du frontend..."
cd frontend

# Restauration du fichier original d'abord
cp src/App.jsx.backup src/App.jsx 2>/dev/null || echo "Pas de backup, utilisation du fichier actuel"

# Modification pour utiliser les noms de service Kubernetes (résolution DNS interne)
sed -i 's|http://localhost:30001|http://user-service:3001|g' src/App.jsx
sed -i 's|http://localhost:30002|http://product-service:3002|g' src/App.jsx
sed -i 's|http://localhost:30003|http://order-service:3003|g' src/App.jsx
sed -i 's|http://localhost:30004|http://payment-service:3004|g' src/App.jsx
sed -i 's|http://localhost:30005|http://notification-service:3005|g' src/App.jsx

docker build -t frontend:1.0 .
cd ..

echo "🚚 Chargement dans Kind..."
kind load docker-image frontend:1.0 --name microservices

echo "🔄 Redéploiement..."
kubectl rollout restart deployment/frontend -n microservices

echo "⏳ Attente du démarrage..."
sleep 30

echo "🔍 Vérification finale..."
kubectl get pods -n microservices -l app=frontend

echo ""
echo "✅ FRONTEND RECONFIGURÉ AVEC URLs KUBERNETES INTERNES"
echo "🌐 Accédez à: http://localhost:30000"
