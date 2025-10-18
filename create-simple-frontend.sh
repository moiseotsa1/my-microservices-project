#!/bin/bash

echo "🎨 CRÉATION D'UN FRONTEND STATIQUE SIMPLE"
echo "========================================"

cd frontend

# Création d'un fichier HTML statique simple
cat > dist/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Microservices Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .service { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
        .online { color: green; }
        .offline { color: red; }
    </style>
</head>
<body>
    <h1>🚀 Microservices Dashboard</h1>
    
    <div class="service">
        <h2>👥 User Service</h2>
        <p id="user-status">Test en cours...</p>
    </div>
    
    <div class="service">
        <h2>🛍️ Product Service</h2>
        <p id="product-status">Test en cours...</p>
    </div>

    <script>
        // Test des services
        async function testService(url, elementId) {
            try {
                const response = await fetch(url);
                const data = await response.json();
                document.getElementById(elementId).innerHTML = 
                    `<span class="online">✅ EN LIGNE - ${data.status}</span>`;
            } catch (error) {
                document.getElementById(elementId).innerHTML = 
                    `<span class="offline">❌ HORS LIGNE</span>`;
            }
        }

        // Tester tous les services
        testService('http://localhost:30001/health', 'user-status');
        testService('http://localhost:30002/health', 'product-status');
    </script>
</body>
</html>
HTML

# Construction
docker build -t frontend:1.0 .
cd ..
kind load docker-image frontend:1.0 --name microservices
kubectl rollout restart deployment/frontend -n microservices

echo "✅ FRONTEND STATIQUE CRÉÉ"
echo "🌐 Accédez à: http://localhost:30000"
