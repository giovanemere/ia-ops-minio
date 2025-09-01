# 🔧 Variables de Entorno

## Variables Principales

### Credenciales MinIO
```bash
# Usuario administrador por defecto
MINIO_ROOT_USER=minioadmin

# Contraseña administrador por defecto
MINIO_ROOT_PASSWORD=minioadmin123
```

### Configuración de Puertos
```bash
# Puerto del dashboard principal
DASHBOARD_PORT=6540

# Puerto de la consola web de MinIO
MINIO_CONSOLE_PORT=9899

# Puerto de la API S3 de MinIO
MINIO_API_PORT=9898

# Puerto de la API REST personalizada
REST_API_PORT=8848

# Puerto de la documentación MkDocs
DOCS_PORT=6541
```

### Configuración de Almacenamiento
```bash
# Directorio de datos de MinIO
MINIO_DATA_DIR=./data

# Directorio de logs
MINIO_LOGS_DIR=./logs

# Configuración de región
MINIO_REGION=us-east-1
```

## Variables de Producción

### URLs Públicas
```bash
# URL del servidor MinIO (para producción)
MINIO_SERVER_URL=https://minio.example.com

# URL de redirección del navegador
MINIO_BROWSER_REDIRECT_URL=https://console.example.com

# Dominio personalizado
MINIO_DOMAIN=minio.example.com
```

### Configuración SSL/TLS
```bash
# Directorio de certificados
MINIO_CERTS_DIR=/certs

# Opciones adicionales de MinIO
MINIO_OPTS="--certs-dir /certs"

# Habilitar HTTPS
MINIO_HTTPS=true
```

### Configuración de Seguridad
```bash
# Tipo de autenticación para Prometheus
MINIO_PROMETHEUS_AUTH_TYPE=public

# URL de Prometheus
MINIO_PROMETHEUS_URL=http://localhost:9090

# JWT Secret para tokens
MINIO_JWT_SECRET=your-secret-key

# Tiempo de expiración de tokens (en horas)
MINIO_TOKEN_EXPIRY=24
```

## Variables de Base de Datos

### PostgreSQL (opcional)
```bash
# Host de la base de datos
DB_HOST=localhost

# Puerto de la base de datos
DB_PORT=5432

# Nombre de la base de datos
DB_NAME=minio_metadata

# Usuario de la base de datos
DB_USER=minio

# Contraseña de la base de datos
DB_PASSWORD=password123
```

## Variables de Notificaciones

### Webhook
```bash
# URL del webhook para notificaciones
MINIO_NOTIFY_WEBHOOK_ENDPOINT=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Token de autenticación del webhook
MINIO_NOTIFY_WEBHOOK_AUTH_TOKEN=your-token
```

### Email (SMTP)
```bash
# Servidor SMTP
MINIO_NOTIFY_SMTP_SERVER=smtp.gmail.com

# Puerto SMTP
MINIO_NOTIFY_SMTP_PORT=587

# Usuario SMTP
MINIO_NOTIFY_SMTP_USERNAME=your-email@gmail.com

# Contraseña SMTP
MINIO_NOTIFY_SMTP_PASSWORD=your-password

# Email de origen
MINIO_NOTIFY_SMTP_FROM=minio@example.com
```

## Variables de Desarrollo

### Debug y Logging
```bash
# Nivel de log (DEBUG, INFO, WARN, ERROR)
LOG_LEVEL=INFO

# Habilitar modo debug
DEBUG=false

# Formato de logs (json, text)
LOG_FORMAT=json

# Archivo de log
LOG_FILE=/app/logs/minio.log
```

### Configuración de Desarrollo
```bash
# Modo de desarrollo
DEVELOPMENT_MODE=true

# Hot reload para desarrollo
HOT_RELOAD=true

# Puerto de desarrollo
DEV_PORT=3000

# Directorio de código fuente
SOURCE_DIR=./src
```

## Variables de Integración

### AWS S3 Gateway
```bash
# Habilitar modo gateway S3
MINIO_GATEWAY_S3=true

# Región de AWS
AWS_REGION=us-east-1

# Credenciales de AWS
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
```

### Azure Blob Gateway
```bash
# Habilitar modo gateway Azure
MINIO_GATEWAY_AZURE=true

# Nombre de la cuenta de Azure
AZURE_STORAGE_ACCOUNT=your-account

# Clave de acceso de Azure
AZURE_STORAGE_KEY=your-key
```

## Ejemplo de Archivo .env

### Desarrollo
```bash
# .env.development
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123

DASHBOARD_PORT=6540
MINIO_CONSOLE_PORT=9899
MINIO_API_PORT=9898
REST_API_PORT=8848
DOCS_PORT=6541

MINIO_DATA_DIR=./data
MINIO_LOGS_DIR=./logs

LOG_LEVEL=DEBUG
DEVELOPMENT_MODE=true
```

### Producción
```bash
# .env.production
MINIO_ROOT_USER=admin_$(openssl rand -hex 8)
MINIO_ROOT_PASSWORD=$(openssl rand -base64 32)

DASHBOARD_PORT=6540
MINIO_CONSOLE_PORT=9899
MINIO_API_PORT=9898
REST_API_PORT=8848
DOCS_PORT=6541

MINIO_SERVER_URL=https://minio.example.com
MINIO_BROWSER_REDIRECT_URL=https://console.example.com

MINIO_DATA_DIR=/data/minio
MINIO_LOGS_DIR=/var/log/minio
MINIO_CERTS_DIR=/etc/ssl/minio

LOG_LEVEL=INFO
LOG_FORMAT=json

# Notificaciones
MINIO_NOTIFY_WEBHOOK_ENDPOINT=https://hooks.slack.com/services/YOUR/WEBHOOK
MINIO_NOTIFY_SMTP_SERVER=smtp.company.com
MINIO_NOTIFY_SMTP_FROM=minio@company.com
```

## Validación de Variables

### Script de Validación
```bash
#!/bin/bash
# validate-env.sh

required_vars=(
    "MINIO_ROOT_USER"
    "MINIO_ROOT_PASSWORD"
    "DASHBOARD_PORT"
    "MINIO_CONSOLE_PORT"
    "MINIO_API_PORT"
)

missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo "ERROR: Missing required environment variables:"
    printf '%s\n' "${missing_vars[@]}"
    exit 1
fi

echo "✅ All required environment variables are set"
```

## Mejores Prácticas

### Seguridad
- Nunca uses credenciales por defecto en producción
- Usa secretos de Docker o Kubernetes para datos sensibles
- Rota credenciales regularmente
- Usa variables de entorno específicas por ambiente

### Organización
- Agrupa variables por funcionalidad
- Usa prefijos consistentes (MINIO_, DB_, etc.)
- Documenta el propósito de cada variable
- Mantén archivos .env separados por ambiente

### Validación
- Valida variables requeridas al inicio
- Usa valores por defecto sensatos
- Implementa verificaciones de formato
- Registra configuración aplicada (sin secretos)
