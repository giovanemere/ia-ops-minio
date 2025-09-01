# 🚀 Instalación

Esta guía te llevará paso a paso para instalar y configurar IA-Ops MinIO en tu entorno.

## 📋 Prerrequisitos

### Sistema Operativo
- **Linux** (Ubuntu 20.04+, CentOS 8+, RHEL 8+)
- **macOS** (10.15+)
- **Windows** (con WSL2)

### Software Requerido

=== "Docker & Docker Compose"
    ```bash
    # Ubuntu/Debian
    sudo apt update
    sudo apt install docker.io docker-compose-plugin
    
    # CentOS/RHEL
    sudo yum install docker docker-compose-plugin
    
    # macOS (con Homebrew)
    brew install docker docker-compose
    ```

=== "Git"
    ```bash
    # Ubuntu/Debian
    sudo apt install git
    
    # CentOS/RHEL
    sudo yum install git
    
    # macOS
    brew install git
    ```

=== "Curl"
    ```bash
    # Ubuntu/Debian
    sudo apt install curl
    
    # CentOS/RHEL
    sudo yum install curl
    
    # macOS (incluido por defecto)
    ```

### Recursos del Sistema

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 4 GB | 8+ GB |
| **Disco** | 20 GB | 100+ GB |
| **Red** | 100 Mbps | 1+ Gbps |

## 📥 Descarga del Proyecto

### Opción 1: Git Clone (Recomendado)

```bash
# Clonar repositorio
git clone git@github.com:giovanemere/ia-ops-minio.git
cd ia-ops-minio

# Verificar estructura
ls -la
```

### Opción 2: Descarga ZIP

```bash
# Descargar y extraer
wget https://github.com/giovanemere/ia-ops-minio/archive/main.zip
unzip main.zip
cd ia-ops-minio-main
```

## ⚙️ Configuración Inicial

### 1. Variables de Entorno

```bash
# Copiar archivos de configuración
cp docker/.env.example docker/.env
cp docker/.env.docker.example docker/.env.docker

# Editar configuración básica
nano docker/.env
```

**Configuración mínima en `.env`:**
```bash
# MinIO Configuration
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
MINIO_VERSION=RELEASE.2023-10-25T06-33-25Z

# Ports Configuration
MINIO_API_PORT=9898
MINIO_CONSOLE_PORT=9899
MINIO_REST_API_PORT=8848
```

### 2. Configuración Docker Hub (Opcional)

Si planeas usar el modo producción:

```bash
# Editar configuración Docker Hub
nano docker/.env.docker
```

```bash
# Docker Hub Configuration
DOCKER_USERNAME=tu-usuario
DOCKER_TOKEN=tu-token
IMAGE_NAME=ia-ops-minio-api
IMAGE_TAG=latest
```

### 3. Permisos de Scripts

```bash
# Hacer scripts ejecutables
chmod +x scripts/*.sh

# Verificar permisos
ls -la scripts/
```

## 🏗️ Instalación

### Instalación Automática (Recomendado)

```bash
# Ejecutar setup completo
./scripts/setup.sh
```

Este script realizará:

1. ✅ Verificación de prerrequisitos
2. 📁 Creación de directorios necesarios
3. ⚙️ Configuración de variables de entorno
4. 🐳 Construcción de imágenes Docker
5. 🚀 Inicio de servicios
6. 🔍 Verificación de salud

### Instalación Manual

Si prefieres control total sobre el proceso:

=== "Paso 1: Preparación"
    ```bash
    # Crear directorios
    mkdir -p data logs config/policies
    
    # Verificar Docker
    docker --version
    docker compose version
    ```

=== "Paso 2: Build"
    ```bash
    # Construir imágenes
    cd docker
    docker compose build --no-cache
    ```

=== "Paso 3: Inicio"
    ```bash
    # Iniciar servicios
    docker compose up -d
    
    # Verificar estado
    docker compose ps
    ```

## 🔍 Verificación de Instalación

### 1. Estado de Servicios

```bash
# Verificar con script
./scripts/status.sh

# O manualmente
docker compose -f docker/docker-compose.yml ps
```

**Salida esperada:**
```
NAME                  STATUS                    PORTS
iaops-minio-storage   Up (healthy)             0.0.0.0:9898->9000/tcp, 0.0.0.0:9899->9001/tcp
iaops-minio-api       Up (healthy)             0.0.0.0:8848->8848/tcp
iaops-minio-setup     Exited (0)               
```

### 2. Health Checks

```bash
# MinIO API
curl -f http://localhost:9898/minio/health/live

# REST API
curl -f http://localhost:8848/health
```

### 3. Acceso Web

Abre en tu navegador:

- **MinIO Console**: [http://localhost:9899](http://localhost:9899)
- **REST API Health**: [http://localhost:8848/health](http://localhost:8848/health)

## 🎯 Primer Uso

### 1. Login en MinIO Console

1. Ve a [http://localhost:9899](http://localhost:9899)
2. Usuario: `minioadmin`
3. Contraseña: `minioadmin123`

### 2. Verificar Buckets

```bash
# Listar buckets via API
curl http://localhost:8848/buckets
```

**Respuesta esperada:**
```json
{
  "buckets": [
    {"name": "techdocs-storage"},
    {"name": "repositories-backup"},
    {"name": "build-artifacts"},
    {"name": "static-assets"}
  ],
  "count": 4
}
```

### 3. Subir Primer Archivo

```bash
# Crear archivo de prueba
echo "Hello IA-Ops MinIO!" > test.txt

# Subir via API
curl -X POST \
  -F "file=@test.txt" \
  http://localhost:8848/buckets/techdocs-storage/objects
```

## 🚨 Solución de Problemas

### Puerto en Uso

```bash
# Verificar puertos ocupados
sudo netstat -tlnp | grep -E ':(9898|9899|8848)'

# Cambiar puertos en .env si es necesario
MINIO_API_PORT=9998
MINIO_CONSOLE_PORT=9999
MINIO_REST_API_PORT=8948
```

### Permisos de Docker

```bash
# Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Reiniciar sesión o ejecutar
newgrp docker
```

### Logs de Depuración

```bash
# Ver logs de todos los servicios
docker compose -f docker/docker-compose.yml logs -f

# Ver logs de un servicio específico
docker compose -f docker/docker-compose.yml logs -f minio-api
```

## ✅ Próximos Pasos

Una vez completada la instalación:

1. **[Configuración Avanzada](configuration.md)** - Personaliza tu instalación
2. **[Primer Uso](first-use.md)** - Aprende las operaciones básicas
3. **[API REST](../api/introduction.md)** - Explora las capacidades de la API

!!! success "¡Instalación Completada!"
    Tu sistema IA-Ops MinIO está listo para usar. Todos los servicios están funcionando y los buckets predefinidos han sido creados.
