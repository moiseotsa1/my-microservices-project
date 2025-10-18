#!/bin/bash

echo "🗄️ CRÉATION DES TABLES ORDERS ET PAYMENTS"
echo "========================================="

docker exec postgres-primary psql -U admin -d ecommerce << 'SQL'
-- Table des commandes
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des paiements
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de données de test pour les commandes
INSERT INTO orders (user_id, total, status) VALUES 
(1, 2599.98, 'pending'),
(2, 499.99, 'confirmed'),
(1, 299.99, 'shipped')
ON CONFLICT DO NOTHING;

-- Vérification
SELECT '=== TABLES CRÉÉES ===' as info;
SELECT table_name, 
       (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as columns
FROM information_schema.tables t 
WHERE table_schema = 'public' AND table_name IN ('orders', 'payments')
ORDER BY table_name;

SELECT '=== DONNÉES DE TEST ===' as info;
SELECT 'Commandes: ' || COUNT(*) FROM orders;
SELECT 'Paiements: ' || COUNT(*) FROM payments;

SELECT '=== DÉTAILS COMMANDES ===' as info;
SELECT o.id, u.name as user_name, o.total, o.status, o.created_at
FROM orders o
JOIN users u ON o.user_id = u.id
ORDER BY o.id;
SQL

echo "✅ Tables orders et payments créées avec des données de test !"
