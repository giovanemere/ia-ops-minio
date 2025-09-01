#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "⏹️  Stopping MinIO services..."
cd "$PROJECT_DIR/docker"
docker compose down

echo "✅ Services stopped"
