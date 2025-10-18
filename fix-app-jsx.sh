#!/bin/bash

# Créer une version corrigée du fichier
cat original-app.jsx | \
  sed 's|http://localhost:3001|http://api-gateway/user-service|g' | \
  sed 's|http://localhost:3002|http://api-gateway/product-service|g' | \
  sed 's|http://localhost:3003|http://api-gateway/order-service|g' | \
  sed 's|http://localhost:\${port}/health|http://api-gateway/health|g' > fixed-app.jsx

# Appliquer la correction au pod
kubectl cp fixed-app.jsx microservices/$(kubectl get pod -l app=frontend -n microservices -o jsonpath='{.items[0].metadata.name}'):/app/src/App.jsx

echo "Fichier App.jsx corrigé !"
