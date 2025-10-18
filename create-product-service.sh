#!/bin/bash

echo "🛍️ CRÉATION DU PRODUCT SERVICE"
echo "=============================="

# Dockerfile pour product-service
cat > microservices/product-service/Dockerfile << 'DOCKERFILE'
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY src/ ./src/
EXPOSE 3002
CMD ["npm", "start"]
DOCKERFILE

# package.json pour product-service
cat > microservices/product-service/package.json << 'PKGJSON'
{
  "name": "product-service",
  "version": "1.0.0",
  "description": "Product Management Microservice",
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

# Application product-service avec logging avancé
cat > microservices/product-service/src/app.js << 'APPJS'
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3002;

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
  console.log('✅ Product Service - Connexion DB établie');
});

pool.on('error', (err) => {
  console.error('❌ Product Service - Erreur DB:', err);
});

// Routes
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ 
      status: 'OK', 
      service: 'product-service',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    console.error('Health check failed:', err);
    res.status(500).json({ 
      status: 'ERROR', 
      service: 'product-service',
      error: err.message 
    });
  }
});

// Récupérer tous les produits
app.get('/products', async (req, res) => {
  try {
    console.log('📦 GET /products - Récupération de tous les produits');
    const result = await pool.query('SELECT * FROM products ORDER BY id');
    console.log(`✅ ${result.rows.length} produits trouvés`);
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Erreur GET /products:', err);
    res.status(500).json({ error: 'Erreur interne du serveur', details: err.message });
  }
});

// Récupérer un produit par ID
app.get('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`📦 GET /products/${id} - Récupération produit`);
    
    const result = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      console.log(`❌ Produit ${id} non trouvé`);
      return res.status(404).json({ error: 'Produit non trouvé' });
    }
    
    console.log(`✅ Produit ${id} trouvé`);
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`❌ Erreur GET /products/${req.params.id}:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Créer un nouveau produit
app.post('/products', async (req, res) => {
  try {
    const { name, price, stock } = req.body;
    console.log('📝 POST /products - Création:', { name, price, stock });
    
    if (!name || price === undefined || stock === undefined) {
      return res.status(400).json({ error: 'Nom, prix et stock sont requis' });
    }
    
    const result = await pool.query(
      'INSERT INTO products (name, price, stock) VALUES ($1, $2, $3) RETURNING *',
      [name, price, stock]
    );
    
    console.log('✅ Produit créé:', result.rows[0]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('❌ Erreur POST /products:', err);
    res.status(500).json({ error: 'Erreur interne du serveur', details: err.message });
  }
});

// Mettre à jour un produit
app.put('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, stock } = req.body;
    console.log(`✏️ PUT /products/${id} - Mise à jour:`, { name, price, stock });
    
    const result = await pool.query(
      'UPDATE products SET name = $1, price = $2, stock = $3 WHERE id = $4 RETURNING *',
      [name, price, stock, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produit non trouvé' });
    }
    
    console.log('✅ Produit mis à jour:', result.rows[0]);
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`❌ Erreur PUT /products/${req.params.id}:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Supprimer un produit
app.delete('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`🗑️ DELETE /products/${id} - Suppression`);
    
    const result = await pool.query('DELETE FROM products WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produit non trouvé' });
    }
    
    console.log('✅ Produit supprimé:', result.rows[0]);
    res.json({ message: 'Produit supprimé', product: result.rows[0] });
  } catch (err) {
    console.error(`❌ Erreur DELETE /products/${req.params.id}:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

app.listen(port, () => {
  console.log(`🚀 Product Service démarré sur le port ${port}`);
  console.log(`🔍 Health check: http://localhost:${port}/health`);
  console.log(`🛍️ Products API: http://localhost:${port}/products`);
});
APPJS

echo "✅ Product Service créé !"
echo ""
echo "📁 Fichiers créés:"
echo "   - microservices/product-service/Dockerfile"
echo "   - microservices/product-service/package.json" 
echo "   - microservices/product-service/src/app.js"
