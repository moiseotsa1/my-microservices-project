#!/bin/bash

echo "🗄️ CRÉATION DE LA TABLE ORDERS"
echo "=============================="

docker exec postgres-primary psql -U admin -d ecommerce << 'SQL'
-- Table des commandes
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des paiements
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
(2, 499.99, 'confirmed'),
(1, 299.99, 'shipped');

-- Vérification
SELECT '=== TABLES CRÉÉES AVEC SUCCÈS ===' as info;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

SELECT '=== DONNÉES INSÉRÉES ===' as info;
SELECT 'Commandes: ' || COUNT(*) FROM orders;
SELECT 'Paiements: ' || COUNT(*) FROM payments;

SELECT '=== DÉTAILS COMMANDES ===' as info;
SELECT o.id, u.name as client, o.total, o.status, o.created_at
FROM orders o
JOIN users u ON o.user_id = u.id
ORDER BY o.id;
SQL

echo "✅ Tables orders et payments créées avec succès !"
