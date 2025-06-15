#!/bin/bash

# IMPORTANT: Fill in these values
RENDER_API_KEY="YOUR_API_KEY_HERE"
SERVICE_ID="YOUR_SERVICE_ID_HERE"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Render Build Fix Script ===${NC}"
echo "This script will fix the empty context issue (2B) on Render"
echo ""

# Function to make API calls
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -z "$data" ]; then
        curl -s -X "$method" \
            "https://api.render.com/v1/$endpoint" \
            -H "Authorization: Bearer $RENDER_API_KEY" \
            -H "Accept: application/json"
    else
        curl -s -X "$method" \
            "https://api.render.com/v1/$endpoint" \
            -H "Authorization: Bearer $RENDER_API_KEY" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d "$data"
    fi
}

# Step 1: Fetch current service details
echo -e "${YELLOW}Step 1: Fetching current service configuration...${NC}"
SERVICE_CONFIG=$(api_call GET "services/$SERVICE_ID")
CURRENT_ROOT=$(echo "$SERVICE_CONFIG" | jq -r '.service.rootDirectory // "null"')
echo "Current rootDirectory: $CURRENT_ROOT"

# Step 2: Fix root directory
echo -e "${YELLOW}Step 2: Setting rootDirectory to repository root...${NC}"
# Try different values until one works
for ROOT_DIR in "." "" "/" ; do
    echo "Trying rootDirectory: '$ROOT_DIR'"
    
    UPDATE_RESPONSE=$(api_call PATCH "services/$SERVICE_ID" "{\"rootDirectory\": \"$ROOT_DIR\"}")
    
    # Step 3: Trigger new deploy
    echo -e "${YELLOW}Step 3: Triggering new deployment...${NC}"
    DEPLOY_RESPONSE=$(api_call POST "services/$SERVICE_ID/deploys" '{"clearCache": true}')
    DEPLOY_ID=$(echo "$DEPLOY_RESPONSE" | jq -r '.deploy.id // .id')
    
    if [ -z "$DEPLOY_ID" ] || [ "$DEPLOY_ID" = "null" ]; then
        echo -e "${RED}Failed to trigger deployment${NC}"
        continue
    fi
    
    echo "Deploy ID: $DEPLOY_ID"
    
    # Step 4: Poll deployment status
    echo -e "${YELLOW}Step 4: Monitoring deployment...${NC}"
    MAX_ATTEMPTS=60  # 5 minutes max
    ATTEMPT=0
    
    while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
        DEPLOY_STATUS=$(api_call GET "services/$SERVICE_ID/deploys/$DEPLOY_ID")
        STATUS=$(echo "$DEPLOY_STATUS" | jq -r '.deploy.status // .status')
        
        echo -ne "\rStatus: $STATUS (attempt $((ATTEMPT+1))/$MAX_ATTEMPTS)"
        
        if [[ "$STATUS" == "live" ]] || [[ "$STATUS" == "build_failed" ]] || [[ "$STATUS" == "canceled" ]]; then
            echo ""
            break
        fi
        
        sleep 5
        ((ATTEMPT++))
    done
    
    # Step 5: Fetch and analyze logs
    echo -e "\n${YELLOW}Step 5: Fetching build logs...${NC}"
    LOGS=$(api_call GET "services/$SERVICE_ID/deploys/$DEPLOY_ID/logs")
    
    # Save logs for analysis
    echo "$LOGS" | jq -r '.logs[].message // .' > deploy_logs.txt
    
    # Step 6: Verify the build
    echo -e "${YELLOW}Step 6: Verifying build context...${NC}"
    
    # Check context size
    CONTEXT_SIZE=$(grep -i "transferring context:" deploy_logs.txt | tail -1)
    echo "Context transfer: $CONTEXT_SIZE"
    
    # Check if it's more than 2B
    if [[ "$CONTEXT_SIZE" == *"2B"* ]] || [[ "$CONTEXT_SIZE" == *"2 B"* ]]; then
        echo -e "${RED}Context is still empty (2B)!${NC}"
        continue
    fi
    
    # Check COPY success
    COPY_SUCCESS=$(grep -i "COPY harper-ai-website/harper-ai-website.html" deploy_logs.txt | grep -v "ERROR")
    if [ -n "$COPY_SUCCESS" ]; then
        echo -e "${GREEN}COPY command found in logs${NC}"
    fi
    
    # Check for errors
    BUILD_ERRORS=$(grep -i "error\|failed" deploy_logs.txt | grep -v "0 errors")
    if [ -z "$BUILD_ERRORS" ]; then
        echo -e "${GREEN}No build errors detected${NC}"
        
        # Success!
        echo -e "\n${GREEN}=== BUILD FIXED! ===${NC}"
        echo "Final rootDirectory: $ROOT_DIR"
        echo "Deploy ID: $DEPLOY_ID"
        echo "Context size: $CONTEXT_SIZE"
        echo -e "${GREEN}Render build now succeeds with full context.${NC}"
        
        # Show key log lines
        echo -e "\n${BLUE}Key log excerpts:${NC}"
        grep -E "transferring context:|COPY harper-ai-website|Successfully built" deploy_logs.txt | head -10
        
        exit 0
    else
        echo -e "${RED}Build errors found:${NC}"
        echo "$BUILD_ERRORS" | head -5
    fi
done

echo -e "\n${RED}Failed to fix the build after all attempts${NC}"
echo "Please check:"
echo "1. The repository structure"
echo "2. The .dockerignore file"
echo "3. The Render service settings manually"