const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());

const products = [
  { id: 1, name: "Laptop", price: 1000 },
  { id: 2, name: "Mouse", price: 25 }
];

app.get('/api/products', (req, res) => res.json({ products }));

app.listen(8080, () => console.log('Product service listening on 8080'));
