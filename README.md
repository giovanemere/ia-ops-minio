# 🗄️ IA-Ops MinIO Storage Solution

Solución de almacenamiento S3 compatible con MinIO para el ecosistema IA-Ops TechDocs.

## 🚀 Características

- **S3 Compatible**: API completamente compatible con Amazon S3
- **Almacenamiento Local**: Persistencia garantizada sin dependencias externas
- **Integración TechDocs**: Optimizado para documentación técnica
- **API REST**: Endpoints para gestión de buckets y archivos
- **Docker Ready**: Contenedores listos para producción

## 📁 Estructura del Proyecto

```
ia-ops-minio/
├── docker/                    # Configuraciones Docker
│   ├── docker-compose.yml     # Servicios MinIO
│   ├── Dockerfile.api         # API personalizada
│   └── .env.example          # Variables de entorno
├── config/                    # Configuraciones
│   ├── minio.conf            # Configuración MinIO
│   └── policies/             # Políticas de acceso
├── scripts/                   # Scripts de gestión
│   ├── setup.sh              # Configuración inicial
│   ├── start.sh              # Iniciar servicios
│   ├── stop.sh               # Detener servicios
│   └── backup.sh             # Respaldos
├── api/                       # API REST
│   ├── main.py               # API principal
│   └── requirements.txt      # Dependencias Python
├── data/                      # Datos persistentes
├── logs/                      # Logs del sistema
└── docs/                      # Documentación
```

## 🛠️ Instalación Rápida

```bash
# 1. Clonar repositorio
git clone git@github.com:giovanemere/ia-ops-minio.git
cd ia-ops-minio

# 2. Configurar entorno
cp docker/.env.example docker/.env
# Editar docker/.env con tus configuraciones

# 3. Iniciar servicios
./scripts/setup.sh

# 4. Verificar instalación
curl http://localhost:8848/health
```

## 🌐 URLs de Acceso

- **MinIO Console**: http://localhost:9899
- **MinIO API**: http://localhost:9898  
- **REST API**: http://localhost:8848

## 🔧 Configuración

### Variables de Entorno

```bash
# MinIO Configuration
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
MINIO_VERSION=RELEASE.2023-10-25T06-33-25Z

# Ports
MINIO_API_PORT=9898
MINIO_CONSOLE_PORT=9899
MINIO_REST_API_PORT=8848
```

## 📊 Buckets Predefinidos

- `techdocs-storage` - Documentación principal
- `repositories-backup` - Respaldos de repositorios
- `build-artifacts` - Artefactos de construcción
- `static-assets` - Recursos estáticos

## 🔗 Integración con IA-Ops

Este repositorio se integra con:
- **ia-ops-docs** - Documentación principal
- **ia-ops-backstage** - Portal Backstage
- **ia-ops-framework** - Framework base

## 🚀 Comandos Rápidos

```bash
# Iniciar servicios
./scripts/start.sh

# Detener servicios
./scripts/stop.sh

# Ver logs
./scripts/logs.sh

# Backup
./scripts/backup.sh

# Estado de servicios
./scripts/status.sh
```

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

---

**🚀 Parte del ecosistema IA-Ops**
