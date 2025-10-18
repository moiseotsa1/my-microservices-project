const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3005;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Stockage en mémoire des notifications
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
    const { user_id, type, title, message } = req.body;
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
      status: 'sent',
      created_at: new Date().toISOString(),
      read: false
    };

    notifications.unshift(notification);

    // Simuler différents types de notifications
    let simulatedResponse = { message: 'Notification envoyée' };
    
    switch (type) {
      case 'order_confirmation':
        simulatedResponse.message = '📦 Confirmation de commande envoyée';
        break;
      case 'payment_success':
        simulatedResponse.message = '💳 Notification de paiement réussie envoyée';
        break;
      case 'shipping_update':
        simulatedResponse.message = '🚚 Mise à jour d\\'expédition envoyée';
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
    const { limit = 50 } = req.query;
    
    let filteredNotifications = notifications.slice(0, parseInt(limit));
    
    console.log(`✅ ${filteredNotifications.length} notifications trouvées`);
    res.json(filteredNotifications);
  } catch (err) {
    console.error('❌ Erreur GET /notifications:', err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

app.listen(port, () => {
  console.log(`🚀 Notification Service démarré sur le port ${port}`);
  console.log(`🔍 Health check: http://localhost:${port}/health`);
  console.log(`🔔 Notifications API: http://localhost:${port}/notifications`);
});
