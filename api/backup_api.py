#!/usr/bin/env python3
"""
IA-Ops MinIO Backup API
API endpoints for repository backup management
"""

import os
import subprocess
import json
import glob
from datetime import datetime
from flask import Blueprint, jsonify, request
from minio import Minio
import logging

logger = logging.getLogger(__name__)

backup_bp = Blueprint('backup', __name__, url_prefix='/backup')

# Configuration
BACKUP_DIR = os.getenv('BACKUP_DIR', './backups')
REPOSITORIES_DIR = os.getenv('REPOSITORIES_DIR', '/home/giovanemere/ia-ops')
BACKUP_SCRIPT = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'backup-repositories.sh')

@backup_bp.route('/repositories', methods=['GET'])
def list_repositories():
    """List available repositories for backup"""
    try:
        repositories = []
        
        if os.path.exists(REPOSITORIES_DIR):
            for item in os.listdir(REPOSITORIES_DIR):
                repo_path = os.path.join(REPOSITORIES_DIR, item)
                git_path = os.path.join(repo_path, '.git')
                
                if os.path.isdir(repo_path) and os.path.exists(git_path):
                    # Get repository info
                    repo_info = {
                        'name': item,
                        'path': repo_path,
                        'size': get_directory_size(repo_path),
                        'last_modified': get_last_modified(repo_path)
                    }
                    
                    # Get git info if possible
                    try:
                        git_info = get_git_info(repo_path)
                        repo_info.update(git_info)
                    except Exception as e:
                        logger.warning(f"Could not get git info for {item}: {e}")
                    
                    repositories.append(repo_info)
        
        return jsonify({
            'repositories': repositories,
            'count': len(repositories),
            'base_path': REPOSITORIES_DIR
        })
    
    except Exception as e:
        logger.error(f"Error listing repositories: {e}")
        return jsonify({'error': str(e)}), 500

@backup_bp.route('/create', methods=['POST'])
def create_backup():
    """Create backup of specified repositories"""
    try:
        data = request.get_json() or {}
        repositories = data.get('repositories', [])
        include_onedrive = data.get('include_onedrive', False)
        
        if not repositories:
            # Backup all repositories if none specified
            cmd = [BACKUP_SCRIPT]
        else:
            # Backup specific repositories
            cmd = [BACKUP_SCRIPT] + repositories
        
        # Set environment variables for the script
        env = os.environ.copy()
        if include_onedrive and 'ONEDRIVE_ACCESS_TOKEN' not in env:
            return jsonify({
                'error': 'OneDrive access token not configured'
            }), 400
        
        # Execute backup script
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            env=env,
            timeout=3600  # 1 hour timeout
        )
        
        if result.returncode == 0:
            return jsonify({
                'status': 'success',
                'message': 'Backup completed successfully',
                'output': result.stdout,
                'timestamp': datetime.now().isoformat()
            })
        else:
            return jsonify({
                'status': 'error',
                'message': 'Backup failed',
                'error': result.stderr,
                'output': result.stdout
            }), 500
    
    except subprocess.TimeoutExpired:
        return jsonify({
            'status': 'error',
            'message': 'Backup timeout (>1 hour)'
        }), 408
    
    except Exception as e:
        logger.error(f"Error creating backup: {e}")
        return jsonify({'error': str(e)}), 500

@backup_bp.route('/list', methods=['GET'])
def list_backups():
    """List available backup files"""
    try:
        backups = []
        
        if os.path.exists(BACKUP_DIR):
            backup_files = glob.glob(os.path.join(BACKUP_DIR, '*.tar.gz'))
            
            for backup_file in sorted(backup_files, key=os.path.getmtime, reverse=True):
                file_stat = os.stat(backup_file)
                filename = os.path.basename(backup_file)
                
                # Parse filename to extract info
                parts = filename.replace('.tar.gz', '').split('_')
                repo_name = '_'.join(parts[:-2]) if len(parts) > 2 else parts[0]
                
                backups.append({
                    'filename': filename,
                    'repository': repo_name,
                    'path': backup_file,
                    'size': file_stat.st_size,
                    'size_human': format_bytes(file_stat.st_size),
                    'created': datetime.fromtimestamp(file_stat.st_ctime).isoformat(),
                    'modified': datetime.fromtimestamp(file_stat.st_mtime).isoformat()
                })
        
        return jsonify({
            'backups': backups,
            'count': len(backups),
            'backup_dir': BACKUP_DIR
        })
    
    except Exception as e:
        logger.error(f"Error listing backups: {e}")
        return jsonify({'error': str(e)}), 500

