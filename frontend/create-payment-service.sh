#!/bin/bash

echo "💰 CRÉATION DU PAYMENT SERVICE"
echo "=============================="

# Création des dossiers
mkdir -p microservices/payment-service/src

# Dockerfile pour payment-service
cat > microservices/payment-service/Dockerfile << 'DOCKERFILE'
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY src/ ./src/
EXPOSE 3004
CMD ["npm", "start"]
DOCKERFILE

# package.json pour payment-service
cat > microservices/payment-service/package.json << 'PKGJSON'
{
  "name": "payment-service",
  "version": "1.0.0",
  "description": "Payment Management Microservice",
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

# Application payment-service
cat > microservices/payment-service/src/app.js << 'APPJS'
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3004;

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

// Routes
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ 
      status: 'OK', 
      service: 'payment-service',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    console.error('Health check failed:', err);
    res.status(500).json({ 
      status: 'ERROR', 
      service: 'payment-service',
      error: err.message 
    });
  }
});

// Traiter un paiement
app.post('/payments', async (req, res) => {
  try {
    const { order_id, amount, payment_method } = req.body;
    console.log('💳 POST /payments - Traitement paiement:', { order_id, amount, payment_method });
    
    if (!order_id || !amount || !payment_method) {
      return res.status(400).json({ error: 'order_id, amount et payment_method sont requis' });
    }

    // Vérifier que la commande existe
    const orderCheck = await pool.query('SELECT id, total FROM orders WHERE id = $1', [order_id]);
    if (orderCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Commande non trouvée' });
    }

    // Simuler un traitement de paiement
    const paymentStatus = Math.random() > 0.1 ? 'completed' : 'failed';
    const paymentMessage = paymentStatus === 'completed' ? 'Paiement traité avec succès' : 'Échec du paiement';

    // Créer l'enregistrement de paiement
    const result = await pool.query(
      'INSERT INTO payments (order_id, amount, status, payment_method) VALUES ($1, $2, $3, $4) RETURNING *',
      [order_id, amount, paymentStatus, payment_method]
    );

    // Mettre à jour le statut de la commande si paiement réussi
    if (paymentStatus === 'completed') {
      await pool.query('UPDATE orders SET status = $1 WHERE id = $2', ['confirmed', order_id]);
    }

    console.log(`✅ Paiement ${paymentStatus}:`, result.rows[0]);
    
    res.status(201).json({
      ...result.rows[0],
      message: paymentMessage
    });
  } catch (err) {
    console.error('❌ Erreur POST /payments:', err);
    res.status(500).json({ error: 'Erreur interne du serveur', details: err.message });
  }
});

// Récupérer tous les paiements
app.get('/payments', async (req, res) => {
  try {
    console.log('💳 GET /payments - Récupération de tous les paiements');
    const result = await pool.query(`
      SELECT p.*, o.total as order_total, u.email as user_email
      FROM payments p
      JOIN orders o ON p.order_id = o.id
      JOIN users u ON o.user_id = u.id
      ORDER BY p.created_at DESC
    `);
    console.log(`✅ ${result.rows.length} paiements trouvés`);
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Erreur GET /payments:', err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Récupérer les paiements d'une commande
app.get('/payments/order/:order_id', async (req, res) => {
  try {
    const { order_id } = req.params;
    console.log(`💳 GET /payments/order/${order_id} - Paiements commande`);
    
    const result = await pool.query(
      'SELECT * FROM payments WHERE order_id = $1 ORDER BY created_at DESC',
      [order_id]
    );
    
    res.json(result.rows);
  } catch (err) {
    console.error(`❌ Erreur GET /payments/order/${req.params.order_id}:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Statut d'un paiement
app.get('/payments/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`💳 GET /payments/${id} - Statut paiement`);
    
    const result = await pool.query(`
      SELECT p.*, o.total as order_total, u.email as user_email
      FROM payments p
      JOIN orders o ON p.order_id = o.id
      JOIN users u ON o.user_id = u.id
      WHERE p.id = $1
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Paiement non trouvé' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`❌ Erreur GET /payments/${req.params.id}:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

app.listen(port, () => {
  console.log(`🚀 Payment Service démarré sur le port ${port}`);
  console.log(`🔍 Health check: http://localhost:${port}/health`);
  console.log(`💳 Payments API: http://localhost:${port}/payments`);
});
APPJS

echo "✅ Payment Service créé !"
