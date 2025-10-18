#!/bin/bash

echo "🗄️ TEST DIRECT DE LA BASE DE DONNÉES"
echo "====================================="

# Connexion à PostgreSQL et vérification des données
docker exec postgres-primary psql -U admin -d ecommerce -c "
SELECT '=== UTILISATEURS ===' as info;
SELECT id, email, name, created_at FROM users ORDER BY id;

SELECT '=== PRODUITS ===' as info; 
SELECT id, name, price, stock FROM products ORDER BY id;

SELECT '=== STATISTIQUES ===' as info;
SELECT 
    (SELECT COUNT(*) FROM users) as users_count,
    (SELECT COUNT(*) FROM products) as products_count,
    (SELECT COUNT(*) FROM orders) as orders_count,
    (SELECT COUNT(*) FROM payments) as payments_count;
"

echo ""
echo "🔍 STRUCTURE DES TABLES:"
docker exec postgres-primary psql -U admin -d ecommerce -c "
\d users;
\d products;
"
