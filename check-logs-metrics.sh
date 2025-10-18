#!/bin/bash

echo "📊 MÉTRIQUES ET LOGS DÉTAILLÉS"
echo "=============================="

echo "1. État des conteneurs:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "2. Utilisation des ressources:"
echo "   User Service:"
docker stats user-service --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo ""
echo "3. Logs du User Service (dernières 20 lignes):"
docker logs user-service --tail 20

echo ""
echo "4. Logs de PostgreSQL (dernières 10 lignes):"
docker logs postgres-primary --tail 10

echo ""
echo "5. Connexions base de données actives:"
docker exec postgres-primary psql -U admin -d ecommerce -c "
SELECT datname, numbackends, xact_commit, xact_rollback 
FROM pg_stat_database WHERE datname = 'ecommerce';
"
