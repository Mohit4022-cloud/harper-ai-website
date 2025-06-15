# Harper AI Website - Static Site
FROM nginx:alpine

# Install bash for more reliable scripting
RUN apk add --no-cache bash

# Remove default nginx config
RUN rm -f /etc/nginx/conf.d/default.conf

# Create nginx config template
RUN echo 'server { \
    listen PORT_PLACEHOLDER; \
    listen [::]:PORT_PLACEHOLDER; \
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
}' > /etc/nginx/conf.d/default.conf.template

# Copy the HTML file
COPY harper-ai-website/harper-ai-website.html /usr/share/nginx/html/index.html

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'PORT=${PORT:-3000}' >> /start.sh && \
    echo 'sed "s/PORT_PLACEHOLDER/$PORT/g" /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf' >> /start.sh && \
    echo 'exec nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

# Expose port
EXPOSE 3000

# Use the startup script
CMD ["/start.sh"]