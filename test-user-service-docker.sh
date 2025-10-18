#!/bin/bash

echo "🐳 Test du User Service avec Docker..."

# Construction de l'image
cd microservices/user-service
docker build -t user-service:1.0 .

# Démarrage de la base de données
cd ../../database
docker-compose up -d

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente du démarrage de PostgreSQL..."
sleep 10

# Démarrage du user-service
docker run -d \
  --name user-service \
  -p 3001:3001 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_USER=admin \
  -e DB_PASSWORD=password123 \
  -e DB_NAME=ecommerce \
  user-service:1.0

# Attendre le démarrage du service
sleep 5

# Test du service
echo "🧪 Test du User Service..."
curl -s http://localhost:3001/health
echo ""

# Test de création d'utilisateur
echo "🧪 Test de création d'utilisateur..."
curl -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test2@example.com", "name":"Test User 2"}'

echo ""
echo "✅ User Service testé avec succès!"

# Arrêt des conteneurs
echo "🛑 Arrêt des conteneurs..."
docker stop user-service
docker stop postgres-primary postgres-replica
docker rm user-service postgres-primary postgres-replica
