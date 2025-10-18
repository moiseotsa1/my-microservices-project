const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3001;

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
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'user-service' });
});

// Récupérer tous les utilisateurs
app.get('/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Récupérer un utilisateur par ID
app.get('/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Créer un nouvel utilisateur
app.post('/users', async (req, res) => {
  try {
    const { email, name } = req.body;
    
    if (!email || !name) {
      return res.status(400).json({ error: 'Email et nom sont requis' });
    }
    
    const result = await pool.query(
      'INSERT INTO users (email, name) VALUES ($1, $2) RETURNING *',
      [email, name]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

app.listen(port, () => {
  console.log(`User service démarré sur le port ${port}`);
  console.log(`Health check: http://localhost:${port}/health`);
});
