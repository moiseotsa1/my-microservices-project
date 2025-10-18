#!/bin/bash

echo "🐳 CONSTRUCTION ET TEST DU PRODUCT SERVICE"
echo "=========================================="

# Construction de l'image
cd microservices/product-service
docker build -t product-service:1.0 .
cd ../..

# Démarrage du service
echo "🚀 Démarrage du Product Service..."
docker run -d \
  --name product-service \
  -p 3002:3002 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_USER=admin \
  -e DB_PASSWORD=password123 \
  -e DB_NAME=ecommerce \
  --add-host=host.docker.internal:host-gateway \
  product-service:1.0

# Attente du démarrage
echo "⏳ Attente du démarrage..."
sleep 8

# Tests
echo "🧪 TESTS DU PRODUCT SERVICE"

echo "1. Health Check:"
curl -s http://localhost:3002/health
echo ""

echo "2. Liste des produits initiaux:"
curl -s http://localhost:3002/products
echo ""

echo "3. Création d'un nouveau produit:"
curl -X POST http://localhost:3002/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Nouveau Produit", "price":199.99, "stock":50}'
echo ""

echo "4. Vérification de la création:"
curl -s http://localhost:3002/products
echo ""

echo "5. Récupération par ID:"
curl -s http://localhost:3002/products/1
echo ""

echo "✅ Tests de base terminés!"

# Affichage des logs
echo ""
echo "📋 Logs du Product Service:"
docker logs product-service --tail 10
