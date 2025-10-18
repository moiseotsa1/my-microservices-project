const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3005;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Stockage en mémoire des notifications (en production, utiliser une base de données)
let notifications = [];
let notificationId = 1;

// Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    service: 'notification-service',
    timestamp: new Date().toISOString(),
    stats: {
      total_notifications: notifications.length,
      notifications_today: notifications.filter(n => {
        const today = new Date().toDateString();
        return new Date(n.created_at).toDateString() === today;
      }).length
    }
  });
});

// Envoyer une notification
app.post('/notifications', async (req, res) => {
  try {
    const { user_id, type, title, message, metadata } = req.body;
    console.log('🔔 POST /notifications - Envoi notification:', { user_id, type, title });
    
    if (!user_id || !type || !title || !message) {
      return res.status(400).json({ error: 'user_id, type, title et message sont requis' });
    }

    // Simuler l'envoi de notification
    const notification = {
      id: notificationId++,
      user_id,
      type,
      title,
      message,
      metadata: metadata || {},
      status: 'sent',
      channel: 'email', // email, sms, push, etc.
      created_at: new Date().toISOString(),
      read: false
    };

    notifications.unshift(notification); // Ajouter au début

    // Simuler différents types de notifications
    let simulatedResponse = { message: 'Notification envoyée' };
    
    switch (type) {
      case 'order_confirmation':
        simulatedResponse.message = '📦 Confirmation de commande envoyée au client';
        break;
      case 'payment_success':
        simulatedResponse.message = '💳 Notification de paiement réussie envoyée';
        break;
      case 'shipping_update':
        simulatedResponse.message = '🚚 Mise à jour d\\'expédition envoyée';
        break;
      case 'promotional':
        simulatedResponse.message = '🎉 Notification promotionnelle envoyée';
        break;
      default:
        simulatedResponse.message = '📨 Notification envoyée';
    }

    console.log(`✅ ${simulatedResponse.message}`);

    res.status(201).json({
      ...notification,
      simulated_response: simulatedResponse
    });
  } catch (err) {
    console.error('❌ Erreur POST /notifications:', err);
    res.status(500).json({ error: 'Erreur interne du serveur', details: err.message });
  }
});

// Récupérer toutes les notifications
app.get('/notifications', (req, res) => {
  try {
    console.log('🔔 GET /notifications - Récupération notifications');
    const { user_id, type, limit = 50 } = req.query;
    
    let filteredNotifications = [...notifications];
    
    if (user_id) {
      filteredNotifications = filteredNotifications.filter(n => n.user_id == user_id);
    }
    
    if (type) {
      filteredNotifications = filteredNotifications.filter(n => n.type === type);
    }
    
    filteredNotifications = filteredNotifications.slice(0, parseInt(limit));
    
    console.log(`✅ ${filteredNotifications.length} notifications trouvées`);
    res.json(filteredNotifications);
  } catch (err) {
    console.error('❌ Erreur GET /notifications:', err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Récupérer les notifications d'un utilisateur
app.get('/notifications/user/:user_id', (req, res) => {
  try {
    const { user_id } = req.params;
    console.log(`🔔 GET /notifications/user/${user_id} - Notifications utilisateur`);
    
    const userNotifications = notifications
      .filter(n => n.user_id == user_id)
      .slice(0, 20); // Limiter à 20 dernières
    
    res.json(userNotifications);
  } catch (err) {
    console.error(`❌ Erreur GET /notifications/user/${req.params.user_id}:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Marquer une notification comme lue
app.patch('/notifications/:id/read', (req, res) => {
  try {
    const { id } = req.params;
    console.log(`📖 PATCH /notifications/${id}/read - Marquer comme lue`);
    
    const notification = notifications.find(n => n.id == id);
    
    if (!notification) {
      return res.status(404).json({ error: 'Notification non trouvée' });
    }
    
    notification.read = true;
    notification.read_at = new Date().toISOString();
    
    console.log('✅ Notification marquée comme lue');
    res.json(notification);
  } catch (err) {
    console.error(`❌ Erreur PATCH /notifications/${req.params.id}/read:`, err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Statistiques des notifications
app.get('/notifications/stats', (req, res) => {
  try {
    const stats = {
      total: notifications.length,
      read: notifications.filter(n => n.read).length,
      unread: notifications.filter(n => !n.read).length,
      by_type: notifications.reduce((acc, n) => {
        acc[n.type] = (acc[n.type] || 0) + 1;
        return acc;
      }, {}),
      today: notifications.filter(n => {
        const today = new Date().toDateString();
        return new Date(n.created_at).toDateString() === today;
      }).length
    };
    
    res.json(stats);
  } catch (err) {
    console.error('❌ Erreur GET /notifications/stats:', err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

app.listen(port, () => {
  console.log(`🚀 Notification Service démarré sur le port ${port}`);
  console.log(`🔍 Health check: http://localhost:${port}/health`);
  console.log(`🔔 Notifications API: http://localhost:${port}/notifications`);
});
