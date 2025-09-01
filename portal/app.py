#!/usr/bin/env python3
"""
IA-Ops MinIO Portal Integrado
"""

import os
import subprocess
import requests
from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import json
from datetime import datetime

app = Flask(__name__)
CORS(app)

@app.route('/')
def dashboard():
    """Dashboard principal"""
    return render_template('dashboard.html')

@app.route('/health')
def health():
    """Health check del portal"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'services': {
            'portal': 'running',
            'minio': 'running',
            'api': 'running',
            'docs': 'running'
        }
    })

@app.route('/api/status')
def api_status():
    """Estado de servicios"""
    try:
        # Check MinIO
        minio_health = requests.get("http://localhost:8848/health", timeout=5)
        minio_status = "healthy" if minio_health.status_code == 200 else "unhealthy"
        
        # Check buckets
        buckets_response = requests.get("http://localhost:8848/buckets", timeout=5)
        bucket_count = buckets_response.json().get('count', 0) if buckets_response.status_code == 200 else 0
        
        return jsonify({
            'minio_api': minio_status,
            'bucket_count': bucket_count,
            'timestamp': datetime.now().isoformat(),
            'urls': {
                'console': 'http://localhost:9899',
                'api': 'http://localhost:8848',
                'docs': 'http://localhost:6541',
                'dashboard': 'http://localhost:6540'
            }
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/buckets')
def api_buckets():
    """Proxy para buckets"""
    try:
        response = requests.get("http://localhost:8848/buckets", timeout=10)
        return response.json()
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6542, debug=False)
