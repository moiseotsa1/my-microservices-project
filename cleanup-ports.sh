#!/bin/bash

echo "🧹 NETTOYAGE DES PORTS"
echo "===================="

echo "🛑 Arrêt de tous les port-forwards..."
pkill -f "kubectl port-forward"

echo "⏳ Attente de la libération des ports..."
sleep 3

echo "🔍 Vérification des processus restants..."
pgrep -f "kubectl port-forward" && echo "❌ Encore des processus" || echo "✅ Ports libérés"

echo ""
echo "🚀 Redémarrage des port-forwards..."
kubectl port-forward -n microservices service/user-service 30001:3001 &
kubectl port-forward -n microservices service/product-service 30002:3002 &
kubectl port-forward -n microservices service/order-service 30003:3003 &
kubectl port-forward -n microservices service/payment-service 30004:3004 &
kubectl port-forward -n microservices service/notification-service 30005:3005 &

echo "✅ Port-forwards redémarrés"
echo "📝 Gardez ce terminal ouvert"
echo "🌐 Ouvrez un NOUVEAU terminal pour: cd frontend && npm run dev"

wait
