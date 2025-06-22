# 🏪 MedusaJS Kubernetes E-commerce Platform

Modern, scalable e-commerce solution built with MedusaJS 2.0 and deployed on Kubernetes.

## 🚀 Features

- **Full E-commerce Stack**: Complete online store with admin panel
- **Microservices Architecture**: Containerized services for scalability
- **Modern Frontend**: Next.js 14 with Tailwind CSS
- **Production Ready**: Kubernetes deployment with monitoring
- **CI/CD Integration**: Automated build and deployment pipeline

## 🏗️ Architecture

### Core Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend** | MedusaJS 2.0 | E-commerce API and admin |
| **Storefront** | Next.js 14 | Customer-facing web app |
| **Database** | PostgreSQL 15 | Primary data storage |
| **Cache** | Redis 7 | Session & workflow engine |
| **Search** | MeiliSearch | Product search indexing |
| **Orchestration** | Kubernetes | Container management |

### Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐
│   Storefront    │    │   Admin Panel   │
│   (Next.js)     │    │   (MedusaJS)    │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
            ┌────────▼────────┐
            │  NGINX Ingress  │
            └────────┬────────┘
                     │
        ┌────────────▼────────────┐
        │    MedusaJS Backend     │
        │      (Node.js 22)       │
        └─┬─────────────────────┬─┘
          │                     │
  ┌───────▼────────┐   ┌───────▼────────┐
  │   PostgreSQL   │   │     Redis      │
  │   (Database)   │   │   (Cache)      │
  └────────────────┘   └────────────────┘
          │
  ┌───────▼────────┐
  │   MeiliSearch  │
  │   (Search)     │
  └────────────────┘
```

## 🛠️ Tech Stack

### Backend
- **Framework**: MedusaJS 2.0 (TypeScript)
- **Runtime**: Node.js 22 Alpine
- **Database**: PostgreSQL 15 Alpine
- **Cache**: Redis 7 Alpine
- **Search**: MeiliSearch v1.5

### Frontend
- **Framework**: Next.js 14.0.0
- **Styling**: Tailwind CSS
- **Language**: TypeScript
- **Testing**: Playwright E2E

### Infrastructure
- **Orchestration**: Kubernetes
- **Manifest Management**: Kustomize
- **Ingress**: NGINX Ingress Controller
- **CI/CD**: GitHub Actions
- **Registry**: Docker Hub

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (v1.24+)
- kubectl CLI tool
- Docker (for building images)

### 1. Clone Repository

```bash
git clone https://github.com/your-username/medusajs-k8s.git
cd medusajs-k8s
```

### 2. Configure Secrets

```bash
# Generate secure secrets
./scripts/generate-secrets.sh

# Or manually update k8s/base/secrets.yaml
```

### 3. Deploy to Staging

```bash
# Deploy all services
kubectl apply -k k8s/overlays/staging/

# Check deployment status
kubectl get pods -l environment=staging
```

### 4. Access Application

```bash
# Port forward for local access
kubectl port-forward svc/storefront-service 3000:3000
kubectl port-forward svc/medusa-backend-service 9000:9000

# Access applications
open http://localhost:3000    # Storefront
open http://localhost:9000    # Admin Panel
```

## 📚 Documentation

- [📖 Deployment Guide](./DEPLOYMENT.md) - Complete deployment instructions
- [🔧 Configuration](./docs/configuration.md) - Environment variables and settings
- [🛡️ Security](./docs/security.md) - Security best practices
- [📊 Monitoring](./docs/monitoring.md) - Logging and metrics

## 🔄 Development Workflow

### 1. Local Development

```bash
# Start local development
cd temp-repo/backend
pnpm install && pnpm dev

# In another terminal
cd temp-repo/storefront  
pnpm install && pnpm dev
```

### 2. Building Images

```bash
# Build backend image
docker build -t turan919/medusajs-backend:latest temp-repo/backend/

# Build storefront image
docker build -t turan919/medusajs-storefront:latest temp-repo/storefront/
```

### 3. Testing Deployment

```bash
# Validate Kubernetes manifests
kubectl apply -k k8s/overlays/staging/ --dry-run=client

# Deploy to staging
kubectl apply -k k8s/overlays/staging/
```

## 🌍 Environments

### Staging
- **API**: `staging-api.your-domain.com`
- **Storefront**: `staging-store.your-domain.com`
- **Purpose**: Testing and validation

### Production
- **API**: `api.your-domain.com`
- **Storefront**: `store.your-domain.com`
- **Purpose**: Live customer traffic

## 📈 Scaling

### Horizontal Scaling

```bash
# Scale backend
kubectl scale deployment medusa-backend --replicas=3

# Auto-scaling
kubectl autoscale deployment medusa-backend --cpu-percent=70 --min=2 --max=10
```

### Resource Management

Production resource limits are configured per service:
- **Backend**: 2GB RAM, 1 CPU
- **Storefront**: 1GB RAM, 500m CPU
- **Database**: 5GB storage
- **Redis**: 1GB storage

## 🔐 Security Features

- ✅ Kubernetes Secrets for sensitive data
- ✅ NGINX Ingress with rate limiting
- ✅ TLS/SSL certificate management
- ✅ CORS configuration
- ✅ Network policies (optional)
- ✅ Container security scanning

## 🚨 Monitoring & Troubleshooting

### Health Checks

```bash
# Check all services
kubectl get pods,svc,ingress

# View logs
kubectl logs -f deployment/medusa-backend
kubectl logs -f deployment/storefront
```

### Common Issues

1. **Database Connection**: Check PostgreSQL pod status
2. **Image Pull Errors**: Verify Docker Hub credentials
3. **Ingress Issues**: Check NGINX controller logs

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- **Documentation**: Check [DEPLOYMENT.md](./DEPLOYMENT.md)
- **Issues**: [GitHub Issues](https://github.com/your-username/medusajs-k8s/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/medusajs-k8s/discussions)

---

<p align="center">
  <strong>Built with ❤️ using MedusaJS, Next.js, and Kubernetes</strong>
</p>