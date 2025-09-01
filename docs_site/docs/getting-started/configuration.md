# ⚙️ Configuración

Guía completa para configurar IA-Ops MinIO según tus necesidades específicas.

## 📁 Archivos de Configuración

### Variables de Entorno Principal (`.env`)

```bash
# MinIO Configuration
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
MINIO_VERSION=RELEASE.2023-10-25T06-33-25Z

# Ports Configuration
MINIO_API_PORT=9898
MINIO_CONSOLE_PORT=9899
MINIO_REST_API_PORT=8848

# Security Configuration
MINIO_BROWSER=on
MINIO_DOMAIN=localhost

# Integration Configuration
TECHDOCS_BUCKET=techdocs-storage
REPOSITORIES_BUCKET=repositories-backup
ARTIFACTS_BUCKET=build-artifacts
ASSETS_BUCKET=static-assets
```

### Configuración Docker Hub (`.env.docker`)

```bash
# Docker Hub Configuration
DOCKER_USERNAME=tu-usuario
DOCKER_TOKEN=tu-token-personal
DOCKER_REGISTRY=docker.io

# Image Configuration
IMAGE_NAME=ia-ops-minio-api
IMAGE_TAG=latest
FULL_IMAGE_NAME=${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}

# Build Configuration
BUILD_PLATFORM=linux/amd64,linux/arm64
BUILD_CONTEXT=../api
DOCKERFILE_PATH=Dockerfile
```

## 🔐 Configuración de Seguridad

### Cambiar Credenciales por Defecto

!!! warning "Importante"
    **Nunca uses las credenciales por defecto en producción**

```bash
# Generar credenciales seguras
MINIO_ROOT_USER=$(openssl rand -hex 8)
MINIO_ROOT_PASSWORD=$(openssl rand -hex 16)

echo "Usuario: $MINIO_ROOT_USER"
echo "Contraseña: $MINIO_ROOT_PASSWORD"
```

### Configuración HTTPS

Para habilitar HTTPS en producción:

```bash
# En .env
MINIO_DOMAIN=tu-dominio.com
MINIO_BROWSER_REDIRECT_URL=https://tu-dominio.com:9899
```

## 🌐 Configuración de Red

### Puertos Personalizados

Si los puertos por defecto están ocupados:

```bash
# Cambiar puertos en .env
MINIO_API_PORT=19898
MINIO_CONSOLE_PORT=19899
MINIO_REST_API_PORT=18848
```

### Acceso Externo

Para permitir acceso desde otras máquinas:

```yaml
# En docker-compose.yml
ports:
  - "0.0.0.0:9898:9000"  # Permitir acceso externo
  - "127.0.0.1:9899:9001"  # Solo acceso local
```

## 💾 Configuración de Almacenamiento

### Volúmenes Persistentes

```yaml
# docker-compose.yml
volumes:
  - ./data:/data                    # Datos de MinIO
  - ./logs:/var/log/minio          # Logs
  - ./config:/etc/minio            # Configuración
```

### Ubicación Personalizada

```bash
# Cambiar ubicación de datos
mkdir -p /opt/minio-data
sudo chown -R 1000:1000 /opt/minio-data

# Actualizar docker-compose.yml
volumes:
  - /opt/minio-data:/data
```

## 🔧 Configuración de la API REST

### Variables de Entorno de la API

```bash
# En el contenedor minio-api
MINIO_ENDPOINT=minio:9000
MINIO_ACCESS_KEY=${MINIO_ROOT_USER}
MINIO_SECRET_KEY=${MINIO_ROOT_PASSWORD}
API_PORT=8848
```

### Configuración de CORS

```python
# En api/main.py
CORS(app, origins=[
    "http://localhost:3000",
    "https://tu-frontend.com"
])
```

## 📊 Configuración de Buckets

### Buckets Predefinidos

Los buckets se crean automáticamente con estas configuraciones:

```bash
# techdocs-storage - Público
mc policy set public minio/techdocs-storage

# repositories-backup - Privado (por defecto)
# build-artifacts - Privado (por defecto)

# static-assets - Público
mc policy set public minio/static-assets
```

### Crear Buckets Adicionales

```bash
# Agregar al script de setup
mc mb minio/mi-bucket-personalizado --ignore-existing
mc policy set download minio/mi-bucket-personalizado
```

## 🔍 Configuración de Monitoreo

### Health Checks

```yaml
# docker-compose.yml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
  interval: 30s
  timeout: 20s
  retries: 3
  start_period: 40s
```

### Logs

```bash
# Configurar rotación de logs
# En /etc/logrotate.d/minio
/path/to/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
}
```

## 🚀 Configuración de Producción

### Recursos del Sistema

```yaml
# docker-compose.yml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 4G
    reservations:
      cpus: '1.0'
      memory: 2G
```

### Variables de Entorno de Producción

```bash
# .env.production
MINIO_ROOT_USER=admin_prod_$(openssl rand -hex 4)
MINIO_ROOT_PASSWORD=$(openssl rand -hex 24)
MINIO_BROWSER=off  # Deshabilitar en producción
MINIO_DOMAIN=minio.tu-empresa.com
```

## 🔄 Configuración de Backup

### Backup Automático

```bash
# Script de backup
#!/bin/bash
BACKUP_DIR="/backup/minio/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup de datos
mc mirror minio/ "$BACKUP_DIR/"

# Backup de configuración
cp -r config/ "$BACKUP_DIR/config/"
```

### Retención de Backups

```bash
# Eliminar backups antiguos (30 días)
find /backup/minio/ -type d -mtime +30 -exec rm -rf {} \;
```

## 🔧 Configuración Avanzada

### Múltiples Instancias

Para alta disponibilidad:

```yaml
# docker-compose.ha.yml
services:
  minio1:
    image: minio/minio
    command: server http://minio{1...4}/data
    
  minio2:
    image: minio/minio
    command: server http://minio{1...4}/data
```

### Integración con Reverse Proxy

```nginx
# nginx.conf
upstream minio_api {
    server localhost:9898;
}

upstream minio_console {
    server localhost:9899;
}

server {
    listen 80;
    server_name minio.tu-dominio.com;
    
    location / {
        proxy_pass http://minio_console;
        proxy_set_header Host $host;
    }
}
```

## ✅ Validación de Configuración

### Script de Validación

```bash
# Crear script de validación
./scripts/validate-config.sh
```

```bash
#!/bin/bash
echo "🔍 Validando configuración..."

# Verificar archivos de configuración
if [ ! -f "docker/.env" ]; then
    echo "❌ Archivo .env no encontrado"
    exit 1
fi

# Verificar puertos disponibles
if netstat -tlnp | grep -q ":9898"; then
    echo "⚠️  Puerto 9898 ya está en uso"
fi

echo "✅ Configuración válida"
```

## 📚 Próximos Pasos

1. **[Primer Uso](first-use.md)** - Comienza a usar el sistema
2. **[API REST](../api/introduction.md)** - Integra con tus aplicaciones
3. **[Despliegue](../deployment/production.md)** - Lleva a producción

!!! tip "Configuración Incremental"
    Comienza con la configuración básica y ve agregando funcionalidades según tus necesidades.
