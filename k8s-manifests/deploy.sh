#!/bin/bash

# MedusaJS Kubernetes Deployment Script
# Bu script tüm servisleri sırayla deploy eder

echo "🚀 MedusaJS Kubernetes Deployment Başlıyor..."

# 1. Namespace oluştur (izolasyon için)
echo "📁 Namespace oluşturuluyor..."
kubectl create namespace medusajs || echo "Namespace zaten mevcut"
kubectl config set-context --current --namespace=medusajs

# 2. ConfigMap'leri deploy et
echo "🔧 ConfigMap deploy ediliyor..."
kubectl apply -f medusa-configmap.yaml

# 3. Database'leri deploy et
echo "🗄️ PostgreSQL deploy ediliyor..."
kubectl apply -f postgres-deployment.yaml

echo "🔥 Redis deploy ediliyor..."
kubectl apply -f redis-deployment.yaml

echo "🔍 MeiliSearch deploy ediliyor..."
kubectl apply -f meilisearch-deployment.yaml

# 4. Database'lerin hazır olmasını bekle
echo "⏳ Database'lerin hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s
kubectl wait --for=condition=ready pod -l app=redis --timeout=300s
kubectl wait --for=condition=ready pod -l app=meilisearch --timeout=300s

# 5. MedusaJS Backend deploy et
echo "🏪 MedusaJS Backend deploy ediliyor..."
kubectl apply -f medusa-backend.yaml

# 6. Backend'in hazır olmasını bekle
echo "⏳ MedusaJS Backend'in hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=medusa-backend --timeout=300s

# 7. Ingress deploy et (Nginx Ingress Controller gerekli)
echo "🌐 Ingress deploy ediliyor..."
kubectl apply -f medusa-ingress.yaml

# 8. Status kontrolü
echo "📊 Deployment durumu:"
kubectl get pods -o wide
kubectl get services
kubectl get ingress

echo ""
echo "✅ Deployment tamamlandı!"
echo ""
echo "🌐 Erişim adresleri:"
echo "   Backend API: http://medusa-api.local"
echo "   Admin Panel: http://medusa-admin.local" 
echo "   Storefront:  http://medusa-store.local"
echo ""
echo "⚠️  Not: /etc/hosts dosyasına şu satırları ekleyin:"
echo "   127.0.0.1 medusa-api.local"
echo "   127.0.0.1 medusa-admin.local"
echo "   127.0.0.1 medusa-store.local"
