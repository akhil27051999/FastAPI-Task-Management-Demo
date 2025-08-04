#!/bin/bash

# Task Management System - Python Kubernetes Deployment

set -e

NAMESPACE="task-management-python"
REGISTRY="your-registry"
VERSION=${1:-"latest"}

echo "🐍 Deploying Python Task Management System to Kubernetes..."
echo "📦 Version: $VERSION"
echo "🏷️ Namespace: $NAMESPACE"

# Build and push images
build_and_push() {
    echo "🔨 Building and pushing images..."
    
    # Build Python API
    echo "Building Python API image..."
    cd 2-source-code
    docker build -t $REGISTRY/task-management-api-python:$VERSION .
    docker push $REGISTRY/task-management-api-python:$VERSION
    cd ..
    
    # Build frontend
    echo "Building frontend image..."
    cd 3-frontend
    docker build -t $REGISTRY/task-management-frontend:$VERSION .
    docker push $REGISTRY/task-management-frontend:$VERSION
    cd ..
    
    echo "✅ Images built and pushed"
}

# Deploy database
deploy_database() {
    echo "🗄️ Deploying MySQL database..."
    
    kubectl apply -f 7-kubernetes-python/mysql-deployment.yaml
    kubectl apply -f 7-kubernetes-python/mysql-service.yaml
    
    echo "✅ MySQL deployed"
}

# Deploy Python API
deploy_api() {
    echo "🐍 Deploying Python API..."
    
    # Update image tag
    sed -i "s|task-management-api-python:latest|$REGISTRY/task-management-api-python:$VERSION|g" 7-kubernetes-python/task-api-deployment.yaml
    
    kubectl apply -f 7-kubernetes-python/task-api-deployment.yaml
    kubectl apply -f 7-kubernetes-python/task-api-service.yaml
    
    echo "✅ Python API deployed"
}

# Deploy frontend
deploy_frontend() {
    echo "🌐 Deploying frontend..."
    
    # Update image tag
    sed -i "s|task-management-frontend:latest|$REGISTRY/task-management-frontend:$VERSION|g" 7-kubernetes-python/frontend-deployment.yaml
    
    kubectl apply -f 7-kubernetes-python/frontend-deployment.yaml
    kubectl apply -f 7-kubernetes-python/frontend-service.yaml
    
    echo "✅ Frontend deployed"
}

# Deploy ingress
deploy_ingress() {
    echo "🌍 Deploying ingress..."
    
    kubectl apply -f 7-kubernetes-python/ingress.yaml
    
    echo "✅ Ingress deployed"
}

# Deploy monitoring
deploy_monitoring() {
    echo "📊 Deploying monitoring stack..."
    
    kubectl apply -f 9-monitoring/prometheus/
    kubectl apply -f 9-monitoring/grafana/
    
    echo "✅ Monitoring deployed"
}

# Wait for deployments
wait_for_deployments() {
    echo "⏳ Waiting for deployments to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/mysql -n $NAMESPACE
    kubectl wait --for=condition=available --timeout=300s deployment/task-api-python -n $NAMESPACE
    kubectl wait --for=condition=available --timeout=300s deployment/task-frontend -n $NAMESPACE
    
    echo "✅ All deployments ready"
}

# Show status
show_status() {
    echo ""
    echo "📋 Deployment Status:"
    kubectl get pods -n $NAMESPACE
    echo ""
    kubectl get svc -n $NAMESPACE
    echo ""
    kubectl get ingress -n $NAMESPACE
    echo ""
    
    # Get ingress IP
    INGRESS_IP=$(kubectl get ingress task-management-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ ! -z "$INGRESS_IP" ]; then
        echo "🌐 Access your application:"
        echo "- Frontend: http://$INGRESS_IP"
        echo "- API: http://$INGRESS_IP/api"
        echo "- API Docs: http://$INGRESS_IP/docs"
    else
        echo "🌐 Ingress IP pending... Check with: kubectl get ingress -n $NAMESPACE"
    fi
}

# Rollback function
rollback() {
    echo "🔄 Rolling back deployment..."
    kubectl rollout undo deployment/task-api-python -n $NAMESPACE
    kubectl rollout undo deployment/task-frontend -n $NAMESPACE
    echo "✅ Rollback complete"
}

# Main execution
main() {
    case "${1:-deploy}" in
        "deploy")
            build_and_push
            deploy_database
            deploy_api
            deploy_frontend
            deploy_ingress
            deploy_monitoring
            wait_for_deployments
            show_status
            ;;
        "rollback")
            rollback
            ;;
        "status")
            show_status
            ;;
        *)
            echo "Usage: $0 [deploy|rollback|status] [version]"
            exit 1
            ;;
    esac
}

main "$@"
