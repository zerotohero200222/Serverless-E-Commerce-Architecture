const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());

const inventory = [
  { productId: 1, stock: 10 },
  { productId: 2, stock: 50 }
];

app.get('/api/inventory', (req, res) => res.json({ inventory }));

app.listen(8080, () => console.log('Inventory service listening on 8080'));
