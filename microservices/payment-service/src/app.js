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

app.listen(port, () => {
  console.log(`🚀 Payment Service démarré sur le port ${port}`);
  console.log(`🔍 Health check: http://localhost:${port}/health`);
  console.log(`💳 Payments API: http://localhost:${port}/payments`);
});
