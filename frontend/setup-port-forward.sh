#!/bin/bash

echo "🔌 CONFIGURATION DE L'ACCÈS VIA PORT-FORWARD"
echo "==========================================="

echo "🌐 Démarrage du port-forward pour user-service..."
echo "L'application sera accessible sur: http://localhost:30001"
echo ""
echo "📝 Gardez ce terminal ouvert et ouvrez un NOUVEAU terminal pour les tests"
echo "🛑 Appuyez sur Ctrl+C pour arrêter le port-forward"
echo ""

# Démarrage du port-forward pour user-service
kubectl port-forward -n microservices service/user-service 30001:3001
