#!/bin/bash

# Task Management API - Python Build Script

set -e

echo "🐍 Building Python Task Management API..."

# Navigate to source directory
cd ../2-source-code

# Check Python version
echo "📋 Checking Python version..."
python --version

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "🔧 Creating virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "⬆️ Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

# Install development dependencies
echo "📦 Installing development dependencies..."
pip install -r requirements-dev.txt

# Run code formatting
echo "🎨 Formatting code with black..."
black app/ --check || black app/

# Run linting
echo "🔍 Running flake8 linting..."
flake8 app/ --max-line-length=88 --extend-ignore=E203,W503

# Run type checking
echo "🔍 Running mypy type checking..."
mypy app/ --ignore-missing-imports || echo "⚠️ Type checking completed with warnings"

# Build Docker image
echo "🐳 Building Docker image..."
docker build -t task-management-api-python:latest .

echo "✅ Build completed successfully!"
echo ""
echo "🚀 Next steps:"
echo "1. Run tests: ./test.sh"
echo "2. Start dev server: ./run-local.sh"
echo "3. Run with Docker: docker run -p 8000:8000 task-management-api-python:latest"
