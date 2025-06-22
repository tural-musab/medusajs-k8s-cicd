# 🚀 realcart.shop Production Deployment Checklist

## ✅ Pre-Deployment (Completed)

- [x] **Domain Configuration**: realcart.shop configured
- [x] **SSL/TLS Setup**: cert-manager and Let's Encrypt ready
- [x] **Namespace Isolation**: Production/staging environments separated
- [x] **Resource Limits**: Production-optimized CPU/memory limits
- [x] **Security**: Generated secure secrets
- [x] **Monitoring**: Health checks and Grafana dashboard
- [x] **Backup Strategy**: Automated PostgreSQL backups

## 🌐 DNS Configuration Required

**⚠️ NEXT STEP: Add these DNS records to GoDaddy:**

1. **Login to GoDaddy DNS Management**
2. **Add these A Records:**

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A    | @    | [CLUSTER_IP] | 600 |
| A    | api  | [CLUSTER_IP] | 600 |
| A    | staging | [CLUSTER_IP] | 600 |
| A    | staging-api | [CLUSTER_IP] | 600 |

**Get CLUSTER_IP by running:**
```bash
./scripts/setup-ingress.sh
```

## 🚀 Deployment Steps

### 1. Setup Infrastructure
```bash
# Setup NGINX Ingress & cert-manager
./scripts/setup-ingress.sh

# Generate production secrets
./scripts/generate-secrets.sh
```

### 2. Configure DNS
- Add DNS records to GoDaddy (see table above)
- Wait 5-10 minutes for DNS propagation

### 3. Deploy to Production
```bash
# Deploy realcart.shop to production
./scripts/deploy-production.sh
```

### 4. Verify Deployment
```bash
# Check all services
kubectl get all -n medusajs-production

# Check SSL certificates
kubectl get certificates -n medusajs-production

# Test endpoints
curl -I https://realcart.shop
curl -I https://api.realcart.shop/health
```

## 📊 Post-Deployment Monitoring

### Health Checks
- **Storefront**: https://realcart.shop/api/healthcheck
- **Backend**: https://api.realcart.shop/health
- **Admin Panel**: https://api.realcart.shop/admin

### Monitoring Commands
```bash
# Pod status
kubectl get pods -n medusajs-production

# Logs
kubectl logs -f deployment/prod-medusa-backend -n medusajs-production

# Events
kubectl get events -n medusajs-production --sort-by='.lastTimestamp'

# Resource usage
kubectl top pods -n medusajs-production
```

## 🔒 Security Checklist

- [x] **Secrets Management**: Kubernetes secrets with base64 encoding
- [x] **SSL/TLS**: Automatic Let's Encrypt certificates
- [x] **Network Policies**: Namespace isolation
- [x] **Resource Limits**: Prevent resource exhaustion
- [x] **Rate Limiting**: NGINX ingress rate limiting
- [x] **CORS Configuration**: Proper CORS headers

## 📈 Performance Optimization

### Current Resource Allocations:
- **Backend**: 1Gi memory, 500m CPU (2Gi/1000m limits)
- **Storefront**: 512Mi memory, 250m CPU (1Gi/500m limits)  
- **PostgreSQL**: 256Mi memory, 100m CPU (512Mi/200m limits)
- **Redis**: 128Mi memory, 50m CPU (256Mi/100m limits)
- **MeiliSearch**: 256Mi memory, 100m CPU (512Mi/200m limits)

### Scaling Commands:
```bash
# Scale backend replicas
kubectl scale deployment prod-medusa-backend --replicas=3 -n medusajs-production

# Scale storefront replicas  
kubectl scale deployment prod-storefront --replicas=3 -n medusajs-production
```

## 💾 Backup & Recovery

### Automated Backups:
- **Schedule**: Daily at 2 AM UTC
- **Retention**: 7 days
- **Location**: `/backup` volume in backup-pvc

### Manual Backup:
```bash
kubectl exec -it deployment/prod-postgres -n medusajs-production -- pg_dump -U postgres medusajs > backup_$(date +%Y%m%d).sql
```

### Restore:
```bash
kubectl exec -i deployment/prod-postgres -n medusajs-production -- psql -U postgres medusajs < backup_YYYYMMDD.sql
```

## 🆘 Troubleshooting

### Common Issues:

**SSL Certificate Issues:**
```bash
kubectl describe certificate production-tls-secret -n medusajs-production
kubectl logs -n cert-manager deployment/cert-manager
```

**DNS Issues:**
```bash
nslookup realcart.shop
nslookup api.realcart.shop
```

**Pod Issues:**
```bash
kubectl describe pod [POD_NAME] -n medusajs-production
kubectl logs [POD_NAME] -n medusajs-production
```

## 📞 Support Contacts

- **Technical Issues**: Check logs and events
- **DNS Issues**: GoDaddy support
- **SSL Issues**: cert-manager logs

## 🎯 Success Criteria

✅ **Deployment Successful When:**
- All pods show `Running` status
- SSL certificates are `Ready`
- https://realcart.shop loads correctly
- https://api.realcart.shop/admin is accessible
- Health checks return `200 OK`

**Expected Response Times:**
- Storefront: < 2 seconds
- API endpoints: < 500ms
- Admin panel: < 3 seconds