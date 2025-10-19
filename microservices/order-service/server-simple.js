const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3003;

app.use(cors());
app.use(express.json());

// DonnÃ©es mockÃ©es
const orders = [
    { id: 1, userId: 1, productId: 1, quantity: 1, status: 'completed' },
    { id: 2, userId: 2, productId: 2, quantity: 2, status: 'pending' }
];

app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        service: 'Order Service', 
        timestamp: new Date(),
        database: 'mock'
    });
});

app.get('/orders', (req, res) => {
    res.json(orders);
});

app.get('/orders/:id', (req, res) => {
    const order = orders.find(o => o.id === parseInt(req.params.id));
    if (order) {
        res.json(order);
    } else {
        res.status(404).json({ error: 'Order not found' });
    }
});

app.listen(PORT, () => {
    console.log(`í³¦ Order Service (mock) running on port ${PORT}`);
});
