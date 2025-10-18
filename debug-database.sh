#!/bin/bash

echo "🔍 DIAGNOSTIC DE LA BASE DE DONNÉES"
echo "==================================="

echo "1. 📊 Liste des bases de données:"
docker exec postgres-primary psql -U admin -l

echo ""
echo "2. 🗃️ Connexion à la base 'ecommerce' et vérification des tables:"
docker exec postgres-primary psql -U admin -d ecommerce -c "
SELECT current_database();
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
"

echo ""
echo "3. 🔄 Redémarrage du Order Service:"
docker restart order-service
sleep 5

echo ""
echo "4. 🧪 Test de connexion du Order Service:"
curl -s http://localhost:3003/health
echo ""

echo ""
echo "5. 📝 Tentative de création manuelle de la table orders:"
docker exec postgres-primary psql -U admin -d ecommerce -c "
DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de données de test
INSERT INTO orders (user_id, total, status) VALUES 
(1, 2599.98, 'pending'),
(2, 499.99, 'confirmed');

SELECT '=== TABLES CRÉÉES ===' as info;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN ('orders', 'payments');

SELECT '=== DONNÉES INSÉRÉES ===' as info;
SELECT * FROM orders;
"
