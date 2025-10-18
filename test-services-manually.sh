#!/bin/bash

echo "🧪 TEST MANUEL DES SERVICES"
echo "==========================="

# Test du user-service
echo "1. 🔍 Test user-service:"
kubectl exec -it deployment/frontend -n microservices -- curl -s http://user-service:3001/health || echo "❌ Échec user-service"

echo ""
echo "2. 🔍 Test product-service:"
kubectl exec -it deployment/frontend -n microservices -- curl -s http://product-service:3002/health || echo "❌ Échec product-service"

echo ""
echo "3. 🔍 Test depuis l'extérieur:"
echo "   User Service:"
curl -s http://localhost:30001/health || echo "❌ Hors ligne"
echo "   Product Service:"
curl -s http://localhost:30002/health || echo "❌ Hors ligne"
echo "   Order Service:"
curl -s http://localhost:30003/health || echo "❌ Hors ligne"

echo ""
echo "4. 📋 Logs du frontend:"
kubectl logs -l app=frontend -n microservices --tail=10 | grep -i "error\|fail\|offline" || echo "✅ Aucune erreur détectée"
