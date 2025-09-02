#!/usr/bin/env python3
"""
IA-Ops MinIO API
Unified API for MinIO storage management with PostgreSQL integration
"""

import os
import sys
import time
import json
from flask import Flask, jsonify, request, send_file
from flask_cors import CORS
from minio import Minio
from minio.error import S3Error
import logging
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import database functions
try:
    from database import init_database, log_operation, save_stats, get_db
    DATABASE_AVAILABLE = True
except ImportError as e:
    print(f"Warning: Database module not available: {e}")
    DATABASE_AVAILABLE = False

# Configure logging
handlers = [logging.StreamHandler(sys.stdout)]

# Try to add file handler if possible
try:
    os.makedirs('/app/logs', exist_ok=True)
    handlers.append(logging.FileHandler('/app/logs/minio-api.log'))
except (PermissionError, OSError) as e:
    print(f"Warning: Could not create log file: {e}")

logging.basicConfig(
    level=getattr(logging, os.getenv('LOG_LEVEL', 'INFO')),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=handlers
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Configuration from environment variables
MINIO_ENDPOINT = os.getenv('MINIO_ENDPOINT', 'localhost:9898')
MINIO_ACCESS_KEY = os.getenv('MINIO_ROOT_USER', 'minioadmin')
MINIO_SECRET_KEY = os.getenv('MINIO_ROOT_PASSWORD', 'minioadmin123')
API_PORT = int(os.getenv('REST_API_PORT', 8848))
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
DEBUG = os.getenv('DEBUG', 'false').lower() == 'true'

# Initialize MinIO client
try:
    minio_client = Minio(
        MINIO_ENDPOINT,
        access_key=MINIO_ACCESS_KEY,
        secret_key=MINIO_SECRET_KEY,
        secure=False
    )
    logger.info(f"MinIO client initialized for {MINIO_ENDPOINT}")
except Exception as e:
    logger.error(f"Failed to initialize MinIO client: {e}")
    minio_client = None

# Initialize database
if DATABASE_AVAILABLE:
    if init_database():
        logger.info("Database initialized successfully")
    else:
        logger.warning("Database initialization failed")

def get_client_info(request):
    """Extract client information from request"""
    return {
        'user_agent': request.headers.get('User-Agent', 'Unknown'),
        'ip_address': request.remote_addr or 'Unknown'
    }

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint with database status"""
    start_time = time.time()
    
    try:
        client_info = get_client_info(request)
        
        if minio_client:
            buckets = list(minio_client.list_buckets())
            response_data = {
                'status': 'healthy',
                'timestamp': datetime.now().isoformat(),
                'minio_endpoint': MINIO_ENDPOINT,
                'buckets_count': len(buckets),
                'database_available': DATABASE_AVAILABLE,
                'environment': ENVIRONMENT
            }
            
            # Log operation to database
            if DATABASE_AVAILABLE:
                response_time = int((time.time() - start_time) * 1000)
                log_operation(
                    operation_type='health_check',
                    user_agent=client_info['user_agent'],
                    ip_address=client_info['ip_address'],
                    success=True,
                    response_time_ms=response_time
                )
            
            return jsonify(response_data)
        else:
            return jsonify({
                'status': 'unhealthy',
                'error': 'MinIO client not initialized',
                'database_available': DATABASE_AVAILABLE
            }), 500
    except Exception as e:
        if DATABASE_AVAILABLE:
            response_time = int((time.time() - start_time) * 1000)
            log_operation(
                operation_type='health_check',
                user_agent=client_info.get('user_agent'),
                ip_address=client_info.get('ip_address'),
                success=False,
                error_message=str(e),
                response_time_ms=response_time
            )
        
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'database_available': DATABASE_AVAILABLE
        }), 500

@app.route('/buckets', methods=['GET'])
def list_buckets():
    """List all buckets"""
    start_time = time.time()
    client_info = get_client_info(request)
    
    try:
        buckets = []
        for bucket in minio_client.list_buckets():
            buckets.append({
                'name': bucket.name,
                'creation_date': bucket.creation_date.isoformat() if bucket.creation_date else None
            })
        
        response_data = {
            'buckets': buckets,
            'count': len(buckets)
        }
        
        # Log operation to database
        if DATABASE_AVAILABLE:
            response_time = int((time.time() - start_time) * 1000)
            log_operation(
                operation_type='list_buckets',
                user_agent=client_info['user_agent'],
                ip_address=client_info['ip_address'],
                success=True,
                response_time_ms=response_time
            )
        
        return jsonify(response_data)
    except Exception as e:
        logger.error(f"Error listing buckets: {e}")
        
        if DATABASE_AVAILABLE:
            response_time = int((time.time() - start_time) * 1000)
            log_operation(
                operation_type='list_buckets',
                user_agent=client_info['user_agent'],
                ip_address=client_info['ip_address'],
                success=False,
                error_message=str(e),
                response_time_ms=response_time
            )
        
        return jsonify({'error': str(e)}), 500

@app.route('/buckets/<bucket_name>/objects', methods=['GET'])
def list_objects(bucket_name):
    """List objects in a bucket"""
    start_time = time.time()
    client_info = get_client_info(request)
    
    try:
        prefix = request.args.get('prefix', '')
        recursive = request.args.get('recursive', 'false').lower() == 'true'
        
        objects = []
        for obj in minio_client.list_objects(bucket_name, prefix=prefix, recursive=recursive):
            objects.append({
                'name': obj.object_name,
                'size': obj.size,
                'last_modified': obj.last_modified.isoformat() if obj.last_modified else None,
                'etag': obj.etag,
                'content_type': obj.content_type
            })
        
        response_data = {
            'bucket': bucket_name,
            'objects': objects,
            'count': len(objects),
            'prefix': prefix,
            'recursive': recursive
        }
        
        # Log operation to database
        if DATABASE_AVAILABLE:
            response_time = int((time.time() - start_time) * 1000)
            log_operation(
                operation_type='list_objects',
                bucket_name=bucket_name,
                user_agent=client_info['user_agent'],
                ip_address=client_info['ip_address'],
                success=True,
                response_time_ms=response_time
            )
        
        return jsonify(response_data)
    except Exception as e:
        logger.error(f"Error listing objects in bucket {bucket_name}: {e}")
        
        if DATABASE_AVAILABLE:
            response_time = int((time.time() - start_time) * 1000)
            log_operation(
                operation_type='list_objects',
                bucket_name=bucket_name,
                user_agent=client_info['user_agent'],
                ip_address=client_info['ip_address'],
                success=False,
                error_message=str(e),
                response_time_ms=response_time
            )
        
        return jsonify({'error': str(e)}), 500

@app.route('/stats', methods=['GET'])
def get_stats():
    """Get MinIO statistics and save to database"""
    start_time = time.time()
    client_info = get_client_info(request)
    
    try:
        buckets = list(minio_client.list_buckets())
        total_objects = 0
        total_size = 0
        
        bucket_stats = []
        for bucket in buckets:
            objects = list(minio_client.list_objects(bucket.name, recursive=True))
            bucket_objects = len(objects)
            bucket_size = sum(obj.size for obj in objects if obj.size)
            
            bucket_stats.append({
                'name': bucket.name,
                'objects': bucket_objects,
                'size': bucket_size,
                'creation_date': bucket.creation_date.isoformat() if bucket.creation_date else None
            })
            
            total_objects += bucket_objects
            total_size += bucket_size
        
        response_data = {
            'total_buckets': len(buckets),
            'total_objects': total_objects,
            'total_size': total_size,
            'buckets': bucket_stats,
            'timestamp': datetime.now().isoformat()
        }
        
        # Save stats to database
        if DATABASE_AVAILABLE:
            response_time = int((time.time() - start_time) * 1000)
            save_stats(
                total_buckets=len(buckets),
                total_objects=total_objects,
                total_size_bytes=total_size,
                snapshot_data=json.dumps(bucket_stats)
            )
            log_operation(
                operation_type='get_stats',
                user_agent=client_info['user_agent'],
                ip_address=client_info['ip_address'],
                success=True,
                response_time_ms=response_time
            )
        
        return jsonify(response_data)
    except Exception as e:
        logger.error(f"Error getting stats: {e}")
        
        if DATABASE_AVAILABLE:
            response_time = int((time.time() - start_time) * 1000)
            log_operation(
                operation_type='get_stats',
                user_agent=client_info['user_agent'],
                ip_address=client_info['ip_address'],
                success=False,
                error_message=str(e),
                response_time_ms=response_time
            )
        
        return jsonify({'error': str(e)}), 500

@app.route('/operations/history', methods=['GET'])
def get_operations_history():
    """Get operations history from database"""
    if not DATABASE_AVAILABLE:
        return jsonify({'error': 'Database not available'}), 503
    
    try:
        db = get_db()
        if db is None:
            return jsonify({'error': 'Database connection failed'}), 500
        
        # This would require implementing the query logic
        # For now, return a placeholder
        return jsonify({
            'message': 'Operations history endpoint',
            'note': 'Implementation pending'
        })
    except Exception as e:
        logger.error(f"Error getting operations history: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    logger.info(f"Starting MinIO API on port {API_PORT}")
    logger.info(f"Environment: {ENVIRONMENT}")
    logger.info(f"Database available: {DATABASE_AVAILABLE}")
    app.run(host='0.0.0.0', port=API_PORT, debug=DEBUG)
