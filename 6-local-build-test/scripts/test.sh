#!/bin/bash

# Task Management API - Python Testing Script

set -e

echo "🧪 Running Python Task Management API Tests..."

# Navigate to source directory
cd ../2-source-code

# Activate virtual environment
if [ -d "venv" ]; then
    echo "🔄 Activating virtual environment..."
    source venv/bin/activate
else
    echo "❌ Virtual environment not found. Run build.sh first."
    exit 1
fi

# Run unit tests
echo "🧪 Running unit tests with pytest..."
pytest tests/ -v

# Run tests with coverage
echo "📊 Running tests with coverage..."
pytest tests/ --cov=app --cov-report=html --cov-report=term

# Run API tests
echo "🌐 Running API integration tests..."
pytest tests/test_tasks.py -v

# Test Docker container
echo "🐳 Testing Docker container..."
docker run -d --name test-api -p 8001:8000 task-management-api-python:latest

# Wait for container to start
echo "⏳ Waiting for container to start..."
sleep 10

# Test health endpoint
echo "🏥 Testing health endpoint..."
curl -f http://localhost:8001/health || {
    echo "❌ Health check failed"
    docker logs test-api
    docker stop test-api
    docker rm test-api
    exit 1
}

# Test API endpoints
echo "📡 Testing API endpoints..."
curl -f http://localhost:8001/api/tasks || {
    echo "❌ API test failed"
    docker logs test-api
    docker stop test-api
    docker rm test-api
    exit 1
}

# Cleanup test container
echo "🧹 Cleaning up test container..."
docker stop test-api
docker rm test-api

echo "✅ All tests passed!"
echo ""
echo "📊 Coverage report generated in htmlcov/"
echo "🌐 API endpoints tested successfully"
