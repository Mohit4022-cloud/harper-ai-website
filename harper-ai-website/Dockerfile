FROM nginx:alpine-slim

WORKDIR /usr/share/nginx/html

# Remove default files
RUN rm -rf ./*

# Copy website files
COPY index.html .
COPY features.html .
COPY pricing.html .
COPY for-sdrs.html .
COPY for-managers.html .
COPY enterprise.html .
COPY small-business.html .
COPY security.html .
COPY styles.css .

# Configure nginx
RUN echo 'server { listen 80; root /usr/share/nginx/html; index index.html; location / { try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]