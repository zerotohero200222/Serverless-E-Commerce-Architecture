const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

const orders = [
  { id: 1, productId: 1, quantity: 2, status: 'confirmed' },
  { id: 2, productId: 2, quantity: 1, status: 'pending' }
];

app.get('/api/orders', (req, res) => res.json({ orders }));
app.get('/api/orders/:id', (req, res) => {
  const order = orders.find(o => o.id == req.params.id);
  order ? res.json(order) : res.status(404).json({ error: 'Not found' });
});
app.post('/api/orders', (req, res) => {
  const order = { id: orders.length + 1, ...req.body, status: 'pending' };
  orders.push(order);
  res.status(201).json(order);
});
app.put('/api/orders/:id', (req, res) => {
  const idx = orders.findIndex(o => o.id == req.params.id);
  if (idx === -1) return res.status(404).json({ error: 'Not found' });
  orders[idx] = { ...orders[idx], ...req.body };
  res.json(orders[idx]);
});
app.delete('/api/orders/:id', (req, res) => {
  const idx = orders.findIndex(o => o.id == req.params.id);
  if (idx === -1) return res.status(404).json({ error: 'Not found' });
  orders.splice(idx, 1);
  res.json({ message: 'Deleted' });
});

app.listen(8080, () => console.log('Order service listening on 8080'));