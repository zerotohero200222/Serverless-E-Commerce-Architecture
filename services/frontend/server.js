const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Serverless E-Commerce</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f9; }
       .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        button { background: #0052cc; color: white; border: none; padding: 10px 20px; cursor: pointer; border-radius: 4px; }
        button:hover { background: #003d99; }
        pre { background: #eee; padding: 15px; border-radius: 4px; overflow-x: auto; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Serverless E-Commerce Dashboard</h1>
        <p>This interface is served via Cloud Run, fronted by a Global Load Balancer.</p>
        <button onclick="fetchData('/api/products', 'product-output')">Load Product Catalog</button>
        <pre id="product-output">Awaiting data...</pre>
        
        <button onclick="fetchData('/api/inventory', 'inventory-output')">Load Inventory Status</button>
        <pre id="inventory-output">Awaiting data...</pre>
      </div>

      <script>
        function fetchData(endpoint, elementId) {
          document.getElementById(elementId).innerText = "Loading...";
          // The Load Balancer routes these /api paths directly to the API Gateway
          fetch(endpoint)
           .then(response => {
              if (!response.ok) throw new Error('HTTP error ' + response.status);
              return response.json();
            })
           .then(data => {
              document.getElementById(elementId).innerText = JSON.stringify(data, null, 2);
            })
           .catch(error => {
              document.getElementById(elementId).innerText = 'Error: ' + error.message;
            });
        }
      </script>
    </body>
    </html>
  `);
});

const PORT = process.env.PORT |

| 8080;
app.listen(PORT, () => {
  console.log(`Frontend service active on port ${PORT}`);
});
