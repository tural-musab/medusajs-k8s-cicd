# 🌍 DNS Setup Guide for realcart.shop

Bu doküman, **realcart.shop** domain'i için gerekli DNS kayıtlarını içerir.

## 📋 Gerekli DNS Kayıtları

### 1. Ana Domain (Production)
```
Type: A Record
Name: @
Value: [KUBERNETES_CLUSTER_IP]
TTL: 300
```

### 2. API Subdomain (Production)
```
Type: A Record  
Name: api
Value: [KUBERNETES_CLUSTER_IP]
TTL: 300
```

### 3. Staging Subdomain
```
Type: A Record
Name: staging
Value: [KUBERNETES_CLUSTER_IP] 
TTL: 300
```

### 4. Staging API Subdomain
```
Type: A Record
Name: staging-api
Value: [KUBERNETES_CLUSTER_IP]
TTL: 300
```

## 🔍 Kubernetes Cluster IP Bulma

### Cloud Providers'dan IP Alma:

**AWS (EKS):**
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
# EXTERNAL-IP sütunundaki değeri kullanın
```

**Google Cloud (GKE):**
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
# EXTERNAL-IP sütunundaki değeri kullanın
```

**Azure (AKS):**
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
# EXTERNAL-IP sütunundaki değeri kullanın
```

**Local/Minikube (Development):**
```bash
minikube tunnel
# Ve başka terminalde:
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

## 📝 GoDaddy DNS Panel'inde Ayarlama

1. **GoDaddy hesabınıza giriş yapın**
2. **"My Products" > "DNS"** bölümüne gidin
3. **realcart.shop** domain'ini seçin
4. **"Manage DNS"** butonuna tıklayın
5. **Aşağıdaki kayıtları ekleyin:**

### Production Kayıtları:
| Type | Name | Value | TTL |
|------|------|-------|-----|
| A    | @    | [CLUSTER_IP] | 600 |
| A    | api  | [CLUSTER_IP] | 600 |

### Staging Kayıtları (Test için):
| Type | Name | Value | TTL |
|------|------|-------|-----|
| A    | staging | [CLUSTER_IP] | 600 |
| A    | staging-api | [CLUSTER_IP] | 600 |

## ✅ DNS Doğrulama

DNS değişikliklerinin yayılmasını bekleyin (5-10 dakika), sonra test edin:

```bash
# Ana domain test
nslookup realcart.shop

# API subdomain test  
nslookup api.realcart.shop

# Staging test
nslookup staging.realcart.shop
nslookup staging-api.realcart.shop
```

## 🚀 SSL Sertifika Otomasyonu

DNS kayıtları aktif olduktan sonra, Let's Encrypt otomatik olarak SSL sertifikaları oluşturacak:

```bash
# Sertifika durumunu kontrol et
kubectl get certificates -n medusajs-production
kubectl get certificates -n medusajs-staging

# Sertifika detayları
kubectl describe certificate production-tls-secret -n medusajs-production
```

## 🔧 Troubleshooting

### DNS Sorunları:
```bash
# DNS yayılma kontrolü
dig realcart.shop
dig api.realcart.shop

# DNS cache temizleme (macOS)
sudo dscacheutil -flushcache

# DNS cache temizleme (Windows)
ipconfig /flushdns
```

### SSL Sorunları:
```bash
# cert-manager logları
kubectl logs -n cert-manager deployment/cert-manager

# Challenge durumu  
kubectl get challenges -A
```

## ⏰ Tahmini Süreler

- **DNS Yayılması:** 5-10 dakika
- **SSL Sertifika Oluşturma:** 2-5 dakika
- **Toplam Süre:** ~15 dakika

## 📞 Sonraki Adımlar

DNS kayıtları eklendikten sonra:

1. **DNS yayılmasını bekleyin** (5-10 dakika)
2. **Production deployment** çalıştırın:
   ```bash
   ./scripts/deploy-production.sh
   ```
3. **SSL sertifikalarını kontrol edin**
4. **Domain'leri test edin:**
   - https://realcart.shop (Storefront)
   - https://api.realcart.shop (Admin/API)