@backup_bp.route('/status', methods=['GET'])
def backup_status():
    """Get backup system status"""
    try:
        status = {
            'backup_dir': BACKUP_DIR,
            'backup_dir_exists': os.path.exists(BACKUP_DIR),
            'repositories_dir': REPOSITORIES_DIR,
            'repositories_dir_exists': os.path.exists(REPOSITORIES_DIR),
            'backup_script_exists': os.path.exists(BACKUP_SCRIPT),
            'onedrive_configured': bool(os.getenv('ONEDRIVE_ACCESS_TOKEN')),
            'minio_configured': bool(os.getenv('MINIO_ROOT_USER')),
            'timestamp': datetime.now().isoformat()
        }
        
        # Get backup directory size
        if os.path.exists(BACKUP_DIR):
            total_size = sum(
                os.path.getsize(os.path.join(BACKUP_DIR, f))
                for f in os.listdir(BACKUP_DIR)
                if os.path.isfile(os.path.join(BACKUP_DIR, f))
            )
            status['backup_dir_size'] = total_size
            status['backup_dir_size_human'] = format_bytes(total_size)
        
        # Count backup files
        if os.path.exists(BACKUP_DIR):
            backup_count = len(glob.glob(os.path.join(BACKUP_DIR, '*.tar.gz')))
            status['backup_files_count'] = backup_count
        
        return jsonify(status)
    
    except Exception as e:
        logger.error(f"Error getting backup status: {e}")
        return jsonify({'error': str(e)}), 500

@backup_bp.route('/cleanup', methods=['POST'])
def cleanup_backups():
    """Clean up old backup files"""
    try:
        data = request.get_json() or {}
        days = data.get('days', 7)
        
        if not os.path.exists(BACKUP_DIR):
            return jsonify({
                'message': 'Backup directory does not exist',
                'deleted_count': 0
            })
        
        # Find old files
        import time
        current_time = time.time()
        cutoff_time = current_time - (days * 24 * 60 * 60)
        
        deleted_files = []
        for backup_file in glob.glob(os.path.join(BACKUP_DIR, '*.tar.gz')):
            if os.path.getmtime(backup_file) < cutoff_time:
                try:
                    os.remove(backup_file)
                    deleted_files.append(os.path.basename(backup_file))
                except Exception as e:
                    logger.warning(f"Could not delete {backup_file}: {e}")
        
        return jsonify({
            'message': f'Cleanup completed for files older than {days} days',
            'deleted_files': deleted_files,
            'deleted_count': len(deleted_files)
        })
    
    except Exception as e:
        logger.error(f"Error cleaning up backups: {e}")
        return jsonify({'error': str(e)}), 500

# Helper functions
def get_directory_size(path):
    """Get directory size in bytes"""
    total_size = 0
    try:
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                filepath = os.path.join(dirpath, filename)
                if os.path.exists(filepath):
                    total_size += os.path.getsize(filepath)
    except Exception:
        pass
    return total_size

def get_last_modified(path):
    """Get last modified timestamp"""
    try:
        return datetime.fromtimestamp(os.path.getmtime(path)).isoformat()
    except Exception:
        return None

def get_git_info(repo_path):
    """Get git repository information"""
    try:
        result = subprocess.run(
            ['git', 'branch', '--show-current'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=10
        )
        branch = result.stdout.strip() if result.returncode == 0 else 'unknown'
        
        result = subprocess.run(
            ['git', 'rev-parse', '--short', 'HEAD'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=10
        )
        commit = result.stdout.strip() if result.returncode == 0 else 'unknown'
        
        result = subprocess.run(
            ['git', 'status', '--porcelain'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=10
        )
        modified_files = len(result.stdout.strip().split('\n')) if result.stdout.strip() else 0
        
        return {
            'git_branch': branch,
            'git_commit': commit,
            'git_modified_files': modified_files
        }
    except Exception:
        return {}

def format_bytes(bytes_value):
    """Format bytes to human readable string"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_value < 1024.0:
            return f"{bytes_value:.1f} {unit}"
        bytes_value /= 1024.0
    return f"{bytes_value:.1f} PB"
