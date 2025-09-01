# 🗄️ IA-Ops MinIO Portal

Bienvenido al portal de documentación de IA-Ops MinIO.

## 🚀 Enlaces Rápidos

- **[Documentación de APIs](api-docs.md)** - Guía completa de las APIs REST y MinIO
- **[MinIO Console](http://localhost:9899)** - Interfaz web de administración
- **[Dashboard](http://localhost:6540)** - Portal principal

## 📦 Características

- **S3 Compatible**: API completamente compatible con Amazon S3
- **Portal Unificado**: Dashboard web integrado
- **Documentación**: Guías y referencias completas
- **API REST**: Endpoints personalizados para gestión

## 🔧 Configuración Rápida

```bash
# Clonar repositorio
git clone git@github.com:giovanemere/ia-ops-minio.git
cd ia-ops-minio

# Despliegue completo
./scripts/deploy-clean.sh

# Acceder al dashboard
open http://localhost:6540
```

## 🌐 URLs de Acceso

| Servicio | URL | Descripción |
|----------|-----|-------------|
| Dashboard | http://localhost:6540 | Portal principal |
| MinIO Console | http://localhost:9899 | Administración web |
| Documentación | http://localhost:6541 | Esta documentación |
| REST API | http://localhost:8848 | API personalizada |
| MinIO API | http://localhost:9898 | API S3 compatible |
