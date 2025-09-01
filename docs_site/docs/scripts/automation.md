# 🤖 Automatización

## Scripts de Automatización

### Backup Automático Diario
```bash
#!/bin/bash
# daily-backup.sh

BACKUP_BASE="/backups"
DATE=$(date +%Y%m%d)
BACKUP_DIR="$BACKUP_BASE/$DATE"

# Crear directorio de backup
mkdir -p "$BACKUP_DIR"

# Backup de datos MinIO
echo "Iniciando backup de datos..."
mc mirror myminio/ "$BACKUP_DIR/minio-data/"

# Backup de configuración
echo "Backup de configuración..."
cp .env "$BACKUP_DIR/"
docker compose -f docker-compose.integrated.yml config > "$BACKUP_DIR/docker-compose.yml"

# Comprimir backup
echo "Comprimiendo backup..."
tar czf "$BACKUP_DIR.tar.gz" -C "$BACKUP_BASE" "$DATE"
rm -rf "$BACKUP_DIR"

# Limpiar backups antiguos (mantener 7 días)
find "$BACKUP_BASE" -name "*.tar.gz" -mtime +7 -delete

echo "Backup completado: $BACKUP_DIR.tar.gz"
```

### Monitoreo Continuo
```bash
#!/bin/bash
# continuous-monitor.sh

LOG_FILE="/var/log/minio-monitor.log"
ALERT_EMAIL="admin@example.com"

monitor_service() {
    local service_name="$1"
    local url="$2"
    
    if curl -sf "$url" > /dev/null; then
        echo "$(date): $service_name OK" >> "$LOG_FILE"
        return 0
    else
        echo "$(date): $service_name FAILED" >> "$LOG_FILE"
        echo "ALERT: $service_name is down" | mail -s "MinIO Alert" "$ALERT_EMAIL"
        return 1
    fi
}

while true; do
    monitor_service "Dashboard" "http://localhost:6540/health"
    monitor_service "REST API" "http://localhost:8848/health"
    monitor_service "MinIO API" "http://localhost:9898/minio/health/live"
    
    # Verificar uso de disco
    DISK_USAGE=$(df /data | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -gt 80 ]; then
        echo "$(date): Disk usage high: ${DISK_USAGE}%" >> "$LOG_FILE"
        echo "WARNING: Disk usage is ${DISK_USAGE}%" | mail -s "MinIO Disk Alert" "$ALERT_EMAIL"
    fi
    
    sleep 300  # 5 minutos
done
```

### Sincronización de Documentación
```bash
#!/bin/bash
# sync-docs.sh

DOCS_SOURCE="/path/to/documentation"
BUCKET="techdocs-storage"

echo "Sincronizando documentación..."

# Configurar mc si no está configurado
mc alias set myminio http://localhost:9898 minioadmin minioadmin123 2>/dev/null

# Sincronizar archivos
mc mirror "$DOCS_SOURCE" "myminio/$BUCKET/docs/" --overwrite

# Hacer bucket público para lectura
mc anonymous set download "myminio/$BUCKET"

echo "Sincronización completada"

# Log de la operación
echo "$(date): Documentation synced to $BUCKET" >> /var/log/docs-sync.log
```

## Cron Jobs

### Configuración de Crontab
```bash
# Editar crontab
crontab -e

# Agregar trabajos automáticos
# Backup diario a las 2:00 AM
0 2 * * * /path/to/scripts/daily-backup.sh

# Sincronizar docs cada hora
0 * * * * /path/to/scripts/sync-docs.sh

# Limpiar logs cada domingo a las 3:00 AM
0 3 * * 0 /path/to/scripts/cleanup-logs.sh

# Verificar salud cada 5 minutos
*/5 * * * * /path/to/scripts/health-check.sh
```

### Script de Health Check
```bash
#!/bin/bash
# health-check.sh

SERVICES=(
    "Dashboard:http://localhost:6540/health"
    "REST API:http://localhost:8848/health"
    "MinIO:http://localhost:9898/minio/health/live"
)

FAILED_SERVICES=()

for service in "${SERVICES[@]}"; do
    name="${service%%:*}"
    url="${service##*:}"
    
    if ! curl -sf "$url" > /dev/null 2>&1; then
        FAILED_SERVICES+=("$name")
    fi
done

if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
    echo "FAILED SERVICES: ${FAILED_SERVICES[*]}" | \
        mail -s "MinIO Health Check Failed" admin@example.com
    
    # Intentar reiniciar servicios
    docker compose -f /path/to/docker-compose.integrated.yml restart
fi
```

## GitHub Actions

### CI/CD Pipeline
```yaml
# .github/workflows/deploy.yml
name: Deploy MinIO

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Run tests
      run: |
        ./scripts/build-integrated.sh
        docker compose -f docker-compose.integrated.yml up -d
        sleep 30
        ./scripts/verify-system.sh

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Deploy to production
      run: |
        echo "${{ secrets.DEPLOY_KEY }}" | ssh-add -
        ssh user@production-server "cd /opt/ia-ops-minio && git pull && ./scripts/deploy-clean.sh"
```

### Build and Push
```yaml
# .github/workflows/build.yml
name: Build and Push

on:
  release:
    types: [published]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push
      run: |
        ./scripts/build-integrated.sh
        ./scripts/publish-integrated.sh
```

## Ansible Playbooks

### Despliegue Automatizado
```yaml
# playbook.yml
---
- hosts: minio_servers
  become: yes
  vars:
    minio_user: minioadmin
    minio_password: "{{ vault_minio_password }}"
  
  tasks:
    - name: Install Docker
      apt:
        name: docker.io
        state: present
    
    - name: Install Docker Compose
      pip:
        name: docker-compose
        state: present
    
    - name: Clone repository
      git:
        repo: https://github.com/giovanemere/ia-ops-minio.git
        dest: /opt/ia-ops-minio
        version: main
    
    - name: Configure environment
      template:
        src: .env.j2
        dest: /opt/ia-ops-minio/.env
    
    - name: Deploy services
      shell: |
        cd /opt/ia-ops-minio
        ./scripts/deploy-clean.sh
```

### Template de Configuración
```bash
# templates/.env.j2
MINIO_ROOT_USER={{ minio_user }}
MINIO_ROOT_PASSWORD={{ minio_password }}

DASHBOARD_PORT=6540
MINIO_CONSOLE_PORT=9899
MINIO_API_PORT=9898
REST_API_PORT=8848
DOCS_PORT=6541

{% if ansible_env == 'production' %}
MINIO_SERVER_URL=https://{{ minio_domain }}
MINIO_BROWSER_REDIRECT_URL=https://{{ console_domain }}
{% endif %}
```

## Terraform

### Infraestructura como Código
```hcl
# main.tf
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "minio_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.minio.id]
  
  user_data = file("${path.module}/user_data.sh")
  
  tags = {
    Name = "MinIO Server"
    Environment = var.environment
  }
}

resource "aws_security_group" "minio" {
  name_prefix = "minio-"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Script de Inicialización
```bash
#!/bin/bash
# user_data.sh

# Actualizar sistema
apt-get update
apt-get install -y docker.io docker-compose git

# Clonar repositorio
git clone https://github.com/giovanemere/ia-ops-minio.git /opt/ia-ops-minio
cd /opt/ia-ops-minio

# Configurar variables de entorno
cp .env.example .env

# Desplegar servicios
./scripts/deploy-clean.sh

# Configurar inicio automático
systemctl enable docker
```
