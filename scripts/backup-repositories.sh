#!/bin/bash

# IA-Ops MinIO - Script de Backup de Repositorios
# Crea backups locales y los sube a MinIO y OneDrive

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Cargar variables de entorno
if [ -f "$PROJECT_DIR/.env" ]; then
    source "$PROJECT_DIR/.env"
fi

# Configuración
REPOSITORIES_DIR="${REPOSITORIES_DIR:-/home/giovanemere/ia-ops}"
MINIO_BUCKET="${BACKUP_BUCKET:-repositories-backup}"
ONEDRIVE_FOLDER="${ONEDRIVE_FOLDER:-IA-Ops-Backups}"

echo "🗄️ IA-Ops - Backup de Repositorios"
echo "=================================="

# Función para crear backup local
create_local_backup() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    local backup_file="$BACKUP_DIR/${repo_name}_${DATE}.tar.gz"
    
    echo "📦 Creando backup de $repo_name..."
    
    # Crear directorio de backup
    mkdir -p "$BACKUP_DIR"
    
    # Crear archivo tar excluyendo archivos innecesarios
    tar -czf "$backup_file" \
        -C "$(dirname "$repo_path")" \
        --exclude='.git/objects/pack/*.pack' \
        --exclude='node_modules' \
        --exclude='venv*' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.env' \
        --exclude='data' \
        --exclude='logs' \
        --exclude='*.log' \
        "$(basename "$repo_path")"
    
    echo "✅ Backup creado: $backup_file"
    echo "   Tamaño: $(du -h "$backup_file" | cut -f1)"
    
    echo "$backup_file"
}

# Función para subir a MinIO
upload_to_minio() {
    local backup_file="$1"
    local filename=$(basename "$backup_file")
    
    echo "☁️ Subiendo a MinIO bucket: $MINIO_BUCKET..."
    
    # Usar API REST para subir
    local minio_url="http://localhost:${MINIO_API_PORT:-9898}"
    local auth_header="Authorization: AWS4-HMAC-SHA256"
    
    # Método simple usando curl con credenciales básicas
    if curl -f -X PUT \
        "http://${MINIO_ROOT_USER:-minioadmin}:${MINIO_ROOT_PASSWORD:-minioadmin123}@localhost:${MINIO_API_PORT:-9898}/$MINIO_BUCKET/$filename" \
        -T "$backup_file" \
        --silent --show-error; then
        echo "✅ Subido a MinIO: $MINIO_BUCKET/$filename"
        return 0
    else
        echo "❌ Error subiendo a MinIO"
        return 1
    fi
}

# Función para subir a OneDrive (usando API REST)
upload_to_onedrive() {
    local backup_file="$1"
    local filename=$(basename "$backup_file")
    
    echo "☁️ Preparando subida a OneDrive..."
    
    # Verificar si existe token de OneDrive
    if [ -z "$ONEDRIVE_ACCESS_TOKEN" ]; then
        echo "⚠️ Token de OneDrive no configurado"
        echo "   Configurar ONEDRIVE_ACCESS_TOKEN en .env"
        return 1
    fi
    
    # Subir archivo a OneDrive usando Microsoft Graph API
    local upload_url="https://graph.microsoft.com/v1.0/me/drive/root:/$ONEDRIVE_FOLDER/$filename:/content"
    
    if curl -f -X PUT \
        -H "Authorization: Bearer $ONEDRIVE_ACCESS_TOKEN" \
        -H "Content-Type: application/octet-stream" \
        --data-binary "@$backup_file" \
        "$upload_url" \
        --silent --show-error > /dev/null; then
        echo "✅ Subido a OneDrive: $ONEDRIVE_FOLDER/$filename"
        return 0
    else
        echo "❌ Error subiendo a OneDrive (verificar token)"
        return 1
    fi
}

# Función para limpiar backups antiguos
cleanup_old_backups() {
    local days="${BACKUP_RETENTION_DAYS:-7}"
    
    echo "🧹 Limpiando backups locales antiguos (>$days días)..."
    
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$days -delete 2>/dev/null || true
    
    echo "✅ Limpieza completada"
}

# Función para obtener información del repositorio
get_repo_info() {
    local repo_path="$1"
    
    if [ -d "$repo_path/.git" ]; then
        cd "$repo_path"
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        local commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        local status=$(git status --porcelain 2>/dev/null | wc -l)
        
        echo "  Branch: $branch"
        echo "  Commit: $commit"
        echo "  Archivos modificados: $status"
    fi
}

# Función principal
main() {
    local repositories=()
    local backup_files=()
    
    # Buscar repositorios automáticamente
    if [ -d "$REPOSITORIES_DIR" ]; then
        echo "🔍 Buscando repositorios en: $REPOSITORIES_DIR"
        
        while IFS= read -r -d '' repo; do
            repositories+=("$repo")
        done < <(find "$REPOSITORIES_DIR" -maxdepth 2 -name ".git" -type d -print0 | sed -z 's|/.git||g')
    fi
    
    # Agregar repositorios específicos si se proporcionan
    if [ $# -gt 0 ]; then
        for repo in "$@"; do
            if [ -d "$repo" ]; then
                repositories+=("$repo")
            fi
        done
    fi
    
    if [ ${#repositories[@]} -eq 0 ]; then
        echo "❌ No se encontraron repositorios"
        echo "   Uso: $0 [ruta_repo1] [ruta_repo2] ..."
        exit 1
    fi
    
    echo "📋 Repositorios encontrados: ${#repositories[@]}"
    
    # Crear backups
    for repo in "${repositories[@]}"; do
        echo ""
        echo "🔄 Procesando: $(basename "$repo")"
        get_repo_info "$repo"
        
        # Crear backup local
        local backup_file=$(create_local_backup "$repo")
        backup_files+=("$backup_file")
        
        # Subir a MinIO
        upload_to_minio "$backup_file" || echo "⚠️ Continuando sin MinIO..."
        
        # Subir a OneDrive
        upload_to_onedrive "$backup_file" || echo "⚠️ Continuando sin OneDrive..."
    done
    
    # Limpiar backups antiguos
    echo ""
    cleanup_old_backups
    
    # Resumen
    echo ""
    echo "📊 Resumen del Backup"
    echo "===================="
    echo "Repositorios procesados: ${#repositories[@]}"
    echo "Backups creados: ${#backup_files[@]}"
    echo "Directorio de backups: $BACKUP_DIR"
    echo "Bucket MinIO: $MINIO_BUCKET"
    echo "Carpeta OneDrive: $ONEDRIVE_FOLDER"
    
    # Mostrar tamaño total
    if [ ${#backup_files[@]} -gt 0 ]; then
        local total_size=$(du -ch "${backup_files[@]}" | tail -1 | cut -f1)
        echo "Tamaño total: $total_size"
    fi
    
    echo ""
    echo "✅ Backup completado: $(date)"
}

# Verificar si se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
