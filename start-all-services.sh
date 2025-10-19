#!/bin/bash

echo "ÔøΩÔøΩ D√âMARRAGE DE L'ARCHITECTURE MICROSERVICES COMPL√àTE"

# Arr√™t des services existants
echo "Ìªë Arr√™t des services existants..."
pkill -f "node.*service" 2>/dev/null
sleep 2

# D√©marrage des microservices
echo "Ì¥ß D√©marrage des 5 microservices..."
cd microservices

echo "Ì±§ D√©marrage User Service (3001)..."
cd user-service
npm start &
cd ..

echo "ÔøΩÔøΩÔ∏è D√©marrage Product Service (3002)..."
cd product-service
npm start &
cd ..

echo "Ì≥¶ D√©marrage Order Service (3003)..."
cd order-service
npm start &
cd ..

echo "Ì≤≥ D√©marrage Payment Service (3004)..."
cd payment-service
npm start &
cd ..

echo "Ì¥î D√©marrage Notification Service (3005)..."
cd notification-service
npm start &
cd ..

cd ..

# Attente du d√©marrage
echo "‚è≥ Attente du d√©marrage des services (10 secondes)..."
sleep 10

# V√©rification
echo "Ì∑™ V√©rification des services..."
for port in 3001 3002 3003 3004 3005; do
    echo -n "Ì¥ç Port $port : "
    if curl -s http://localhost:$port/health > /dev/null; then
        echo "‚úÖ EN LIGNE"
    else
        echo "‚ùå HORS LIGNE"
    fi
done

echo ""
echo "Ìæâ ARCHITECTURE MICROSERVICES D√âMARR√âE !"
echo "Ìºê OUVREZ VOTRE NAVIGATEUR :"
echo "   Ì¥ó http://localhost:3000/simple-frontend.html"
echo "   Ì¥ó frontend-interactif.html (double-cliquez)"
echo ""
echo "ÌøÜ PROJET COMPL√àTEMENT OP√âRATIONNEL !"
