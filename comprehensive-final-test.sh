#!/bin/bash

echo "🎯 TEST COMPLET FINAL - ORDER SERVICE"
echo "===================================="

# Test 1: Health Check
echo "1. ✅ Health Check:"
curl -s http://localhost:3003/health
echo ""

# Test 2: Liste toutes les commandes
echo "2. 📦 Liste des commandes:"
response=$(curl -s -w "\n%{http_code}" http://localhost:3003/orders)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 200 ]; then
    echo "   SUCCÈS - Code: $http_code"
    order_count=$(echo "$body" | grep -o '"id"' | wc -l)
    echo "   Nombre de commandes: $order_count"
    echo "$body"
else
    echo "   ÉCHEC - Code: $http_code"
    echo "   Erreur: $body"
fi
echo ""

# Test 3: Création commande
echo "3. 📝 Création nouvelle commande:"
response=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3003/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id": 4, "items": [{"product_id": 3, "quantity": 2}], "total": 599.98}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 201 ]; then
    echo "   SUCCÈS - Code: $http_code"
    echo "   Commande créée: $body"
else
    echo "   ÉCHEC - Code: $http_code"
    echo "   Erreur: $body"
fi
echo ""

# Test 4: Commandes par utilisateur
echo "4. 👤 Commandes utilisateur 1:"
curl -s http://localhost:3003/orders/user/1
echo ""

# Test 5: Mise à jour statut
echo "5. ✏️ Mise à jour statut commande 1:"
response=$(curl -s -w "\n%{http_code}" -X PATCH http://localhost:3003/orders/1/status \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 200 ]; then
    echo "   SUCCÈS - Code: $http_code"
    echo "   Commande mise à jour: $body"
else
    echo "   ÉCHEC - Code: $http_code"
    echo "   Erreur: $body"
fi
echo ""

# Test 6: Récupération commande spécifique
echo "6. 🔍 Récupération commande 1:"
curl -s http://localhost:3003/orders/1
echo ""

echo "🎉 TEST ORDER SERVICE TERMINÉ !"
