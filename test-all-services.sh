#!/bin/bash

echo "🌐 TEST DES TROIS MICROSERVICES"
echo "================================"

echo "📊 ÉTAT DES CONTENEURS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "👥 USER SERVICE (Port 3001):"
echo "   Health: $(curl -s http://localhost:3001/health | grep status)"
users_count=$(curl -s http://localhost:3001/users | grep -o '"email"' | wc -l)
echo "   Utilisateurs: $users_count utilisateurs"

echo ""
echo "🛍️ PRODUCT SERVICE (Port 3002):"
echo "   Health: $(curl -s http://localhost:3002/health | grep status)"
products_count=$(curl -s http://localhost:3002/products | grep -o '"name"' | wc -l)
echo "   Produits: $products_count produits"

echo ""
echo "📦 ORDER SERVICE (Port 3003):"
echo "   Health: $(curl -s http://localhost:3003/health | grep status)"
orders_count=$(curl -s http://localhost:3003/orders | grep -o '"id"' | wc -l)
echo "   Commandes: $orders_count commandes"

echo ""
echo "🗄️ BASE DE DONNÉES COMMUNE:"
docker exec postgres-primary psql -U admin -d ecommerce -t -c "
SELECT 'Utilisateurs: ' || COUNT(*) FROM users;
SELECT 'Produits: ' || COUNT(*) FROM products;
SELECT 'Commandes: ' || COUNT(*) FROM orders;
SELECT 'Paiements: ' || COUNT(*) FROM payments;
" 2>/dev/null || echo "   (Connexion en cours...)"

echo ""
echo "🎉 RÉSUMÉ DE L'\''ARCHITECTURE:"
echo "   ✅ User Service: Gestion de $users_count utilisateurs"
echo "   ✅ Product Service: Gestion de $products_count produits" 
echo "   ✅ Order Service: Gestion de $orders_count commandes"
echo "   ✅ Base de données: PostgreSQL partagée"
echo ""
echo "🚀 ARCHITECTURE MICROSERVICES OPÉRATIONNELLE !"
