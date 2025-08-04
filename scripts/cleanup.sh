#!/bin/bash

# Task Management System - Python Cleanup Script

set -e

echo "🧹 Cleaning up Python Task Management System..."

# Cleanup Docker resources
cleanup_docker() {
    echo "🐳 Cleaning up Docker resources..."
    
    # Stop and remove containers
    docker stop task-app-python task-frontend task-mysql task-prometheus task-grafana 2>/dev/null || true
    docker rm task-app-python task-frontend task-mysql task-prometheus task-grafana 2>/dev/null || true
    
    # Remove images
    docker rmi task-management-api-python:latest 2>/dev/null || true
    docker rmi task-management-frontend:latest 2>/dev/null || true
    
    # Remove volumes
    docker volume rm 5-containerization_mysql_data 2>/dev/null || true
    docker volume rm 5-containerization_grafana_data 2>/dev/null || true
    
    # Remove network
    docker network rm task-network 2>/dev/null || true
    
    # Prune unused resources
    docker system prune -f
    
    echo "✅ Docker cleanup complete"
}

# Cleanup Kubernetes resources
cleanup_kubernetes() {
    echo "☸️ Cleaning up Kubernetes resources..."
    
    # Delete namespace (removes all resources)
    kubectl delete namespace task-management-python --ignore-not-found=true
    
    # Wait for namespace deletion
    echo "⏳ Waiting for namespace deletion..."
    kubectl wait --for=delete namespace/task-management-python --timeout=60s 2>/dev/null || true
    
    echo "✅ Kubernetes cleanup complete"
}

# Cleanup Python environment
cleanup_python() {
    echo "🐍 Cleaning up Python environment..."
    
    cd 2-source-code
    
    # Remove virtual environment
    if [ -d "venv" ]; then
        rm -rf venv
        echo "✅ Removed virtual environment"
    fi
    
    # Remove Python cache
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -name "*.pyc" -delete 2>/dev/null || true
    find . -name "*.pyo" -delete 2>/dev/null || true
    
    # Remove test artifacts
    rm -rf .pytest_cache 2>/dev/null || true
    rm -rf htmlcov 2>/dev/null || true
    rm -f coverage.xml 2>/dev/null || true
    rm -f test-results.xml 2>/dev/null || true
    
    cd ..
    
    echo "✅ Python environment cleanup complete"
}

# Cleanup build artifacts
cleanup_build() {
    echo "🔨 Cleaning up build artifacts..."
    
    # Remove generated manifests
    rm -f 3-frontend/frontend-deployment-python-*.yaml 2>/dev/null || true
    
    # Remove logs
    rm -rf logs 2>/dev/null || true
    
    # Remove data directories
    rm -rf data 2>/dev/null || true
    
    # Remove backups
    rm -rf backups 2>/dev/null || true
    
    echo "✅ Build artifacts cleanup complete"
}

# Cleanup monitoring data
cleanup_monitoring() {
    echo "📊 Cleaning up monitoring data..."
    
    # Remove Prometheus data
    docker volume rm prometheus_data 2>/dev/null || true
    
    # Remove Grafana data
    docker volume rm grafana_data 2>/dev/null || true
    
    echo "✅ Monitoring cleanup complete"
}

# Reset to clean state
reset_environment() {
    echo "🔄 Resetting environment to clean state..."
    
    # Reset git changes (optional)
    read -p "Reset git changes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout -- .
        git clean -fd
        echo "✅ Git reset complete"
    fi
    
    # Recreate basic directories
    mkdir -p logs
    mkdir -p data
    mkdir -p backups
    
    echo "✅ Environment reset complete"
}

# Show cleanup summary
show_summary() {
    echo ""
    echo "📋 Cleanup Summary:"
    echo "- Docker containers and images removed"
    echo "- Kubernetes namespace deleted"
    echo "- Python virtual environment removed"
    echo "- Build artifacts cleaned"
    echo "- Monitoring data cleared"
    echo ""
    echo "🎉 Cleanup complete!"
    echo ""
    echo "To restart the system:"
    echo "1. Run: ./scripts/setup-environment-python.sh"
    echo "2. Then: cd 5-containerization && docker-compose -f docker-compose-python.yml up -d"
}

# Main execution
main() {
    case "${1:-all}" in
        "docker")
            cleanup_docker
            ;;
        "kubernetes"|"k8s")
            cleanup_kubernetes
            ;;
        "python")
            cleanup_python
            ;;
        "build")
            cleanup_build
            ;;
        "monitoring")
            cleanup_monitoring
            ;;
        "reset")
            cleanup_docker
            cleanup_kubernetes
            cleanup_python
            cleanup_build
            cleanup_monitoring
            reset_environment
            ;;
        "all")
            cleanup_docker
            cleanup_kubernetes
            cleanup_python
            cleanup_build
            cleanup_monitoring
            show_summary
            ;;
        *)
            echo "Usage: $0 [all|docker|kubernetes|python|build|monitoring|reset]"
            echo ""
            echo "Options:"
            echo "  all        - Clean everything (default)"
            echo "  docker     - Clean Docker resources only"
            echo "  kubernetes - Clean Kubernetes resources only"
            echo "  python     - Clean Python environment only"
            echo "  build      - Clean build artifacts only"
            echo "  monitoring - Clean monitoring data only"
            echo "  reset      - Full reset including git changes"
            echo ""
            echo "Examples:"
            echo "  $0 all"
            echo "  $0 docker"
            echo "  $0 kubernetes"
            exit 1
            ;;
    esac
}

main "$@"
