# 🗄️ IA-Ops MinIO Storage Solution

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

### Portal Integrado
- **🏠 Dashboard Principal**: http://localhost:6540
- **🖥️ MinIO Console**: http://localhost:9899
- **🔌 MinIO API**: http://localhost:9898
- **🚀 REST API**: http://localhost:8848
- **📚 Documentación**: http://localhost:6541

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────┐
│           IA-Ops MinIO Portal           │
│              (Puerto 6540)              │
├─────────────────────────────────────────┤
│  📊 Dashboard  │  🖥️ Console (9899)    │
│  📚 Docs       │  🔌 API (9898)        │
│  🚀 REST API   │  ⚙️ Management        │
└─────────────────────────────────────────┘
```

## 📦 Características

- **Portal Unificado**: Dashboard web integrado
- **S3 Compatible**: API completamente compatible con Amazon S3
- **Documentación**: MkDocs integrado con Material theme
- **API REST**: Endpoints personalizados para gestión
- **Docker Ready**: Un solo contenedor para todo
- **Auto-setup**: Buckets y políticas preconfiguradas

## 🛠️ Scripts Disponibles

| Script | Función | Uso |
|--------|---------|-----|
| `deploy-clean.sh` | **Despliegue limpio completo** | **Recomendado** |
| `deploy-integrated-full.sh` | Build + Docker Hub + Deploy | Producción |
| `build-integrated.sh` | Solo build local | Desarrollo |
| `publish-integrated.sh` | Solo publicar a Docker Hub | CI/CD |
| `docs.sh` | Solo documentación | Docs independiente |
| `verify-system.sh` | Verificar estado | Diagnóstico |

## 🔧 Configuración

### Variables de Entorno (.env)

```bash
# MinIO Configuration
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123

# Ports (cambiar si hay conflictos)
DASHBOARD_PORT=6540
MINIO_CONSOLE_PORT=9899
MINIO_API_PORT=9898
REST_API_PORT=8848
DOCS_PORT=6541
```

### Buckets Predefinidos

- `techdocs-storage` - Documentación principal (público)
- `repositories-backup` - Respaldos de repositorios (privado)
- `build-artifacts` - Artefactos de construcción (privado)
- `static-assets` - Recursos estáticos (público)

## 🐳 Docker Hub

- **Imagen**: `edissonz8809/ia-ops-minio-integrated:latest`
- **Repositorio**: https://hub.docker.com/repositories/edissonz8809

## 🔗 Integración con IA-Ops

Este sistema se integra con:
- **ia-ops-docs** - Documentación principal
- **ia-ops-backstage** - Portal Backstage
- **ia-ops-framework** - Framework base

## 🚨 Solución de Problemas

```bash
# Verificar estado
./scripts/verify-system.sh

# Limpiar y reiniciar
./scripts/deploy-clean.sh

# Ver logs
docker compose -f docker-compose.integrated.yml logs -f

# Verificar puertos
netstat -tulpn | grep -E "(6540|9898|9899|8848|6541)"
```

## 📁 Estructura del Proyecto

```
ia-ops-minio/
├── 📄 docker-compose.integrated.yml  # Configuración principal
├── 🐳 Dockerfile.integrated          # Imagen integrada
├── 📋 .env.example                   # Variables de ejemplo
├── 📂 portal/                        # Aplicación web
├── 📂 api/                          # API REST
├── 📂 docs/                         # Documentación MkDocs
├── 📂 config/                       # Configuraciones
├── 📂 scripts/                      # Scripts de despliegue
└── 📂 data/                         # Datos persistentes
```

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

---

**🚀 Parte del ecosistema IA-Ops**
