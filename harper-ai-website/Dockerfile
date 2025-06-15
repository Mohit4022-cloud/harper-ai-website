FROM nginx:alpine

# Remove default nginx config
RUN rm -f /etc/nginx/conf.d/default.conf

# Create nginx config
RUN echo 'server { \
    listen 80; \
    listen [::]:80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    location /health { \
        access_log off; \
        return 200 "OK"; \
        add_header Content-Type text/plain; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Copy the HTML file from subdirectory
COPY harper-ai-website/harper-ai-website.html /usr/share/nginx/html/index.html

# Also copy any other marketing pages if they exist
COPY *.html /usr/share/nginx/html/ || true
COPY *.css /usr/share/nginx/html/ || true

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]