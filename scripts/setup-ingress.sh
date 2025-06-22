#!/bin/bash

set -e

echo "🌐 Setting up NGINX Ingress Controller for realcart.shop"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Checking NGINX Ingress Controller...${NC}"

# Check if NGINX Ingress is already installed
if kubectl get namespace ingress-nginx &> /dev/null; then
    echo -e "${GREEN}✅ NGINX Ingress Controller already installed${NC}"
else
    echo -e "${YELLOW}📦 Installing NGINX Ingress Controller...${NC}"
    
    # Install NGINX Ingress Controller
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
    
    echo -e "${BLUE}⏳ Waiting for NGINX Ingress Controller to be ready...${NC}"
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
fi

echo -e "${BLUE}📋 Checking cert-manager...${NC}"

# Check if cert-manager is installed
if kubectl get namespace cert-manager &> /dev/null; then
    echo -e "${GREEN}✅ cert-manager already installed${NC}"
else
    echo -e "${YELLOW}🔐 Installing cert-manager...${NC}"
    
    # Install cert-manager
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
    
    echo -e "${BLUE}⏳ Waiting for cert-manager to be ready...${NC}"
    kubectl wait --namespace cert-manager \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/instance=cert-manager \
        --timeout=300s
fi

# Apply ClusterIssuer for Let's Encrypt
echo -e "${BLUE}🔑 Setting up Let's Encrypt ClusterIssuer...${NC}"
kubectl apply -f k8s/base/cert-manager.yaml

# Get LoadBalancer IP
echo -e "${BLUE}🌐 Getting LoadBalancer IP...${NC}"
EXTERNAL_IP=""
while [ -z $EXTERNAL_IP ]; do
    echo "Waiting for external IP..."
    EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
    [ -z "$EXTERNAL_IP" ] && sleep 10
done

echo ""
echo -e "${GREEN}🎉 NGINX Ingress Controller setup completed!${NC}"
echo ""
echo -e "${YELLOW}📋 IMPORTANT: Add these DNS records to GoDaddy:${NC}"
echo ""
echo -e "${BLUE}Production Records:${NC}"
echo "Type: A, Name: @, Value: $EXTERNAL_IP"
echo "Type: A, Name: api, Value: $EXTERNAL_IP"
echo ""
echo -e "${BLUE}Staging Records:${NC}"
echo "Type: A, Name: staging, Value: $EXTERNAL_IP"
echo "Type: A, Name: staging-api, Value: $EXTERNAL_IP"
echo ""
echo -e "${YELLOW}🔗 LoadBalancer IP: ${GREEN}$EXTERNAL_IP${NC}"
echo ""
echo -e "${BLUE}📚 Full DNS setup guide: ${YELLOW}./DNS-SETUP.md${NC}"
echo ""
echo -e "${YELLOW}⏰ Next steps:${NC}"
echo "1. Add DNS records to GoDaddy (see above)"
echo "2. Wait 5-10 minutes for DNS propagation"
echo "3. Run: ./scripts/deploy-production.sh"