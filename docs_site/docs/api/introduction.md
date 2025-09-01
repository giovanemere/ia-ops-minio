# 🌐 API REST - Introducción

La API REST de IA-Ops MinIO proporciona una interfaz HTTP simple y potente para interactuar con el almacenamiento de objetos MinIO.

## 🎯 Características

- **RESTful**: Sigue los principios REST estándar
- **JSON**: Todas las respuestas en formato JSON
- **CORS**: Habilitado para aplicaciones web
- **Health Checks**: Monitoreo integrado
- **Documentación**: Endpoints autodocumentados

## 🔗 URL Base

```
http://localhost:8848
```

## 📊 Endpoints Principales

### Health & Status
```http
GET /health              # Estado del sistema
GET /info               # Información del servidor
```

### Buckets
```http
GET    /buckets          # Listar buckets
POST   /buckets          # Crear bucket
DELETE /buckets/{name}   # Eliminar bucket
```

### Objects
```http
GET    /buckets/{bucket}/objects           # Listar objetos
POST   /buckets/{bucket}/objects           # Subir objeto
GET    /buckets/{bucket}/objects/{object}  # Descargar objeto
DELETE /buckets/{bucket}/objects/{object}  # Eliminar objeto
```

## 🔧 Formato de Respuesta

Todas las respuestas siguen este formato estándar:

### Respuesta Exitosa
```json
{
  "status": "success",
  "data": {
    // Datos específicos del endpoint
  },
  "timestamp": "2025-09-01T18:52:30.123Z"
}
```

### Respuesta de Error
```json
{
  "status": "error",
  "error": {
    "code": "BUCKET_NOT_FOUND",
    "message": "El bucket especificado no existe",
    "details": "Bucket 'mi-bucket' not found"
  },
  "timestamp": "2025-09-01T18:52:30.123Z"
}
```

## 🚀 Ejemplo Rápido

### 1. Verificar Estado
```bash
curl http://localhost:8848/health
```

**Respuesta:**
```json
{
  "status": "healthy",
  "minio_endpoint": "minio:9000",
  "buckets_count": 4,
  "timestamp": "2025-09-01T18:52:30.123Z"
}
```

### 2. Listar Buckets
```bash
curl http://localhost:8848/buckets
```

**Respuesta:**
```json
{
  "buckets": [
    {
      "name": "techdocs-storage",
      "creation_date": "2025-09-01T18:36:33.704000+00:00"
    },
    {
      "name": "repositories-backup",
      "creation_date": "2025-09-01T18:36:33.744000+00:00"
    }
  ],
  "count": 4
}
```

### 3. Subir Archivo
```bash
curl -X POST \
  -F "file=@documento.pdf" \
  http://localhost:8848/buckets/techdocs-storage/objects
```

**Respuesta:**
```json
{
  "status": "success",
  "data": {
    "bucket": "techdocs-storage",
    "object": "documento.pdf",
    "size": 1024576,
    "etag": "d41d8cd98f00b204e9800998ecf8427e"
  }
}
```

## 🔐 Autenticación

Actualmente la API utiliza la autenticación de MinIO configurada:

```bash
# Variables de entorno en el contenedor
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin123
```

!!! warning "Seguridad en Producción"
    En entornos de producción, cambia las credenciales por defecto y considera implementar autenticación adicional.

## 📝 Content Types

### Subida de Archivos
```http
Content-Type: multipart/form-data
```

### Respuestas JSON
```http
Content-Type: application/json
```

### Descarga de Archivos
```http
Content-Type: application/octet-stream
# O el tipo MIME específico del archivo
```

## 🔄 Códigos de Estado HTTP

| Código | Significado | Uso |
|--------|-------------|-----|
| `200` | OK | Operación exitosa |
| `201` | Created | Recurso creado |
| `400` | Bad Request | Solicitud malformada |
| `404` | Not Found | Recurso no encontrado |
| `409` | Conflict | Recurso ya existe |
| `500` | Internal Error | Error del servidor |

## 🧪 Herramientas de Testing

### cURL
```bash
# GET simple
curl http://localhost:8848/health

# POST con datos
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"name": "mi-bucket"}' \
  http://localhost:8848/buckets
```

### HTTPie
```bash
# Instalar HTTPie
pip install httpie

# Usar HTTPie
http GET localhost:8848/health
http POST localhost:8848/buckets name=mi-bucket
```

### Postman
Importa esta colección base:

```json
{
  "info": {
    "name": "IA-Ops MinIO API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/health",
          "host": ["{{base_url}}"],
          "path": ["health"]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8848"
    }
  ]
}
```

## 🔍 Monitoreo y Logs

### Health Check Endpoint
```bash
# Verificación básica
curl -f http://localhost:8848/health

# Con detalles
curl http://localhost:8848/health | jq
```

### Logs de la API
```bash
# Ver logs en tiempo real
docker compose -f docker/docker-compose.yml logs -f minio-api

# Logs específicos
docker logs iaops-minio-api --tail 100
```

## 📚 Próximos Pasos

1. **[Endpoints Detallados](endpoints.md)** - Documentación completa de cada endpoint
2. **[Ejemplos Prácticos](examples.md)** - Casos de uso reales
3. **[Integración](../deployment/production.md)** - Uso en aplicaciones

!!! tip "Desarrollo Local"
    Para desarrollo, puedes usar la API directamente desde tu aplicación apuntando a `http://localhost:8848`
