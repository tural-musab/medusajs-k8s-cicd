#!/bin/bash

set -e

echo "🔐 Generating Production Secrets for MedusaJS"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if openssl is available
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}❌ openssl is not installed${NC}"
    exit 1
fi

echo -e "${BLUE}🔑 Generating secure secrets...${NC}"

# Generate secrets
JWT_SECRET=$(openssl rand -base64 32)
COOKIE_SECRET=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -base64 16)
MEILISEARCH_KEY=$(openssl rand -base64 32)

# Encode to base64 for Kubernetes
JWT_SECRET_B64=$(echo -n "$JWT_SECRET" | base64)
COOKIE_SECRET_B64=$(echo -n "$COOKIE_SECRET" | base64)
POSTGRES_PASSWORD_B64=$(echo -n "$POSTGRES_PASSWORD" | base64)
MEILISEARCH_KEY_B64=$(echo -n "$MEILISEARCH_KEY" | base64)

echo -e "${GREEN}✅ Secrets generated successfully${NC}"

# Create production secrets file
cat > k8s/overlays/production/secrets.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: medusa-secrets
type: Opaque
data:
  jwt-secret: $JWT_SECRET_B64
  cookie-secret: $COOKIE_SECRET_B64
  postgres-password: $POSTGRES_PASSWORD_B64
  meilisearch-master-key: $MEILISEARCH_KEY_B64
EOF

echo -e "${BLUE}📝 Production secrets file created: k8s/overlays/production/secrets.yaml${NC}"

# Create staging secrets file (with different values)
STAGING_JWT_SECRET=$(openssl rand -base64 32)
STAGING_COOKIE_SECRET=$(openssl rand -base64 32)
STAGING_POSTGRES_PASSWORD=$(openssl rand -base64 16)
STAGING_MEILISEARCH_KEY=$(openssl rand -base64 32)

STAGING_JWT_SECRET_B64=$(echo -n "$STAGING_JWT_SECRET" | base64)
STAGING_COOKIE_SECRET_B64=$(echo -n "$STAGING_COOKIE_SECRET" | base64)
STAGING_POSTGRES_PASSWORD_B64=$(echo -n "$STAGING_POSTGRES_PASSWORD" | base64)
STAGING_MEILISEARCH_KEY_B64=$(echo -n "$STAGING_MEILISEARCH_KEY" | base64)

cat > k8s/overlays/staging/secrets.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: medusa-secrets
type: Opaque
data:
  jwt-secret: $STAGING_JWT_SECRET_B64
  cookie-secret: $STAGING_COOKIE_SECRET_B64
  postgres-password: $STAGING_POSTGRES_PASSWORD_B64
  meilisearch-master-key: $STAGING_MEILISEARCH_KEY_B64
EOF

echo -e "${BLUE}📝 Staging secrets file created: k8s/overlays/staging/secrets.yaml${NC}"

# Update kustomization files to include secrets
echo -e "${YELLOW}📋 Updating kustomization files...${NC}"

# Add secrets to staging kustomization if not already present
if ! grep -q "secrets.yaml" k8s/overlays/staging/kustomization.yaml; then
    sed -i '/patchesStrategicMerge:/a - secrets.yaml' k8s/overlays/staging/kustomization.yaml
fi

# Add secrets to production kustomization if not already present
if ! grep -q "secrets.yaml" k8s/overlays/production/kustomization.yaml; then
    sed -i '/patchesStrategicMerge:/a - secrets.yaml' k8s/overlays/production/kustomization.yaml
fi

echo ""
echo -e "${GREEN}🎉 Secret generation completed!${NC}"
echo ""
echo -e "${YELLOW}🔒 IMPORTANT SECURITY NOTES:${NC}"
echo "1. ✅ Secrets are generated with cryptographically secure random values"
echo "2. ⚠️  Never commit these secret files to version control"
echo "3. 🔐 Store them securely (password manager, vault, etc.)"
echo "4. 🔄 Rotate secrets regularly in production"
echo ""
echo -e "${BLUE}📂 Generated files:${NC}"
echo "- k8s/overlays/staging/secrets.yaml"
echo "- k8s/overlays/production/secrets.yaml"
echo ""
echo -e "${YELLOW}🚀 Next steps:${NC}"
echo "1. Review and customize the secrets if needed"
echo "2. Add to .gitignore to prevent accidental commits"
echo "3. Deploy with: ./scripts/deploy-staging.sh"