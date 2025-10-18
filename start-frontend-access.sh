#!/bin/bash

echo "🔌 ACCÈS AU FRONTEND"
echo "==================="

echo "🌐 Démarrage du port-forward..."
echo "L'application sera accessible sur: http://localhost:30000"
echo ""
echo "📝 Gardez CE terminal ouvert"
echo "🛑 Appuyez sur Ctrl+C pour arrêter"
echo ""

kubectl port-forward -n microservices service/frontend 30000:3000
