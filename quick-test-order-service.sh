#!/bin/bash

echo "🧪 TEST RAPIDE DU ORDER SERVICE"
echo "================================"

echo "1. Liste des commandes:"
curl -s http://localhost:3003/orders
echo ""

echo "2. Création nouvelle commande:"
curl -X POST http://localhost:3003/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id": 3, "items": [{"product_id": 2, "quantity": 1}], "total": 499.99}'
echo ""

echo "3. Commandes utilisateur 1:"
curl -s http://localhost:3003/orders/user/1
echo ""

echo "4. Mise à jour statut:"
curl -X PATCH http://localhost:3003/orders/1/status \
  -H "Content-Type: application/json" \
  -d '{"status": "delivered"}'
echo ""

echo "✅ Test rapide terminé !"
