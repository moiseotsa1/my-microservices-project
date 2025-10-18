#!/bin/bash

set -e

echo "🐳 Test du User Service avec Docker (version finale)..."

# Fonction pour attendre qu'un conteneur soit prêt
wait_for_container() {
    local container_name=$1
    local wait_time=0
    local max_wait=60
    
    echo "⏳ Attente du conteneur $container_name..."
    while [ $wait_time -lt $max_wait ]; do
        if docker ps --filter "name=$container_name" --filter "status=running" | grep -q "$container_name"; then
            echo "✅ Conteneur $container_name en cours d'exécution"
            return 0
        fi
        sleep 2
        wait_time=$((wait_time + 2))
        echo "   ...${wait_time}s"
    done
    echo "❌ Timeout en attendant le conteneur $container_name"
    return 1
}

wait_for_postgres() {
    local container_name=$1
    local wait_time=0
    local max_wait=30
    
    echo "⏳ Attente que PostgreSQL soit prêt dans $container_name..."
    while [ $wait_time -lt $max_wait ]; do
        if docker exec $container_name pg_isready -U admin > /dev/null 2>&1; then
            echo "✅ PostgreSQL dans $container_name est prêt!"
            return 0
        fi
        sleep 2
        wait_time=$((wait_time + 2))
        echo "   ...${wait_time}s"
    done
    echo "❌ Timeout en attendant PostgreSQL dans $container_name"
    return 1
}

# Nettoyage des conteneurs existants
echo "🧹 Nettoyage des conteneurs existants..."
docker stop user-service postgres-primary 2>/dev/null || true
docker rm user-service postgres-primary 2>/dev/null || true

# Construction de l'image user-service
echo "🔨 Construction de l'image user-service..."
cd microservices/user-service
docker build -t user-service:1.0 .
cd ../..

# Vérification si l'image PostgreSQL existe déjà
if ! docker images postgres:13-alpine | grep -q "13-alpine"; then
    echo "📥 Téléchargement de l'image PostgreSQL..."
    docker pull postgres:13-alpine
fi

# Démarrage de la base de données PostgreSQL avec Docker
echo "🗄️ Démarrage de PostgreSQL..."
docker run -d \
  --name postgres-primary \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=password123 \
  -e POSTGRES_DB=ecommerce \
  -p 5432:5432 \
  postgres:13-alpine

# Attendre que PostgreSQL soit prêt
wait_for_container "postgres-primary"
wait_for_postgres "postgres-primary"

# Initialisation de la base de données
echo "📊 Initialisation de la base de données..."
docker exec -i postgres-primary psql -U admin -d ecommerce << 'SQL'
-- Création des tables
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de données de test
INSERT INTO users (email, name) VALUES 
('test@example.com', 'Test User'),
('admin@example.com', 'Admin User')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (name, price, stock) VALUES 
('Laptop', 999.99, 10),
('Smartphone', 499.99, 25),
('Tablet', 299.99, 15)
ON CONFLICT DO NOTHING;

-- Vérification
SELECT 'Tables créées avec succès!' as status;
SELECT COUNT(*) as users_count FROM users;
SELECT COUNT(*) as products_count FROM products;
SQL

echo "✅ Base de données initialisée!"

# Démarrage du user-service
echo "🚀 Démarrage du user-service..."
docker run -d \
  --name user-service \
  -p 3001:3001 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_USER=admin \
  -e DB_PASSWORD=password123 \
  -e DB_NAME=ecommerce \
  --add-host=host.docker.internal:host-gateway \
  user-service:1.0

# Attendre le démarrage du service
echo "⏳ Attente du démarrage du user-service..."
wait_for_container "user-service"
sleep 8

# Test du service
echo "🧪 TESTS EN COURS..."
echo ""

# Test 1: Health check
echo "1. Test health check:"
response=$(curl -s -w "%{http_code}" http://localhost:3001/health)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 200 ]; then
    echo "   ✅ SUCCÈS: $body"
else
    echo "   ❌ ÉCHEC: Code HTTP $http_code"
    echo "   Response: $body"
fi

echo ""

# Test 2: Récupération des utilisateurs
echo "2. Test récupération des utilisateurs:"
response=$(curl -s -w "%{http_code}" http://localhost:3001/users)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 200 ]; then
    user_count=$(echo "$body" | grep -o '"email"' | wc -l || echo "0")
    echo "   ✅ SUCCÈS: $user_count utilisateur(s) trouvé(s)"
    echo "$body" | jq . 2>/dev/null || echo "   $body"
else
    echo "   ❌ ÉCHEC: Code HTTP $http_code"
    echo "   Response: $body"
fi

echo ""

# Test 3: Création d'un utilisateur
echo "3. Test création d'utilisateur:"
response=$(curl -s -w "%{http_code}" -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test-final@example.com", "name":"Test User Final"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 201 ]; then
    echo "   ✅ SUCCÈS: Utilisateur créé"
    echo "$body" | jq . 2>/dev/null || echo "   $body"
else
    echo "   ❌ ÉCHEC: Code HTTP $http_code"
    echo "   Response: $body"
fi

echo ""

# Test 4: Vérification finale
echo "4. Vérification finale des utilisateurs:"
curl -s http://localhost:3001/users | jq '. | length' | read user_count
echo "   📊 Nombre total d'utilisateurs: $user_count"

echo ""
echo "🔍 Affichage des logs du user-service (dernières 10 lignes):"
docker logs user-service --tail 10

echo ""
echo "✅ Tests terminés!"
echo ""
echo "📋 COMMANDES UTILES:"
echo "   Voir les logs: docker logs user-service -f"
echo "   Arrêter: docker stop user-service postgres-primary"
echo "   Redémarrer: docker start postgres-primary user-service"
echo "   Shell dans PostgreSQL: docker exec -it postgres-primary psql -U admin -d ecommerce"
