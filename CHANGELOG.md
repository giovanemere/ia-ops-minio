# Changelog

## [1.4.0] - 2025-09-02

### ✨ Nuevas Características
- **PostgreSQL Integration**: Configuración automática con puerto 5434
- **Sistema de Backup Completo**: Backup automático de repositorios con soporte OneDrive
- **Portal Unificado**: Dashboard integrado con navegación completa
- **Documentación Dual**: MkDocs completo + API Docs integrada
- **REST API Personalizada**: Endpoints customizados para gestión simplificada
- **Auto-setup**: Buckets y políticas preconfiguradas automáticamente

### 🔧 Optimizaciones
- **MinIO Actualizado**: Última versión Community Edition (RELEASE.2025-07-23T15-54-02Z)
- **Configuración Automática**: Script `update-env.sh` detecta PostgreSQL existente
- **Gestión Simplificada**: Script `manage.sh` para operaciones diarias
- **Docker Optimizado**: Imagen integrada con todos los servicios
- **Backup System**: API REST para gestión de backups

### 🐛 Correcciones
- **Puerto PostgreSQL**: Corregida configuración para usar puerto 5434 (Docker)
- **Conflictos de Contenedores**: Resolución automática de nombres duplicados
- **Variables de Entorno**: Generación automática de claves de seguridad
- **Health Checks**: Verificación completa del estado del sistema

### 📚 Documentación
- **Guía Completa**: Documentación actualizada con todos los servicios
- **URLs de Acceso**: Lista completa de servicios y puertos
- **Troubleshooting**: Guía de solución de problemas comunes
- **API Documentation**: Documentación integrada de todas las APIs

### 🔐 Seguridad
- **JWT Secrets**: Generación automática de claves únicas
- **API Keys**: Claves de API generadas automáticamente
- **Backup Seguro**: Configuración de backup con OneDrive opcional

### 🌐 URLs de Servicios
- **Dashboard Principal**: http://localhost:6540
- **MinIO Console**: http://localhost:9899
- **Documentación**: http://localhost:6541
- **REST API**: http://localhost:8848
- **MinIO API**: http://localhost:9898

## [1.3.0] - 2025-09-01
### Características Anteriores
- Sistema base de MinIO
- Configuración Docker básica
- Scripts de despliegue iniciales

## [1.0.0] - 2025-09-01
### Lanzamiento Inicial
- Implementación base de IA-Ops MinIO
- Configuración Docker Compose
- Documentación inicial
