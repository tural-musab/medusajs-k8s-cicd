# MedusaJS Kubernetes Deployment Guide

Bu proje, MedusaJS 2.0 e-ticaret platformunu Kubernetes üzerinde çalıştırmak için gerekli tüm bileşenleri içerir.

## 📋 Sistem Gereksinimleri

- **Kubernetes Cluster**: v1.24+
- **kubectl**: Cluster erişimi
- **Kustomize**: Manifest yönetimi için
- **NGINX Ingress Controller**: Dış erişim için
- **cert-manager**: SSL sertifikaları için (opsiyonel)

## 🏗️ Proje Yapısı

```
k8s/
├── base/                    # Temel Kubernetes manifests
│   ├── secrets.yaml         # Güvenlik credentials
│   ├── medusa-backend.yaml  # MedusaJS API server
│   ├── storefront.yaml      # Next.js frontend
│   ├── postgres.yaml        # PostgreSQL database
│   ├── redis.yaml           # Redis cache
│   ├── meilisearch.yaml     # Search engine
│   └── ingress.yaml         # Load balancer
└── overlays/
    ├── staging/             # Staging environment patches
    └── production/          # Production environment patches
```

## 🔐 Güvenlik Konfigürasyonu

### 1. Secrets Güncelleme

**ÖNEMLİ**: Production'da secrets.yaml dosyasındaki default değerleri değiştirin:

```bash
# Güvenli JWT secret oluştur
JWT_SECRET=$(openssl rand -base64 32)
echo -n "$JWT_SECRET" | base64

# Güvenli Cookie secret oluştur
COOKIE_SECRET=$(openssl rand -base64 32)
echo -n "$COOKIE_SECRET" | base64

# MeiliSearch master key oluştur
MEILI_KEY=$(openssl rand -base64 32)
echo -n "$MEILI_KEY" | base64
```

### 2. Secrets Dosyasını Güncelle

```yaml
# k8s/base/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: medusa-secrets
type: Opaque
data:
  jwt-secret: <YUKARIDAKİ_JWT_SECRET_BASE64>
  cookie-secret: <YUKARIDAKİ_COOKIE_SECRET_BASE64>
  postgres-password: <GÜVENLİ_POSTGRES_ŞİFRE_BASE64>
  meilisearch-master-key: <YUKARIDAKİ_MEILI_KEY_BASE64>
```

## 🚀 Deployment Adımları

### 1. Staging Deployment

```bash
# Staging environment'ı deploy et
kubectl apply -k k8s/overlays/staging/

# Deployment durumunu kontrol et
kubectl get pods -l environment=staging
kubectl get services -l environment=staging
```

### 2. Production Deployment

```bash
# Production environment'ı deploy et
kubectl apply -k k8s/overlays/production/

# Deployment durumunu kontrol et
kubectl get pods -l environment=production
kubectl get services -l environment=production
```

## 🌐 Domain Konfigürasyonu

### 1. Staging Domains

Staging environment için aşağıdaki dosyaları güncelleyin:

```yaml
# k8s/overlays/staging/ingress-patch.yaml
# k8s/overlays/staging/storefront-patch.yaml
```

Değiştirin:
- `staging-api.your-domain.com` → `staging-api.sizin-domain.com`
- `staging-store.your-domain.com` → `staging-store.sizin-domain.com`

### 2. Production Domains

Production environment için aşağıdaki dosyaları güncelleyin:

```yaml
# k8s/overlays/production/ingress-patch.yaml
# k8s/overlays/production/storefront-patch.yaml
```

Değiştirin:
- `api.your-domain.com` → `api.sizin-domain.com`
- `store.your-domain.com` → `store.sizin-domain.com`

## 📊 Monitoring ve Logs

### Pod Durumunu Kontrol Etme

```bash
# Tüm podları listele
kubectl get pods

# Specific pod loglarını görüntüle
kubectl logs -f deployment/medusa-backend
kubectl logs -f deployment/storefront
kubectl logs -f deployment/postgres
```

### Servisleri Kontrol Etme

```bash
# Servisleri listele
kubectl get services

# Ingress durumunu kontrol et
kubectl get ingress
```

## 🔧 Troubleshooting

### 1. Database Bağlantı Sorunları

```bash
# PostgreSQL pod'una bağlan
kubectl exec -it deployment/postgres -- psql -U postgres -d medusajs

# Connection string'i kontrol et
kubectl get configmap medusa-config -o yaml
```

### 2. Secrets Sorunları

```bash
# Secrets'ı kontrol et
kubectl get secrets medusa-secrets -o yaml

# Secret değerini decode et
kubectl get secret medusa-secrets -o jsonpath='{.data.jwt-secret}' | base64 -d
```

### 3. Ingress Sorunları

```bash
# Ingress controller loglarını kontrol et
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# NGINX configuration'ı kontrol et
kubectl exec -n ingress-nginx deployment/ingress-nginx-controller -- nginx -T
```

## 🔄 CI/CD Pipeline

### 1. GitHub Actions Workflows

- **Backend**: `.github/workflows/staging.yml`
- **Storefront**: `.github/workflows/storefront.yml`

### 2. Docker Hub Credentials

GitHub repository'de aşağıdaki secrets'ları ekleyin:

```
DOCKER_USERNAME: <dockerhub-kullanıcı-adı>
DOCKER_PASSWORD: <dockerhub-şifre>
```

### 3. Otomatik Deployment

Her main branch'e push yapıldığında:
1. Docker images build edilir
2. Docker Hub'a push edilir
3. Kubernetes manifests güncellenir
4. Yeni SHA ile deployment tetiklenir

## 📈 Scaling

### Horizontal Pod Autoscaler

```bash
# Backend için HPA oluştur
kubectl autoscale deployment medusa-backend --cpu-percent=70 --min=2 --max=10

# Storefront için HPA oluştur
kubectl autoscale deployment storefront --cpu-percent=70 --min=2 --max=10
```

### Resource Limits

Production environment'da resource limits'leri ayarlayın:

```yaml
# k8s/overlays/production/ içinde patch dosyası oluşturun
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

## 🔒 Security Best Practices

1. **Secrets Management**: Kubernetes secrets kullanın, hard-coded değerler kullanmayın
2. **Network Policies**: Pod'lar arası network trafiğini kısıtlayın
3. **RBAC**: Service account'lar için minimum privilege principle uygulayın
4. **Image Security**: Düzenli vulnerability scanning yapın
5. **TLS**: Tüm external communication için SSL/TLS kullanın

## 📞 Support

Herhangi bir sorun durumunda:
1. Yukarıdaki troubleshooting adımlarını deneyin
2. Kubernetes cluster logs'larını kontrol edin
3. GitHub Issues'da yeni bir issue açın