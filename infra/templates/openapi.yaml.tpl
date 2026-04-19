swagger: "2.0"
info:
  title: ${api_id}
  description: "Ecommerce API Gateway — routes to Product, Order and Inventory services"
  version: "1.0.0"

# API Gateway only supports HTTPS on the backend Cloud Run endpoints
schemes:
  - https

# ── API Key Security Definition ───────────────────────────────────────────────
securityDefinitions:
  api_key:
    type: "apiKey"
    name: "x-api-key"
    in: "header"

# Apply API key requirement globally to all routes
security:
  - api_key: []

# ── Routes ────────────────────────────────────────────────────────────────────
paths:

  # ── Product Service ──────────────────────────────────────────────────────────
  /api/products:
    get:
      operationId: listProducts
      summary: "List all products"
      tags: ["Product"]
      security:
        - api_key: []
      x-google-backend:
        address: ${product_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      produces:
        - application/json
      responses:
        "200":
          description: "List of products"
        "401":
          description: "Unauthorized — missing or invalid API key"
        "500":
          description: "Internal server error"

    post:
      operationId: createProduct
      summary: "Create a new product"
      tags: ["Product"]
      security:
        - api_key: []
      x-google-backend:
        address: ${product_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      consumes:
        - application/json
      produces:
        - application/json
      responses:
        "201":
          description: "Product created"
        "401":
          description: "Unauthorized"

  /api/products/{id}:
    get:
      operationId: getProductById
      summary: "Get product by ID"
      tags: ["Product"]
      security:
        - api_key: []
      x-google-backend:
        address: ${product_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      produces:
        - application/json
      responses:
        "200":
          description: "Product detail"
        "401":
          description: "Unauthorized"
        "404":
          description: "Not found"

    put:
      operationId: updateProduct
      summary: "Update a product"
      tags: ["Product"]
      security:
        - api_key: []
      x-google-backend:
        address: ${product_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      responses:
        "200":
          description: "Product updated"
        "401":
          description: "Unauthorized"

    delete:
      operationId: deleteProduct
      summary: "Delete a product"
      tags: ["Product"]
      security:
        - api_key: []
      x-google-backend:
        address: ${product_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      responses:
        "200":
          description: "Product deleted"
        "401":
          description: "Unauthorized"

  # ── Order Service ────────────────────────────────────────────────────────────
  /api/orders:
    get:
      operationId: listOrders
      summary: "List all orders"
      tags: ["Order"]
      security:
        - api_key: []
      x-google-backend:
        address: ${order_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      produces:
        - application/json
      responses:
        "200":
          description: "List of orders"
        "401":
          description: "Unauthorized"

    post:
      operationId: createOrder
      summary: "Create a new order"
      tags: ["Order"]
      security:
        - api_key: []
      x-google-backend:
        address: ${order_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      consumes:
        - application/json
      produces:
        - application/json
      responses:
        "201":
          description: "Order created"
        "401":
          description: "Unauthorized"

  /api/orders/{id}:
    get:
      operationId: getOrderById
      summary: "Get order by ID"
      tags: ["Order"]
      security:
        - api_key: []
      x-google-backend:
        address: ${order_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      produces:
        - application/json
      responses:
        "200":
          description: "Order detail"
        "401":
          description: "Unauthorized"
        "404":
          description: "Not found"

    put:
      operationId: updateOrder
      summary: "Update an order"
      tags: ["Order"]
      security:
        - api_key: []
      x-google-backend:
        address: ${order_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      responses:
        "200":
          description: "Order updated"
        "401":
          description: "Unauthorized"

    delete:
      operationId: deleteOrder
      summary: "Delete an order"
      tags: ["Order"]
      security:
        - api_key: []
      x-google-backend:
        address: ${order_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      responses:
        "200":
          description: "Order deleted"
        "401":
          description: "Unauthorized"

  # ── Inventory Service ────────────────────────────────────────────────────────
  /api/inventory:
    get:
      operationId: listInventory
      summary: "List all inventory"
      tags: ["Inventory"]
      security:
        - api_key: []
      x-google-backend:
        address: ${inventory_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      produces:
        - application/json
      responses:
        "200":
          description: "Inventory list"
        "401":
          description: "Unauthorized"

    post:
      operationId: createInventory
      summary: "Create an inventory record"
      tags: ["Inventory"]
      security:
        - api_key: []
      x-google-backend:
        address: ${inventory_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      consumes:
        - application/json
      produces:
        - application/json
      responses:
        "201":
          description: "Inventory record created"
        "401":
          description: "Unauthorized"

  /api/inventory/{id}:
    get:
      operationId: getInventoryById
      summary: "Get inventory by product ID"
      tags: ["Inventory"]
      security:
        - api_key: []
      x-google-backend:
        address: ${inventory_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      produces:
        - application/json
      responses:
        "200":
          description: "Inventory record"
        "401":
          description: "Unauthorized"
        "404":
          description: "Not found"

    put:
      operationId: updateInventory
      summary: "Update inventory"
      tags: ["Inventory"]
      security:
        - api_key: []
      x-google-backend:
        address: ${inventory_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      responses:
        "200":
          description: "Inventory updated"
        "401":
          description: "Unauthorized"

    delete:
      operationId: deleteInventory
      summary: "Delete inventory record"
      tags: ["Inventory"]
      security:
        - api_key: []
      x-google-backend:
        address: ${inventory_url}
        path_translation: APPEND_PATH_TO_ADDRESS
        deadline: ${deadline}
      parameters:
        - name: id
          in: path
          required: true
          type: string
      responses:
        "200":
          description: "Inventory deleted"
        "401":
          description: "Unauthorized"
