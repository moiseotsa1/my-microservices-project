#!/bin/bash
echo "Initialisation de la base de données..."

# Attendre PostgreSQL
until PGPASSWORD=password123 psql -h postgres-primary -U admin -d ecommerce -c "SELECT 1;" > /dev/null 2>&1; do
  echo "En attente de PostgreSQL..."
  sleep 5
done

# Exécuter les commandes SQL
PGPASSWORD=password123 psql -h postgres-primary -U admin -d ecommerce << SQL
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  total DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Données de test
INSERT INTO users (name, email) VALUES 
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (name, price, stock) VALUES 
('Laptop', 999.99, 10),
('Mouse', 29.99, 50),
('Keyboard', 79.99, 30)
ON CONFLICT (name) DO NOTHING;

INSERT INTO orders (user_id, total, status) VALUES 
(1, 1029.98, 'completed'),
(2, 29.99, 'pending')
ON CONFLICT DO NOTHING;
SQL

echo "✅ Base de données initialisée !"
