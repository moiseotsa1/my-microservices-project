# 🏗️ Architecture Microservices E-commerce

Une architecture microservices complète déployée sur Kubernetes avec 5 services backend, frontend React/Vue, et base de données PostgreSQL répliquée.

## 🚀 Fonctionnalités

- **🌐 Frontend** - Application React/Vue (Port 30000)
- **🚪 API Gateway** - Nginx avec routing intelligent (Port 32000)
- **👥 User Service** - Gestion des utilisateurs (Port 3001)
- **🛍️ Product Service** - Catalogue produits (Port 3002)
- **📦 Order Service** - Commandes (Port 3003)
- **💳 Payment Service** - Paiements (Port 3004)
- **🔔 Notification Service** - Notifications (Port 3005)
- **🗄️ PostgreSQL** - Base de données répliquée

## 🛠️ Technologies

- **Containerisation**: Docker
- **Orchestration**: Kubernetes
- **Base de Données**: PostgreSQL 13
- **Backend**: Node.js
- **Frontend**: React/Vue.js
- **API Gateway**: Nginx
- **Monitoring**: HPA, Health Checks

## 📦 Déploiement

\`\`\`bash
# Déployer l'application complète
kubectl apply -f k8s/

# Accéder à l'application
echo "🌐 Frontend: http://localhost:30000"
\`\`\`

## 🏗️ Architecture

\`\`\`
🌐 Frontend (30000)
    │
    └── 🚪 API Gateway (32000)
        │
        ├── 👥 User Service (3001) → PostgreSQL
        ├── 🛍️ Product Service (3002) → PostgreSQL
        ├── 📦 Order Service (3003) → PostgreSQL
        ├── 💳 Payment Service (3004) → PostgreSQL
        └── 🔔 Notification Service (3005) → Mémoire
\`\`\`

## 🔧 Commandes Utiles

\`\`\`bash
# Surveillance
kubectl get pods -n microservices -w

# Logs
kubectl logs -f deployment/user-service -n microservices

# Scale
kubectl scale deployment user-service --replicas=3 -n microservices
\`\`\`

## 📊 Performance

- ✅ Tests de charge: 84 req/s, 0% erreur
- ✅ Auto-scaling horizontal configuré
- ✅ Health checks et résilience
- ✅ Base de données répliquée
# GitLab CI/CD Trigger - Sun, Oct 19, 2025 11:01:52 PM
