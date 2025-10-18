#!/bin/bash

echo "🚀 DÉPLOIEMENT SUR KIND"
echo "======================"

# Vérification
kubectl cluster-info
kubectl get nodes

# Namespace
kubectl create namespace microservices --dry-run=client -o yaml | kubectl apply -f -

# Déploiement PostgreSQL avec NodePort pour l'accès externe
cat > postgres-kind.yaml << 'POSTGRES_KIND'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-primary
  namespace: microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-primary
  template:
    metadata:
      labels:
        app: postgres-primary
    spec:
      containers:
      - name: postgres
        image: postgres:13-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          value: "password123"
        - name: POSTGRES_DB
          value: "ecommerce"
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "200m"
      volumes:
      - name: postgres-data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-primary
  namespace: microservices
spec:
  selector:
    app: postgres-primary
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
POSTGRES_KIND

kubectl apply -f postgres-kind.yaml

# Attente PostgreSQL
echo "⏳ Attente de PostgreSQL..."
kubectl wait --for=condition=ready pod -l app=postgres-primary -n microservices --timeout=120s

# Déploiement des services avec NodePort
services=(
  "user-service:3001"
  "product-service:3002" 
  "order-service:3003"
  "payment-service:3004"
  "notification-service:3005"
  "frontend:3000"
)

for service in "${services[@]}"; do
  name=$(echo $service | cut -d: -f1)
  port=$(echo $service | cut -d: -f2)
  
  echo "🛠️ Déploiement de $name..."
  
  # Déploiement
  cat > ${name}-deployment.yaml << DEPLOYMENT
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $name
  namespace: microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $name
  template:
    metadata:
      labels:
        app: $name
    spec:
      containers:
      - name: $name
        image: $name:1.0
        ports:
        - containerPort: $port
        env:
        - name: DB_HOST
          value: "postgres-primary"
        - name: DB_PORT  
          value: "5432"
        - name: DB_USER
          value: "admin"
        - name: DB_PASSWORD
          value: "password123"
        - name: DB_NAME
          value: "ecommerce"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
DEPLOYMENT

  # Service NodePort
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
    nodePort: 3$(echo $port | cut -c2-)
  type: NodePort
SERVICE

  kubectl apply -f ${name}-deployment.yaml
  kubectl apply -f ${name}-service.yaml
  rm ${name}-deployment.yaml ${name}-service.yaml
done

# Attente
echo "⏳ Attente des services..."
sleep 30

# Vérification
echo "🔍 Vérification..."
kubectl get all -n microservices

echo ""
echo "🎉 DÉPLOIEMENT TERMINÉ !"
echo ""
echo "🌐 ACCÈS AUX SERVICES:"
echo "   Frontend:        http://localhost:30000"
echo "   User Service:    http://localhost:30001" 
echo "   Product Service: http://localhost:30002"
echo "   Order Service:   http://localhost:30003"
echo "   Payment Service: http://localhost:30004"
echo "   Notification:    http://localhost:30005"
echo ""
echo "🔧 COMMANDES:"
echo "   kubectl get pods -n microservices"
echo "   kubectl logs -f deployment/frontend -n microservices"
echo "   kubectl describe service frontend -n microservices"
