FROM nginx:alpine

# Remove default nginx config
RUN rm -f /etc/nginx/conf.d/default.conf

# Create nginx config with proper error handling
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

# Debug: Show build context
RUN echo "Nginx config created"

# Create the target directory
RUN mkdir -p /usr/share/nginx/html

# Copy the HTML file from subdirectory with explicit path
COPY ./harper-ai-website/harper-ai-website.html /usr/share/nginx/html/index.html

# Copy other marketing pages if they exist (with explicit paths)
COPY ./index.html /usr/share/nginx/html/home.html
COPY ./features.html /usr/share/nginx/html/
COPY ./pricing.html /usr/share/nginx/html/
COPY ./for-sdrs.html /usr/share/nginx/html/
COPY ./for-managers.html /usr/share/nginx/html/
COPY ./enterprise.html /usr/share/nginx/html/
COPY ./small-business.html /usr/share/nginx/html/
COPY ./security.html /usr/share/nginx/html/
COPY ./styles.css /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]