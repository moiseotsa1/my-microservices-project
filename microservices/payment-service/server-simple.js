const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3004;

app.use(cors());
app.use(express.json());

// DonnÃ©es mockÃ©es
const payments = [
    { id: 1, orderId: 1, amount: 999.99, status: 'completed', method: 'credit_card' },
    { id: 2, orderId: 2, amount: 1399.98, status: 'pending', method: 'paypal' }
];

app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        service: 'Payment Service', 
        timestamp: new Date(),
        database: 'mock'
    });
});

app.get('/payments', (req, res) => {
    res.json(payments);
});

app.get('/payments/order/:orderId', (req, res) => {
    const payment = payments.find(p => p.orderId === parseInt(req.params.orderId));
    if (payment) {
        res.json(payment);
    } else {
        res.status(404).json({ error: 'Payment not found' });
    }
});

app.listen(PORT, () => {
    console.log(`í²³ Payment Service (mock) running on port ${PORT}`);
});
