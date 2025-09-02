#!/bin/bash

# IA-Ops MinIO - Script de Actualización de Variables de Entorno
# Actualiza automáticamente las variables desde el entorno del sistema

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"
ENV_TEMPLATE="$PROJECT_DIR/.env.template"

echo "🔧 IA-Ops MinIO - Actualizador de Variables"
echo "============================================"

# Función para obtener credenciales de PostgreSQL existente
get_postgres_credentials() {
    echo "📊 Detectando configuración de PostgreSQL..."
    
    # Intentar obtener credenciales del contenedor existente
    if docker ps --format "table {{.Names}}" | grep -q "veritas-postgres"; then
        echo "✅ PostgreSQL encontrado: veritas-postgres"
        
        # Obtener variables del contenedor
        POSTGRES_USER=$(docker exec veritas-postgres printenv POSTGRES_USER 2>/dev/null || echo "veritas_user")
        POSTGRES_PASSWORD=$(docker exec veritas-postgres printenv POSTGRES_PASSWORD 2>/dev/null || echo "veritas_password")
        POSTGRES_DB=$(docker exec veritas-postgres printenv POSTGRES_DB 2>/dev/null || echo "veritas_db")
        
        echo "  - Usuario: $POSTGRES_USER"
        echo "  - Base de datos: $POSTGRES_DB"
        echo "  - Host: localhost:5432"
    else
        echo "⚠️  PostgreSQL no encontrado, usando valores por defecto"
        POSTGRES_USER="veritas_user"
        POSTGRES_PASSWORD="veritas_password"
        POSTGRES_DB="veritas_db"
    fi
}

# Función para generar claves seguras
generate_secure_keys() {
    echo "🔐 Generando claves de seguridad..."
    
    if command -v openssl >/dev/null 2>&1; then
        JWT_SECRET_KEY=$(openssl rand -base64 32)
        API_KEY=$(openssl rand -hex 32)
        echo "✅ Claves generadas con OpenSSL"
    else
        JWT_SECRET_KEY=$(date +%s | sha256sum | base64 | head -c 32)
        API_KEY=$(date +%s | sha256sum | head -c 32)
        echo "✅ Claves generadas con SHA256"
    fi
}

# Función para crear archivo .env
create_env_file() {
    echo "📝 Creando archivo .env..."
    
    cat > "$ENV_FILE" << EOF
# IA-Ops MinIO Portal Integrado - Variables de Entorno
# Generado automáticamente el $(date)

# MinIO Configuration
MINIO_ROOT_USER=${MINIO_ROOT_USER:-minioadmin}
MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-minioadmin123}
MINIO_ENDPOINT=${MINIO_ENDPOINT:-localhost:9898}

# PostgreSQL Database Configuration
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_DB=${POSTGRES_DB}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}/${POSTGRES_DB}

# Ports Configuration
DASHBOARD_PORT=${DASHBOARD_PORT:-6540}
MINIO_API_PORT=${MINIO_API_PORT:-9898}
MINIO_CONSOLE_PORT=${MINIO_CONSOLE_PORT:-9899}
REST_API_PORT=${REST_API_PORT:-8848}
DOCS_PORT=${DOCS_PORT:-6541}

# Storage Configuration
MINIO_DATA_DIR=${MINIO_DATA_DIR:-./data}
MINIO_LOGS_DIR=${MINIO_LOGS_DIR:-./logs}

# Docker Hub Configuration
DOCKER_HUB_USER=${DOCKER_HUB_USER:-edissonz8809}
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-ia-ops-minio-integrated}
DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG:-latest}

# Security Configuration
JWT_SECRET_KEY=${JWT_SECRET_KEY}
API_KEY=${API_KEY}

# Logging Configuration
LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG_FORMAT=${LOG_FORMAT:-json}

# Environment
ENVIRONMENT=${ENVIRONMENT:-development}
DEBUG=${DEBUG:-false}
EOF
}

# Función para mostrar resumen
show_summary() {
    echo ""
    echo "📋 Resumen de Configuración"
    echo "=========================="
    echo "PostgreSQL:"
    echo "  - Host: ${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}"
    echo "  - Database: $POSTGRES_DB"
    echo "  - User: $POSTGRES_USER"
    echo "  - URL: postgresql://$POSTGRES_USER:***@${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}/$POSTGRES_DB"
    echo ""
    echo "MinIO:"
    echo "  - Endpoint: ${MINIO_ENDPOINT:-localhost:9898}"
    echo "  - User: ${MINIO_ROOT_USER:-minioadmin}"
    echo ""
    echo "Puertos:"
    echo "  - Dashboard: ${DASHBOARD_PORT:-6540}"
    echo "  - MinIO API: ${MINIO_API_PORT:-9898}"
    echo "  - MinIO Console: ${MINIO_CONSOLE_PORT:-9899}"
    echo "  - REST API: ${REST_API_PORT:-8848}"
    echo "  - Docs: ${DOCS_PORT:-6541}"
    echo ""
    echo "✅ Archivo .env actualizado correctamente"
}

# Función principal
main() {
    # Hacer backup del .env actual si existe
    if [ -f "$ENV_FILE" ]; then
        cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        echo "💾 Backup creado: $ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Obtener configuración actual si existe
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
        echo "📖 Cargando configuración existente..."
    fi
    
    # Detectar PostgreSQL
    get_postgres_credentials
    
    # Generar claves seguras si no existen
    if [ -z "$JWT_SECRET_KEY" ] || [ -z "$API_KEY" ]; then
        generate_secure_keys
    fi
    
    # Crear nuevo archivo .env
    create_env_file
    
    # Mostrar resumen
    show_summary
    
    echo ""
    echo "🚀 Para aplicar los cambios, ejecuta:"
    echo "   ./scripts/manage.sh restart"
}

# Verificar si se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
