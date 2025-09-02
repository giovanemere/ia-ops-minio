# ⚙️ Configuración

## 🔧 Configuración Automática

### Script de Actualización

El script `update-env.sh` configura automáticamente todas las variables:

```bash
# Ejecutar configuración automática
./scripts/update-env.sh

# Aplicar cambios
./scripts/manage.sh restart
```

### Características del Script

- ✅ **Detección automática** de PostgreSQL existente
- ✅ **Backup automático** del archivo `.env` actual
- ✅ **Generación segura** de claves JWT y API
- ✅ **Configuración completa** sin valores hardcodeados
- ✅ **Integración** con base de datos existente

## 🗄️ Configuración de PostgreSQL

### Detección Automática

El script detecta automáticamente la configuración de PostgreSQL:

```bash
# Busca contenedor veritas-postgres
docker ps | grep postgres

# Extrae credenciales del contenedor
POSTGRES_USER=$(docker exec veritas-postgres printenv POSTGRES_USER)
POSTGRES_PASSWORD=$(docker exec veritas-postgres printenv POSTGRES_PASSWORD)
POSTGRES_DB=$(docker exec veritas-postgres printenv POSTGRES_DB)
```

### Variables Configuradas

```bash
# PostgreSQL Database Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=veritas_db
POSTGRES_USER=veritas_user
POSTGRES_PASSWORD=veritas_password
DATABASE_URL=postgresql://veritas_user:veritas_password@localhost:5432/veritas_db
```

## 🔐 Configuración de Seguridad

### Generación Automática de Claves

```bash
# JWT Secret Key (OpenSSL)
JWT_SECRET_KEY=$(openssl rand -base64 32)

# API Key (OpenSSL)
API_KEY=$(openssl rand -hex 32)

# Fallback (SHA256)
JWT_SECRET_KEY=$(date +%s | sha256sum | base64 | head -c 32)
API_KEY=$(date +%s | sha256sum | head -c 32)
```

### Variables de Seguridad

```bash
# Security Configuration
JWT_SECRET_KEY=<clave-generada-automáticamente>
API_KEY=<api-key-generada-automáticamente>
```

## 🚀 Configuración de Servicios

### Puertos

```bash
# Ports Configuration
DASHBOARD_PORT=6540          # Dashboard principal
MINIO_API_PORT=9898         # MinIO API
MINIO_CONSOLE_PORT=9899     # MinIO Console
REST_API_PORT=8848          # REST API personalizada
DOCS_PORT=6541              # Documentación MkDocs
```

### MinIO

```bash
# MinIO Configuration
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
MINIO_ENDPOINT=localhost:9898
```

### Almacenamiento

```bash
# Storage Configuration
MINIO_DATA_DIR=./data       # Datos de MinIO
MINIO_LOGS_DIR=./logs       # Logs del sistema
```

## 🐳 Configuración de Docker

### Docker Hub

```bash
# Docker Hub Configuration
DOCKER_HUB_USER=edissonz8809
DOCKER_IMAGE_NAME=ia-ops-minio-integrated
DOCKER_IMAGE_TAG=latest
```

### Variables de Entorno

```bash
# Environment
ENVIRONMENT=development     # development | production
DEBUG=false                # true | false
LOG_LEVEL=INFO             # DEBUG | INFO | WARNING | ERROR
LOG_FORMAT=json            # json | text
```

## 📋 Archivo .env Completo

```bash
# IA-Ops MinIO Portal Integrado - Variables de Entorno
# Generado automáticamente

# MinIO Configuration
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
MINIO_ENDPOINT=localhost:9898

# PostgreSQL Database Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=veritas_db
POSTGRES_USER=veritas_user
POSTGRES_PASSWORD=veritas_password
DATABASE_URL=postgresql://veritas_user:veritas_password@localhost:5432/veritas_db

# Ports Configuration
DASHBOARD_PORT=6540
MINIO_API_PORT=9898
MINIO_CONSOLE_PORT=9899
REST_API_PORT=8848
DOCS_PORT=6541

# Storage Configuration
MINIO_DATA_DIR=./data
MINIO_LOGS_DIR=./logs

# Docker Hub Configuration
DOCKER_HUB_USER=edissonz8809
DOCKER_IMAGE_NAME=ia-ops-minio-integrated
DOCKER_IMAGE_TAG=latest

# Security Configuration
JWT_SECRET_KEY=<generada-automáticamente>
API_KEY=<generada-automáticamente>

# Logging Configuration
LOG_LEVEL=INFO
LOG_FORMAT=json

# Environment
ENVIRONMENT=development
DEBUG=false
```

## 🔄 Aplicar Configuración

### Reiniciar Servicios

```bash
# Método 1: Script de gestión
./scripts/manage.sh restart

# Método 2: Docker Compose
docker compose -f docker-compose.integrated.yml restart
```

### Verificar Configuración

```bash
# Verificar estado
./scripts/manage.sh status

# Verificar logs
./scripts/manage.sh logs

# Health check
curl http://localhost:8848/health
```

## 🚨 Solución de Problemas

### Backup y Restauración

```bash
# Los backups se crean automáticamente
ls -la .env.backup.*

# Restaurar backup
cp .env.backup.20250901_201216 .env
./scripts/manage.sh restart
```

### Regenerar Configuración

```bash
# Forzar regeneración completa
rm .env
./scripts/update-env.sh
./scripts/manage.sh restart
```

### Verificar PostgreSQL

```bash
# Verificar conexión
docker exec veritas-postgres pg_isready

# Verificar credenciales
docker exec veritas-postgres psql -U veritas_user -d veritas_db -c "\dt"
```
