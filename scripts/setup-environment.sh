#!/bin/bash

# Task Management System - Python Environment Setup

set -e

echo "🐍 Setting up Python Task Management System Environment..."

# Check prerequisites
check_prerequisites() {
    echo "📋 Checking prerequisites..."
    
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python 3 is not installed"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose is not installed"
        exit 1
    fi
    
    echo "✅ All prerequisites met"
}

# Setup Python environment
setup_python() {
    echo "🐍 Setting up Python environment..."
    
    cd 2-source-code
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        echo "✅ Created virtual environment"
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    pip install --upgrade pip
    pip install -r requirements.txt
    pip install -r requirements-dev.txt
    
    echo "✅ Python environment setup complete"
    cd ..
}

# Setup Docker
setup_docker() {
    echo "🐳 Setting up Docker environment..."
    
    # Create custom network
    if ! docker network ls | grep -q task-network; then
        docker network create task-network
        echo "✅ Created task-network"
    fi
    
    # Pull required images
    docker pull mysql:8.0
    docker pull python:3.11-slim
    docker pull nginx:alpine
    docker pull prom/prometheus:latest
    docker pull grafana/grafana:latest
    
    echo "✅ Docker setup complete"
}

# Create directories
create_directories() {
    echo "📁 Creating project directories..."
    
    mkdir -p logs
    mkdir -p data/mysql
    mkdir -p data/grafana
    mkdir -p backups
    
    echo "✅ Directories created"
}

# Set permissions
set_permissions() {
    echo "🔐 Setting permissions..."
    
    chmod +x scripts/*.sh
    chmod +x 6-local-build-test/scripts/*.sh
    chmod 755 data/
    
    echo "✅ Permissions set"
}

# Main execution
main() {
    check_prerequisites
    setup_python
    setup_docker
    create_directories
    set_permissions
    
    echo ""
    echo "🎉 Python environment setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Run: cd 5-containerization && docker-compose -f docker-compose-python.yml up -d"
    echo "2. Or start dev server: cd 2-source-code && source venv/bin/activate && uvicorn app.main:app --reload"
    echo ""
    echo "Access URLs:"
    echo "- Frontend: http://localhost:3001"
    echo "- API: http://localhost:8000"
    echo "- API Docs: http://localhost:8000/docs"
    echo "- Grafana: http://localhost:3000"
}

main "$@"
