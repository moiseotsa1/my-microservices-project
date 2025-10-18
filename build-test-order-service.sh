#!/bin/bash

echo "🐳 CONSTRUCTION ET TEST DU ORDER SERVICE"
echo "========================================"

# Nettoyage préalable
docker stop order-service 2>/dev/null || true
docker rm order-service 2>/dev/null || true

# Construction de l'image
cd microservices/order-service
docker build -t order-service:1.0 .
cd ../..

# Démarrage du service
echo "🚀 Démarrage du Order Service..."
docker run -d \
  --name order-service \
  -p 3003:3003 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_USER=admin \
  -e DB_PASSWORD=password123 \
  -e DB_NAME=ecommerce \
  --add-host=host.docker.internal:host-gateway \
  order-service:1.0

# Attente du démarrage
echo "⏳ Attente du démarrage..."
sleep 8

# Tests
echo "🧪 TESTS DU ORDER SERVICE"

echo "1. Health Check:"
curl -s http://localhost:3003/health
echo ""

echo "2. Création d'une commande:"
curl -X POST http://localhost:3003/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "items": [{"product_id": 1, "quantity": 2}], "total": 2599.98}'
echo ""

echo "3. Liste des commandes:"
curl -s http://localhost:3003/orders
echo ""

echo "4. Commandes d'\''un utilisateur:"
curl -s http://localhost:3003/orders/user/1
echo ""

echo "5. Récupération commande spécifique:"
curl -s http://localhost:3003/orders/1
echo ""

echo "6. Mise à jour statut commande:"
curl -X PATCH http://localhost:3003/orders/1/status \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}'
echo ""

echo "7. Vérification finale:"
curl -s http://localhost:3003/orders
echo ""

echo "✅ Tests Order Service terminés!"

# Affichage des logs
echo ""
echo "📋 Logs du Order Service:"
docker logs order-service --tail 15
