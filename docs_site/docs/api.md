# 🔌 API REST

## 📊 Endpoints Disponibles

### Health Check

```http
GET /health
```

**Respuesta:**
```json
{
  "status": "healthy",
  "timestamp": "2025-09-02T01:01:58.649530",
  "buckets_count": 9,
  "minio_endpoint": "localhost:9000"
}
```

### Gestión de Buckets

#### Listar Buckets

```http
GET /buckets
```

**Respuesta:**
```json
{
  "buckets": [
    {
      "name": "static-assets",
      "creation_date": "2025-09-01T18:36:33.820000+00:00"
    },
    {
      "name": "build-artifacts", 
      "creation_date": "2025-09-01T18:36:33.781000+00:00"
    }
  ],
  "count": 2
}
```

### Gestión de Objetos

#### Listar Objetos

```http
GET /buckets/{bucket_name}/objects
```

**Parámetros de consulta:**
- `prefix` (opcional): Filtrar por prefijo
- `recursive` (opcional): Búsqueda recursiva (true/false)

**Ejemplo:**
```http
GET /buckets/static-assets/objects?prefix=docs/&recursive=true
```

**Respuesta:**
```json
{
  "bucket": "static-assets",
  "objects": [
    {
      "name": "docs/documento.pdf",
      "size": 1024000,
      "last_modified": "2025-09-01T15:30:00.000Z",
      "etag": "d41d8cd98f00b204e9800998ecf8427e",
      "content_type": "application/pdf"
    }
  ],
  "count": 1,
  "prefix": "docs/",
  "recursive": true
}
```

### Estadísticas del Sistema

```http
GET /stats
```

**Respuesta:**
```json
{
  "total_buckets": 9,
  "total_objects": 0,
  "total_size": 0,
  "buckets": [
    {
      "name": "static-assets",
      "objects": 0,
      "size": 0,
      "creation_date": "2025-09-01T18:36:33.820000+00:00"
    }
  ],
  "timestamp": "2025-09-02T01:02:18.544288"
}
```

## 🔧 Ejemplos de Uso

### Python

```python
import requests

# Health check
response = requests.get('http://localhost:8848/health')
print(response.json())

# Listar buckets
response = requests.get('http://localhost:8848/buckets')
buckets = response.json()['buckets']

# Listar objetos de un bucket
response = requests.get('http://localhost:8848/buckets/static-assets/objects')
objects = response.json()['objects']

# Estadísticas del sistema
response = requests.get('http://localhost:8848/stats')
stats = response.json()
```

### cURL

```bash
# Health check
curl http://localhost:8848/health

# Listar buckets
curl http://localhost:8848/buckets

# Listar objetos
curl http://localhost:8848/buckets/static-assets/objects

# Listar objetos con filtros
curl "http://localhost:8848/buckets/static-assets/objects?prefix=docs/&recursive=true"

# Estadísticas del sistema
curl http://localhost:8848/stats
```

### JavaScript

```javascript
// Health check
fetch('http://localhost:8848/health')
  .then(response => response.json())
  .then(data => console.log(data));

// Listar buckets
fetch('http://localhost:8848/buckets')
  .then(response => response.json())
  .then(data => console.log(data.buckets));

// Listar objetos con filtros
fetch('http://localhost:8848/buckets/static-assets/objects?prefix=docs/&recursive=true')
  .then(response => response.json())
  .then(data => console.log(data.objects));

// Estadísticas
fetch('http://localhost:8848/stats')
  .then(response => response.json())
  .then(data => console.log(data));
```

## 🔐 Configuración

La API se conecta a MinIO usando:

- **Endpoint**: `localhost:9898`
- **Usuario**: `minioadmin`
- **Contraseña**: `minioadmin123`

## 📈 Códigos de Estado

| Código | Descripción |
|--------|-------------|
| 200 | Operación exitosa |
| 404 | Recurso no encontrado |
| 500 | Error interno del servidor |

## 🌐 CORS

La API tiene CORS habilitado para desarrollo local. En producción, configurar dominios específicos.
