#!/bin/bash

echo "🔌 REDÉMARRAGE DU PORT-FORWARD"
echo "=============================="

echo "🌐 Démarrage du port-forward pour user-service..."
echo "L'application sera accessible sur: http://localhost:30001"
echo ""
echo "📝 Gardez CE terminal ouvert"
echo "🛑 Appuyez sur Ctrl+C pour arrêter"
echo ""

# Vérification que le service existe
kubectl get service user-service -n microservices

# Démarrage du port-forward
kubectl port-forward -n microservices service/user-service 30001:3001
