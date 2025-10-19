const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3005;

app.use(cors());
app.use(express.json());

// DonnÃ©es mockÃ©es
const notifications = [
    { id: 1, userId: 1, message: 'Welcome to our service!', type: 'welcome', read: true },
    { id: 2, userId: 2, message: 'Your order has been shipped', type: 'order', read: false }
];

app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        service: 'Notification Service', 
        timestamp: new Date(),
        database: 'mock'
    });
});

app.get('/notifications', (req, res) => {
    res.json(notifications);
});

app.get('/notifications/user/:userId', (req, res) => {
    const userNotifications = notifications.filter(n => n.userId === parseInt(req.params.userId));
    res.json(userNotifications);
});

app.listen(PORT, () => {
    console.log(`í´” Notification Service (mock) running on port ${PORT}`);
});
