# 🚀 Primer Uso

## Verificar Instalación

Después de la instalación, verifica que todos los servicios estén funcionando:

```bash
# Verificar estado de servicios
./scripts/verify-system.sh

# Ver logs
docker compose -f docker-compose.integrated.yml logs -f
```

## Acceder al Dashboard

1. Abre tu navegador en: http://localhost:6540
2. Verifica que todos los servicios estén en verde
3. Explora las diferentes secciones

## Primer Acceso a MinIO Console

1. Ve a: http://localhost:9899
2. Usa las credenciales por defecto:
   - **Usuario**: `minioadmin`
   - **Contraseña**: `minioadmin123`

## Crear tu Primer Bucket

### Desde MinIO Console
1. Accede a MinIO Console
2. Click en "Create Bucket"
3. Nombra tu bucket: `mi-primer-bucket`
4. Click "Create Bucket"

### Desde API REST
```bash
curl -X POST http://localhost:8848/api/buckets \
  -H "Content-Type: application/json" \
  -d '{"name": "mi-primer-bucket"}'
```

## Subir tu Primer Archivo

### Usando Python
```python
import boto3

client = boto3.client(
    's3',
    endpoint_url='http://localhost:9898',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin123'
)

# Subir archivo
client.upload_file('archivo.txt', 'mi-primer-bucket', 'archivo.txt')
```

### Usando curl
```bash
curl -X PUT http://localhost:9898/mi-primer-bucket/archivo.txt \
  --data-binary @archivo.txt
```

## Próximos Pasos

- [Configuración Avanzada](configuration.md)
- [Despliegue en Producción](../deployment/production.md)
- [API REST](../api/introduction.md)
