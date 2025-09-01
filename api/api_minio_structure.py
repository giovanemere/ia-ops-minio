#!/usr/bin/env python3
"""
API para mostrar estructura de MinIO
"""

from flask import Blueprint, jsonify
import logging
from minio import Minio
import os

logger = logging.getLogger(__name__)

# Crear blueprint
api_minio_structure = Blueprint('api_minio_structure', __name__)

def get_minio_client():
    """Obtener cliente MinIO"""
    try:
        return Minio(
            os.getenv('MINIO_ENDPOINT', 'iaops-minio:9000'),
            access_key=os.getenv('MINIO_ACCESS_KEY', 'minioadmin'),
            secret_key=os.getenv('MINIO_SECRET_KEY', 'minioadmin123'),
            secure=False
        )
    except Exception as e:
        logger.error(f"Error conectando a MinIO: {e}")
        return None

@api_minio_structure.route('/api/minio/structure', methods=['GET'])
def get_minio_structure():
    """Obtener estructura organizada de MinIO"""
    try:
        client = get_minio_client()
        if not client:
            return jsonify({'error': 'Cliente MinIO no disponible'}), 500
        
        bucket = os.getenv('MINIO_BUCKET', 'techdocs-storage')
        objects = list(client.list_objects(bucket, recursive=True))
        
        # Organizar por carpetas
        structure = {
            'repositories': [],
            'builds': [],
            'temp': [],
            'metadata': [],
            'other': []
        }
        
        total_size = 0
        
        for obj in objects:
            size_mb = obj.size / (1024 * 1024)
            total_size += obj.size
            
            file_info = {
                'name': obj.object_name,
                'size_bytes': obj.size,
                'size_mb': round(size_mb, 2),
                'last_modified': obj.last_modified.isoformat() if obj.last_modified else None
            }
            
            # Clasificar por carpeta
            if obj.object_name.startswith('repositories/'):
                structure['repositories'].append(file_info)
            elif obj.object_name.startswith('builds/'):
                structure['builds'].append(file_info)
            elif obj.object_name.startswith('temp/'):
                structure['temp'].append(file_info)
            elif obj.object_name.startswith('metadata/'):
                structure['metadata'].append(file_info)
            else:
                structure['other'].append(file_info)
        
        # Estadísticas
        stats = {
            'total_objects': len(objects),
            'total_size_bytes': total_size,
            'total_size_mb': round(total_size / (1024 * 1024), 2),
            'repositories_count': len(structure['repositories']),
            'builds_count': len(structure['builds']),
            'temp_count': len(structure['temp']),
            'metadata_count': len(structure['metadata']),
            'other_count': len(structure['other'])
        }
        
        return jsonify({
            'success': True,
            'bucket': bucket,
            'structure': structure,
            'stats': stats,
            'recommended_structure': {
                'repositories/': 'Repositorios comprimidos como ZIP',
                'builds/': 'Documentación construida (HTML, CSS, JS)',
                'temp/': 'Archivos temporales de procesamiento',
                'metadata/': 'Metadatos y configuraciones'
            }
        })
        
    except Exception as e:
        logger.error(f"Error obteniendo estructura MinIO: {e}")
        return jsonify({'error': str(e)}), 500

@api_minio_structure.route('/api/minio/repositories', methods=['GET'])
def get_minio_repositories():
    """Obtener lista de repositorios en MinIO"""
    try:
        client = get_minio_client()
        if not client:
            return jsonify({'error': 'Cliente MinIO no disponible'}), 500
        
        bucket = os.getenv('MINIO_BUCKET', 'techdocs-storage')
        objects = list(client.list_objects(bucket, prefix='repositories/', recursive=True))
        
        repositories = []
        for obj in objects:
            if obj.object_name.endswith('.zip'):
                repo_name = obj.object_name.replace('repositories/', '').replace('.zip', '')
                repositories.append({
                    'name': repo_name,
                    'zip_file': obj.object_name,
                    'size_mb': round(obj.size / (1024 * 1024), 2),
                    'last_modified': obj.last_modified.isoformat() if obj.last_modified else None
                })
        
        return jsonify({
            'success': True,
            'repositories': repositories,
            'count': len(repositories)
        })
        
    except Exception as e:
        logger.error(f"Error obteniendo repositorios MinIO: {e}")
        return jsonify({'error': str(e)}), 500

@api_minio_structure.route('/api/minio/builds', methods=['GET'])
def get_minio_builds():
    """Obtener lista de builds en MinIO"""
    try:
        client = get_minio_client()
        if not client:
            return jsonify({'error': 'Cliente MinIO no disponible'}), 500
        
        bucket = os.getenv('MINIO_BUCKET', 'techdocs-storage')
        objects = list(client.list_objects(bucket, prefix='builds/', recursive=True))
        
        builds = {}
        for obj in objects:
            path_parts = obj.object_name.split('/')
            if len(path_parts) >= 2:
                repo_name = path_parts[1]
                if repo_name not in builds:
                    builds[repo_name] = {
                        'name': repo_name,
                        'files': [],
                        'total_size_mb': 0
                    }
                
                builds[repo_name]['files'].append({
                    'path': '/'.join(path_parts[2:]) if len(path_parts) > 2 else '',
                    'full_path': obj.object_name,
                    'size_bytes': obj.size,
                    'last_modified': obj.last_modified.isoformat() if obj.last_modified else None
                })
                builds[repo_name]['total_size_mb'] += obj.size / (1024 * 1024)
        
        # Redondear tamaños
        for build in builds.values():
            build['total_size_mb'] = round(build['total_size_mb'], 2)
            build['files_count'] = len(build['files'])
        
        return jsonify({
            'success': True,
            'builds': list(builds.values()),
            'count': len(builds)
        })
        
    except Exception as e:
        logger.error(f"Error obteniendo builds MinIO: {e}")
        return jsonify({'error': str(e)}), 500
