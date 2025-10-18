#!/bin/bash

set -e

echo "🧪 TESTS COMPLETS DU USER SERVICE"
echo "=================================="

# Fonction pour formater les résultats de test
print_test_result() {
    local test_name=$1
    local success=$2
    if [ "$success" = true ]; then
        echo "✅ $test_name"
    else
        echo "❌ $test_name"
    fi
}

# Variables pour suivre les résultats
all_tests_passed=true

# Test 1: Health Check
echo ""
echo "1. TEST HEALTH CHECK"
response=$(curl -s -w "\n%{http_code}" http://localhost:3001/health)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 200 ]; then
    print_test_result "Health check retourne 200" true
    echo "   Response: $body"
else
    print_test_result "Health check retourne 200" false
    all_tests_passed=false
fi

# Test 2: Récupération de tous les utilisateurs
echo ""
echo "2. TEST RÉCUPÉRATION UTILISATEURS"
response=$(curl -s -w "\n%{http_code}" http://localhost:3001/users)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 200 ]; then
    print_test_result "GET /users retourne 200" true
    user_count=$(echo "$body" | grep -o '"email"' | wc -l)
    echo "   Nombre d'utilisateurs: $user_count"
    echo "   Données: $body"
else
    print_test_result "GET /users retourne 200" false
    all_tests_passed=false
fi

# Test 3: Création d'un nouvel utilisateur
echo ""
echo "3. TEST CRÉATION UTILISATEUR"
response=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test-complet@example.com", "name":"Test Complet"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 201 ]; then
    print_test_result "POST /users retourne 201" true
    echo "   Utilisateur créé: $body"
    
    # Extraire l'ID de l'utilisateur créé
    user_id=$(echo "$body" | grep -o '"id":[0-9]*' | cut -d: -f2)
    echo "   ID de l'utilisateur créé: $user_id"
else
    print_test_result "POST /users retourne 201" false
    echo "   Erreur: $body"
    all_tests_passed=false
fi

# Test 4: Récupération d'un utilisateur spécifique
echo ""
echo "4. TEST RÉCUPÉRATION UTILISATEUR SPÉCIFIQUE"
if [ ! -z "$user_id" ]; then
    response=$(curl -s -w "\n%{http_code}" "http://localhost:3001/users/$user_id")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)

    if [ "$http_code" -eq 200 ]; then
        print_test_result "GET /users/{id} retourne 200" true
        echo "   Utilisateur trouvé: $body"
    else
        print_test_result "GET /users/{id} retourne 200" false
        all_tests_passed=false
    fi
else
    echo "⚠️  Test skipped - aucun ID d'utilisateur disponible"
fi

# Test 5: Test de validation (email manquant)
echo ""
echo "5. TEST VALIDATION (EMAIL MANQUANT)"
response=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Sans Email"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 400 ]; then
    print_test_result "Validation échoue correctement (400)" true
    echo "   Message d'erreur: $body"
else
    print_test_result "Validation échoue correctement (400)" false
    all_tests_passed=false
fi

# Test 6: Test de validation (nom manquant)
echo ""
echo "6. TEST VALIDATION (NOM MANQUANT)"
response=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{"email":"sans-nom@example.com"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 400 ]; then
    print_test_result "Validation échoue correctement (400)" true
    echo "   Message d'erreur: $body"
else
    print_test_result "Validation échoue correctement (400)" false
    all_tests_passed=false
fi

# Test 7: Test utilisateur non existant
echo ""
echo "7. TEST UTILISATEUR NON EXISTANT"
response=$(curl -s -w "\n%{http_code}" "http://localhost:3001/users/9999")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 404 ]; then
    print_test_result "Utilisateur non trouvé retourne 404" true
    echo "   Message: $body"
else
    print_test_result "Utilisateur non trouvé retourne 404" false
    all_tests_passed=false
fi

# Test 8: Vérification finale de l'état des données
echo ""
echo "8. ÉTAT FINAL DES DONNÉES"
response=$(curl -s http://localhost:3001/users)
user_count=$(echo "$response" | grep -o '"email"' | wc -l)
echo "   Nombre total d'utilisateurs dans la base: $user_count"
echo "   Liste complète: $response"

# Test 9: Performance et résilience
echo ""
echo "9. TEST DE PERFORMANCE"
start_time=$(date +%s%3N)
for i in {1..5}; do
    curl -s http://localhost:3001/health > /dev/null
done
end_time=$(date +%s%3N)
duration=$((end_time - start_time))
echo "   5 requêtes health check en ${duration}ms"

# Résumé final
echo ""
echo "=================================="
if [ "$all_tests_passed" = true ]; then
    echo "🎉 TOUS LES TESTS SONT RÉUSSIS !"
    echo "✅ User Service est complètement opérationnel"
else
    echo "⚠️  Certains tests ont échoué"
    echo "💡 Vérifiez les logs pour plus de détails"
fi
echo "=================================="

# Affichage des logs récents
echo ""
echo "📋 LOGS RÉCENTS DU USER SERVICE:"
docker logs user-service --tail 15
