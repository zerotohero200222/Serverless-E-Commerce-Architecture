const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

const products =;

app.get('/api/products', (req, res) => {
  res.status(200).json({
    status: "success",
    data: products
  });
});

app.get('/api/products/:id', (req, res) => {
  const product = products.find(p => p.id === parseInt(req.params.id));
  if (!product) return res.status(404).json({ error: "Product not found" });
  res.status(200).json({ status: "success", data: product });
});

const PORT = process.env.PORT |

| 8080;
app.listen(PORT, () => {
  console.log(`Product service active on port ${PORT}`);
});
