#!/bin/bash

echo "🎨 CRÉATION DU FRONTEND REACT"
echo "=============================="

# Création des dossiers
mkdir -p frontend/{src,public}

# package.json pour le frontend
cat > frontend/package.json << 'PKGJSON'
{
  "name": "ecommerce-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.5.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.4.0"
  }
}
PKGJSON

# Vite config
cat > frontend/vite.config.js << 'VITECONFIG'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    port: 3000
  }
})
VITECONFIG

# HTML principal
cat > frontend/index.html << 'HTML'
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Microservices E-commerce</title>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      body { font-family: Arial, sans-serif; background: #f5f5f5; }
    </style>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
HTML

# Point d'entrée React
cat > frontend/src/main.jsx << 'MAINJSX'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
MAINJSX

# Composant principal
cat > frontend/src/App.jsx << 'APPJSX'
import React, { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

const API_BASE = {
  users: 'http://localhost:3001',
  products: 'http://localhost:3002',
  orders: 'http://localhost:3003'
}

function App() {
  const [activeTab, setActiveTab] = useState('dashboard')
  const [users, setUsers] = useState([])
  const [products, setProducts] = useState([])
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(false)
  const [stats, setStats] = useState({})

  // Charger les données
  const loadData = async () => {
    setLoading(true)
    try {
      const [usersRes, productsRes, ordersRes] = await Promise.all([
        axios.get(`${API_BASE.users}/users`),
        axios.get(`${API_BASE.products}/products`),
        axios.get(`${API_BASE.orders}/orders`)
      ])
      
      setUsers(usersRes.data)
      setProducts(productsRes.data)
      setOrders(ordersRes.data)
      
      setStats({
        users: usersRes.data.length,
        products: productsRes.data.length,
        orders: ordersRes.data.length
      })
    } catch (error) {
      console.error('Erreur chargement données:', error)
    }
    setLoading(false)
  }

  useEffect(() => {
    loadData()
  }, [])

  // Nouvel utilisateur
  const [newUser, setNewUser] = useState({ email: '', name: '' })
  const addUser = async (e) => {
    e.preventDefault()
    try {
      await axios.post(`${API_BASE.users}/users`, newUser)
      setNewUser({ email: '', name: '' })
      loadData()
    } catch (error) {
      alert('Erreur création utilisateur')
    }
  }

  // Nouveau produit
  const [newProduct, setNewProduct] = useState({ name: '', price: '', stock: '' })
  const addProduct = async (e) => {
    e.preventDefault()
    try {
      await axios.post(`${API_BASE.products}/products`, {
        ...newProduct,
        price: parseFloat(newProduct.price),
        stock: parseInt(newProduct.stock)
      })
      setNewProduct({ name: '', price: '', stock: '' })
      loadData()
    } catch (error) {
      alert('Erreur création produit')
    }
  }

  // Nouvelle commande
  const [newOrder, setNewOrder] = useState({ user_id: '', total: '' })
  const addOrder = async (e) => {
    e.preventDefault()
    try {
      await axios.post(`${API_BASE.orders}/orders`, {
        user_id: parseInt(newOrder.user_id),
        items: [{ product_id: 1, quantity: 1 }],
        total: parseFloat(newOrder.total)
      })
      setNewOrder({ user_id: '', total: '' })
      loadData()
    } catch (error) {
      alert('Erreur création commande')
    }
  }

  return (
    <div className="app">
      <header className="header">
        <h1>🛍️ Microservices E-commerce</h1>
        <p>Architecture avec 3 services indépendants</p>
      </header>

      <nav className="tabs">
        <button 
          className={activeTab === 'dashboard' ? 'active' : ''}
          onClick={() => setActiveTab('dashboard')}
        >
          📊 Tableau de bord
        </button>
        <button 
          className={activeTab === 'users' ? 'active' : ''}
          onClick={() => setActiveTab('users')}
        >
          👥 Utilisateurs
        </button>
        <button 
          className={activeTab === 'products' ? 'active' : ''}
          onClick={() => setActiveTab('products')}
        >
          🛍️ Produits
        </button>
        <button 
          className={activeTab === 'orders' ? 'active' : ''}
          onClick={() => setActiveTab('orders')}
        >
          📦 Commandes
        </button>
      </nav>

      <main className="main">
        {loading && <div className="loading">Chargement...</div>}

        {activeTab === 'dashboard' && (
          <div className="dashboard">
            <div className="stats">
              <div className="stat-card">
                <h3>👥 Utilisateurs</h3>
                <div className="stat-number">{stats.users || 0}</div>
                <div className="stat-service">User Service (3001)</div>
              </div>
              <div className="stat-card">
                <h3>🛍️ Produits</h3>
                <div className="stat-number">{stats.products || 0}</div>
                <div className="stat-service">Product Service (3002)</div>
              </div>
              <div className="stat-card">
                <h3>📦 Commandes</h3>
                <div className="stat-number">{stats.orders || 0}</div>
                <div className="stat-service">Order Service (3003)</div>
              </div>
            </div>

            <div className="services-status">
              <h3>🔧 Statut des Services</h3>
              <div className="status-list">
                <ServiceStatus name="User Service" port="3001" />
                <ServiceStatus name="Product Service" port="3002" />
                <ServiceStatus name="Order Service" port="3003" />
              </div>
            </div>
          </div>
        )}

        {activeTab === 'users' && (
          <div className="tab-content">
            <h2>👥 Gestion des Utilisateurs</h2>
            
            <form onSubmit={addUser} className="form">
              <h3>Ajouter un utilisateur</h3>
              <input
                type="email"
                placeholder="Email"
                value={newUser.email}
                onChange={(e) => setNewUser({...newUser, email: e.target.value})}
                required
              />
              <input
                type="text"
                placeholder="Nom"
                value={newUser.name}
                onChange={(e) => setNewUser({...newUser, name: e.target.value})}
                required
              />
              <button type="submit">Créer Utilisateur</button>
            </form>

            <div className="list">
              <h3>Liste des utilisateurs ({users.length})</h3>
              {users.map(user => (
                <div key={user.id} className="card">
                  <strong>{user.name}</strong>
                  <div>{user.email}</div>
                  <small>ID: {user.id} • Créé le {new Date(user.created_at).toLocaleDateString()}</small>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'products' && (
          <div className="tab-content">
            <h2>🛍️ Gestion des Produits</h2>
            
            <form onSubmit={addProduct} className="form">
              <h3>Ajouter un produit</h3>
              <input
                type="text"
                placeholder="Nom du produit"
                value={newProduct.name}
                onChange={(e) => setNewProduct({...newProduct, name: e.target.value})}
                required
              />
              <input
                type="number"
                step="0.01"
                placeholder="Prix"
                value={newProduct.price}
                onChange={(e) => setNewProduct({...newProduct, price: e.target.value})}
                required
              />
              <input
                type="number"
                placeholder="Stock"
                value={newProduct.stock}
                onChange={(e) => setNewProduct({...newProduct, stock: e.target.value})}
                required
              />
              <button type="submit">Créer Produit</button>
            </form>

            <div className="list">
              <h3>Liste des produits ({products.length})</h3>
              {products.map(product => (
                <div key={product.id} className="card">
                  <strong>{product.name}</strong>
                  <div>💰 {parseFloat(product.price).toFixed(2)}€</div>
                  <div>📦 Stock: {product.stock}</div>
                  <small>ID: {product.id}</small>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'orders' && (
          <div className="tab-content">
            <h2>📦 Gestion des Commandes</h2>
            
            <form onSubmit={addOrder} className="form">
              <h3>Créer une commande</h3>
              <input
                type="number"
                placeholder="ID Utilisateur"
                value={newOrder.user_id}
                onChange={(e) => setNewOrder({...newOrder, user_id: e.target.value})}
                required
              />
              <input
                type="number"
                step="0.01"
                placeholder="Montant total"
                value={newOrder.total}
                onChange={(e) => setNewOrder({...newOrder, total: e.target.value})}
                required
              />
              <button type="submit">Créer Commande</button>
            </form>

            <div className="list">
              <h3>Liste des commandes ({orders.length})</h3>
              {orders.map(order => (
                <div key={order.id} className="card">
                  <strong>Commande #{order.id}</strong>
                  <div>👤 {order.user_name} ({order.user_email})</div>
                  <div>💰 Total: {parseFloat(order.total).toFixed(2)}€</div>
                  <div>📋 Statut: <span className={`status ${order.status}`}>{order.status}</span></div>
                  <small>Créée le {new Date(order.created_at).toLocaleDateString()}</small>
                </div>
              ))}
            </div>
          </div>
        )}
      </main>
    </div>
  )
}

// Composant statut des services
function ServiceStatus({ name, port }) {
  const [status, setStatus] = useState('checking')
  
  useEffect(() => {
    const checkStatus = async () => {
      try {
        const response = await axios.get(`http://localhost:${port}/health`, { timeout: 5000 })
        setStatus(response.data.status === 'OK' ? 'online' : 'error')
      } catch (error) {
        setStatus('offline')
      }
    }
    
    checkStatus()
    const interval = setInterval(checkStatus, 10000)
    return () => clearInterval(interval)
  }, [port])

  return (
    <div className="service-status">
      <span className={`status-dot ${status}`}></span>
      <span className="service-name">{name}</span>
      <span className="service-port">:{port}</span>
      <span className={`status-text ${status}`}>
        {status === 'online' ? '✅ En ligne' : 
         status === 'checking' ? '⏳ Vérification...' : '❌ Hors ligne'}
      </span>
    </div>
  )
}

export default App
APPJSX

# Styles CSS
cat > frontend/src/App.css << 'CSS'
.app {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.header {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  padding: 2rem;
  text-align: center;
  color: white;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.header h1 {
  margin: 0 0 0.5rem 0;
  font-size: 2.5rem;
}

.header p {
  margin: 0;
  opacity: 0.9;
  font-size: 1.1rem;
}

.tabs {
  display: flex;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid #e0e0e0;
}

.tabs button {
  flex: 1;
  padding: 1rem 2rem;
  border: none;
  background: none;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.3s ease;
  border-bottom: 3px solid transparent;
}

.tabs button:hover {
  background: rgba(0, 0, 0, 0.05);
}

.tabs button.active {
  background: white;
  border-bottom-color: #667eea;
  font-weight: bold;
}

.main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.loading {
  text-align: center;
  padding: 2rem;
  font-size: 1.2rem;
  color: #666;
}

/* Dashboard */
.dashboard {
  display: grid;
  gap: 2rem;
}

.stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  text-align: center;
  border-left: 4px solid #667eea;
}

.stat-card h3 {
  margin: 0 0 1rem 0;
  color: #333;
  font-size: 1.1rem;
}

.stat-number {
  font-size: 3rem;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 0.5rem;
}

.stat-service {
  color: #666;
  font-size: 0.9rem;
}

.services-status {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.services-status h3 {
  margin: 0 0 1.5rem 0;
  color: #333;
}

.status-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.service-status {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.status-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.status-dot.online { background: #10b981; }
.status-dot.offline { background: #ef4444; }
.status-dot.checking { background: #f59e0b; }

.service-name {
  font-weight: bold;
  color: #333;
}

.service-port {
  color: #666;
  font-family: monospace;
}

.status-text.online { color: #10b981; font-weight: bold; }
.status-text.offline { color: #ef4444; }
.status-text.checking { color: #f59e0b; }

/* Tab Content */
.tab-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.tab-content h2 {
  padding: 2rem 2rem 1rem 2rem;
  margin: 0;
  color: #333;
  border-bottom: 1px solid #e0e0e0;
}

.form {
  padding: 2rem;
  border-bottom: 1px solid #e0e0e0;
  background: #f8f9fa;
}

.form h3 {
  margin: 0 0 1rem 0;
  color: #333;
}

.form input {
  display: block;
  width: 100%;
  padding: 0.75rem;
  margin-bottom: 1rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
}

.form button {
  background: #667eea;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  transition: background 0.3s ease;
}

.form button:hover {
  background: #5a6fd8;
}

.list {
  padding: 2rem;
}

.list h3 {
  margin: 0 0 1.5rem 0;
  color: #333;
}

.card {
  background: #f8f9fa;
  padding: 1.5rem;
  margin-bottom: 1rem;
  border-radius: 8px;
  border-left: 4px solid #667eea;
}

.card strong {
  display: block;
  font-size: 1.1rem;
  margin-bottom: 0.5rem;
  color: #333;
}

.card div {
  margin-bottom: 0.25rem;
  color: #555;
}

.card small {
  color: #888;
  font-size: 0.85rem;
}

.status {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: bold;
  text-transform: uppercase;
}

.status.pending { background: #fef3c7; color: #d97706; }
.status.confirmed { background: #d1fae5; color: #065f46; }
.status.shipped { background: #dbeafe; color: #1e40af; }
.status.delivered { background: #dcfce7; color: #166534; }

/* Responsive */
@media (max-width: 768px) {
  .tabs {
    flex-direction: column;
  }
  
  .stats {
    grid-template-columns: 1fr;
  }
  
  .header h1 {
    font-size: 2rem;
  }
  
  .main {
    padding: 1rem;
  }
}
CSS

echo "✅ Frontend React créé !"
echo ""
echo "📁 Structure créée:"
echo "   - frontend/package.json"
echo "   - frontend/vite.config.js" 
echo "   - frontend/index.html"
echo "   - frontend/src/main.jsx"
echo "   - frontend/src/App.jsx"
echo "   - frontend/src/App.css"
