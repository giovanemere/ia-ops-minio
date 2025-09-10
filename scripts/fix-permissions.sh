#!/bin/bash

# Script para establecer permisos correctos de MinIO
echo "🔧 Estableciendo permisos correctos para MinIO..."

# Crear directorios si no existen
mkdir -p ./data ./logs

# Establecer permisos correctos
sudo chown -R 999:999 ./data ./logs
sudo chmod -R 755 ./data ./logs

echo "✅ Permisos establecidos correctamente"
echo "   - Usuario: 999:999 (minio)"
echo "   - Permisos: 755"
