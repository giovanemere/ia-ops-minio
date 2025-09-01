#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

MODE=${1:-local}

case $MODE in
    "local"|"dev")
        echo "🔧 Switching to local integrated mode..."
        cd "$PROJECT_DIR"
        docker compose -f docker-compose.integrated.prod.yml down 2>/dev/null || true
        docker compose -f docker-compose.integrated.yml up -d
        echo "✅ Local integrated mode activated"
        echo "📊 Dashboard: http://localhost:6540"
        ;;
    "prod"|"production")
        echo "🚀 Switching to production integrated mode..."
        cd "$PROJECT_DIR"
        docker compose -f docker-compose.integrated.yml down 2>/dev/null || true
        if [ ! -f "docker-compose.integrated.prod.yml" ]; then
            echo "❌ Production compose file not found. Run publish-integrated.sh first."
            exit 1
        fi
        docker compose -f docker-compose.integrated.prod.yml up -d
        echo "✅ Production integrated mode activated"
        echo "📊 Dashboard: http://localhost:6540"
        ;;
    *)
        echo "Usage: $0 [local|prod]"
        echo "  local - Use local build"
        echo "  prod  - Use Docker Hub image"
        exit 1
        ;;
esac
