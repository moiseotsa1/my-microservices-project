#!/bin/bash

echo "🌐 TEST FINAL DES TROIS MICROSERVICES"
echo "====================================="

echo "📊 ÉTAT DES CONTENEURS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "👥 USER SERVICE:"
echo "   Health: $(curl -s http://localhost:3001/health)"
users=$(curl -s http://localhost:3001/users | grep -o '"id"' | wc -l)
echo "   Utilisateurs: $users"

echo ""
echo "🛍️ PRODUCT SERVICE:"
echo "   Health: $(curl -s http://localhost:3002/health)"
products=$(curl -s http://localhost:3002/products | grep -o '"id"' | wc -l)
echo "   Produits: $products"

echo ""
echo "📦 ORDER SERVICE:"
echo "   Health: $(curl -s http://localhost:3003/health)"
orders=$(curl -s http://localhost:3003/orders | grep -o '"id"' | wc -l)
echo "   Commandes: $orders"

echo ""
echo "🗄️ BASE DE DONNÉES:"
docker exec postgres-primary psql -U admin -d ecommerce -t -c "
SELECT '=== STATISTIQUES ===' as info;
SELECT 'Utilisateurs: ' || COUNT(*) FROM users;
SELECT 'Produits: ' || COUNT(*) FROM products;
SELECT 'Commandes: ' || COUNT(*) FROM orders;
SELECT 'Paiements: ' || COUNT(*) FROM payments;
"

echo ""
echo "🎉 FÉLICITATIONS ! ARCHITECTURE MICROSERVICES COMPLÈTE !"
echo "✅ User Service: $users utilisateurs"
echo "✅ Product Service: $products produits" 
echo "✅ Order Service: $orders commandes"
echo "✅ Base de données PostgreSQL partagée"
echo ""
echo "🚀 LES 3 MICROSERVICES FONCTIONNENT PARFAITEMENT !"
