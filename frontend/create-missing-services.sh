#!/bin/bash

echo "🔧 CRÉATION DES SERVICES MANQUANTS"
echo "================================"

# Services à créer avec leurs ports
services=(
  "user-service:3001:30001"
  "product-service:3002:30002" 
  "order-service:3003:30003"
  "payment-service:3004:30004"
  "notification-service:3005:30005"
  "frontend:3000:30000"
)

for service in "${services[@]}"; do
  name=$(echo $service | cut -d: -f1)
  port=$(echo $service | cut -d: -f2)
  nodeport=$(echo $service | cut -d: -f3)
  
  echo "🌐 Création du service $name sur le port $nodeport..."
  
  # Vérification si le service existe déjà
  if kubectl get service $name -n microservices &>/dev/null; then
    echo "✅ Service $name existe déjà"
  else
    # Création du service NodePort
    cat > ${name}-service.yaml << SERVICE
apiVersion: v1
kind: Service
metadata:
  name: $name
  namespace: microservices
spec:
  selector:
    app: $name
  ports:
  - port: $port
    targetPort: $port
    nodePort: $nodeport
  type: NodePort
SERVICE

    kubectl apply -f ${name}-service.yaml
    rm ${name}-service.yaml
    echo "✅ Service $name créé"
  fi
done

# Vérification
echo ""
echo "🔍 VÉRIFICATION DES SERVICES:"
kubectl get services -n microservices

echo ""
echo "🌐 PORTS D'ACCÈS:"
echo "   Frontend:        http://localhost:30000"
echo "   User Service:    http://localhost:30001"
echo "   Product Service: http://localhost:30002"
echo "   Order Service:   http://localhost:30003"
echo "   Payment Service: http://localhost:30004"
echo "   Notification:    http://localhost:30005"
