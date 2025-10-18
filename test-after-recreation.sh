#!/bin/bash

echo "🧪 TEST APRÈS RECRÉATION DE LA BASE"
echo "==================================="

echo "1. 📊 Vérification des tables:"
docker exec postgres-primary psql -U admin -d ecommerce -c "
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
"

echo ""
echo "2. 🔧 Tests des services:"

echo "User Service:"
curl -s http://localhost:3001/health
echo ""
curl -s http://localhost:3001/users | grep -o '"id"' | wc -l | awk '{print "   Utilisateurs: "$1}'

echo ""
echo "Product Service:"
curl -s http://localhost:3002/health
echo ""
curl -s http://localhost:3002/products | grep -o '"id"' | wc -l | awk '{print "   Produits: "$1}'

echo ""
echo "Order Service:"
curl -s http://localhost:3003/health
echo ""
echo "   Test création commande:"
curl -X POST http://localhost:3003/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "items": [{"product_id": 1, "quantity": 1}], "total": 1299.99}'
echo ""

echo "   Liste commandes:"
curl -s http://localhost:3003/orders
echo ""

echo "🎉 TEST TERMINÉ !"
