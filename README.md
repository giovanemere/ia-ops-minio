# 🗄️ IA-Ops MinIO Storage Solution

[![Version](https://img.shields.io/badge/version-1.1.1-blue.svg)](https://github.com/giovanemere/ia-ops-minio/releases)
[![Docker](https://img.shields.io/badge/docker-ready-green.svg)](https://hub.docker.com/repositories/edissonz8809)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Solución de almacenamiento S3 compatible con MinIO para el ecosistema IA-Ops TechDocs.

## 🚀 Despliegue Rápido

### Portal Integrado (Recomendado)
**Un solo contenedor con todo integrado**

```bash
# 1. Clonar repositorio
git clone git@github.com:giovanemere/ia-ops-minio.git
cd ia-ops-minio

# 2. Configurar variables (opcional)
cp .env.example .env
# Editar .env si necesitas cambiar puertos o credenciales

# 3. Despliegue limpio y completo
./scripts/deploy-clean.sh

# 4. Acceder al dashboard
open http://localhost:6540
```

## 🌐 URLs de Acceso

### Servicios Web (Abrir en navegador)
- **🏠 Dashboard Principal**: http://localhost:6540
- **🖥️ MinIO Console**: http://localhost:9899
- **📚 Documentación MkDocs**: http://localhost:6541
- **🔌 API Documentation**: http://localhost:6540/api-docs

### APIs (Para desarrollo)
- **🚀 REST API**: http://localhost:8848
- **📡 MinIO API**: http://localhost:9898

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────┐
│           IA-Ops MinIO Portal           │
│              (Puerto 6540)              │
├─────────────────────────────────────────┤
│  📊 Dashboard  │  🖥️ Console (9899)    │
│  📚 MkDocs     │  🔌 API (9898)        │
│  🚀 REST API   │  ⚙️ Management        │
└─────────────────────────────────────────┘
```

## 📦 Características

- **Portal Unificado**: Dashboard web integrado con navegación completa
- **Documentación Dual**: MkDocs completo + API Docs integrada
- **S3 Compatible**: API completamente compatible con Amazon S3
- **REST API**: Endpoints personalizados para gestión simplificada
- **Docker Ready**: Un solo contenedor para todo el ecosistema
- **Auto-setup**: Buckets y políticas preconfiguradas

## 🛠️ Scripts Disponibles

| Script | Función | Uso |
|--------|---------|-----|
| `deploy-clean.sh` | **Despliegue limpio completo** | **⭐ Recomendado** |
| `manage.sh` | **Gestión de servicios** | **⭐ Uso diario** |
| `verify-system.sh` | Verificar estado del sistema | Diagnóstico |
| `build-integrated.sh` | Solo build local | Desarrollo |
| `publish-integrated.sh` | Solo publicar a Docker Hub | CI/CD |

### Gestión de Servicios

```bash
# Iniciar servicios
./scripts/manage.sh start

# Detener servicios
./scripts/manage.sh stop

# Reiniciar servicios
./scripts/manage.sh restart

# Ver estado
./scripts/manage.sh status

# Ver logs en tiempo real
./scripts/manage.sh logs
```

## 🔧 Configuración

### Variables de Entorno (.env)

#### Configuración Básica
```bash
# MinIO Credentials
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123

# Ports Configuration
DASHBOARD_PORT=6540
MINIO_CONSOLE_PORT=9899
MINIO_API_PORT=9898
REST_API_PORT=8848
DOCS_PORT=6541

# Storage Configuration
MINIO_DATA_DIR=./data
MINIO_LOGS_DIR=./logs
```

#### Configuración de Producción
```bash
# Production URLs
MINIO_SERVER_URL=https://minio.example.com
MINIO_BROWSER_REDIRECT_URL=https://console.example.com

# Security
MINIO_CERTS_DIR=/certs
MINIO_OPTS="--certs-dir /certs"

# Monitoring
MINIO_PROMETHEUS_AUTH_TYPE=public
MINIO_PROMETHEUS_URL=http://localhost:9090

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json
```

### Buckets Predefinidos

| Bucket | Propósito | Acceso |
|--------|-----------|--------|
| `techdocs-storage` | Documentación principal | Público |
| `repositories-backup` | Respaldos de repositorios | Privado |
| `build-artifacts` | Artefactos de construcción | Privado |
| `static-assets` | Recursos estáticos | Público |

## 📚 Documentación Completa

### 🔌 API Documentation (Integrada)
**URL**: http://localhost:6540/api-docs

- Documentación de REST API (puerto 8848)
- Documentación de MinIO API (puerto 9898)
- Ejemplos de uso con curl y Python
- Credenciales y configuración

### 📖 MkDocs (Sitio Completo)
**URL**: http://localhost:6541

#### Secciones Disponibles:
- **🚀 Guía de Inicio**: Instalación, configuración, primer uso
- **🗄️ MinIO**: Arquitectura, buckets, políticas de acceso
- **🔌 API REST**: Introducción, endpoints, ejemplos completos
- **🚀 Despliegue**: Docker, producción, monitoreo
- **🛠️ Scripts**: Comandos, automatización
- **📖 Referencia**: Variables de entorno, troubleshooting

## 🐳 Docker Hub

- **Imagen**: `edissonz8809/ia-ops-minio-integrated:latest`
- **Repositorio**: https://hub.docker.com/repositories/edissonz8809

## 🔗 Integración con IA-Ops

Este sistema se integra con:
- **ia-ops-docs** - Documentación principal
- **ia-ops-backstage** - Portal Backstage
- **ia-ops-framework** - Framework base

## 🚨 Solución de Problemas

### Verificación Rápida
```bash
# Verificar estado completo
./scripts/verify-system.sh

# Ver logs de todos los servicios
docker compose -f docker-compose.integrated.yml logs -f

# Verificar puertos específicos
ss -tulpn | grep -E "(6540|9898|9899|8848|6541)"
```

### Problemas Comunes

#### Puertos en Uso
```bash
# Cambiar puertos en .env
DASHBOARD_PORT=6542
MINIO_CONSOLE_PORT=9901
MINIO_API_PORT=9900
```

#### Permisos de Archivos
```bash
# Arreglar permisos
sudo chown -R 1000:1000 ./data ./logs
sudo chmod -R 755 ./data ./logs
```

#### Reset Completo
```bash
# Limpiar y reiniciar todo
./scripts/deploy-clean.sh
```

## 📁 Estructura del Proyecto

```
ia-ops-minio/
├── 📄 docker-compose.integrated.yml  # Configuración principal
├── 🐳 Dockerfile.integrated          # Imagen integrada
├── 📋 .env.example                   # Variables de ejemplo
├── 📂 portal/                        # Dashboard web + API Docs
├── 📂 api/                          # REST API personalizada
├── 📂 docs_site/                    # Documentación MkDocs completa
├── 📂 config/                       # Configuraciones de servicios
├── 📂 scripts/                      # Scripts de despliegue y gestión
└── 📂 data/                         # Datos persistentes de MinIO
```

## 🚀 Ejemplos de Uso

### Python SDK
```python
import boto3

client = boto3.client(
    's3',
    endpoint_url='http://localhost:9898',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin123'
)

# Crear bucket
client.create_bucket(Bucket='mi-bucket')

# Subir archivo
client.upload_file('archivo.txt', 'mi-bucket', 'archivo.txt')
```

### REST API
```bash
# Health check
curl http://localhost:8848/health

# Listar buckets
curl http://localhost:8848/buckets

# Listar objetos de un bucket
curl http://localhost:8848/buckets/static-assets/objects

# Listar objetos con filtros
curl "http://localhost:8848/buckets/static-assets/objects?prefix=docs/&recursive=true"

# Estadísticas del sistema
curl http://localhost:8848/stats
```

### MinIO Client
```bash
# Configurar cliente
mc alias set myminio http://localhost:9898 minioadmin minioadmin123

# Operaciones básicas
mc ls myminio
mc cp archivo.txt myminio/mi-bucket/
mc mirror ./docs myminio/mi-bucket/docs/
```

## 🔐 Seguridad

### Credenciales por Defecto
- **Usuario**: `minioadmin`
- **Contraseña**: `minioadmin123`

⚠️ **Importante**: Cambiar credenciales en producción

### Configuración Segura
```bash
# Generar credenciales seguras
MINIO_ROOT_USER=admin_$(openssl rand -hex 8)
MINIO_ROOT_PASSWORD=$(openssl rand -base64 32)
```

## 📊 Monitoreo

### Health Checks
```bash
# Verificar servicios
curl http://localhost:6540/health
curl http://localhost:8848/health
curl http://localhost:9898/minio/health/live
```

### Métricas
- Prometheus integration disponible
- Grafana dashboards incluidos
- Alertas automáticas configurables

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

---

**🚀 Parte del ecosistema IA-Ops**

Para más información, consulta la [documentación completa](http://localhost:6541) después del despliegue.
