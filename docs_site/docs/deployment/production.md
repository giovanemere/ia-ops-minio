# 🚀 Despliegue en Producción

## Configuración de Producción

### Variables de Entorno Seguras
```bash
# Credenciales seguras
MINIO_ROOT_USER=admin_$(openssl rand -hex 8)
MINIO_ROOT_PASSWORD=$(openssl rand -base64 32)

# URLs de producción
MINIO_SERVER_URL=https://minio.example.com
MINIO_BROWSER_REDIRECT_URL=https://console.example.com

# SSL/TLS
MINIO_OPTS="--certs-dir /certs"
```

### Docker Compose para Producción
```yaml
version: '3.8'
services:
  ia-ops-minio:
    image: edissonz8809/ia-ops-minio-integrated:latest
    restart: always
    environment:
      - MINIO_ROOT_USER=${MINIO_ROOT_USER}
      - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
    volumes:
      - /data/minio:/data
      - /etc/ssl/certs:/certs:ro
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.minio.rule=Host(`minio.example.com`)"
      - "traefik.http.routers.minio.tls.certresolver=letsencrypt"
```

## Proxy Reverso con Nginx

### Configuración Nginx
```nginx
upstream minio_console {
    server localhost:9899;
}

upstream minio_api {
    server localhost:9898;
}

server {
    listen 443 ssl http2;
    server_name console.example.com;
    
    ssl_certificate /etc/ssl/certs/console.crt;
    ssl_certificate_key /etc/ssl/private/console.key;
    
    location / {
        proxy_pass http://minio_console;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 443 ssl http2;
    server_name minio.example.com;
    
    ssl_certificate /etc/ssl/certs/minio.crt;
    ssl_certificate_key /etc/ssl/private/minio.key;
    
    location / {
        proxy_pass http://minio_api;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Alta Disponibilidad

### Cluster MinIO
```bash
# Nodo 1
docker run -d \
  --name minio1 \
  -p 9000:9000 \
  -p 9001:9001 \
  -v /data1:/data1 \
  -v /data2:/data2 \
  minio/minio server \
  http://minio{1...4}/data{1...2} \
  --console-address ":9001"

# Nodo 2-4 similar configuración
```

### Load Balancer
```yaml
version: '3.8'
services:
  haproxy:
    image: haproxy:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
```

## Monitoreo y Alertas

### Prometheus + Grafana
```yaml
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
```

### Health Checks
```bash
#!/bin/bash
# health-check.sh

ENDPOINTS=(
  "http://localhost:6540/health"
  "http://localhost:8848/health"
  "http://localhost:9898/minio/health/live"
)

for endpoint in "${ENDPOINTS[@]}"; do
  if ! curl -f "$endpoint" > /dev/null 2>&1; then
    echo "ALERT: $endpoint is down"
    # Enviar alerta
  fi
done
```

## Backup y Recuperación

### Backup Automático
```bash
#!/bin/bash
# backup-production.sh

BACKUP_DIR="/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup de datos
mc mirror minio/production-data "$BACKUP_DIR/data"

# Backup de configuración
docker exec minio-container cat /etc/minio/config.json > "$BACKUP_DIR/config.json"

# Comprimir y subir a S3 externo
tar czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
aws s3 cp "$BACKUP_DIR.tar.gz" s3://backups-bucket/
```

## Seguridad

### Firewall
```bash
# Solo puertos necesarios
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw deny 9898/tcp   # MinIO API (solo interno)
ufw deny 9899/tcp   # MinIO Console (solo interno)
```

### Certificados SSL
```bash
# Let's Encrypt
certbot --nginx -d minio.example.com -d console.example.com

# Renovación automática
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
```
