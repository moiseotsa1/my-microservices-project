#!/bin/bash

echo "🗄️ VÉRIFICATION DES TABLES DE LA BASE DE DONNÉES"
echo "================================================"

docker exec postgres-primary psql -U admin -d ecommerce -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
"

echo ""
echo "📊 DONNÉES ACTUELLES:"
docker exec postgres-primary psql -U admin -d ecommerce -c "
SELECT 
  (SELECT COUNT(*) FROM users) as users,
  (SELECT COUNT(*) FROM products) as products,
  (SELECT COUNT(*) FROM orders) as orders,
  (SELECT COUNT(*) FROM payments) as payments;
"
