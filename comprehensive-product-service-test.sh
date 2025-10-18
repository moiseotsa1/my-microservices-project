#!/bin/bash

echo "🧪 TEST COMPLET DU PRODUCT SERVICE"
echo "=================================="

# Test 1: Health Check
echo "1. Health Check:"
curl -s http://localhost:3002/health
echo ""

# Test 2: Produits existants
echo "2. Produits existants:"
curl -s http://localhost:3002/products
echo ""

# Test 3: Création produit
echo "3. Création produit:"
curl -X POST http://localhost:3002/products \
  -H "Content-Type: application/json" \
  -d '{"name":"iPhone 15", "price":1099.99, "stock":25}'
echo ""

# Test 4: Mise à jour produit
echo "4. Mise à jour produit:"
curl -X PUT http://localhost:3002/products/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop Gaming", "price":1299.99, "stock":8}'
echo ""

# Test 5: Récupération par ID
echo "5. Récupération produit 1:"
curl -s http://localhost:3002/products/1
echo ""

# Test 6: Validation
echo "6. Test validation (données manquantes):"
curl -X POST http://localhost:3002/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Produit Incomplet"}'
echo ""

# Test 7: État final
echo "7. État final des produits:"
curl -s http://localhost:3002/products
echo ""

echo "✅ Tests Product Service terminés!"

# Vérification dans la base de données
echo ""
echo "🗄️ Vérification en base de données:"
docker exec postgres-primary psql -U admin -d ecommerce -c "
SELECT '=== PRODUITS ===' as info;
SELECT id, name, price, stock FROM products ORDER BY id;
"
