#!/bin/bash

echo "☸️ CONFIGURATION KUBERNETES POUR PRODUCT SERVICE"
echo "=============================================="

# Déploiement Kubernetes
cat > kubernetes/manifests/microservices/product-service-deployment.yaml << 'K8SDEPLOY'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
  labels:
    app: product-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-service
  template:
    metadata:
      labels:
        app: product-service
    spec:
      containers:
      - name: product-service
        image: product-service:1.0
        ports:
        - containerPort: 3002
        env:
        - name: DB_HOST
          value: "postgres-primary"
        - name: DB_PORT
          value: "5432"
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        - name: DB_NAME
          value: "ecommerce"
        livenessProbe:
          httpGet:
            path: /health
            port: 3002
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3002
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
K8SDEPLOY

# Service Kubernetes
cat > kubernetes/manifests/microservices/product-service-service.yaml << 'K8SSVC'
apiVersion: v1
kind: Service
metadata:
  name: product-service
spec:
  selector:
    app: product-service
  ports:
  - port: 3002
    targetPort: 3002
  type: ClusterIP
K8SSVC

echo "✅ Configuration Kubernetes créée:"
echo "   - kubernetes/manifests/microservices/product-service-deployment.yaml"
echo "   - kubernetes/manifests/microservices/product-service-service.yaml"
