# 📦 Buckets y Objetos

## ¿Qué son los Buckets?

Los buckets son contenedores para almacenar objetos (archivos) en MinIO. Son similares a carpetas, pero con características especiales:

- **Únicos globalmente**: Cada bucket tiene un nombre único
- **Políticas de acceso**: Control granular de permisos
- **Versionado**: Mantener múltiples versiones de objetos
- **Metadatos**: Información adicional sobre el contenido

## Buckets Predefinidos

### `techdocs-storage`
- **Propósito**: Documentación principal
- **Acceso**: Público
- **Uso**: Almacenar documentos, guías, manuales

### `repositories-backup`
- **Propósito**: Respaldos de repositorios
- **Acceso**: Privado
- **Uso**: Backup de código fuente, configuraciones

### `build-artifacts`
- **Propósito**: Artefactos de construcción
- **Acceso**: Privado
- **Uso**: Binarios, paquetes, releases

### `static-assets`
- **Propósito**: Recursos estáticos
- **Acceso**: Público
- **Uso**: Imágenes, CSS, JavaScript, assets web

## Operaciones con Buckets

### Crear Bucket

#### MinIO Console
1. Accede a http://localhost:9899
2. Click "Create Bucket"
3. Ingresa nombre del bucket
4. Configura políticas si es necesario

#### API REST
```bash
curl -X POST http://localhost:8848/api/buckets \
  -H "Content-Type: application/json" \
  -d '{"name": "mi-bucket"}'
```

#### Python SDK
```python
import boto3

client = boto3.client(
    's3',
    endpoint_url='http://localhost:9898',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin123'
)

client.create_bucket(Bucket='mi-bucket')
```

### Listar Buckets

#### API REST
```bash
curl http://localhost:8848/api/buckets
```

#### Python SDK
```python
response = client.list_buckets()
for bucket in response['Buckets']:
    print(bucket['Name'])
```

## Operaciones con Objetos

### Subir Objeto

#### Python SDK
```python
# Subir archivo
client.upload_file('archivo.txt', 'mi-bucket', 'archivo.txt')

# Subir desde memoria
client.put_object(
    Bucket='mi-bucket',
    Key='datos.json',
    Body=json.dumps({'key': 'value'})
)
```

#### curl
```bash
curl -X PUT http://localhost:9898/mi-bucket/archivo.txt \
  --data-binary @archivo.txt
```

### Descargar Objeto

#### Python SDK
```python
# Descargar archivo
client.download_file('mi-bucket', 'archivo.txt', 'descarga.txt')

# Obtener contenido
response = client.get_object(Bucket='mi-bucket', Key='archivo.txt')
content = response['Body'].read()
```

#### curl
```bash
curl http://localhost:9898/mi-bucket/archivo.txt -o descarga.txt
```

### Listar Objetos

#### Python SDK
```python
response = client.list_objects_v2(Bucket='mi-bucket')
for obj in response.get('Contents', []):
    print(obj['Key'])
```

## Metadatos y Propiedades

### Metadatos Personalizados
```python
client.put_object(
    Bucket='mi-bucket',
    Key='archivo.txt',
    Body=b'contenido',
    Metadata={
        'autor': 'usuario',
        'version': '1.0',
        'tipo': 'documento'
    }
)
```

### Content-Type
```python
client.put_object(
    Bucket='mi-bucket',
    Key='imagen.jpg',
    Body=imagen_data,
    ContentType='image/jpeg'
)
```

## Mejores Prácticas

### Nomenclatura
- Usa nombres descriptivos
- Evita caracteres especiales
- Considera la organización jerárquica

### Organización
```
mi-bucket/
├── docs/
│   ├── 2024/
│   └── 2025/
├── images/
│   ├── thumbnails/
│   └── full-size/
└── backups/
    ├── daily/
    └── weekly/
```

### Seguridad
- Configura políticas de acceso apropiadas
- Usa HTTPS en producción
- Implementa versionado para datos críticos
