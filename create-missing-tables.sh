#!/bin/bash

echo "🗄️ CRÉATION DES TABLES MANQUANTES"
echo "================================"

docker exec postgres-primary psql -U admin -d ecommerce << 'SQL'
-- Table des commandes (manquante)
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des paiements (manquante)
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vérification du schéma complet
SELECT '=== SCHÉMA COMPLET ===' as info;
SELECT table_name, 
       (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as columns
FROM information_schema.tables t 
WHERE table_schema = 'public' 
ORDER BY table_name;

SELECT '=== DONNÉES ACTUELLES ===' as info;
SELECT 'Utilisateurs: ' || COUNT(*) FROM users
UNION ALL
SELECT 'Produits: ' || COUNT(*) FROM products
UNION ALL  
SELECT 'Commandes: ' || COUNT(*) FROM orders
UNION ALL
SELECT 'Paiements: ' || COUNT(*) FROM payments;
SQL

echo "✅ Schéma de base de données complété !"
