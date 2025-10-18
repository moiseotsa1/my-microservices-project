#!/bin/bash

# Corriger le fichier .env.production
kubectl exec -it deployment/frontend -n microservices -- sh -c "
cat > /app/.env.production << 'ENV'
VITE_USER_SERVICE_URL=http://api-gateway/user-service
VITE_PRODUCT_SERVICE_URL=http://api-gateway/product-service
VITE_ORDER_SERVICE_URL=http://api-gateway/order-service
VITE_PAYMENT_SERVICE_URL=http://api-gateway/payment-service
VITE_NOTIFICATION_SERVICE_URL=http://api-gateway/notification-service
ENV
"

# Corriger le fichier App.jsx (remplacer les localhost par api-gateway)
kubectl exec -it deployment/frontend -n microservices -- sed -i 's|http://localhost:3001|http://api-gateway/user-service|g' /app/src/App.jsx
kubectl exec -it deployment/frontend -n microservices -- sed -i 's|http://localhost:3002|http://api-gateway/product-service|g' /app/src/App.jsx
kubectl exec -it deployment/frontend -n microservices -- sed -i 's|http://localhost:3003|http://api-gateway/order-service|g' /app/src/App.jsx

# Corriger aussi la fonction de health check
kubectl exec -it deployment/frontend -n microservices -- sed -i 's|http://localhost:\${port}/health|http://api-gateway/health|g' /app/src/App.jsx

echo "Fichiers corrigés !"
