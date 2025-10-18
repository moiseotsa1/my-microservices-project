#!/bin/bash

echo "🔧 CORRECTION DES DÉPENDANCES NOTIFICATION-SERVICE"
echo "================================================"

echo "1. 📋 Analyse de l'erreur..."
kubectl logs -l app=notification-service -n microservices --tail=20

echo ""
echo "2. 🐳 Reconstruction avec correction des dépendances..."
cd microservices/notification-service

# Vérification du package.json
cat package.json

# Reconstruction avec npm install forcé
docker build --no-cache -t notification-service:1.0 .

cd ../..

echo "3. 🚚 Rechargement dans Kind..."
kind load docker-image notification-service:1.0 --name microservices

echo "4. 🔄 Redémarrage du déploiement..."
kubectl rollout restart deployment/notification-service -n microservices

echo "5. ⏳ Attente du démarrage..."
sleep 20

echo "6. 🔍 Vérification finale..."
kubectl get pods -n microservices -l app=notification-service
kubectl logs -l app=notification-service -n microservices --tail=10

echo ""
echo "✅ CORRECTION APPLIQUÉE"
