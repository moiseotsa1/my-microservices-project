#!/bin/bash

echo "🚀 UTILISATION DU FRONTEND LOCAL"
echo "================================"

echo "1. 🔄 Arrêt du frontend Kubernetes..."
kubectl scale deployment/frontend --replicas=0 -n microservices

echo "2. 🌐 Démarrage des port-forwards pour tous les services..."
echo "   Gardez CE terminal ouvert"

# Démarrer tous les port-forwards
kubectl port-forward -n microservices service/user-service 30001:3001 &
kubectl port-forward -n microservices service/product-service 30002:3002 &
kubectl port-forward -n microservices service/order-service 30003:3003 &
kubectl port-forward -n microservices service/payment-service 30004:3004 &
kubectl port-forward -n microservices service/notification-service 30005:3005 &

echo "✅ Tous les services sont accessibles sur localhost:30001-30005"

echo ""
echo "3. 🎨 Démarrage du frontend local..."
echo "   Ouvrez un NOUVEAU terminal et exécutez:"
echo "   cd frontend && npm run dev"
echo ""
echo "4. 🌐 Accédez à: http://localhost:3000"
echo ""
echo "📝 Ce terminal reste ouvert pour les port-forwards"
echo "🛑 Ctrl+C pour tout arrêter"

wait
