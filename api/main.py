#!/usr/bin/env python3
"""
IA-Ops MinIO API
Unified API for MinIO storage management
"""

import os
import sys
from flask import Flask, jsonify, request, send_file
from flask_cors import CORS
from minio import Minio
from minio.error import S3Error
import logging
from datetime import datetime
import json
import io

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/minio-api.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# MinIO Configuration
MINIO_ENDPOINT = os.getenv('MINIO_ENDPOINT', 'localhost:9898')
MINIO_ACCESS_KEY = os.getenv('MINIO_ACCESS_KEY', 'minioadmin')
MINIO_SECRET_KEY = os.getenv('MINIO_SECRET_KEY', 'minioadmin123')
API_PORT = int(os.getenv('API_PORT', 8848))

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

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        if minio_client:
            buckets = list(minio_client.list_buckets())
            return jsonify({
                'status': 'healthy',
                'timestamp': datetime.now().isoformat(),
                'minio_endpoint': MINIO_ENDPOINT,
                'buckets_count': len(buckets)
            })
        else:
            return jsonify({
                'status': 'unhealthy',
                'error': 'MinIO client not initialized'
            }), 500
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 500

@app.route('/buckets', methods=['GET'])
def list_buckets():
    """List all buckets"""
    try:
        buckets = []
        for bucket in minio_client.list_buckets():
            buckets.append({
                'name': bucket.name,
                'creation_date': bucket.creation_date.isoformat() if bucket.creation_date else None
            })
        return jsonify({
            'buckets': buckets,
            'count': len(buckets)
        })
    except Exception as e:
        logger.error(f"Error listing buckets: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/buckets/<bucket_name>/objects', methods=['GET'])
def list_objects(bucket_name):
    """List objects in a bucket"""
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
        
        return jsonify({
            'bucket': bucket_name,
            'objects': objects,
            'count': len(objects),
            'prefix': prefix,
            'recursive': recursive
        })
    except Exception as e:
        logger.error(f"Error listing objects in bucket {bucket_name}: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/stats', methods=['GET'])
def get_stats():
    """Get MinIO statistics"""
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
        
        return jsonify({
            'total_buckets': len(buckets),
            'total_objects': total_objects,
            'total_size': total_size,
            'buckets': bucket_stats,
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        logger.error(f"Error getting stats: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    logger.info(f"Starting MinIO API on port {API_PORT}")
    app.run(host='0.0.0.0', port=API_PORT, debug=False)
