#!/bin/bash

echo "🧪 TEST DE TOUS LES SERVICES"
echo "==========================="

services=(
  "frontend:30000"
  "user-service:30001"
  "product-service:30002"
  "order-service:30003" 
  "payment-service:30004"
  "notification-service:30005"
)

for service in "${services[@]}"; do
  name=$(echo $service | cut -d: -f1)
  port=$(echo $service | cut -d: -f2)
  
  echo "🔍 Test de $name sur le port $port..."
  if curl -s --connect-timeout 5 http://localhost:$port/health > /dev/null; then
    echo "✅ $name: EN LIGNE"
    curl -s http://localhost:$port/health | head -1
  else
    echo "❌ $name: HORS LIGNE"
  fi
  echo ""
done
