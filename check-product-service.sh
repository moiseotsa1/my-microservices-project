#!/bin/bash

echo "🛍️ VÉRIFICATION DU PRODUCT-SERVICE"
echo "================================"

echo "1. 🔍 État du pod:"
kubectl get pods -n microservices -l app=product-service

echo ""
echo "2. 📋 Logs:"
kubectl logs -l app=product-service -n microservices --tail=10

echo ""
echo "3. 🌐 Test via port-forward:"
echo "   Dans un terminal: kubectl port-forward -n microservices service/product-service 30002:3002"
echo "   Dans un autre: curl http://localhost:30002/health"
