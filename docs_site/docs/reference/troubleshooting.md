# 🔧 Troubleshooting

## Problemas Comunes

### Servicios No Inician

#### Puertos en Uso
**Síntoma:** Error "port already in use"

**Solución:**
```bash
# Verificar puertos ocupados
ss -tulpn | grep -E "(6540|9899|9898|8848|6541)"

# Cambiar puertos en .env
DASHBOARD_PORT=6542
MINIO_CONSOLE_PORT=9901
MINIO_API_PORT=9900
```

#### Permisos de Archivos
**Síntoma:** Error "permission denied"

**Solución:**
```bash
# Arreglar permisos de datos
sudo chown -R 1000:1000 ./data
sudo chmod -R 755 ./data

# Arreglar permisos de logs
sudo chown -R 1000:1000 ./logs
sudo chmod -R 755 ./logs
```

#### Memoria Insuficiente
**Síntoma:** Contenedor se reinicia constantemente

**Solución:**
```bash
# Verificar memoria disponible
free -h

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

### Problemas de Conectividad

#### No Puedo Acceder al Dashboard
**Síntoma:** "Connection refused" en http://localhost:6540

**Diagnóstico:**
```bash
# Verificar estado del contenedor
docker compose -f docker-compose.integrated.yml ps

# Verificar logs
docker compose -f docker-compose.integrated.yml logs portal

# Verificar puerto
curl -I http://localhost:6540
```

**Soluciones:**
```bash
# Reiniciar servicios
docker compose -f docker-compose.integrated.yml restart

# Reconstruir si es necesario
./scripts/deploy-clean.sh
```

#### MinIO Console No Carga
**Síntoma:** Página en blanco en http://localhost:9899

**Solución:**
```bash
# Verificar logs de MinIO
docker compose -f docker-compose.integrated.yml logs minio

# Verificar credenciales
echo "Usuario: $MINIO_ROOT_USER"
echo "Password: $MINIO_ROOT_PASSWORD"

# Reiniciar MinIO específicamente
docker compose -f docker-compose.integrated.yml restart
```

### Problemas de API

#### API REST No Responde
**Síntoma:** Timeout en http://localhost:8848

**Diagnóstico:**
```bash
# Verificar salud de la API
curl -v http://localhost:8848/health

# Ver logs de la API
docker compose -f docker-compose.integrated.yml logs minio-api
```

**Solución:**
```bash
# Verificar conectividad interna
docker compose -f docker-compose.integrated.yml exec ia-ops-minio-integrated curl http://localhost:8848/health

# Reiniciar servicio API
docker compose -f docker-compose.integrated.yml restart
```

#### Errores 500 en API
**Síntoma:** Internal Server Error

**Diagnóstico:**
```bash
# Ver logs detallados
docker compose -f docker-compose.integrated.yml logs --tail=50 minio-api

# Verificar conectividad con MinIO
curl http://localhost:9898/minio/health/live
```

### Problemas de Almacenamiento

#### Buckets No Se Crean
**Síntoma:** Error al crear buckets

**Diagnóstico:**
```bash
# Verificar permisos de datos
ls -la ./data

# Verificar espacio en disco
df -h

# Probar creación manual
mc mb myminio/test-bucket
```

**Solución:**
```bash
# Arreglar permisos
sudo chown -R 1000:1000 ./data

# Limpiar espacio si es necesario
docker system prune -f
```

#### Objetos No Se Suben
**Síntoma:** Error al subir archivos

**Diagnóstico:**
```bash
# Verificar tamaño del archivo
ls -lh archivo.txt

# Verificar límites de MinIO
curl http://localhost:8848/api/info

# Probar subida manual
mc cp archivo.txt myminio/mi-bucket/
```

### Problemas de Documentación

#### MkDocs No Carga
**Síntoma:** Error 502 en http://localhost:6541

**Diagnóstico:**
```bash
# Verificar logs de docs
docker compose -f docker-compose.integrated.yml logs docs

# Verificar archivos de documentación
ls -la docs_site/docs/
```

**Solución:**
```bash
# Reconstruir documentación
docker compose -f docker-compose.integrated.yml exec ia-ops-minio-integrated mkdocs build

# Reiniciar servicio de docs
docker compose -f docker-compose.integrated.yml restart
```

## Comandos de Diagnóstico

### Verificación Completa del Sistema
```bash
#!/bin/bash
# diagnose.sh

echo "=== DIAGNÓSTICO DEL SISTEMA ==="

# 1. Estado de contenedores
echo "1. Estado de contenedores:"
docker compose -f docker-compose.integrated.yml ps

# 2. Verificar puertos
echo -e "\n2. Puertos:"
for port in 6540 9899 9898 8848 6541; do
    if curl -s -I http://localhost:$port > /dev/null; then
        echo "✅ Puerto $port: OK"
    else
        echo "❌ Puerto $port: ERROR"
    fi
done

# 3. Uso de recursos
echo -e "\n3. Uso de recursos:"
docker stats --no-stream ia-ops-minio-portal

