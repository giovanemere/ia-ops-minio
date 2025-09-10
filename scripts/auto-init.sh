#!/bin/bash

echo "🚀 Iniciando MinIO con configuración persistente..."

# Iniciar MinIO
cd /home/giovanemere/ia-ops/ia-ops-minio
docker-compose -f docker-compose.integrated.yml up -d

# Esperar a que esté listo
echo "⏳ Esperando a que MinIO esté listo..."
sleep 20

# Inicializar buckets
echo "📦 Inicializando buckets..."
cd /home/giovanemere/ia-ops/ia-ops-docs
source venv/bin/activate
python3 /home/giovanemere/ia-ops/ia-ops-minio/init-buckets.py

echo "✅ MinIO iniciado y configurado correctamente"
