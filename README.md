# Harper AI Marketing Website

This is the main repository for the Harper AI marketing website.

## Directory Structure

```
/Users/mohit/Documents/Harper AI/harper-ai-website/
├── Dockerfile                 # Docker configuration for nginx
├── .dockerignore             # Files to exclude from Docker build
├── render.yaml               # Render.com deployment configuration
├── README.md                 # This file
├── index.html                # Homepage
├── features.html             # Features page
├── pricing.html              # Pricing page
├── for-sdrs.html            # SDR landing page
├── for-managers.html        # Managers landing page
├── enterprise.html          # Enterprise page
├── small-business.html      # Small business page
├── security.html            # Security/compliance page
└── styles.css               # Global stylesheet
```

## Local Development

1. Build the Docker image:
```bash
docker build -t harper-site .
```

2. Run the container:
```bash
docker run -p 8080:80 harper-site
```

3. Test the site:
```bash
curl http://localhost:8080/        # Homepage
curl http://localhost:8080/health  # Health check
```

## Deployment

This site is configured to deploy automatically to Render.com when you push to the main branch.

### Render Configuration
- **Service Type**: Web Service
- **Runtime**: Docker
- **Health Check Path**: `/health`
- **Port**: Automatically set by Render

## Repository

GitHub: https://github.com/Mohit4022-cloud/harper-ai-website