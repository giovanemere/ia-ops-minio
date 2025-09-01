# 🔌 Documentación de APIs

## REST API (Puerto 8848)

### Endpoints Disponibles

#### Health Check
```bash
GET http://localhost:8848/health
```

#### Status del Sistema
```bash
GET http://localhost:8848/api/status
```

#### Listar Buckets
```bash
GET http://localhost:8848/api/buckets
```

#### Información del Sistema
```bash
GET http://localhost:8848/api/info
```

### Ejemplos de Uso

```bash
# Verificar estado
curl http://localhost:8848/health

# Obtener información de buckets
curl http://localhost:8848/api/buckets

# Ver estado del sistema
curl http://localhost:8848/api/status
```

## MinIO API (Puerto 9898)

### API S3 Compatible

La API de MinIO es completamente compatible con Amazon S3. Puedes usar cualquier SDK de AWS S3.

#### Configuración de Cliente

```python
import boto3

client = boto3.client(
    's3',
    endpoint_url='http://localhost:9898',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin123'
)
```

#### Operaciones Básicas

```bash
# Listar buckets
curl -X GET http://localhost:9898/ \
  --aws-sigv4 "aws:amz:us-east-1:s3"

# Crear bucket
curl -X PUT http://localhost:9898/mi-bucket \
  --aws-sigv4 "aws:amz:us-east-1:s3"
```

### Buckets Predefinidos

- `techdocs-storage` - Documentación principal (público)
- `repositories-backup` - Respaldos de repositorios (privado)
- `build-artifacts` - Artefactos de construcción (privado)
- `static-assets` - Recursos estáticos (público)

## Autenticación

### Credenciales por Defecto
- **Usuario**: `minioadmin`
- **Contraseña**: `minioadmin123`

### Variables de Entorno
```bash
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
```
