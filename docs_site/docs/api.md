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
  "timestamp": "2025-09-01T20:19:00.000Z",
  "buckets_count": 4,
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
      "name": "techdocs-storage",
      "creation_date": "2025-09-01T10:00:00.000Z"
    },
    {
      "name": "repositories-backup", 
      "creation_date": "2025-09-01T10:00:00.000Z"
    }
  ],
  "count": 2
}
```

#### Crear Bucket

```http
POST /buckets
Content-Type: application/json

{
  "name": "mi-nuevo-bucket"
}
```

#### Eliminar Bucket

```http
DELETE /buckets/{bucket_name}
```

### Gestión de Objetos

#### Subir Archivo

```http
POST /buckets/{bucket_name}/upload
Content-Type: multipart/form-data

file: [archivo]
```

#### Descargar Archivo

```http
GET /buckets/{bucket_name}/objects/{object_name}
```

#### Listar Objetos

```http
GET /buckets/{bucket_name}/objects
```

**Respuesta:**
```json
{
  "objects": [
    {
      "name": "documento.pdf",
      "size": 1024000,
      "last_modified": "2025-09-01T15:30:00.000Z"
    }
  ],
  "count": 1
}
```

## 🔧 Ejemplos de Uso

### Python

```python
import requests

# Health check
response = requests.get('http://localhost:8848/health')
print(response.json())

# Crear bucket
data = {"name": "mi-bucket"}
response = requests.post('http://localhost:8848/buckets', json=data)

# Subir archivo
files = {'file': open('documento.pdf', 'rb')}
response = requests.post('http://localhost:8848/buckets/mi-bucket/upload', files=files)
```

### cURL

```bash
# Health check
curl http://localhost:8848/health

# Crear bucket
curl -X POST http://localhost:8848/buckets \
  -H "Content-Type: application/json" \
  -d '{"name": "mi-bucket"}'

# Subir archivo
curl -X POST http://localhost:8848/buckets/mi-bucket/upload \
  -F "file=@documento.pdf"

# Listar objetos
curl http://localhost:8848/buckets/mi-bucket/objects
```

### JavaScript

```javascript
// Health check
fetch('http://localhost:8848/health')
  .then(response => response.json())
  .then(data => console.log(data));

// Crear bucket
fetch('http://localhost:8848/buckets', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({name: 'mi-bucket'})
});

// Subir archivo
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch('http://localhost:8848/buckets/mi-bucket/upload', {
  method: 'POST',
  body: formData
});
```

## 🔐 Autenticación

La API utiliza las credenciales de MinIO configuradas:

- **Usuario**: `minioadmin`
- **Contraseña**: `minioadmin123`

## 📈 Códigos de Estado

| Código | Descripción |
|--------|-------------|
| 200 | Operación exitosa |
| 201 | Recurso creado |
| 400 | Solicitud inválida |
| 404 | Recurso no encontrado |
| 500 | Error interno del servidor |

## 🌐 CORS

La API tiene CORS habilitado para desarrollo local. En producción, configurar dominios específicos.
