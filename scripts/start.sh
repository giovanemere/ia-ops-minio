#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting MinIO services..."
cd "$PROJECT_DIR/docker"
docker compose up -d

echo "✅ Services started"
echo "📊 Access URLs:"
echo "   MinIO Console: http://localhost:9899"
echo "   MinIO API: http://localhost:9898"
echo "   REST API: http://localhost:8848"
