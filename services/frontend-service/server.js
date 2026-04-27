const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
  <title>Ecommerce Platform</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
    button { padding: 10px 20px; margin: 5px; cursor: pointer; background: #4285f4; color: white; border: none; border-radius: 4px; }
    button:hover { background: #3367d6; }
    pre { background: #f5f5f5; padding: 15px; border-radius: 4px; overflow-x: auto; }
    h1 { color: #333; }
    .status { padding: 5px 10px; border-radius: 3px; display: inline-block; margin: 5px 0; }
    .ok { background: #d4edda; color: #155724; }
    .err { background: #f8d7da; color: #721c24; }
  </style>
</head>
<body>
  <h1>🛒 Ecommerce Platform</h1>
  <p>Serverless microservices on GCP — Cloud Run + API Gateway + Cloud Armor</p>
  <hr/>
  <div>
    <button onclick="load('products')">Load Products</button>
    <button onclick="load('orders')">Load Orders</button>
    <button onclick="load('inventory')">Load Inventory</button>
  </div>
  <div id="status"></div>
  <pre id="output">Click a button to load data...</pre>
  <script>
    function load(route) {
      document.getElementById('status').innerHTML = '<span class="status">Loading...</span>';
      document.getElementById('output').innerText = 'Fetching /api/' + route + ' ...';
      fetch('/api/' + route)
        .then(r => {
          const ok = r.ok;
          return r.text().then(t => ({ ok, text: t, status: r.status }));
        })
        .then(({ ok, text, status }) => {
          document.getElementById('status').innerHTML =
            '<span class="status ' + (ok ? 'ok' : 'err') + '">HTTP ' + status + '</span>';
          try {
            document.getElementById('output').innerText =
              JSON.stringify(JSON.parse(text), null, 2);
          } catch(e) {
            document.getElementById('output').innerText = text;
          }
        })
        .catch(err => {
          document.getElementById('status').innerHTML = '<span class="status err">Error</span>';
          document.getElementById('output').innerText = err.toString();
        });
    }
  </script>
</body>
</html>
  `);
});

app.listen(PORT, () => {
  console.log('Frontend service running on port ' + PORT);
});
