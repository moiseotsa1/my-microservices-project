#!/bin/bash

echo "🐳 CONSTRUCTION RAPIDE DES IMAGES"
echo "================================"

# Construction des images localement d'abord
services=("user-service" "product-service" "order-service" "payment-service" "notification-service")

for service in "${services[@]}"; do
    echo "🔨 Construction de $service..."
    if [ -d "microservices/$service" ]; then
        cd "microservices/$service"
        docker build -t $service:1.0 .
        cd ../..
    fi
done

# Frontend
echo "🎨 Construction du frontend..."
cd frontend
docker build -t frontend:1.0 .
cd ..

# Chargement dans Kind
echo "🚚 Chargement des images dans Kind..."
for service in "${services[@]}"; do
    kind load docker-image $service:1.0 --name microservices
done
kind load docker-image frontend:1.0 --name microservices

echo "✅ Images construites et chargées !"
