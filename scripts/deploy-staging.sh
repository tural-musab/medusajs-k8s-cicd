#!/bin/bash

set -e

echo "🚀 Deploying MedusaJS to Staging Environment"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Build Docker images
echo -e "${BLUE}🔨 Building Docker images...${NC}"

echo -e "${YELLOW}Building backend image...${NC}"
docker build -t turan919/medusajs-backend:latest temp-repo/backend/

echo -e "${YELLOW}Building storefront image...${NC}"
docker build -t turan919/medusajs-storefront:latest temp-repo/storefront/

echo -e "${GREEN}✅ Docker images built successfully${NC}"

# Deploy to staging
echo -e "${BLUE}🚀 Deploying to staging namespace...${NC}"

kubectl apply -k k8s/overlays/staging/

echo -e "${GREEN}✅ Deployment applied successfully${NC}"

# Wait for rollout
echo -e "${BLUE}⏳ Waiting for rollout to complete...${NC}"

kubectl rollout status deployment/staging-medusa-backend -n medusajs-staging --timeout=300s
kubectl rollout status deployment/staging-storefront -n medusajs-staging --timeout=300s
kubectl rollout status deployment/staging-postgres -n medusajs-staging --timeout=300s
kubectl rollout status deployment/staging-redis -n medusajs-staging --timeout=300s
kubectl rollout status deployment/staging-meilisearch -n medusajs-staging --timeout=300s

echo -e "${GREEN}✅ All deployments are ready${NC}"

# Show status
echo -e "${BLUE}📊 Deployment status:${NC}"
kubectl get pods -n medusajs-staging
kubectl get services -n medusajs-staging

echo ""
echo -e "${GREEN}🎉 Staging deployment completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📌 Next steps:${NC}"
echo "1. Port forward services for local testing:"
echo "   kubectl port-forward svc/staging-medusa-backend-service 9000:9000 -n medusajs-staging"
echo "   kubectl port-forward svc/staging-storefront-service 3000:3000 -n medusajs-staging"
echo ""
echo "2. Check logs if needed:"
echo "   kubectl logs -f deployment/staging-medusa-backend -n medusajs-staging"
echo "   kubectl logs -f deployment/staging-storefront -n medusajs-staging"