#!/bin/bash

echo "🔧 CORRECTION DES PORTS DU FRONTEND LOCAL"
echo "========================================"

cd frontend

# Modification du fichier App.jsx pour utiliser localhost:30001-30005
echo "📝 Modification de la configuration..."
sed -i 's|http://localhost:3001|http://localhost:30001|g' src/App.jsx
sed -i 's|http://localhost:3002|http://localhost:30002|g' src/App.jsx
sed -i 's|http://localhost:3003|http://localhost:30003|g' src/App.jsx
sed -i 's|http://localhost:3004|http://localhost:30004|g' src/App.jsx
sed -i 's|http://localhost:3005|http://localhost:30005|g' src/App.jsx

echo "✅ Configuration modifiée"
echo "🔄 Redémarrage du serveur de développement..."
echo ""
echo "🌐 Le frontend utilisera maintenant les ports 30001-30005"
echo "📝 Gardez les port-forwards ouverts dans l'autre terminal"
