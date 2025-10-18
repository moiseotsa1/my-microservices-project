import React, { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

const API_BASE = {
  users: 'http://localhost:30001',
  products: 'http://localhost:30002',
  orders: 'http://localhost:30003'
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
              <button 
          className={activeTab === 'payments' ? 'active' : ''}
          onClick={() => setActiveTab('payments')}
        >
          💳 Paiements
        </button>
        <button 
          className={activeTab === 'notifications' ? 'active' : ''}
          onClick={() => setActiveTab('notifications')}
        >
          🔔 Notifications
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

        {activeTab === 'payments' && (
          <div className="tab-content">
            <h2>💳 Gestion des Paiements</h2>
            <div className="list">
              <h3>Service Payment (Port 3004)</h3>
              <div className="card">
                <strong>Fonctionnalités:</strong>
                <div>• Traitement des paiements</div>
                <div>• Historique des transactions</div>
                <div>• Statuts de paiement</div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'notifications' && (
          <div className="tab-content">
            <h2>🔔 Gestion des Notifications</h2>
            <div className="list">
              <h3>Service Notification (Port 3005)</h3>
              <div className="card">
                <strong>Fonctionnalités:</strong>
                <div>• Envoi de notifications</div>
                <div>• Types: email, SMS, push</div>
                <div>• Historique des envois</div>
              </div>
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
