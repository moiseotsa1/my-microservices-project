#!/bin/bash

echo "🔄 RECRÉATION COMPLÈTE DE LA STRUCTURE DE BASE DE DONNÉES"
echo "========================================================"

# Arrêt des services qui utilisent la base
docker stop order-service product-service user-service 2>/dev/null || true

# Recréation complète du schéma
docker exec postgres-primary psql -U admin -d ecommerce << 'SQL'
-- Suppression des tables existantes
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Création des tables dans le bon ordre
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

-- Réinsertion des données de base
INSERT INTO users (email, name) VALUES 
('test@example.com', 'Test User'),
('admin@example.com', 'Admin User'),
('client1@example.com', 'Client One'),
('client2@example.com', 'Client Two');

INSERT INTO products (name, price, stock) VALUES 
('Laptop Gaming', 1299.99, 8),
('Smartphone', 499.99, 25),
('Tablet', 299.99, 15),
('Headphones', 199.99, 30);

INSERT INTO orders (user_id, total, status) VALUES 
(1, 2599.98, 'pending'),
(2, 499.99, 'confirmed'),
(1, 299.99, 'shipped'),
(3, 199.99, 'delivered');

-- Vérification finale
SELECT '=== SCHÉMA COMPLET ===' as info;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

SELECT '=== DONNÉES ===' as info;
SELECT 'Utilisateurs: ' || COUNT(*) FROM users;
SELECT 'Produits: ' || COUNT(*) FROM products;
SELECT 'Commandes: ' || COUNT(*) FROM orders;
SELECT 'Paiements: ' || COUNT(*) FROM payments;
SQL

echo "✅ Structure de base de données recréée avec succès !"

# Redémarrage des services
echo ""
echo "🔄 Redémarrage des services..."
docker start user-service product-service order-service
sleep 8

echo "✅ Services redémarrés"
