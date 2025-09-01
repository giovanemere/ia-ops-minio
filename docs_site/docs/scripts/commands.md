# 🛠️ Comandos y Scripts

## Scripts Principales

### `manage.sh` ⭐ **Uso Diario**
Gestión básica de servicios.

```bash
# Iniciar servicios
./scripts/manage.sh start

# Detener servicios
./scripts/manage.sh stop

# Reiniciar servicios
./scripts/manage.sh restart

# Ver estado de servicios
./scripts/manage.sh status

# Ver logs en tiempo real
./scripts/manage.sh logs
```

### `deploy-clean.sh` ⭐ **Recomendado**
Despliegue limpio y completo del sistema.

```bash
./scripts/deploy-clean.sh
```

**Funciones:**
- Para servicios existentes
- Limpia contenedores e imágenes
- Construye imagen actualizada
- Inicia todos los servicios
- Configura buckets predefinidos

### `verify-system.sh`
Verificar estado del sistema.

```bash
./scripts/verify-system.sh
```

**Verifica:**
- Estado de contenedores
- Conectividad de puertos
- Health checks de APIs
- Buckets predefinidos

### `build-integrated.sh`
Solo construir imagen local.

```bash
./scripts/build-integrated.sh
```

### `publish-integrated.sh`
Publicar imagen a Docker Hub.

```bash
./scripts/publish-integrated.sh
```

## Comandos Docker

### Gestión de Contenedores
```bash
# Ver estado
docker compose -f docker-compose.integrated.yml ps

# Ver logs
docker compose -f docker-compose.integrated.yml logs -f

# Reiniciar servicios
docker compose -f docker-compose.integrated.yml restart

# Parar servicios
docker compose -f docker-compose.integrated.yml down

# Iniciar servicios
docker compose -f docker-compose.integrated.yml up -d
```

### Debugging
```bash
# Acceder al contenedor
docker compose -f docker-compose.integrated.yml exec ia-ops-minio-integrated bash

# Ver procesos internos
docker compose -f docker-compose.integrated.yml exec ia-ops-minio-integrated ps aux

# Ver logs específicos
docker compose -f docker-compose.integrated.yml exec ia-ops-minio-integrated cat /app/logs/minio.log
```

## MinIO Client (mc)

### Configuración
```bash
# Configurar alias
mc alias set myminio http://localhost:9898 minioadmin minioadmin123

# Verificar conexión
mc admin info myminio
```

### Operaciones con Buckets
```bash
# Listar buckets
mc ls myminio

# Crear bucket
mc mb myminio/mi-bucket

# Eliminar bucket
mc rb myminio/mi-bucket

# Copiar archivos
mc cp archivo.txt myminio/mi-bucket/

# Sincronizar directorio
mc mirror ./docs myminio/mi-bucket/docs
```

### Políticas de Acceso
```bash
# Ver política actual
mc anonymous get myminio/mi-bucket

# Hacer bucket público para lectura
mc anonymous set download myminio/mi-bucket

# Hacer bucket completamente público
mc anonymous set public myminio/mi-bucket

# Hacer bucket privado
mc anonymous set none myminio/mi-bucket
```

## Comandos de API REST

### Health Checks
```bash
# Verificar API REST
curl http://localhost:8848/health

# Estado del sistema
curl http://localhost:8848/api/status | jq '.'

# Información del sistema
curl http://localhost:8848/api/info | jq '.'
```

### Gestión de Buckets
```bash
# Listar buckets
curl http://localhost:8848/api/buckets | jq '.buckets[].name'

# Crear bucket
curl -X POST http://localhost:8848/api/buckets \
  -H "Content-Type: application/json" \
  -d '{"name": "mi-bucket"}'

# Eliminar bucket
curl -X DELETE http://localhost:8848/api/buckets/mi-bucket
```

### Gestión de Objetos
```bash
# Listar objetos
curl http://localhost:8848/api/buckets/mi-bucket/objects | jq '.objects[].key'

# Subir archivo
curl -X POST http://localhost:8848/api/buckets/mi-bucket/objects \
  -F "file=@archivo.txt" \
  -F "key=mi-archivo.txt"

# Descargar archivo
curl http://localhost:8848/api/buckets/mi-bucket/objects/mi-archivo.txt -o descarga.txt

# Eliminar objeto
curl -X DELETE http://localhost:8848/api/buckets/mi-bucket/objects/mi-archivo.txt
```

## Scripts de Utilidad

### Backup Automático
```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup de datos MinIO
docker run --rm \
  -v ia-ops-minio_minio-data:/data:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/minio-data.tar.gz -C /data .

# Backup de configuración
docker compose -f docker-compose.integrated.yml config > "$BACKUP_DIR/docker-compose.yml"
cp .env "$BACKUP_DIR/"

echo "Backup completado en: $BACKUP_DIR"
```

### Monitoreo Simple
```bash
#!/bin/bash
# monitor.sh

while true; do
  echo "=== $(date) ==="
  
  # Verificar servicios
  curl -s http://localhost:6540/health | jq '.status' || echo "Dashboard: ERROR"
  curl -s http://localhost:8848/health | jq '.status' || echo "API REST: ERROR"
  curl -s http://localhost:9898/minio/health/live > /dev/null && echo "MinIO: OK" || echo "MinIO: ERROR"
  
  # Uso de disco
  echo "Disk usage: $(df -h /data | tail -1 | awk '{print $5}')"
  
  echo "---"
  sleep 60
done
```

### Limpieza del Sistema
```bash
#!/bin/bash
# cleanup.sh

echo "Limpiando sistema..."

# Parar servicios
docker compose -f docker-compose.integrated.yml down

# Limpiar contenedores
docker container prune -f

# Limpiar imágenes no utilizadas
docker image prune -f

# Limpiar volúmenes no utilizados
docker volume prune -f

# Limpiar redes no utilizadas
docker network prune -f

echo "Limpieza completada"
```

## Troubleshooting

### Verificar Puertos
```bash
# Ver puertos en uso
ss -tulpn | grep -E "(6540|9899|9898|8848|6541)"

# Verificar conectividad
for port in 6540 9899 9898 8848 6541; do
  echo "Puerto $port: $(curl -s -I http://localhost:$port | head -1 || echo 'ERROR')"
done
```

### Logs de Diagnóstico
```bash
# Logs completos
docker compose -f docker-compose.integrated.yml logs > debug.log

# Logs por servicio
docker compose -f docker-compose.integrated.yml logs minio > minio.log
docker compose -f docker-compose.integrated.yml logs portal > portal.log

# Logs en tiempo real con filtro
docker compose -f docker-compose.integrated.yml logs -f | grep ERROR
```

### Reset Completo
```bash
#!/bin/bash
# reset.sh

echo "⚠️  ADVERTENCIA: Esto eliminará todos los datos"
read -p "¿Continuar? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Parar servicios
  docker compose -f docker-compose.integrated.yml down -v
  
  # Eliminar datos
  sudo rm -rf ./data/*
  sudo rm -rf ./logs/*
  
  # Reconstruir y iniciar
  ./scripts/deploy-clean.sh
  
  echo "✅ Reset completado"
fi
```
