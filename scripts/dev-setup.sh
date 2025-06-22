#!/bin/bash

set -e

echo "🛠️  MedusaJS Local Development Setup"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

# Check Node.js version
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    echo -e "${YELLOW}⚠️  Node.js version is $NODE_VERSION. Recommended: 22+${NC}"
fi

# Check pnpm
if ! command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}📦 pnpm not found. Installing...${NC}"
    npm install -g pnpm
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

# Check Kubernetes
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Setup backend
echo -e "${BLUE}🔧 Setting up backend...${NC}"
cd temp-repo/backend
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing backend dependencies...${NC}"
    pnpm install
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating backend .env file...${NC}"
    cat > .env << 'EOF'
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/medusajs
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-jwt-secret-change-this
COOKIE_SECRET=your-cookie-secret-change-this
MEDUSA_BACKEND_URL=http://localhost:9000
MEDUSA_ADMIN_BACKEND_URL=http://localhost:9000
EOF
fi

cd ../../

# Setup storefront
echo -e "${BLUE}🎨 Setting up storefront...${NC}"
cd temp-repo/storefront
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing storefront dependencies...${NC}"
    pnpm install
fi

# Create .env file if it doesn't exist
if [ ! -f ".env.local" ]; then
    echo -e "${YELLOW}Creating storefront .env.local file...${NC}"
    cat > .env.local << 'EOF'
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_BASE_URL=http://localhost:3000
SKIP_PUBLISHABLE_KEY_CHECK=true
NEXT_TELEMETRY_DISABLED=1
EOF
fi

cd ../../

echo -e "${GREEN}✅ Development environment setup completed!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps for local development:${NC}"
echo ""
echo -e "${BLUE}Option 1: Local Development (without Kubernetes)${NC}"
echo "1. Start PostgreSQL and Redis locally"
echo "2. Backend: cd temp-repo/backend && pnpm dev"
echo "3. Storefront: cd temp-repo/storefront && pnpm dev"
echo ""
echo -e "${BLUE}Option 2: Kubernetes Development${NC}"
echo "1. ./scripts/deploy-staging.sh"
echo "2. kubectl port-forward svc/staging-medusa-backend-service 9000:9000 -n medusajs-staging"
echo "3. kubectl port-forward svc/staging-storefront-service 3000:3000 -n medusajs-staging"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"