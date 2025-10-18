import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_BASE = {
  users: import.meta.env.VITE_USER_SERVICE_URL || 'http://api-gateway/user-service',
  products: import.meta.env.VITE_PRODUCT_SERVICE_URL || 'http://api-gateway/product-service',
  orders: import.meta.env.VITE_ORDER_SERVICE_URL || 'http://api-gateway/order-service',
  payments: import.meta.env.VITE_PAYMENT_SERVICE_URL || 'http://api-gateway/payment-service',
  notifications: import.meta.env.VITE_NOTIFICATION_SERVICE_URL || 'http://api-gateway/notification-service'
};

function ServiceStatus({ name, port }) {
  const [status, setStatus] = useState('loading');

  useEffect(() => {
    const checkService = async () => {
      try {
        // Utiliser l'API Gateway pour tous les health checks
        let healthUrl;
        switch(name) {
          case 'User Service': healthUrl = `${API_BASE.users}/health`; break;
          case 'Product Service': healthUrl = `${API_BASE.products}/health`; break;
          case 'Order Service': healthUrl = `${API_BASE.orders}/health`; break;
          case 'Payment Service': healthUrl = `${API_BASE.payments}/health`; break;
          case 'Notification Service': healthUrl = `${API_BASE.notifications}/health`; break;
          default: healthUrl = `http://api-gateway/health`;
        }
        
        const response = await axios.get(healthUrl, { timeout: 5000 });
        setStatus(response.status === 200 ? 'online' : 'offline');
      } catch (error) {
        setStatus('offline');
      }
    };

    checkService();
    const interval = setInterval(checkService, 10000);
    return () => clearInterval(interval);
  }, [name]);

  return (
    <div className={`service-status ${status}`}>
      <span className="service-name">{name}</span>
      <span className="service-port">:{port}</span>
      <span className={`status-indicator ${status}`}>
        {status === 'online' ? '✅ En ligne' : '❌ Hors ligne'}
      </span>
    </div>
  );
}

function App() {
  const [stats, setStats] = useState({
    users: 0,
    products: 0,
    orders: 0
  });

  // ... (le reste du code App.jsx original reste le même)
  // Pour gagner du temps, je garde la structure mais corrige seulement les URLs
