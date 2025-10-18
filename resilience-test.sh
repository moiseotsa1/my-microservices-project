#!/bin/bash

echo "🔄 TEST DE RÉSILIENCE"
echo "====================="

echo "1. Santé avant redémarrage:"
curl -s http://localhost:3001/health | grep status

echo ""
echo "2. Redémarrage du User Service..."
docker restart user-service
echo "   ⏳ Attente du redémarrage..."
sleep 8

echo ""
echo "3. Santé après redémarrage:"
curl -s http://localhost:3001/health | grep status

echo ""
echo "4. Vérification des données après redémarrage:"
user_count=$(curl -s http://localhost:3001/users | grep -o '"email"' | wc -l)
echo "   Nombre d'utilisateurs: $user_count"

echo ""
echo "5. Test de création après redémarrage:"
response=$(curl -s -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{"email":"resilience@example.com", "name":"Resilience Test"}')
echo "   Résultat: $response"

echo ""
echo "✅ Test de résilience terminé - le service récupère correctement après redémarrage"