# 4. Espacio en disco
echo -e "\n4. Espacio en disco:"
df -h ./data

# 5. Logs recientes
echo -e "\n5. Errores recientes:"
docker compose -f docker-compose.integrated.yml logs --tail=10 | grep -i error

echo -e "\n=== FIN DEL DIAGNÓSTICO ==="
```

### Health Check Completo
```bash
#!/bin/bash
# health-check-full.sh

SERVICES=(
    "Dashboard:http://localhost:6540/health"
    "REST API:http://localhost:8848/health"
    "MinIO API:http://localhost:9898/minio/health/live"
    "MinIO Console:http://localhost:9899"
    "Documentation:http://localhost:6541"
)

echo "=== HEALTH CHECK COMPLETO ==="

for service in "${SERVICES[@]}"; do
    name="${service%%:*}"
    url="${service##*:}"
    
    if curl -sf "$url" > /dev/null 2>&1; then
        echo "✅ $name: OK"
    else
        echo "❌ $name: FAILED"
        
        # Diagnóstico adicional
        echo "   Diagnóstico:"
        curl -v "$url" 2>&1 | head -5 | sed 's/^/   /'
    fi
done
```

## Logs de Diagnóstico

### Ubicaciones de Logs
```bash
# Logs de Docker Compose
docker compose -f docker-compose.integrated.yml logs

# Logs específicos por servicio
docker compose -f docker-compose.integrated.yml logs minio
docker compose -f docker-compose.integrated.yml logs portal
docker compose -f docker-compose.integrated.yml logs minio-api
docker compose -f docker-compose.integrated.yml logs docs

# Logs internos del contenedor
docker compose -f docker-compose.integrated.yml exec ia-ops-minio-integrated cat /app/logs/minio.log
docker compose -f docker-compose.integrated.yml exec ia-ops-minio-integrated cat /app/logs/portal.log
docker compose -f docker-compose.integrated.yml exec ia-ops-minio-integrated cat /app/logs/api.log
```

### Análisis de Logs
```bash
# Buscar errores
docker compose -f docker-compose.integrated.yml logs | grep -i error

# Buscar warnings
docker compose -f docker-compose.integrated.yml logs | grep -i warn

# Logs de los últimos 10 minutos
docker compose -f docker-compose.integrated.yml logs --since=10m

# Seguir logs en tiempo real
docker compose -f docker-compose.integrated.yml logs -f --tail=100
```

## Reset y Recuperación

### Reset Suave
```bash
#!/bin/bash
# soft-reset.sh

echo "Realizando reset suave..."

# Reiniciar servicios
docker compose -f docker-compose.integrated.yml restart

# Verificar estado
sleep 10
./scripts/verify-system.sh
```

### Reset Completo
```bash
#!/bin/bash
# hard-reset.sh

echo "⚠️  ADVERTENCIA: Esto eliminará todos los datos"
read -p "¿Continuar? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Parar servicios
    docker compose -f docker-compose.integrated.yml down -v
    
    # Limpiar datos
    sudo rm -rf ./data/*
    sudo rm -rf ./logs/*
    
    # Limpiar Docker
    docker system prune -f
    
    # Reconstruir y iniciar
    ./scripts/deploy-clean.sh
    
    echo "✅ Reset completo realizado"
fi
```

### Recuperación de Backup
```bash
#!/bin/bash
# restore-backup.sh

BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo "Uso: $0 <archivo-backup.tar.gz>"
    exit 1
fi

echo "Restaurando desde: $BACKUP_FILE"

# Parar servicios
docker compose -f docker-compose.integrated.yml down

# Limpiar datos actuales
sudo rm -rf ./data/*

# Restaurar backup
tar xzf "$BACKUP_FILE" -C ./data

# Arreglar permisos
sudo chown -R 1000:1000 ./data

# Iniciar servicios
docker compose -f docker-compose.integrated.yml up -d

echo "✅ Restauración completada"
```

## Contacto y Soporte

### Información del Sistema
```bash
# Generar reporte del sistema
echo "=== REPORTE DEL SISTEMA ===" > system-report.txt
echo "Fecha: $(date)" >> system-report.txt
echo "Usuario: $(whoami)" >> system-report.txt
echo "OS: $(uname -a)" >> system-report.txt
echo "Docker: $(docker --version)" >> system-report.txt
echo "" >> system-report.txt

echo "=== ESTADO DE SERVICIOS ===" >> system-report.txt
docker compose -f docker-compose.integrated.yml ps >> system-report.txt
echo "" >> system-report.txt

echo "=== LOGS RECIENTES ===" >> system-report.txt
docker compose -f docker-compose.integrated.yml logs --tail=50 >> system-report.txt

echo "Reporte generado: system-report.txt"
```

### Recursos de Ayuda
- **GitHub Issues**: https://github.com/giovanemere/ia-ops-minio/issues
- **Documentación MinIO**: https://docs.min.io/
- **Docker Compose**: https://docs.docker.com/compose/
- **Logs del Sistema**: `/var/log/` y `./logs/`
