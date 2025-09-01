# 💡 Ejemplos

## Python Examples

### Configuración Básica
```python
import requests
import json

# Base URL
BASE_URL = "http://localhost:8848"

# Headers comunes
headers = {
    'Content-Type': 'application/json'
}
```

### Gestión de Buckets

#### Listar Buckets
```python
def list_buckets():
    response = requests.get(f"{BASE_URL}/api/buckets")
    if response.status_code == 200:
        data = response.json()
        print(f"Total buckets: {data['count']}")
        for bucket in data['buckets']:
            print(f"- {bucket['name']} (created: {bucket['creation_date']})")
    return response.json()

# Uso
buckets = list_buckets()
```

#### Crear Bucket
```python
def create_bucket(bucket_name):
    payload = {"name": bucket_name}
    response = requests.post(
        f"{BASE_URL}/api/buckets",
        headers=headers,
        data=json.dumps(payload)
    )
    if response.status_code == 201:
        print(f"Bucket '{bucket_name}' creado exitosamente")
    else:
        print(f"Error: {response.json()}")
    return response.json()

# Uso
create_bucket("mi-proyecto")
```

#### Eliminar Bucket
```python
def delete_bucket(bucket_name):
    response = requests.delete(f"{BASE_URL}/api/buckets/{bucket_name}")
    if response.status_code == 200:
        print(f"Bucket '{bucket_name}' eliminado")
    return response.json()

# Uso
delete_bucket("bucket-temporal")
```

### Gestión de Objetos

#### Subir Archivo
```python
def upload_file(bucket_name, file_path, object_key=None):
    with open(file_path, 'rb') as file:
        files = {'file': file}
        data = {}
        if object_key:
            data['key'] = object_key
        
        response = requests.post(
            f"{BASE_URL}/api/buckets/{bucket_name}/objects",
            files=files,
            data=data
        )
    
    if response.status_code == 201:
        result = response.json()
        print(f"Archivo subido: {result['key']} ({result['size']} bytes)")
    return response.json()

# Uso
upload_file("mi-proyecto", "documento.pdf", "docs/documento.pdf")
```

#### Listar Objetos
```python
def list_objects(bucket_name, prefix=None):
    params = {}
    if prefix:
        params['prefix'] = prefix
    
    response = requests.get(
        f"{BASE_URL}/api/buckets/{bucket_name}/objects",
        params=params
    )
    
    if response.status_code == 200:
        data = response.json()
        print(f"Objetos en '{bucket_name}': {data['count']}")
        for obj in data['objects']:
            print(f"- {obj['key']} ({obj['size']} bytes)")
    return response.json()

# Uso
list_objects("mi-proyecto")
list_objects("mi-proyecto", prefix="docs/")
```

#### Descargar Archivo
```python
def download_file(bucket_name, object_key, local_path):
    response = requests.get(
        f"{BASE_URL}/api/buckets/{bucket_name}/objects/{object_key}"
    )
    
    if response.status_code == 200:
        with open(local_path, 'wb') as file:
            file.write(response.content)
        print(f"Archivo descargado: {local_path}")
    else:
        print(f"Error: {response.status_code}")

# Uso
download_file("mi-proyecto", "docs/documento.pdf", "descarga.pdf")
```

## JavaScript Examples

### Configuración con Fetch
```javascript
const BASE_URL = 'http://localhost:8848';

// Función helper para requests
async function apiRequest(endpoint, options = {}) {
    const response = await fetch(`${BASE_URL}${endpoint}`, {
        headers: {
            'Content-Type': 'application/json',
            ...options.headers
        },
        ...options
    });
    
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return response.json();
}
```

### Gestión de Buckets
```javascript
// Listar buckets
async function listBuckets() {
    try {
        const data = await apiRequest('/api/buckets');
        console.log(`Total buckets: ${data.count}`);
        data.buckets.forEach(bucket => {
            console.log(`- ${bucket.name}`);
        });
        return data;
    } catch (error) {
        console.error('Error:', error);
    }
}

// Crear bucket
async function createBucket(bucketName) {
    try {
        const data = await apiRequest('/api/buckets', {
            method: 'POST',
            body: JSON.stringify({ name: bucketName })
        });
        console.log(`Bucket '${bucketName}' creado`);
        return data;
    } catch (error) {
        console.error('Error:', error);
    }
}

// Uso
listBuckets();
createBucket('mi-bucket-js');
```

