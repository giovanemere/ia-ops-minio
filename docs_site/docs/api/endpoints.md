# 🔌 Endpoints

## Base URL
```
http://localhost:8848
```

## Health & Status

### GET /health
Verificar estado del servicio.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-01T12:00:00Z"
}
```

**Ejemplo:**
```bash
curl http://localhost:8848/health
```

### GET /api/status
Estado completo del sistema.

**Response:**
```json
{
  "minio_api": "healthy",
  "bucket_count": 4,
  "timestamp": "2025-01-01T12:00:00Z",
  "urls": {
    "console": "http://localhost:9899",
    "api": "http://localhost:8848",
    "docs": "http://localhost:6541",
    "dashboard": "http://localhost:6540"
  }
}
```

## Buckets

### GET /api/buckets
Listar todos los buckets.

**Response:**
```json
{
  "buckets": [
    {
      "name": "techdocs-storage",
      "creation_date": "2025-01-01T10:00:00Z"
    },
    {
      "name": "repositories-backup",
      "creation_date": "2025-01-01T10:01:00Z"
    }
  ],
  "count": 2
}
```

**Ejemplo:**
```bash
curl http://localhost:8848/api/buckets
```

### POST /api/buckets
Crear un nuevo bucket.

**Request Body:**
```json
{
  "name": "mi-nuevo-bucket"
}
```

**Response:**
```json
{
  "message": "Bucket created successfully",
  "bucket": "mi-nuevo-bucket"
}
```

**Ejemplo:**
```bash
curl -X POST http://localhost:8848/api/buckets \
  -H "Content-Type: application/json" \
  -d '{"name": "mi-nuevo-bucket"}'
```

### DELETE /api/buckets/{bucket_name}
Eliminar un bucket.

**Response:**
```json
{
  "message": "Bucket deleted successfully",
  "bucket": "mi-bucket"
}
```

**Ejemplo:**
```bash
curl -X DELETE http://localhost:8848/api/buckets/mi-bucket
```

## Objects

### GET /api/buckets/{bucket_name}/objects
Listar objetos en un bucket.

**Query Parameters:**
- `prefix` (opcional): Filtrar por prefijo
- `limit` (opcional): Límite de resultados

**Response:**
```json
{
  "objects": [
    {
      "key": "documento.pdf",
      "size": 1024,
      "last_modified": "2025-01-01T11:00:00Z",
      "etag": "abc123"
    }
  ],
  "count": 1
}
```

**Ejemplo:**
```bash
curl http://localhost:8848/api/buckets/mi-bucket/objects
curl http://localhost:8848/api/buckets/mi-bucket/objects?prefix=docs/
```

### POST /api/buckets/{bucket_name}/objects
Subir un objeto.

**Request:** Multipart form data
- `file`: Archivo a subir
- `key` (opcional): Nombre del objeto

**Response:**
```json
{
  "message": "Object uploaded successfully",
  "bucket": "mi-bucket",
  "key": "archivo.txt",
  "size": 1024
}
```

**Ejemplo:**
```bash
curl -X POST http://localhost:8848/api/buckets/mi-bucket/objects \
  -F "file=@archivo.txt" \
  -F "key=mi-archivo.txt"
```

### GET /api/buckets/{bucket_name}/objects/{object_key}
Descargar un objeto.

**Response:** Contenido del archivo

**Ejemplo:**
```bash
curl http://localhost:8848/api/buckets/mi-bucket/objects/archivo.txt -o descarga.txt
```

### DELETE /api/buckets/{bucket_name}/objects/{object_key}
Eliminar un objeto.

**Response:**
```json
{
  "message": "Object deleted successfully",
  "bucket": "mi-bucket",
  "key": "archivo.txt"
}
```

**Ejemplo:**
```bash
curl -X DELETE http://localhost:8848/api/buckets/mi-bucket/objects/archivo.txt
```

## System Info

### GET /api/info
Información del sistema MinIO.

**Response:**
```json
{
  "version": "RELEASE.2024-01-01T00-00-00Z",
  "uptime": "24h30m15s",
  "storage": {
    "total": "100GB",
    "used": "25GB",
    "available": "75GB"
  },
  "buckets": 4,
  "objects": 150
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid request",
  "message": "Bucket name is required"
}
```

### 404 Not Found
```json
{
  "error": "Not found",
  "message": "Bucket 'mi-bucket' does not exist"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "message": "Failed to connect to MinIO server"
}
```

## Rate Limiting

- **Límite**: 100 requests por minuto por IP
- **Headers de respuesta**:
  - `X-RateLimit-Limit`: Límite total
  - `X-RateLimit-Remaining`: Requests restantes
  - `X-RateLimit-Reset`: Tiempo de reset

## Authentication

Para endpoints que requieren autenticación:

**Header:**
```
Authorization: Bearer <token>
```

**Ejemplo:**
```bash
curl -H "Authorization: Bearer abc123" \
  http://localhost:8848/api/buckets
```
