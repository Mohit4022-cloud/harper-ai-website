# Multi-page marketing website for Harper AI
# Updated: 2024-12-14
FROM nginx:alpine

# Remove default nginx config
RUN rm -rf /etc/nginx/conf.d/*

# Create optimized nginx config
RUN echo 'server { \
    listen 3000; \
    listen [::]:3000; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Compression \
    gzip on; \
    gzip_types text/css application/javascript text/html; \
    \
    # Cache static assets \
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg)$ { \
        expires 30d; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    # Serve HTML files \
    location / { \
        try_files $uri $uri/ /index.html; \
        expires -1; \
        add_header Cache-Control "no-cache, no-store, must-revalidate"; \
    } \
    \
    # Health check endpoint \
    location /health { \
        access_log off; \
        return 200 "OK"; \
        add_header Content-Type text/plain; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Copy all website files
WORKDIR /usr/share/nginx/html
COPY index.html .
COPY features.html .
COPY pricing.html .
COPY for-sdrs.html .
COPY for-managers.html .
COPY enterprise.html .
COPY small-business.html .
COPY security.html .
COPY styles.css .

# Create startup script for PORT handling
RUN echo '#!/bin/sh\n\
# Replace port placeholder with actual PORT env variable\n\
if [ -n "$PORT" ]; then\n\
  echo "Configuring nginx to listen on port $PORT"\n\
  sed -i "s/listen 3000/listen $PORT/g" /etc/nginx/conf.d/default.conf\n\
  sed -i "s/listen \[::\]:3000/listen \[::\]:$PORT/g" /etc/nginx/conf.d/default.conf\n\
fi\n\
\n\
# Start nginx\n\
echo "Starting nginx..."\n\
nginx -g "daemon off;"' > /startup.sh && \
chmod +x /startup.sh

# Expose port
EXPOSE 3000

# Use the startup script
CMD ["/startup.sh"]