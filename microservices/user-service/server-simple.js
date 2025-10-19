const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

// DonnÃ©es mockÃ©es
const users = [
    { id: 1, name: 'John Doe', email: 'john@example.com', role: 'admin' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'user' },
    { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'user' }
];

app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        service: 'User Service', 
        timestamp: new Date(),
        database: 'mock',
        users: users.length
    });
});

app.get('/users', (req, res) => {
    res.json(users);
});

app.get('/users/:id', (req, res) => {
    const user = users.find(u => u.id === parseInt(req.params.id));
    if (user) {
        res.json(user);
    } else {
        res.status(404).json({ error: 'User not found' });
    }
});

app.get('/users/count', (req, res) => {
    res.json({ count: users.length });
});

app.listen(PORT, () => {
    console.log(`í±¤ User Service (mock) running on port ${PORT}`);
});
