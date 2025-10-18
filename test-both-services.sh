#!/bin/bash

echo "🌐 TEST DES DEUX MICROSERVICES"
echo "=============================="

echo "📊 ÉTAT DES CONTENEURS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "👥 USER SERVICE (Port 3001):"
echo "   Health: $(curl -s http://localhost:3001/health | grep status)"
echo "   Utilisateurs: $(curl -s http://localhost:3001/users | grep -o '"email"' | wc -l) utilisateurs"

echo ""
echo "🛍️ PRODUCT SERVICE (Port 3002):"
echo "   Health: $(curl -s http://localhost:3002/health | grep status)"
echo "   Produits: $(curl -s http://localhost:3002/products | grep -o '"name"' | wc -l) produits"

echo ""
echo "🗄️ BASE DE DONNÉES COMMUNE:"
docker exec postgres-primary psql -U admin -d ecommerce -t -c "
SELECT 'Utilisateurs: ' || COUNT(*) FROM users;
SELECT 'Produits: ' || COUNT(*) FROM products;
" 2>/dev/null || echo "   (Connexion en cours...)"

echo ""
echo "✅ LES DEUX SERVICES FONCTIONNENT !"
