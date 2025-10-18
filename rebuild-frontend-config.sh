#!/bin/bash

echo "🎨 RECONFIGURATION DU FRONTEND"
echo "=============================="

echo "1. 🐳 Reconstruction avec les bonnes URLs..."
cd frontend

# Création d'un fichier de configuration pour les services
cat > .env.production << 'ENV'
VITE_USER_SERVICE_URL=http://localhost:30001
VITE_PRODUCT_SERVICE_URL=http://localhost:30002
VITE_ORDER_SERVICE_URL=http://localhost:30003
VITE_PAYMENT_SERVICE_URL=http://localhost:30004
VITE_NOTIFICATION_SERVICE_URL=http://localhost:30005
ENV

# Modification du fichier App.jsx pour utiliser les variables d'environnement
cat > src/App-config.js << 'JS'
const API_BASE = {
  users: import.meta.env.VITE_USER_SERVICE_URL || 'http://localhost:30001',
  products: import.meta.env.VITE_PRODUCT_SERVICE_URL || 'http://localhost:30002',
  orders: import.meta.env.VITE_ORDER_SERVICE_URL || 'http://localhost:30003',
  payments: import.meta.env.VITE_PAYMENT_SERVICE_URL || 'http://localhost:30004',
  notifications: import.meta.env.VITE_NOTIFICATION_SERVICE_URL || 'http://localhost:30005'
};
JS

docker build -t frontend:1.0 .

cd ..

echo "2. 🚚 Rechargement dans Kind..."
kind load docker-image frontend:1.0 --name microservices

echo "3. 🔄 Redéploiement du frontend..."
kubectl rollout restart deployment/frontend -n microservices

echo "4. ⏳ Attente du démarrage..."
sleep 20

echo "5. 🔍 Vérification..."
kubectl get pods -n microservices -l app=frontend
kubectl logs -l app=frontend -n microservices --tail=5

echo ""
echo "✅ FRONTEND RECONFIGURÉ"
echo "🌐 Accédez à: http://localhost:30000"
