#!/bin/bash

echo "🔧 CORRECTION DES SELECTORS DES SERVICES"
echo "========================================"

# Liste des services à corriger
services=(
  "user-service:3001:30001"
  "product-service:3002:30002" 
  "order-service:3003:30003"
  "payment-service:3004:30004"
  "notification-service:3005:30005"
)

for service in "${services[@]}"; do
  name=$(echo $service | cut -d: -f1)
  port=$(echo $service | cut -d: -f2)
  nodeport=$(echo $service | cut -d: -f3)
  
  echo "🔗 Correction du service $name..."
  
  # Suppression du service existant
  kubectl delete service $name -n microservices 2>/dev/null && echo "  ✅ Service existant supprimé"
  
  # Création du service avec le bon selector
  cat > ${name}-service-fixed.yaml << SERVICE
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

  kubectl apply -f ${name}-service-fixed.yaml
  rm ${name}-service-fixed.yaml
  echo "  ✅ Service $name recréé avec le bon selector"
done

echo ""
echo "⏳ Attente de la configuration réseau..."
sleep 10

echo ""
echo "🔍 VÉRIFICATION:"
kubectl get services -n microservices

echo ""
echo "✅ CORRECTION TERMINÉE - Testez maintenant avec: curl http://localhost:30001/health"
