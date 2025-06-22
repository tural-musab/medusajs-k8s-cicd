#!/bin/bash

set -e

echo "🚀 Deploying MedusaJS to Production Environment"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Production safety check
echo -e "${RED}⚠️  PRODUCTION DEPLOYMENT WARNING ⚠️${NC}"
echo -e "${YELLOW}This will deploy to production environment.${NC}"
echo -e "${YELLOW}Make sure you have:${NC}"
echo "- ✅ Tested in staging environment"
echo "- ✅ Updated secrets in production"
echo "- ✅ Configured domain and SSL certificates"
echo "- ✅ Set up monitoring and alerting"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [[ $confirm != "yes" ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

# Check if cert-manager is installed
if ! kubectl get clusterissuer &> /dev/null; then
    echo -e "${YELLOW}⚠️  cert-manager not found. SSL certificates will not be automatically managed.${NC}"
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Validate production images exist in registry
echo -e "${BLUE}🔍 Validating production images...${NC}"

# This would typically check if images exist in registry
echo -e "${YELLOW}Note: Make sure Docker images are pushed to registry${NC}"
echo "- turan919/medusajs-backend:latest"
echo "- turan919/medusajs-storefront:latest"

# Deploy to production
echo -e "${BLUE}🚀 Deploying to production namespace...${NC}"

kubectl apply -k k8s/overlays/production/

echo -e "${GREEN}✅ Deployment applied successfully${NC}"

# Wait for rollout
echo -e "${BLUE}⏳ Waiting for rollout to complete...${NC}"

kubectl rollout status deployment/prod-medusa-backend -n medusajs-production --timeout=600s
kubectl rollout status deployment/prod-storefront -n medusajs-production --timeout=600s
kubectl rollout status deployment/prod-postgres -n medusajs-production --timeout=300s
kubectl rollout status deployment/prod-redis -n medusajs-production --timeout=300s
kubectl rollout status deployment/prod-meilisearch -n medusajs-production --timeout=300s

echo -e "${GREEN}✅ All deployments are ready${NC}"

# Show status
echo -e "${BLUE}📊 Production deployment status:${NC}"
kubectl get pods -n medusajs-production
kubectl get services -n medusajs-production
kubectl get ingress -n medusajs-production

echo ""
echo -e "${GREEN}🎉 Production deployment completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📌 Post-deployment checklist:${NC}"
echo "1. ✅ Verify all pods are running"
echo "2. ✅ Check ingress and SSL certificates"
echo "3. ✅ Test API endpoints"
echo "4. ✅ Verify storefront accessibility"
echo "5. ✅ Monitor logs and metrics"
echo ""
echo -e "${BLUE}🔍 Monitoring commands:${NC}"
echo "kubectl logs -f deployment/prod-medusa-backend -n medusajs-production"
echo "kubectl get events -n medusajs-production --sort-by='.lastTimestamp'"