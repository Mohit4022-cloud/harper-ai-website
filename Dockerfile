FROM nginx:alpine

# Remove default nginx config
RUN rm -f /etc/nginx/conf.d/default.conf

# Create nginx config using heredoc (no indentation to avoid parsing issues)
RUN cat << 'EOF' > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Copy all website files to nginx html root
COPY . /usr/share/nginx/html/

# Create startup script to handle PORT env variable (if needed by Render)
RUN cat << 'EOF' > /docker-entrypoint.sh
#!/bin/sh
if [ -n "$PORT" ]; then
    sed -i "s/listen 80/listen $PORT/g" /etc/nginx/conf.d/default.conf
fi
exec nginx -g "daemon off;"
EOF

# Make startup script executable
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]