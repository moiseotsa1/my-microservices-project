#!/bin/bash

echo "📋 VERIFICATION DES LOGS USER-SERVICE"
echo "===================================="

echo "🔍 Logs du user-service:"
kubectl logs -l app=user-service -n microservices --tail=20

echo ""
echo "🐳 Vérification de la connexion à PostgreSQL:"
kubectl exec -it deployment/user-service -n microservices -- nslookup postgres-primary
