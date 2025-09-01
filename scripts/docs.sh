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

echo -e "${BLUE}📚 IA-Ops MinIO Documentation${NC}"
echo "=================================="

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}❌ pip3 is not installed${NC}"
    exit 1
fi

# Install dependencies
echo -e "${YELLOW}📦 Installing documentation dependencies...${NC}"
cd "$PROJECT_DIR"

if [ ! -d "venv-docs" ]; then
    python3 -m venv venv-docs
fi

source venv-docs/bin/activate
pip install -r requirements-docs.txt

echo -e "${GREEN}✅ Dependencies installed${NC}"

# Serve documentation
echo -e "${YELLOW}🚀 Starting documentation server...${NC}"
echo -e "${BLUE}📖 Documentation will be available at: ${YELLOW}http://localhost:6541${NC}"
echo -e "${BLUE}🔄 Press Ctrl+C to stop the server${NC}"
echo ""

mkdocs serve --dev-addr=0.0.0.0:6541
