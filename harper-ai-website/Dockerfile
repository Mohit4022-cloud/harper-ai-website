# Use nginx alpine for lightweight static serving
# Force rebuild: 2024-12-14
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Create nginx config that listens on $PORT
RUN echo 'server { \
    listen 3000; \
    listen [::]:3000; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Copy all HTML and CSS files
COPY *.html /usr/share/nginx/html/
COPY *.css /usr/share/nginx/html/

# Create a startup script to handle PORT env variable
RUN echo '#!/bin/sh\n\
if [ -n "$PORT" ]; then\n\
  sed -i "s/listen 3000/listen $PORT/g" /etc/nginx/conf.d/default.conf\n\
  sed -i "s/listen \[::\]:3000/listen \[::\]:$PORT/g" /etc/nginx/conf.d/default.conf\n\
fi\n\
nginx -g "daemon off;"' > /docker-entrypoint.sh && \
chmod +x /docker-entrypoint.sh

# Expose port (Render will override this)
EXPOSE 3000

# Start nginx
CMD ["/docker-entrypoint.sh"]