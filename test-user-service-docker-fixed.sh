#!/bin/bash

set -e

echo "🐳 Test du User Service avec Docker (version corrigée)..."

# Nettoyage des conteneurs existants
echo "🧹 Nettoyage des conteneurs existants..."
docker stop user-service postgres-primary postgres-replica 2>/dev/null || true
docker rm user-service postgres-primary postgres-replica 2>/dev/null || true

# Construction de l'image user-service
echo "🔨 Construction de l'image user-service..."
cd microservices/user-service
docker build -t user-service:1.0 .
cd ../..

# Démarrage de la base de données PostgreSQL avec Docker
echo "🗄️ Démarrage de PostgreSQL..."
docker run -d \
  --name postgres-primary \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=password123 \
  -e POSTGRES_DB=ecommerce \
  -p 5432:5432 \
  -v $(pwd)/database/init:/docker-entrypoint-initdb.d \
  postgres:13-alpine

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente du démarrage de PostgreSQL..."
until docker exec postgres-primary pg_isready -U admin; do
  sleep 2
done
echo "✅ PostgreSQL est prêt!"

# Initialisation de la base de données
echo "📊 Initialisation de la base de données..."
sleep 5

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
sleep 10

# Test du service
echo "🧪 Test health check..."
curl -s http://localhost:3001/health
echo ""

# Test de récupération des utilisateurs
echo "🧪 Test récupération des utilisateurs..."
curl -s http://localhost:3001/users
echo ""

# Test de création d'utilisateur
echo "🧪 Test de création d'utilisateur..."
curl -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test2@example.com", "name":"Test User 2"}'
echo ""

# Vérification que l'utilisateur a été créé
echo "🧪 Vérification des utilisateurs..."
curl -s http://localhost:3001/users
echo ""

echo "✅ User Service testé avec succès!"

# Affichage des logs pour debug
echo "📋 Logs du user-service:"
docker logs user-service --tail 20

echo ""
echo "📋 Prochaines étapes:"
echo "Pour arrêter les conteneurs: docker stop user-service postgres-primary"
echo "Pour voir les logs: docker logs user-service -f"
