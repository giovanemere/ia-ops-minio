# 🔐 Políticas de Acceso

## Tipos de Políticas

### Políticas de Bucket
Controlan el acceso a buckets completos:

- **Private**: Solo el propietario tiene acceso
- **Public Read**: Lectura pública, escritura privada
- **Public Write**: Lectura y escritura pública
- **Custom**: Políticas personalizadas

### Políticas de Usuario
Definen permisos específicos por usuario:

- **Admin**: Acceso completo al sistema
- **ReadWrite**: Lectura y escritura en buckets específicos
- **ReadOnly**: Solo lectura
- **Custom**: Permisos granulares

## Configurar Políticas

### Desde MinIO Console

1. Accede a http://localhost:9899
2. Ve a "Buckets" → Selecciona bucket
3. Click en "Manage" → "Access Rules"
4. Configura las reglas de acceso

### Políticas JSON

#### Política de Solo Lectura
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["*"]},
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::mi-bucket/*"]
    }
  ]
}
```

#### Política de Lectura/Escritura
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["*"]},
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::mi-bucket/*"]
    }
  ]
}
```

### Aplicar Políticas via CLI

```bash
# Configurar mc (MinIO Client)
mc alias set myminio http://localhost:9898 minioadmin minioadmin123

# Aplicar política pública de lectura
mc anonymous set public myminio/mi-bucket

# Aplicar política personalizada
mc anonymous set-json policy.json myminio/mi-bucket
```

## Gestión de Usuarios

### Crear Usuario

#### MinIO Console
1. Ve a "Identity" → "Users"
2. Click "Create User"
3. Ingresa credenciales
4. Asigna políticas

#### CLI
```bash
# Crear usuario
mc admin user add myminio usuario contraseña

# Asignar política
mc admin policy set myminio readwrite user=usuario
```

### Políticas de Usuario Predefinidas

#### ReadWrite
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::*",
        "arn:aws:s3:::*/*"
      ]
    }
  ]
}
```

#### ReadOnly
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::*",
        "arn:aws:s3:::*/*"
      ]
    }
  ]
}
```

## Grupos de Usuarios

### Crear Grupo
```bash
# Crear grupo
mc admin group add myminio developers

# Agregar usuarios al grupo
mc admin group add myminio developers usuario1 usuario2

# Asignar política al grupo
mc admin policy set myminio readwrite group=developers
```

## Tokens de Acceso Temporal

### Service Account Tokens
```bash
# Crear service account
mc admin user svcacct add myminio usuario

# Listar service accounts
mc admin user svcacct list myminio usuario
```

### STS (Security Token Service)
```python
import boto3

# Cliente STS
sts_client = boto3.client(
    'sts',
    endpoint_url='http://localhost:9898',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin123'
)

# Obtener token temporal
response = sts_client.assume_role(
    RoleArn='arn:aws:iam::123456789012:role/temp-role',
    RoleSessionName='temp-session'
)
```

## Configuración por Bucket

### Buckets Públicos
```bash
# techdocs-storage - Público para lectura
mc anonymous set download myminio/techdocs-storage

# static-assets - Público para lectura
mc anonymous set download myminio/static-assets
```

### Buckets Privados
```bash
# repositories-backup - Solo admin
mc anonymous set none myminio/repositories-backup

# build-artifacts - Solo usuarios autorizados
mc anonymous set none myminio/build-artifacts
```

## Mejores Prácticas

### Principio de Menor Privilegio
- Otorga solo los permisos mínimos necesarios
- Usa grupos en lugar de permisos individuales
- Revisa periódicamente los accesos

### Seguridad
- Cambia credenciales por defecto
- Usa HTTPS en producción
- Implementa rotación de tokens
- Audita accesos regularmente

### Organización
- Agrupa usuarios por función
- Usa políticas consistentes
- Documenta las configuraciones
