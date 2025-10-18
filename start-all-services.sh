#!/bin/bash

echo "🔌 DÉMARRAGE DE TOUS LES SERVICES"
echo "================================"

echo "🚀 Démarrage des port-forwards..."
echo "Services accessibles sur:"
echo "  Frontend: http://localhost:30000"
echo "  User: http://localhost:30001/health"
echo "  Product: http://localhost:30002/health"
echo "  Order: http://localhost:30003/health"
echo "  Payment: http://localhost:30004/health"
echo "  Notification: http://localhost:30005/health"

# Démarrer tous les port-forwards
kubectl port-forward -n microservices service/frontend 30000:3000 &
kubectl port-forward -n microservices service/user-service 30001:3001 &
kubectl port-forward -n microservices service/product-service 30002:3002 &
kubectl port-forward -n microservices service/order-service 30003:3003 &
kubectl port-forward -n microservices service/payment-service 30004:3004 &
kubectl port-forward -n microservices service/notification-service 30005:3005 &

echo "✅ Tous les port-forwards démarrés"
echo "📝 Gardez ce terminal ouvert"
echo "🛑 Ctrl+C pour arrêter tout"

wait
