#!/bin/bash

echo "⚡ TEST DE CHARGE SIMPLE"
echo "========================"

echo "1. Test de 10 requêtes health check rapides:"
for i in {1..10}; do
    curl -s http://localhost:3001/health > /dev/null &
done
wait
echo "   ✅ 10 requêtes simultanées terminées"

echo ""
echo "2. Test de création multiple d'utilisateurs:"
for i in {1..3}; do
    response=$(curl -s -X POST http://localhost:3001/users \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"loadtest$i@example.com\", \"name\":\"Load Test $i\"}")
    echo "   Utilisateur $i: $response"
done

echo ""
echo "3. Vérification après test de charge:"
curl -s http://localhost:3001/users | grep -o '"email"' | wc -l | awk '{print "   Nombre total d'\''utilisateurs: "$1}'
