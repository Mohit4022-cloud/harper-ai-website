#!/bin/bash

# Configuration - Fill these in
RENDER_API_KEY="YOUR_RENDER_API_KEY"
SERVICE_ID="YOUR_SERVICE_ID"  # e.g., srv-xxxxxx

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "=== Fixing Render Build Configuration ==="

# Step 1: Get current service configuration
echo -e "${YELLOW}Fetching current service configuration...${NC}"
CURRENT_CONFIG=$(curl -s -X GET \
  "https://api.render.com/v1/services/${SERVICE_ID}" \
  -H "Authorization: Bearer ${RENDER_API_KEY}" \
  -H "Accept: application/json")

echo "Current rootDirectory: $(echo $CURRENT_CONFIG | jq -r '.rootDirectory')"

# Step 2: Update the root directory
echo -e "${YELLOW}Updating root directory to 'harper-ai-website'...${NC}"
UPDATE_RESPONSE=$(curl -s -X PATCH \
  "https://api.render.com/v1/services/${SERVICE_ID}" \
  -H "Authorization: Bearer ${RENDER_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "rootDirectory": "harper-ai-website"
  }')

echo "Update response: $(echo $UPDATE_RESPONSE | jq -r '.rootDirectory')"

# Step 3: Trigger a new deploy
echo -e "${YELLOW}Triggering new deployment...${NC}"
DEPLOY_RESPONSE=$(curl -s -X POST \
  "https://api.render.com/v1/services/${SERVICE_ID}/deploys" \
  -H "Authorization: Bearer ${RENDER_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"clearCache": true}')

DEPLOY_ID=$(echo $DEPLOY_RESPONSE | jq -r '.id')
echo "Deploy ID: $DEPLOY_ID"

# Step 4: Poll deployment status
echo -e "${YELLOW}Monitoring deployment...${NC}"
while true; do
  DEPLOY_STATUS=$(curl -s -X GET \
    "https://api.render.com/v1/services/${SERVICE_ID}/deploys/${DEPLOY_ID}" \
    -H "Authorization: Bearer ${RENDER_API_KEY}" \
    -H "Accept: application/json" | jq -r '.status')
  
  echo "Status: $DEPLOY_STATUS"
  
  if [[ "$DEPLOY_STATUS" == "live" ]] || [[ "$DEPLOY_STATUS" == "deactivated" ]]; then
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    break
  elif [[ "$DEPLOY_STATUS" == "build_failed" ]] || [[ "$DEPLOY_STATUS" == "update_failed" ]]; then
    echo -e "${RED}Deployment failed!${NC}"
    
    # Fetch logs
    echo -e "${YELLOW}Fetching build logs...${NC}"
    curl -s -X GET \
      "https://api.render.com/v1/services/${SERVICE_ID}/deploys/${DEPLOY_ID}/logs" \
      -H "Authorization: Bearer ${RENDER_API_KEY}" \
      -H "Accept: application/json" | jq -r '.[]'
    break
  fi
  
  sleep 5
done

echo -e "${GREEN}Configuration updated!${NC}"
echo "Root Directory is now set to: harper-ai-website"
echo "Next steps:"
echo "1. Check the Render dashboard to verify the build succeeded"
echo "2. Visit your site URL to confirm it's working"