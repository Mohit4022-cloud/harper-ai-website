#!/bin/bash

# Test script for Harper AI website Docker build

echo "Testing Harper AI website Docker build..."
echo "========================================="

# Build the Docker image
echo "Building Docker image..."
docker build -t harper-site .

if [ $? -eq 0 ]; then
    echo "✓ Docker build successful!"
    
    # Run the container
    echo -e "\nStarting container on port 8080..."
    docker run -d --name harper-test -p 8080:80 harper-site
    
    # Wait for container to start
    sleep 3
    
    # Test the endpoints
    echo -e "\nTesting endpoints..."
    echo "Homepage:"
    curl -s http://localhost:8080/ | head -20
    
    echo -e "\n\nHealth check:"
    curl -s http://localhost:8080/health
    
    # Cleanup
    echo -e "\n\nCleaning up..."
    docker stop harper-test
    docker rm harper-test
    
    echo -e "\n✓ All tests passed!"
else
    echo "✗ Docker build failed!"
    exit 1
fi