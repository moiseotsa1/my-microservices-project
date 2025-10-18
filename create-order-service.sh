#!/bin/bash

echo "📦 CRÉATION DU ORDER SERVICE"
echo "============================"

# Création des dossiers si nécessaire
mkdir -p microservices/order-service/src

# Dockerfile pour order-service
cat > microservices/order-service/Dockerfile << 'DOCKERFILE'
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY src/ ./src/
EXPOSE 3003
CMD ["npm", "start"]
DOCKERFILE

# package.json pour order-service
cat > microservices/order-service/package.json << 'PKGJSON'
{
  "name": "order-service",
  "version": "1.0.0",
  "description": "Order Management Microservice",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.8.0",
    "cors": "^2.8.5",
    "helmet": "^6.0.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
PKGJSON

# Application order-service
cat > microservices/order-service/src/app.js << 'APPJS'
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3003;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Configuration de la base de données
const pool = new Pool({
  user: process.env.DB_USER || 'admin',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'ecommerce',
  password: process.env.DB_PASSWORD || 'password123',
  port: process.env.DB_PORT || 5432,
});

// Test de connexion au démarrage
pool.on('connect', () => {
  console.log('✅ Order Service - Connexion DB établie');
});

pool.on('error', (err) => {
  console.error('❌ Order Service - Erreur DB:', err);
});

// Routes
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ 
      status: 'OK', 
      service: 'order-service',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    console.error('Health check failed:', err);
    res.status(500).json({ 
      status: 'ERROR', 
      service: 'order-service',
      error: err.message 
    });
  }
});

// Créer une nouvelle commande
app.post('/orders', async (req, res) => {
  try {
    const { user_id, items, total } = req.body;
    console.log('📦 POST /orders - Création commande:', { user_id, items, total });
    
    if (!user_id || !items || !total) {
      return res.status(400).json({ error: 'user_id, items et total sont requis' });
    }

    // Vérifier que l'utilisateur existe
    const userCheck = await pool.query('SELECT id FROM users WHERE id = $1', [user_id]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    // Créer la commande
    const result = await pool.query(
      'INSERT INTO orders (user_id, total, status) VALUES ($1, $2, $3) RETURNING *',
      [user_id, total, 'pending']
    );

    console.log('✅ Commande créée:', result.rows[0]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('❌ Erreur POST /orders:', err);
    res.status(500).json({ error: 'Erreur interne du serveur', details: err.message });
  }
});

// Récupérer toutes les commandes
app.get('/orders', async (req, res) => {
  try {
    console.log('📦 GET /orders - Récupération de toutes les commandes');
    const result = await pool.query(`
      SELECT o.*, u.name as user_name, u.email as user_email 
      FROM orders o 
      JOIN users u ON o.user_id = u.id 
      ORDER BY o.created_at DESC
    `);
    console.log(`✅ ${result.rows.length} commandes trouvées`);
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Erreur GET /orders:', err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Récupérer les commandes d'un utilisateur
app.get('/orders/user/:user_id', async (req, res) => {
  try {
    const { user_id } = req.params;
    console.log(`📦 GET /orders/user/${user_id} - Commandes utilisateur`);
    
    const result = await pool.query(
      'SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC',
      [user_id]
    );
    
    res.json(result.rows);
  } catch (err) {
    console.error(`❌ Erreur GET /orders/user/${req.params.user_id}:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Mettre à jour le statut d'une commande
app.patch('/orders/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    console.log(`✏️ PATCH /orders/${id}/status - Mise à jour: ${status}`);
    
    const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Statut invalide' });
    }
    
    const result = await pool.query(
      'UPDATE orders SET status = $1 WHERE id = $2 RETURNING *',
      [status, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Commande non trouvée' });
    }
    
    console.log('✅ Statut commande mis à jour:', result.rows[0]);
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`❌ Erreur PATCH /orders/${req.params.id}/status:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Récupérer une commande spécifique
app.get('/orders/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`📦 GET /orders/${id} - Récupération commande`);
    
    const result = await pool.query(`
      SELECT o.*, u.name as user_name, u.email as user_email 
      FROM orders o 
      JOIN users u ON o.user_id = u.id 
      WHERE o.id = $1
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Commande non trouvée' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`❌ Erreur GET /orders/${req.params.id}:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

app.listen(port, () => {
  console.log(`🚀 Order Service démarré sur le port ${port}`);
  console.log(`🔍 Health check: http://localhost:${port}/health`);
  console.log(`📦 Orders API: http://localhost:${port}/orders`);
});
APPJS

echo "✅ Order Service créé !"
echo ""
echo "📁 Fichiers créés:"
echo "   - microservices/order-service/Dockerfile"
echo "   - microservices/order-service/package.json" 
echo "   - microservices/order-service/src/app.js"
