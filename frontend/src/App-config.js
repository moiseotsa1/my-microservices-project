const API_BASE = {
  users: import.meta.env.VITE_USER_SERVICE_URL || 'http://localhost:30001',
  products: import.meta.env.VITE_PRODUCT_SERVICE_URL || 'http://localhost:30002',
  orders: import.meta.env.VITE_ORDER_SERVICE_URL || 'http://localhost:30003',
  payments: import.meta.env.VITE_PAYMENT_SERVICE_URL || 'http://localhost:30004',
  notifications: import.meta.env.VITE_NOTIFICATION_SERVICE_URL || 'http://localhost:30005'
};
