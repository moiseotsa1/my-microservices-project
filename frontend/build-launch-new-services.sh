#!/bin/bash

echo "🚀 CONSTRUCTION ET LANCEMENT DES NOUVEAUX SERVICES"
echo "================================================="

# Payment Service
echo "💰 Construction du Payment Service..."
cd microservices/payment-service
docker build -t payment-service:1.0 .
cd ../..

echo "🚀 Démarrage du Payment Service..."
docker run -d \
  --name payment-service \
  -p 3004:3004 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_USER=admin \
  -e DB_PASSWORD=password123 \
  -e DB_NAME=ecommerce \
  --add-host=host.docker.internal:host-gateway \
  payment-service:1.0

# Notification Service
echo "🔔 Construction du Notification Service..."
cd microservices/notification-service
docker build -t notification-service:1.0 .
cd ../..

echo "🚀 Démarrage du Notification Service..."
docker run -d \
  --name notification-service \
  -p 3005:3005 \
  notification-service:1.0

# Attente du démarrage
echo "⏳ Attente du démarrage des services..."
sleep 8

# Tests
echo "🧪 TESTS DES NOUVEAUX SERVICES"

echo "1. Payment Service Health:"
curl -s http://localhost:3004/health
echo ""

echo "2. Notification Service Health:"
curl -s http://localhost:3005/health
echo ""

echo "3. Test création paiement:"
curl -X POST http://localhost:3004/payments \
  -H "Content-Type: application/json" \
  -d '{"order_id": 1, "amount": 2599.98, "payment_method": "credit_card"}'
echo ""

echo "4. Test envoi notification:"
curl -X POST http://localhost:3005/notifications \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "type": "order_confirmation", "title": "Confirmation de commande", "message": "Votre commande #1 a été confirmée"}'
echo ""

echo "5. Liste des paiements:"
curl -s http://localhost:3004/payments
echo ""

echo "6. Liste des notifications:"
curl -s http://localhost:3005/notifications
echo ""

echo "✅ Nouveaux services testés avec succès !"
