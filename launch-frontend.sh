#!/bin/bash

echo "🚀 LANCEMENT DU FRONTEND"
echo "========================"

cd frontend

echo "📦 Installation des dépendances..."
npm install

echo "🌐 Démarrage du serveur de développement..."
echo ""
echo "✅ Le frontend sera accessible sur: http://localhost:3000"
echo "📊 Tableau de bord en temps réel de vos microservices"
echo ""
echo "Appuyez sur Ctrl+C pour arrêter le serveur"

npm run dev
