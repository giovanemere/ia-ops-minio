# 🚀 Instalación Rápida - IA-Ops MinIO

## ⚡ Instalación en 3 Pasos

### 1. Clonar y Configurar

```bash
# Clonar repositorio
git clone https://github.com/giovanemere/ia-ops-minio.git
cd ia-ops-minio

# Configurar variables automáticamente
./scripts/update-env.sh
```

### 2. Desplegar

```bash
# Despliegue limpio y completo
./scripts/deploy-clean.sh
```

### 3. Acceder

- **🏠 Dashboard**: http://localhost:6540
- **🖥️ MinIO Console**: http://localhost:9899
- **🚀 REST API**: http://localhost:8848
- **📚 Documentación**: http://localhost:6541

## 📋 Requisitos Previos

- **Docker** y **Docker Compose**
- **PostgreSQL** (opcional - se detecta automáticamente)
- **Git**
- **curl** y **jq** (para pruebas)

## 🔧 Configuración Personalizada

### Variables de Entorno

El script `update-env.sh` configura automáticamente:

- ✅ **PostgreSQL**: Detecta instancia existente
- ✅ **Puertos**: Configuración por defecto
- ✅ **Seguridad**: Genera claves JWT y API
- ✅ **Backup**: Configura directorios y retención

### Personalizar Configuración

```bash
# Editar variables antes de desplegar
cp .env.template .env
nano .env

# O usar el configurador automático
./scripts/update-env.sh
```

## 🗄️ Sistema de Backup

### Configuración Automática

```bash
# El sistema detecta automáticamente repositorios en:
REPOSITORIES_DIR=/home/usuario/ia-ops

# Crear backup de todos los repositorios
./scripts/backup-repositories.sh

# Backup vía API
curl -X POST http://localhost:8848/backup/create
```

### OneDrive (Opcional)

Para habilitar backup en OneDrive:

1. Obtener token de Microsoft Graph API
2. Agregar a `.env`:
   ```bash
   ONEDRIVE_ACCESS_TOKEN=your_token_here
   ```

## 🛠️ Scripts Disponibles

| Script | Función |
|--------|---------|
| `deploy-clean.sh` | **Despliegue completo** |
| `update-env.sh` | **Configurar variables** |
| `manage.sh` | **Gestionar servicios** |
| `backup-repositories.sh` | **Crear backups** |
| `verify-system.sh` | **Verificar estado** |

## 🔍 Verificación

```bash
# Verificar servicios
./scripts/manage.sh status

# Health check
curl http://localhost:8848/health

# Verificar backup
curl http://localhost:8848/backup/status
```

## 🚨 Solución de Problemas

### Puertos en Uso

```bash
# Cambiar puertos en .env
DASHBOARD_PORT=6542
MINIO_API_PORT=9900
REST_API_PORT=8850
```

### Reset Completo

```bash
# Limpiar y reiniciar
./scripts/deploy-clean.sh
```

### Logs

```bash
# Ver logs en tiempo real
./scripts/manage.sh logs

# Logs específicos
docker logs ia-ops-minio-portal
```

## 📦 Estructura del Proyecto

```
ia-ops-minio/
├── 🚀 scripts/           # Scripts de gestión
├── 🔌 api/              # REST API + Backup API
├── 🏠 portal/           # Dashboard web
├── 📚 docs_site/        # Documentación MkDocs
├── ⚙️ config/           # Configuraciones
├── 🗄️ data/             # Datos MinIO (creado automáticamente)
├── 📝 logs/             # Logs del sistema
└── 💾 backups/          # Backups de repositorios
```

## 🔗 URLs de Acceso

Una vez desplegado:

- **Dashboard Principal**: http://localhost:6540
- **MinIO Console**: http://localhost:9899
- **REST API**: http://localhost:8848
- **API Docs**: http://localhost:6540/api-docs
- **MkDocs**: http://localhost:6541

## 🎯 Características

- ✅ **Portal unificado** con dashboard integrado
- ✅ **PostgreSQL** con logging automático
- ✅ **Backup automático** de repositorios
- ✅ **OneDrive integration** para backup en nube
- ✅ **API REST** completa con documentación
- ✅ **Configuración automática** sin valores hardcodeados
- ✅ **Docker ready** - un solo contenedor

---

**¿Problemas?** Consulta la [documentación completa](http://localhost:6541) o abre un [issue](https://github.com/giovanemere/ia-ops-minio/issues).
