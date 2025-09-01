# 📖 Guía de Uso

## 🚀 Despliegue Rápido

### Opción 1: Portal Integrado (Recomendado)

```bash
# 1. Clonar repositorio
git clone git@github.com:giovanemere/ia-ops-minio.git
cd ia-ops-minio

# 2. Despliegue limpio completo
./scripts/deploy-clean.sh

# 3. Acceder al dashboard
open http://localhost:6540
```

### Opción 2: Desarrollo Local

```bash
# Build local
./scripts/build-integrated.sh

# Iniciar servicios
docker compose -f docker-compose.integrated.yml up -d
```

## 🔧 Scripts Disponibles

| Script | Función | Uso |
|--------|---------|-----|
| `deploy-clean.sh` | **Despliegue limpio completo** | **Recomendado** |
| `deploy-integrated-full.sh` | Build + Docker Hub + Deploy | Producción |
| `build-integrated.sh` | Solo build local | Desarrollo |
| `publish-integrated.sh` | Solo publicar a Docker Hub | CI/CD |
| `verify-system.sh` | Verificar estado | Diagnóstico |

## ⚙️ Configuración

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

## 🗄️ Gestión de Buckets

### Crear Bucket

```bash
# Via REST API
curl -X POST http://localhost:8848/buckets \
  -H "Content-Type: application/json" \
  -d '{"name": "mi-bucket"}'

# Via MinIO Client
mc mb minio/mi-bucket
```

### Subir Archivos

```bash
# Via REST API
curl -X POST http://localhost:8848/buckets/mi-bucket/upload \
  -F "file=@archivo.txt"

# Via MinIO Client
mc cp archivo.txt minio/mi-bucket/
```

## 🔍 Monitoreo

### Health Checks

```bash
# Portal principal
curl http://localhost:6540/health

# MinIO API
curl http://localhost:9898/minio/health/live

# REST API
curl http://localhost:8848/health
```

### Logs

```bash
# Ver logs del contenedor
docker logs ia-ops-minio-portal

# Logs específicos
docker exec ia-ops-minio-portal tail -f /app/logs/minio.log
docker exec ia-ops-minio-portal tail -f /app/logs/api.log
```

## 🚨 Solución de Problemas

### Problemas Comunes

1. **Puerto ocupado**
   ```bash
   # Verificar puertos
   ss -tulpn | grep -E "(6540|9898|9899|8848|6541)"
   
   # Cambiar puertos en .env
   DASHBOARD_PORT=6542
   ```

2. **Permisos de MinIO**
   ```bash
   # Arreglar permisos
   sudo chown -R 999:999 data/
   ```

3. **Servicios no inician**
   ```bash
   # Verificar estado
   ./scripts/verify-system.sh
   
   # Reiniciar limpio
   ./scripts/deploy-clean.sh
   ```
