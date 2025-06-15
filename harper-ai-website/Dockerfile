# Multi-stage Dockerfile for Harper AI Static Website
# Stage 1: Build stage (minimal since it's static HTML)
FROM node:18-alpine AS builder
WORKDIR /app

# Copy all files
COPY . .

# Create a simple package.json if it doesn't exist for the http-server
RUN echo '{"name":"harper-ai-website","version":"1.0.0","scripts":{"start":"http-server -p 3000 -c-1"}}' > package.json

# Stage 2: Production stage with nginx
FROM nginx:alpine AS runner

# Copy custom nginx config
RUN echo 'server { \
    listen 3000; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index harper-ai-website.html index.html; \
    location / { \
        try_files $uri $uri/ /harper-ai-website.html; \
    } \
    location /health { \
        access_log off; \
        return 200 "healthy\n"; \
        add_header Content-Type text/plain; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Copy static files
COPY --from=builder /app/harper-ai-website.html /usr/share/nginx/html/
COPY --from=builder /app/harper-ai-website.html /usr/share/nginx/html/index.html

# Create non-root user
RUN adduser -D -H -u 1001 -s /sbin/nologin nginx-user

# Set permissions
RUN chown -R nginx-user:nginx-user /usr/share/nginx/html && \
    chown -R nginx-user:nginx-user /var/cache/nginx && \
    chown -R nginx-user:nginx-user /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx-user:nginx-user /var/run/nginx.pid

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Switch to non-root user
USER nginx-user

# Start nginx
CMD ["nginx", "-g", "daemon off;"]