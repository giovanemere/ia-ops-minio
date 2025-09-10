#!/usr/bin/env python3
import time
from minio import Minio
from minio.error import S3Error

def wait_for_minio():
    """Esperar a que MinIO esté disponible"""
    max_retries = 30
    for i in range(max_retries):
        try:
            client = Minio("localhost:9898", access_key="minioadmin", secret_key="minioadmin123", secure=False)
            client.list_buckets()
            print("✅ MinIO está disponible")
            return client
        except Exception as e:
            print(f"⏳ Esperando MinIO... ({i+1}/{max_retries})")
            time.sleep(2)
    raise Exception("❌ MinIO no está disponible después de 60 segundos")

def create_buckets():
    """Crear solo los buckets necesarios según configuración de DB"""
    client = wait_for_minio()
    
    # Buckets requeridos por la aplicación
    buckets = [
        "techdocs",           # Bucket principal para documentación (requerido por app)
        "iaops-portal",       # Portal principal con documentación
        "ia-ops-config",      # Configuraciones del sistema
        "ia-ops-data",        # Datos de aplicaciones
        "ia-ops-logs",        # Logs del sistema
        "veritas-projects"    # Proyectos de Veritas
    ]
    
    created_count = 0
    for bucket_name in buckets:
        try:
            if not client.bucket_exists(bucket_name):
                client.make_bucket(bucket_name)
                print(f"✅ Bucket '{bucket_name}' creado")
                created_count += 1
            else:
                print(f"ℹ️  Bucket '{bucket_name}' ya existe")
        except S3Error as e:
            print(f"❌ Error creando bucket '{bucket_name}': {e}")
    
    print(f"\n📦 Resumen: {created_count} buckets creados")
    
    # Listar todos los buckets
    buckets = client.list_buckets()
    print("\n📋 Buckets disponibles:")
    total_objects = 0
    for bucket in buckets:
        objects = list(client.list_objects(bucket.name, recursive=True))
        total_objects += len(objects)
        print(f"  - {bucket.name}: {len(objects)} objetos")
    
    print(f"\n📊 Total: {len(buckets)} buckets, {total_objects} objetos")

if __name__ == "__main__":
    create_buckets()
