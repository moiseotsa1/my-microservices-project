const fs = require('fs');

let content = fs.readFileSync('src/App.jsx', 'utf8');
content = content.replace(/http:\/\/localhost:3001/g, 'http://localhost:30001');
content = content.replace(/http:\/\/localhost:3002/g, 'http://localhost:30002'); 
content = content.replace(/http:\/\/localhost:3003/g, 'http://localhost:30003');
content = content.replace(/http:\/\/localhost:3004/g, 'http://localhost:30004');
content = content.replace(/http:\/\/localhost:3005/g, 'http://localhost:30005');

fs.writeFileSync('src/App.jsx', content);
console.log('✅ Ports modifiés: 3001→30001, 3002→30002, etc.');
