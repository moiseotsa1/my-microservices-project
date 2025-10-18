#!/bin/bash

echo "🔌 DÉMARRAGE DES PORT-FORWARDS"
echo "=============================="

echo "🚀 Démarrage en arrière-plan:"
kubectl port-forward -n microservices service/frontend 30000:3000 &
kubectl port-forward -n microservices service/user-service 30001:3001 &
kubectl port-forward -n microservices service/product-service 30002:3002 &
kubectl port-forward -n microservices service/order-service 30003:3003 &
kubectl port-forward -n microservices service/payment-service 30004:3004 &
kubectl port-forward -n microservices service/notification-service 30005:3005 &

echo "✅ Tous les port-forwards démarrés"
echo "🌐 Frontend: http://localhost:30000"
echo "📝 Gardez ce terminal ouvert"
echo "🛑 Ctrl+C pour arrêter"

# Garder le script en vie
wait
