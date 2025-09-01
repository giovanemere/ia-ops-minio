#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "📊 MinIO Services Status"
echo "========================"

cd "$PROJECT_DIR/docker"
docker compose ps

echo ""
echo "🔍 Health Checks:"
echo -n "MinIO API: "
if curl -f http://localhost:9898/minio/health/live > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

echo -n "REST API: "
if curl -f http://localhost:8848/health > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi
