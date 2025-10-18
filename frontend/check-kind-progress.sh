#!/bin/bash

echo "🔍 VÉRIFICATION DE LA PROGRESSION KIND"
echo "======================================"

# Vérification si le cluster est en cours de création
if docker ps | grep -q "kind"; then
    echo "✅ Kind est en cours de création..."
    echo "📊 État des conteneurs:"
    docker ps | grep kind
    echo ""
    echo "⏳ Patientez, cela peut prendre 2-5 minutes..."
else
    echo "❌ Aucun cluster Kind détecté"
    echo "💡 Redémarrez l'installation: ./quick-kind-setup.sh"
fi
