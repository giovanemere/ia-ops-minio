#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

MODE=${1:-dev}

case $MODE in
    "dev"|"development")
        echo "🔧 Switching to development mode..."
        cd "$PROJECT_DIR/docker"
        cp docker-compose.yml.backup docker-compose.yml 2>/dev/null || echo "No backup found, using current"
        echo "✅ Development mode activated (local build)"
        ;;
    "prod"|"production")
        echo "🚀 Switching to production mode..."
        cd "$PROJECT_DIR/docker"
        cp docker-compose.yml docker-compose.yml.backup
        cp docker-compose.prod.yml docker-compose.yml
        echo "✅ Production mode activated (Docker Hub image)"
        ;;
    *)
        echo "Usage: $0 [dev|prod]"
        echo "  dev  - Use local build"
        echo "  prod - Use Docker Hub image"
        exit 1
        ;;
esac
