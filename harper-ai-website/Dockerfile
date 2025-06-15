# Harper AI Marketing Website
# Version: 2.0 - Complete rebuild
FROM nginx:1.25-alpine

# Install bash for scripting
RUN apk add --no-cache bash

# Remove all default nginx configurations
RUN rm -rf /etc/nginx/conf.d/* && \
    rm -rf /usr/share/nginx/html/*

# Create new nginx configuration
RUN echo 'server { \
    listen 8080; \
    listen [::]:8080; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Enable gzip compression \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 256; \
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json; \
    \
    # Security headers \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
    \
    # Main location \
    location / { \
        try_files $uri $uri/ /index.html; \
        add_header Cache-Control "no-cache, no-store, must-revalidate"; \
    } \
    \
    # Static assets caching \
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 30d; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    # Health check \
    location /health { \
        access_log off; \
        return 200 "healthy\n"; \
        add_header Content-Type text/plain; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy all marketing website files
COPY ./index.html ./
COPY ./features.html ./
COPY ./pricing.html ./
COPY ./for-sdrs.html ./
COPY ./for-managers.html ./
COPY ./enterprise.html ./
COPY ./small-business.html ./
COPY ./security.html ./
COPY ./styles.css ./

# Create entrypoint script
RUN echo '#!/bin/bash \
set -e \
\
# Use PORT env variable if set, otherwise default to 8080 \
PORT=${PORT:-8080} \
echo "Configuring nginx to listen on port $PORT" \
\
# Replace port in nginx config \
sed -i "s/listen 8080/listen $PORT/g" /etc/nginx/conf.d/default.conf \
sed -i "s/listen \[::\]:8080/listen \[::\]:$PORT/g" /etc/nginx/conf.d/default.conf \
\
# Verify files exist \
echo "Checking website files:" \
ls -la /usr/share/nginx/html/ \
\
# Start nginx \
echo "Starting nginx on port $PORT" \
exec nginx -g "daemon off;"' > /entrypoint.sh && \
chmod +x /entrypoint.sh

# Default port (Render will override via PORT env)
EXPOSE 8080

# Use our custom entrypoint
ENTRYPOINT ["/entrypoint.sh"]