const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

const inventory =;

app.get('/api/inventory', (req, res) => {
  res.status(200).json({
    status: "success",
    data: inventory
  });
});

app.get('/api/inventory/:id', (req, res) => {
  const item = inventory.find(i => i.productId === parseInt(req.params.id));
  if (!item) return res.status(404).json({ error: "Inventory record not found" });
  res.status(200).json({ status: "success", data: item });
});

const PORT = process.env.PORT |

| 8080;
app.listen(PORT, () => {
  console.log(`Inventory service active on port ${PORT}`);
});
