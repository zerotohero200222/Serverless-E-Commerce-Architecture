const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send(`
    <h1>E-Commerce Frontend</h1>
    <button onclick="loadProducts()">Load Products</button>
    <button onclick="loadInventory()">Load Inventory</button>
    <pre id="output"></pre>
    <script>
      function loadProducts(){
        fetch('/api/products')
         .then(r=>r.json())
         .then(d=>document.getElementById('output').innerText=JSON.stringify(d,null,2))
      }
      function loadInventory(){
        fetch('/api/inventory')
         .then(r=>r.json())
         .then(d=>document.getElementById('output').innerText=JSON.stringify(d,null,2))
      }
    </script>
  `)
});

app.listen(8080, () => console.log('Frontend listening on 8080'));

app.listen(8080, () => console.log('Frontend listening on 8080'));
