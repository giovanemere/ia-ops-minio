#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 IA-Ops MinIO System Verification${NC}"
echo "===================================="

# 1. Check Docker services
echo -e "${YELLOW}📊 Checking Docker services...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"
./scripts/status.sh

echo ""

# 2. Test MinIO API
echo -e "${YELLOW}🧪 Testing MinIO API endpoints...${NC}"

# Health check
if curl -f -s http://localhost:8848/health > /dev/null; then
    echo -e "${GREEN}✅ REST API Health: OK${NC}"
else
    echo -e "${RED}❌ REST API Health: FAILED${NC}"
fi

# Buckets endpoint
if curl -f -s http://localhost:8848/buckets > /dev/null; then
    BUCKET_COUNT=$(curl -s http://localhost:8848/buckets | jq -r '.count')
    echo -e "${GREEN}✅ Buckets API: OK (${BUCKET_COUNT} buckets)${NC}"
else
    echo -e "${RED}❌ Buckets API: FAILED${NC}"
fi

# MinIO Console
if curl -f -s -I http://localhost:9899 > /dev/null; then
    echo -e "${GREEN}✅ MinIO Console: OK${NC}"
else
    echo -e "${RED}❌ MinIO Console: FAILED${NC}"
fi

echo ""

# 3. Test file upload/download
echo -e "${YELLOW}📁 Testing file operations...${NC}"

# Create test file
TEST_FILE="/tmp/minio-test-$(date +%s).txt"
echo "IA-Ops MinIO Test File - $(date)" > "$TEST_FILE"

# Upload test file
if curl -s -X POST -F "file=@$TEST_FILE" http://localhost:8848/buckets/iaops-portal/objects > /dev/null; then
    echo -e "${GREEN}✅ File Upload: OK${NC}"
    
    # Try to download
    FILENAME=$(basename "$TEST_FILE")
    if curl -f -s "http://localhost:8848/buckets/iaops-portal/objects/$FILENAME" > /dev/null; then
        echo -e "${GREEN}✅ File Download: OK${NC}"
        
        # Clean up
        curl -s -X DELETE "http://localhost:8848/buckets/iaops-portal/objects/$FILENAME" > /dev/null
        echo -e "${GREEN}✅ File Cleanup: OK${NC}"
    else
        echo -e "${RED}❌ File Download: FAILED${NC}"
    fi
else
    echo -e "${RED}❌ File Upload: FAILED${NC}"
fi

# Clean up test file
rm -f "$TEST_FILE"

echo ""

# 4. Check documentation
echo -e "${YELLOW}📚 Checking documentation...${NC}"

if [ -f "mkdocs.yml" ]; then
    echo -e "${GREEN}✅ MkDocs Config: Found${NC}"
else
    echo -e "${RED}❌ MkDocs Config: Missing${NC}"
fi

if [ -d "docs_site/docs" ]; then
    DOC_COUNT=$(find docs_site/docs -name "*.md" | wc -l)
    echo -e "${GREEN}✅ Documentation: ${DOC_COUNT} pages found${NC}"
else
    echo -e "${RED}❌ Documentation: Missing${NC}"
fi

echo ""

# 5. Check Docker Hub integration
echo -e "${YELLOW}🐳 Checking Docker Hub integration...${NC}"

if [ -f "docker/.env.docker" ]; then
    echo -e "${GREEN}✅ Docker Hub Config: Found${NC}"
else
    echo -e "${YELLOW}⚠️  Docker Hub Config: Not configured${NC}"
fi

# Check if using published image
if docker ps --format "table {{.Image}}" | grep -q "edissonz8809/ia-ops-minio-api"; then
    echo -e "${GREEN}✅ Using Published Image: Yes${NC}"
else
    echo -e "${YELLOW}⚠️  Using Published Image: No (local build)${NC}"
fi

echo ""

# 6. Summary
echo -e "${BLUE}📋 System Summary${NC}"
echo "=================="
echo -e "🌐 MinIO Console:    ${YELLOW}http://localhost:9899${NC}"
echo -e "🔌 MinIO API:        ${YELLOW}http://localhost:9898${NC}"
echo -e "🚀 REST API:         ${YELLOW}http://localhost:8848${NC}"
echo -e "📚 Documentation:    ${YELLOW}http://localhost:6541${NC} (run ./scripts/docs.sh)"
echo -e "🐳 Docker Hub:       ${YELLOW}https://hub.docker.com/repositories/edissonz8809${NC}"

echo ""
echo -e "${GREEN}🎉 System verification completed!${NC}"
