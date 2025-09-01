#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}📚 Building IA-Ops MinIO Documentation${NC}"
echo "=================================="

# Install dependencies
echo -e "${YELLOW}📦 Installing documentation dependencies...${NC}"
cd "$PROJECT_DIR"

if [ ! -d "venv-docs" ]; then
    python3 -m venv venv-docs
fi

source venv-docs/bin/activate
pip install -r requirements-docs.txt

echo -e "${GREEN}✅ Dependencies installed${NC}"

# Build documentation
echo -e "${YELLOW}🏗️  Building static documentation...${NC}"
mkdocs build

echo -e "${GREEN}✅ Documentation built successfully${NC}"
echo -e "${BLUE}📁 Static files available in: ${YELLOW}docs_site/site/${NC}"
echo -e "${BLUE}🌐 You can serve them with any web server${NC}"

# Optional: Start simple HTTP server
read -p "¿Quieres servir la documentación ahora? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🚀 Starting HTTP server...${NC}"
    echo -e "${BLUE}📖 Documentation available at: ${YELLOW}http://localhost:8080${NC}"
    cd docs_site/site
    python3 -m http.server 8080
fi
