#!/bin/bash

# Task Management API - Python Development Server

set -e

echo "🚀 Starting Python Task Management API Development Server..."

# Navigate to source directory
cd ../2-source-code

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Run build.sh first."
    exit 1
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Set environment variables
export DATABASE_URL="mysql+pymysql://taskuser:taskpass@localhost:3306/taskdb"
export PYTHONPATH="/app"

# Check if MySQL is running
echo "🔍 Checking MySQL connection..."
if ! mysqladmin ping -h localhost -u taskuser -ptaskpass --silent; then
    echo "⚠️ MySQL not accessible. Starting with Docker Compose..."
    cd ../5-containerization
    docker-compose -f docker-compose-python.yml up -d mysql
    echo "⏳ Waiting for MySQL to be ready..."
    sleep 10
    cd ../2-source-code
fi

# Start development server with hot reload
echo "🌟 Starting FastAPI development server..."
echo "📡 API will be available at: http://localhost:8000"
echo "📚 API documentation at: http://localhost:8000/docs"
echo "🔄 Hot reload enabled - changes will auto-restart server"
echo ""
echo "Press Ctrl+C to stop the server"

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
