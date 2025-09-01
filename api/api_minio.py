from flask import Blueprint, request, jsonify, Response
import os
import json
import base64
from datetime import datetime
from minio import Minio
from minio.error import S3Error
import logging

logger = logging.getLogger(__name__)

minio_api = Blueprint('minio_api', __name__)

def get_minio_client():
    """Obtener cliente MinIO"""
    try:
        minio_endpoint = os.getenv('MINIO_ENDPOINT', 'localhost:9898')
        minio_access_key = os.getenv('MINIO_ACCESS_KEY', 'minioadmin')
        minio_secret_key = os.getenv('MINIO_SECRET_KEY', 'minioadmin123')
        
        # Remover http:// si está presente
        if minio_endpoint.startswith('http://'):
            minio_endpoint = minio_endpoint[7:]
        elif minio_endpoint.startswith('https://'):
            minio_endpoint = minio_endpoint[8:]
        
        return Minio(
            minio_endpoint,
            access_key=minio_access_key,
            secret_key=minio_secret_key,
            secure=False
        )
    except Exception as e:
        logger.error(f"Error creando cliente MinIO: {e}")
        return None

@minio_api.route('/files', methods=['GET'])
def list_files():
    """Listar archivos y carpetas en MinIO"""
    try:
        path = request.args.get('path', '').strip('/')
        bucket_name = 'techdocs-storage'
        
        minio_client = get_minio_client()
        if not minio_client:
            return jsonify({
                'success': False,
                'message': 'Error conectando a MinIO',
                'files': []
            }), 500
        
        # Verificar que el bucket existe
        if not minio_client.bucket_exists(bucket_name):
            return jsonify({
                'success': False,
                'message': f'Bucket {bucket_name} no existe',
                'files': []
            }), 404
        
        # Obtener objetos
        prefix = f"{path}/" if path else ""
        objects = minio_client.list_objects(bucket_name, prefix=prefix, recursive=False)
        
        files = []
        folders = set()
        total_size = 0
        file_count = 0
        
        for obj in objects:
            # Remover el prefijo para obtener el nombre relativo
            relative_name = obj.object_name[len(prefix):] if prefix else obj.object_name
            
            # Saltar si es el mismo directorio
            if not relative_name:
                continue
            
            # Si contiene '/', es una carpeta
            if '/' in relative_name:
                folder_name = relative_name.split('/')[0]
                folders.add(folder_name)
            else:
                # Es un archivo
                files.append({
                    'name': relative_name,
                    'type': 'file',
                    'size': obj.size,
                    'last_modified': obj.last_modified.isoformat() if obj.last_modified else None,
                    'etag': obj.etag,
                    'content_type': get_content_type(relative_name)
                })
                total_size += obj.size or 0
                file_count += 1
        
        # Agregar carpetas
        for folder_name in folders:
            files.insert(0, {  # Insertar carpetas al principio
                'name': folder_name,
                'type': 'folder',
                'size': None,
                'last_modified': None,
                'etag': None,
                'content_type': 'folder'
            })
        
        # Ordenar: carpetas primero, luego archivos alfabéticamente
        files.sort(key=lambda x: (x['type'] != 'folder', x['name'].lower()))
        
        stats = {
            'files': file_count,
            'folders': len(folders),
            'total_size': total_size,
            'path': path
        }
        
        return jsonify({
            'success': True,
            'files': files,
            'stats': stats,
            'path': path
        })
        
    except S3Error as e:
        logger.error(f"Error S3 listando archivos: {e}")
        return jsonify({
            'success': False,
            'message': f'Error S3: {str(e)}',
            'files': []
        }), 500
    except Exception as e:
        logger.error(f"Error listando archivos: {e}")
        return jsonify({
            'success': False,
            'message': f'Error interno: {str(e)}',
            'files': []
        }), 500

@minio_api.route('/preview', methods=['GET'])
def preview_file():
    """Vista previa de archivo"""
    try:
        path = request.args.get('path', '').strip('/')
        bucket_name = 'techdocs-storage'
        
        if not path:
            return jsonify({
                'success': False,
                'message': 'Ruta de archivo requerida'
            }), 400
        
        minio_client = get_minio_client()
        if not minio_client:
            return jsonify({
                'success': False,
                'message': 'Error conectando a MinIO'
            }), 500
        
        try:
            # Obtener objeto
            response = minio_client.get_object(bucket_name, path)
            content = response.read()
            response.close()
            
            # Determinar tipo de contenido
            content_type = get_content_type(path)
            
            # Para archivos de texto, decodificar contenido
            if content_type.startswith('text/') or content_type in ['application/json', 'application/xml']:
                try:
                    decoded_content = content.decode('utf-8')
                    return jsonify({
                        'success': True,
                        'content': decoded_content,
                        'content_type': content_type,
                        'size': len(content),
                        'encoding': 'text'
                    })
                except UnicodeDecodeError:
                    # Si no se puede decodificar como texto, tratar como binario
                    pass
            
            # Para archivos binarios (imágenes, etc.), codificar en base64
            if content_type.startswith('image/'):
                encoded_content = base64.b64encode(content).decode('utf-8')
                return jsonify({
                    'success': True,
                    'content': encoded_content,
                    'content_type': content_type,
                    'size': len(content),
                    'encoding': 'base64'
                })
            
            # Para otros tipos de archivo
            return jsonify({
                'success': True,
                'content': f'Archivo binario ({len(content)} bytes)',
                'content_type': content_type,
                'size': len(content),
                'encoding': 'binary'
            })
            
        except S3Error as e:
            if e.code == 'NoSuchKey':
                return jsonify({
                    'success': False,
                    'message': 'Archivo no encontrado'
                }), 404
            else:
                raise e
                
    except Exception as e:
        logger.error(f"Error en vista previa: {e}")
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500

