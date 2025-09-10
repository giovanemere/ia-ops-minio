#!/bin/bash

# Script para hacer backup de datos MinIO a Terpel
BACKUP_DIR="/home/giovanemere/terpel/backups"
MINIO_DATA_DIR="/home/giovanemere/ia-ops/ia-ops-minio/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔄 Iniciando backup de MinIO a Terpel..."

# Crear directorio de backup con timestamp
BACKUP_PATH="$BACKUP_DIR/minio-backup-$TIMESTAMP"
mkdir -p "$BACKUP_PATH"

# Backup de datos locales
if [ -d "$MINIO_DATA_DIR" ] && [ "$(ls -A $MINIO_DATA_DIR)" ]; then
    echo "📦 Copiando datos locales..."
    cp -r "$MINIO_DATA_DIR"/* "$BACKUP_PATH/"
    echo "✅ Datos locales copiados a $BACKUP_PATH"
else
    echo "ℹ️  No hay datos locales para copiar"
fi

# Backup de volúmenes Docker
echo "🐳 Haciendo backup de volúmenes Docker..."
for volume in $(docker volume ls -q | grep minio); do
    echo "  📂 Backing up volume: $volume"
    docker run --rm -v "$volume":/source -v "$BACKUP_PATH":/backup alpine tar czf "/backup/${volume}.tar.gz" -C /source .
done

# Backup de configuración
echo "⚙️  Copiando configuración..."
cp /home/giovanemere/ia-ops/ia-ops-minio/.env "$BACKUP_PATH/minio.env"
cp /home/giovanemere/ia-ops/ia-ops-minio/docker-compose.integrated.yml "$BACKUP_PATH/"

# Crear resumen del backup
cat > "$BACKUP_PATH/backup-info.txt" << EOF
MinIO Backup Information
========================
Timestamp: $TIMESTAMP
Source: /home/giovanemere/ia-ops/ia-ops-minio
Backup Path: $BACKUP_PATH

Files included:
- Local data directory
- Docker volumes (*.tar.gz)
- Configuration files (.env, docker-compose.yml)

To restore:
1. Extract volume backups: tar xzf volume-name.tar.gz
2. Copy configuration files back
3. Restart MinIO services
EOF

echo "✅ Backup completado en: $BACKUP_PATH"
echo "📊 Tamaño del backup: $(du -sh $BACKUP_PATH | cut -f1)"
