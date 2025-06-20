FROM nginx:alpine

# Custom nginx config
COPY k8s-manifests/nginx-config.conf /etc/nginx/conf.d/default.conf

# Custom HTML content
RUN echo '<h1>🚀 MedusaJS CI/CD Demo</h1><p>Deployed via GitHub Actions!</p><p>Commit: $COMMIT_SHA</p>' > /var/www/html/index.html

EXPOSE 80
