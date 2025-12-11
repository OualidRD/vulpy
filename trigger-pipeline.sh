#!/bin/bash
# Script to trigger Jenkins pipeline after fixes

echo "🔄 Waiting for Docker to stabilize..."
sleep 5

echo "✅ Checking Docker status..."
docker ps

if [ $? -eq 0 ]; then
    echo "🚀 Docker is ready. Updating Jenkins workspace..."
    
    docker exec jenkins-vulpy bash -c "cd /var/jenkins_home/workspace/vulpy-security-pipeline && git fetch origin && git reset --hard origin/master && echo 'Git updated successfully'"
    
    echo "📋 You can now trigger the pipeline in Jenkins:"
    echo "   1. Go to http://localhost:8081"
    echo "   2. Click on 'vulpy-security-pipeline' job"
    echo "   3. Click 'Build Now'"
    echo ""
    echo "Or use Jenkins API:"
    echo "   curl -X POST http://localhost:8081/job/vulpy-security-pipeline/build"
    
else
    echo "❌ Docker is not responding. Please restart Docker Desktop and try again."
    exit 1
fi
