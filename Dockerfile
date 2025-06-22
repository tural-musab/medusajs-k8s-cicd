FROM nginx:alpine

ARG COMMIT_SHA

# Custom nginx config
COPY k8s-manifests/nginx-config.conf /etc/nginx/conf.d/default.conf

# Create directory and add custom HTML content
RUN mkdir -p /usr/share/nginx/html && \
    echo "<h1>🚀 MedusaJS CI/CD Demo</h1><p>Deployed via GitHub Actions!</p><p>Commit: ${COMMIT_SHA}</p>" > /usr/share/nginx/html/index.html

EXPOSE 80
