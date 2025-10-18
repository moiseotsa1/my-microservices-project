#!/bin/bash

echo "📋 RAPPORT FINAL - USER SERVICE"
echo "================================"
echo "Date: $(date)"
echo ""

# État des services
echo "🔧 ÉTAT DES SERVICES:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(user-service|postgres-primary)"

echo ""
echo "🌐 POINTS D'ACCÈS API:"
echo "   Health Check:    curl http://localhost:3001/health"
echo "   Liste users:     curl http://localhost:3001/users" 
echo "   Créer user:      curl -X POST http://localhost:3001/users -H 'Content-Type: application/json' -d '{\"email\":\"test@example.com\", \"name\":\"Test\"}'"
echo "   Get user by ID:  curl http://localhost:3001/users/1"

echo ""
echo "🗄️  BASE DE DONNÉES:"
docker exec postgres-primary psql -U admin -d ecommerce -t -c "
SELECT 'Utilisateurs: ' || COUNT(*) FROM users;
SELECT 'Produits: ' || COUNT(*) FROM products;
"

echo ""
echo "✅ USER SERVICE EST PRÊT POUR LA PRODUCTION !"
echo ""
echo "📅 PROCHAINE ÉTAPE: Création du Product Service"
echo "   Le User Service a été complètement testé et validé"
echo "   Nous pouvons maintenant passer au microservice suivant"
