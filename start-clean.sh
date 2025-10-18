#!/bin/bash

echo "🚀 DÉMARRAGE PROPRE"
echo "=================="

echo "🛑 Arrêt de tous les port-forwards..."
pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 2

echo "🔧 Démarrage des port-forwards..."
kubectl port-forward -n microservices service/user-service 30001:3001 &
kubectl port-forward -n microservices service/product-service 30002:3002 &
kubectl port-forward -n microservices service/order-service 30003:3003 &
kubectl port-forward -n microservices service/payment-service 30004:3004 &
kubectl port-forward -n microservices service/notification-service 30005:3005 &

echo "⏳ Attente du démarrage..."
sleep 5

echo "🔍 Test des services..."
curl -s http://localhost:30001/health && echo " ✅ User Service OK" || echo " ❌ User Service échoué"
curl -s http://localhost:30002/health && echo " ✅ Product Service OK" || echo " ❌ Product Service échoué"
curl -s http://localhost:30003/health && echo " ✅ Order Service OK" || echo " ❌ Order Service échoué"
curl -s http://localhost:30004/health && echo " ✅ Payment Service OK" || echo " ❌ Payment Service échoué"
curl -s http://localhost:30005/health && echo " ✅ Notification Service OK" || echo " ❌ Notification Service échoué"

echo ""
echo "✅ PORT-FORWARDS DÉMARRÉS"
echo "📝 Gardez CE terminal ouvert"
echo "🌐 Ouvrez un NOUVEAU terminal pour le frontend"

wait