@minio_api.route('/download', methods=['GET'])
def download_file():
    """Descargar archivo"""
    try:
        path = request.args.get('path', '').strip('/')
        bucket_name = 'techdocs-storage'
        
        if not path:
            return jsonify({
                'success': False,
                'message': 'Ruta de archivo requerida'
            }), 400
        
        minio_client = get_minio_client()
        if not minio_client:
            return jsonify({
                'success': False,
                'message': 'Error conectando a MinIO'
            }), 500
        
        try:
            # Obtener objeto
            response = minio_client.get_object(bucket_name, path)
            content = response.read()
            response.close()
            
            # Obtener nombre del archivo
            filename = path.split('/')[-1]
            content_type = get_content_type(path)
            
            return Response(
                content,
                mimetype=content_type,
                headers={
                    'Content-Disposition': f'attachment; filename="{filename}"',
                    'Content-Length': str(len(content))
                }
            )
            
        except S3Error as e:
            if e.code == 'NoSuchKey':
                return jsonify({
                    'success': False,
                    'message': 'Archivo no encontrado'
                }), 404
            else:
                raise e
                
    except Exception as e:
        logger.error(f"Error descargando archivo: {e}")
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500

@minio_api.route('/stats', methods=['GET'])
def get_storage_stats():
    """Obtener estadísticas de almacenamiento"""
    try:
        bucket_name = 'techdocs-storage'
        
        minio_client = get_minio_client()
        if not minio_client:
            return jsonify({
                'success': False,
                'message': 'Error conectando a MinIO'
            }), 500
        
        # Obtener todos los objetos
        objects = minio_client.list_objects(bucket_name, recursive=True)
        
        stats = {
            'total_objects': 0,
            'total_size': 0,
            'repositories': {},
            'file_types': {},
            'largest_files': []
        }
        
        files_info = []
        
        for obj in objects:
            stats['total_objects'] += 1
            stats['total_size'] += obj.size or 0
            
            # Estadísticas por repositorio
            repo_name = obj.object_name.split('/')[0] if '/' in obj.object_name else 'root'
            if repo_name not in stats['repositories']:
                stats['repositories'][repo_name] = {'files': 0, 'size': 0}
            stats['repositories'][repo_name]['files'] += 1
            stats['repositories'][repo_name]['size'] += obj.size or 0
            
            # Estadísticas por tipo de archivo
            file_extension = obj.object_name.split('.')[-1].lower() if '.' in obj.object_name else 'no_extension'
            if file_extension not in stats['file_types']:
                stats['file_types'][file_extension] = {'count': 0, 'size': 0}
            stats['file_types'][file_extension]['count'] += 1
            stats['file_types'][file_extension]['size'] += obj.size or 0
            
            # Guardar info para archivos más grandes
            files_info.append({
                'name': obj.object_name,
                'size': obj.size or 0,
                'last_modified': obj.last_modified.isoformat() if obj.last_modified else None
            })
        
        # Top 10 archivos más grandes
        files_info.sort(key=lambda x: x['size'], reverse=True)
        stats['largest_files'] = files_info[:10]
        
        return jsonify({
            'success': True,
            'stats': stats,
            'bucket': bucket_name
        })
        
    except Exception as e:
        logger.error(f"Error obteniendo estadísticas: {e}")
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500

def get_content_type(filename):
    """Determinar tipo de contenido basado en extensión"""
    extension = filename.split('.')[-1].lower() if '.' in filename else ''
    
    content_types = {
        'html': 'text/html',
        'htm': 'text/html',
        'css': 'text/css',
        'js': 'application/javascript',
        'json': 'application/json',
        'xml': 'application/xml',
        'txt': 'text/plain',
        'md': 'text/markdown',
        'png': 'image/png',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'gif': 'image/gif',
        'svg': 'image/svg+xml',
        'pdf': 'application/pdf',
        'zip': 'application/zip',
        'gz': 'application/gzip'
    }
    
    return content_types.get(extension, 'application/octet-stream')
