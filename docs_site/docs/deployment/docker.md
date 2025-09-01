# 🐳 Despliegue con Docker

## Despliegue Rápido

### Un Solo Comando
```bash
# Clonar y desplegar
git clone git@github.com:giovanemere/ia-ops-minio.git
cd ia-ops-minio
./scripts/deploy-clean.sh
```

### Verificar Despliegue
```bash
# Ver estado de contenedores
docker compose -f docker-compose.integrated.yml ps

# Ver logs
docker compose -f docker-compose.integrated.yml logs -f
```

## Configuración Manual

### 1. Preparar Entorno
```bash
# Copiar variables de entorno
cp .env.example .env

# Editar configuración (opcional)
nano .env
```

### 2. Construir Imagen
```bash
# Build local
docker compose -f docker-compose.integrated.yml build

# O usar imagen pre-construida
docker pull edissonz8809/ia-ops-minio-integrated:latest
```

### 3. Iniciar Servicios
```bash
# Iniciar en background
docker compose -f docker-compose.integrated.yml up -d

# Ver logs en tiempo real
docker compose -f docker-compose.integrated.yml logs -f
```

## Configuración Avanzada

### Variables de Entorno (.env)
```bash
# MinIO Configuration
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123

# Ports Configuration
DASHBOARD_PORT=6540
MINIO_CONSOLE_PORT=9899
MINIO_API_PORT=9898
REST_API_PORT=8848
DOCS_PORT=6541

# Storage Configuration
MINIO_DATA_DIR=./data
MINIO_LOGS_DIR=./logs

# Security (Production)
MINIO_SERVER_URL=https://minio.example.com
MINIO_BROWSER_REDIRECT_URL=https://console.example.com
```

### Docker Compose Personalizado
```yaml
version: '3.8'

services:
  ia-ops-minio-integrated:
    image: edissonz8809/ia-ops-minio-integrated:latest
    container_name: ia-ops-minio-portal
    ports:
      - "${DASHBOARD_PORT:-6540}:6540"
      - "${DOCS_PORT:-6541}:6541"
      - "${REST_API_PORT:-8848}:8848"
      - "${MINIO_API_PORT:-9898}:9000"
      - "${MINIO_CONSOLE_PORT:-9899}:9001"
    volumes:
      - "${MINIO_DATA_DIR:-./data}:/data"
      - "${MINIO_LOGS_DIR:-./logs}:/app/logs"
    environment:
      - MINIO_ROOT_USER=${MINIO_ROOT_USER:-minioadmin}
      - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-minioadmin123}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6540/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    networks:
      - minio-network

networks:
  minio-network:
    driver: bridge

volumes:
  minio-data:
    driver: local
  minio-logs:
    driver: local
```

## Gestión de Contenedores

### Comandos Básicos
```bash
# Iniciar servicios
docker compose up -d

# Parar servicios
docker compose down

# Reiniciar servicios
docker compose restart

# Ver logs
docker compose logs -f [servicio]

# Ejecutar comando en contenedor
docker compose exec ia-ops-minio-integrated bash
```

### Actualización
```bash
# Parar servicios
docker compose down

# Actualizar imagen
docker compose pull

# Reconstruir si es necesario
docker compose build --no-cache

# Iniciar con nueva versión
docker compose up -d
```

### Backup de Datos
```bash
# Crear backup de datos
docker run --rm -v ia-ops-minio_minio-data:/data \
  -v $(pwd):/backup alpine \
  tar czf /backup/minio-backup-$(date +%Y%m%d).tar.gz -C /data .

# Restaurar backup
docker run --rm -v ia-ops-minio_minio-data:/data \
  -v $(pwd):/backup alpine \
  tar xzf /backup/minio-backup-20250101.tar.gz -C /data
```

## Monitoreo

### Health Checks
```bash
# Verificar salud del contenedor
docker compose ps

# Health check manual
curl http://localhost:6540/health
curl http://localhost:8848/health
```

### Logs y Debugging
```bash
# Ver logs de todos los servicios
docker compose logs

# Logs de servicio específico
docker compose logs minio
docker compose logs portal
docker compose logs docs

# Seguir logs en tiempo real
docker compose logs -f --tail=100

# Logs con timestamps
docker compose logs -t
```

### Métricas de Recursos
```bash
# Uso de recursos
docker stats ia-ops-minio-portal

# Información del contenedor
docker inspect ia-ops-minio-portal

# Procesos en el contenedor
docker compose exec ia-ops-minio-integrated ps aux
```

## Troubleshooting

### Problemas Comunes

#### Puerto en Uso
```bash
# Verificar puertos ocupados
netstat -tulpn | grep -E "(6540|9899|9898|8848|6541)"

# Cambiar puertos en .env
DASHBOARD_PORT=6542
MINIO_CONSOLE_PORT=9901
```

#### Permisos de Archivos
```bash
# Arreglar permisos de datos
sudo chown -R 1000:1000 ./data
sudo chmod -R 755 ./data
```

#### Memoria Insuficiente
```bash
# Verificar uso de memoria
docker stats

# Aumentar límites en docker-compose.yml
services:
  ia-ops-minio-integrated:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

### Logs de Diagnóstico
```bash
# Logs detallados de MinIO
docker compose exec ia-ops-minio-integrated cat /app/logs/minio.log

# Logs del portal
docker compose exec ia-ops-minio-integrated cat /app/logs/portal.log

# Logs de la API
docker compose exec ia-ops-minio-integrated cat /app/logs/api.log
```

## Desarrollo

### Desarrollo Local
```bash
# Montar código fuente para desarrollo
docker compose -f docker-compose.dev.yml up -d

# Reconstruir después de cambios
docker compose -f docker-compose.dev.yml up -d --build
```

### Testing
```bash
# Ejecutar tests
docker compose exec ia-ops-minio-integrated python -m pytest tests/

# Tests de integración
./scripts/test-integration.sh
```

## Seguridad

### Configuración Segura
```bash
# Cambiar credenciales por defecto
MINIO_ROOT_USER=admin_$(openssl rand -hex 4)
MINIO_ROOT_PASSWORD=$(openssl rand -base64 32)

# Usar secrets de Docker
echo "mi_password_seguro" | docker secret create minio_password -
```

### Red Segura
```yaml
networks:
  minio-network:
    driver: bridge
    internal: true  # Solo comunicación interna
```

### Volúmenes Seguros
```yaml
volumes:
  minio-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /secure/path/data
```