### Subir Archivo con FormData
```javascript
async function uploadFile(bucketName, file, objectKey) {
    const formData = new FormData();
    formData.append('file', file);
    if (objectKey) {
        formData.append('key', objectKey);
    }
    
    try {
        const response = await fetch(
            `${BASE_URL}/api/buckets/${bucketName}/objects`,
            {
                method: 'POST',
                body: formData
            }
        );
        
        const data = await response.json();
        console.log(`Archivo subido: ${data.key}`);
        return data;
    } catch (error) {
        console.error('Error:', error);
    }
}

// Uso con input file
document.getElementById('fileInput').addEventListener('change', (event) => {
    const file = event.target.files[0];
    if (file) {
        uploadFile('mi-bucket', file, `uploads/${file.name}`);
    }
});
```

## Bash/curl Examples

### Script de Backup
```bash
#!/bin/bash

BUCKET_NAME="backup-$(date +%Y%m%d)"
BASE_URL="http://localhost:8848"

# Crear bucket para backup
echo "Creando bucket: $BUCKET_NAME"
curl -X POST "$BASE_URL/api/buckets" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$BUCKET_NAME\"}"

# Subir archivos de configuración
echo "Subiendo archivos..."
for file in /etc/config/*.conf; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        curl -X POST "$BASE_URL/api/buckets/$BUCKET_NAME/objects" \
          -F "file=@$file" \
          -F "key=config/$filename"
        echo "Subido: $filename"
    fi
done

echo "Backup completado en bucket: $BUCKET_NAME"
```

### Monitoreo de Sistema
```bash
#!/bin/bash

# Verificar estado del sistema
check_health() {
    echo "=== Health Check ==="
    curl -s http://localhost:8848/health | jq '.'
    echo
}

# Obtener estadísticas
get_stats() {
    echo "=== System Stats ==="
    curl -s http://localhost:8848/api/status | jq '.'
    echo
}

# Listar buckets
list_buckets() {
    echo "=== Buckets ==="
    curl -s http://localhost:8848/api/buckets | jq '.buckets[] | .name'
    echo
}

# Ejecutar todas las verificaciones
check_health
get_stats
list_buckets
```

## Casos de Uso Completos

### Sistema de Documentación
```python
import os
import requests
from pathlib import Path

class DocManager:
    def __init__(self, base_url="http://localhost:8848"):
        self.base_url = base_url
        self.bucket = "techdocs-storage"
    
    def upload_docs(self, docs_dir):
        """Subir todos los documentos de un directorio"""
        docs_path = Path(docs_dir)
        
        for file_path in docs_path.rglob("*.md"):
            relative_path = file_path.relative_to(docs_path)
            object_key = f"docs/{relative_path}"
            
            with open(file_path, 'rb') as file:
                files = {'file': file}
                data = {'key': object_key}
                
                response = requests.post(
                    f"{self.base_url}/api/buckets/{self.bucket}/objects",
                    files=files,
                    data=data
                )
                
                if response.status_code == 201:
                    print(f"✓ {object_key}")
                else:
                    print(f"✗ Error subiendo {object_key}")
    
    def sync_docs(self, docs_dir):
        """Sincronizar documentos locales con el bucket"""
        # Obtener lista de objetos remotos
        response = requests.get(
            f"{self.base_url}/api/buckets/{self.bucket}/objects",
            params={'prefix': 'docs/'}
        )
        
        if response.status_code == 200:
            remote_objects = {obj['key'] for obj in response.json()['objects']}
            
            # Subir archivos nuevos o modificados
            self.upload_docs(docs_dir)
            
            print(f"Sincronización completada. {len(remote_objects)} archivos remotos.")

# Uso
doc_manager = DocManager()
doc_manager.sync_docs("./documentation")
```

### Cliente de Backup Automático
```python
import schedule
import time
from datetime import datetime

class BackupClient:
    def __init__(self):
        self.base_url = "http://localhost:8848"
    
    def daily_backup(self):
        """Backup diario automático"""
        bucket_name = f"backup-{datetime.now().strftime('%Y%m%d')}"
        
        # Crear bucket
        requests.post(
            f"{self.base_url}/api/buckets",
            json={"name": bucket_name}
        )
        
        # Subir archivos importantes
        important_files = [
            "/etc/config/app.conf",
            "/var/log/app.log",
            "/data/database.db"
        ]
        
        for file_path in important_files:
            if os.path.exists(file_path):
                with open(file_path, 'rb') as file:
                    files = {'file': file}
                    data = {'key': os.path.basename(file_path)}
                    
                    requests.post(
                        f"{self.base_url}/api/buckets/{bucket_name}/objects",
                        files=files,
                        data=data
                    )
        
        print(f"Backup completado: {bucket_name}")

# Programar backup diario
backup_client = BackupClient()
schedule.every().day.at("02:00").do(backup_client.daily_backup)

# Ejecutar scheduler
while True:
    schedule.run_pending()
    time.sleep(60)
```
