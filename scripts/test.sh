#!/bin/bash

echo "🧪 Tests du déploiement Kubernetes..."

# Vérification des pods
echo "1. Vérification des pods..."
kubectl get pods -o wide

# Vérification des services
echo -e "\n2. Vérification des services..."
kubectl get services

# Vérification de la base de données
echo -e "\n3. Test de la base de données..."
kubectl exec -it deployment/postgres-primary -- psql -U admin -d ecommerce -c "SELECT COUNT(*) FROM users;"

# Test du user-service
echo -e "\n4. Test du user-service..."
kubectl port-forward service/user-service 3001:3001 &
PORT_FORWARD_PID=$!

sleep 5

# Test health check
curl -s http://localhost:3001/health
echo ""

# Test création d'utilisateur
curl -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{"email":"kubernetes@example.com", "name":"K8s User"}'
echo ""

# Nettoyage
kill $PORT_FORWARD_PID

echo -e "\n✅ Tests terminés avec succès!"
