#!/bin/bash

echo "🧪 TEST DU ORDER SERVICE (AVEC TABLES)"
echo "======================================"

echo "1. Health Check:"
curl -s http://localhost:3003/health
echo ""

echo "2. Liste des commandes existantes:"
curl -s http://localhost:3003/orders
echo ""

echo "3. Création d'une nouvelle commande:"
curl -X POST http://localhost:3003/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "items": [{"product_id": 1, "quantity": 1}], "total": 1299.99}'
echo ""

echo "4. Commandes de l'\''utilisateur 1:"
curl -s http://localhost:3003/orders/user/1
echo ""

echo "5. Mise à jour statut de la commande 1:"
curl -X PATCH http://localhost:3003/orders/1/status \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}'
echo ""

echo "6. Récupération de la commande 1:"
curl -s http://localhost:3003/orders/1
echo ""

echo "7. État final des commandes:"
curl -s http://localhost:3003/orders
echo ""

echo "✅ Tests Order Service avec tables !"
