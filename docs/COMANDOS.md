# 🚀 Guía de Comandos MinIO

## Scripts Principales

| Script | Función | Uso |
|--------|---------|-----|
| `deploy-clean.sh` | **Despliegue limpio completo** | **Recomendado** |
| `deploy-integrated-full.sh` | Build + Docker Hub + Deploy | Producción |
| `build-integrated.sh` | Build y test local integrado | Desarrollo |
| `publish-integrated.sh` | Publicar a Docker Hub | CI/CD |
| `switch-integrated.sh` | Cambiar entre local/prod | Gestión |
| `docs.sh` | Documentación independiente | Docs |
| `verify-system.sh` | Verificar estado completo | Diagnóstico |

## Configuración Docker Hub

Edita tu archivo `.env` con tus credenciales:
```bash
DOCKER_HUB_USER=tu_usuario_dockerhub
DOCKER_IMAGE_NAME=ia-ops-minio-integrated
DOCKER_IMAGE_TAG=latest
```

## Flujos de Trabajo

### 🆕 Primera Instalación
```bash
# 1. Clonar repositorio
git clone git@github.com:giovanemere/ia-ops-minio.git
cd ia-ops-minio

# 2. Despliegue limpio completo
./scripts/deploy-clean.sh
```

### 🔧 Desarrollo Local
```bash
# Build y test local
./scripts/build-integrated.sh

# Iniciar servicios locales
./scripts/switch-integrated.sh local
```

### 🚀 Despliegue Completo a Producción
```bash
# Pipeline completo automatizado
./scripts/deploy-integrated-full.sh
```

### 🔄 Actualización Manual
```bash
# 1. Build y test local
./scripts/build-integrated.sh

# 2. Publicar a Docker Hub
./scripts/publish-integrated.sh

# 3. Cambiar a modo producción
./scripts/switch-integrated.sh prod
```

### 🧹 Limpieza y Reinicio
```bash
# Limpiar todo y reiniciar
./scripts/deploy-clean.sh
```

### 🚨 Solución de Problemas
```bash
# 1. Ver estado completo
./scripts/verify-system.sh

# 2. Limpiar y reiniciar
./scripts/deploy-clean.sh

# 3. Ver logs
docker compose -f docker-compose.integrated.yml logs -f
```

## URLs de Acceso

- **Dashboard Principal**: http://localhost:6540
- **MinIO Console**: http://localhost:9899
- **MinIO API**: http://localhost:9898  
- **REST API**: http://localhost:8848
- **Documentación**: http://localhost:6541

## Credenciales por Defecto

- **Usuario**: minioadmin
- **Contraseña**: minioadmin123

## Docker Hub

- **Repositorio**: https://hub.docker.com/repositories/edissonz8809
- **Imagen Integrada**: edissonz8809/ia-ops-minio-integrated:latest

## Buckets Creados Automáticamente

- `techdocs-storage` - Documentación principal (público)
- `repositories-backup` - Respaldos de repositorios (privado)
- `build-artifacts` - Artefactos de construcción (privado)
- `static-assets` - Recursos estáticos (público)
