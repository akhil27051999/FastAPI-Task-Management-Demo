#!/bin/bash

# Frontend Build Script for Python Task Management System

set -e

REGISTRY=${REGISTRY:-"your-registry"}
VERSION=${VERSION:-"latest"}
BUILD_ENV=${BUILD_ENV:-"production"}

echo "🔨 Building Frontend for Python Backend..."
echo "📦 Registry: $REGISTRY"
echo "🏷️ Version: $VERSION"
echo "🌍 Environment: $BUILD_ENV"

# Navigate to frontend directory
cd 3-frontend

# Update nginx config for Python backend
update_nginx_config() {
    echo "🔧 Updating nginx config for Python backend..."
    
    cat > nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://app:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /docs {
        proxy_pass http://app:8000/docs;
    }
    
    location /metrics {
        proxy_pass http://app:8000/metrics;
    }
}
EOF
    
    echo "✅ Nginx config updated for Python backend (port 8000)"
}

# Validate frontend files
validate_files() {
    echo "📋 Validating frontend files..."
    
    required_files=("src/index.html" "src/css/style.css" "src/js/script.js")
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "❌ Missing required file: $file"
            exit 1
        fi
    done
    
    echo "✅ All required files present"
}

# Build Docker image
build_image() {
    echo "🐳 Building Docker image..."
    
    docker build \
        --build-arg BUILD_ENV=$BUILD_ENV \
        --build-arg VERSION=$VERSION \
        -t $REGISTRY/task-management-frontend:$VERSION \
        -t $REGISTRY/task-management-frontend:latest \
        .
    
    echo "✅ Docker image built successfully"
}

# Test image with Python backend
test_image() {
    echo "🧪 Testing Docker image with Python backend..."
    
    # Start test container
    CONTAINER_ID=$(docker run -d -p 8081:80 $REGISTRY/task-management-frontend:$VERSION)
    
    # Wait for container
    sleep 5
    
    # Test frontend
    if curl -f http://localhost:8081 > /dev/null 2>&1; then
        echo "✅ Frontend container test passed"
    else
        echo "❌ Frontend container test failed"
        docker logs $CONTAINER_ID
        docker stop $CONTAINER_ID
        exit 1
    fi
    
    # Test nginx config
    if docker exec $CONTAINER_ID nginx -t; then
        echo "✅ Nginx configuration test passed"
    else
        echo "❌ Nginx configuration test failed"
        docker stop $CONTAINER_ID
        exit 1
    fi
    
    # Cleanup
    docker stop $CONTAINER_ID
    docker rm $CONTAINER_ID
}

# Push to registry
push_image() {
    echo "📤 Pushing image to registry..."
    
    if [ "$REGISTRY" != "your-registry" ]; then
        docker push $REGISTRY/task-management-frontend:$VERSION
        docker push $REGISTRY/task-management-frontend:latest
        echo "✅ Image pushed to registry"
    else
        echo "⚠️ Skipping push - update REGISTRY variable"
    fi
}

# Generate deployment manifest
generate_manifest() {
    echo "📄 Generating deployment manifest..."
    
    cat > frontend-deployment-python-$VERSION.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-frontend
  labels:
    app: task-frontend
    version: $VERSION
    backend: python
spec:
  replicas: 2
  selector:
    matchLabels:
      app: task-frontend
  template:
    metadata:
      labels:
        app: task-frontend
        version: $VERSION
        backend: python
    spec:
      containers:
      - name: frontend
        image: $REGISTRY/task-management-frontend:$VERSION
        ports:
        - containerPort: 80
        env:
        - name: BUILD_ENV
          value: "$BUILD_ENV"
        - name: BACKEND_TYPE
          value: "python"
        - name: API_PORT
          value: "8000"
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
    
    echo "✅ Deployment manifest generated: frontend-deployment-python-$VERSION.yaml"
}

# Show build info
show_info() {
    echo ""
    echo "📊 Build Information:"
    echo "Image: $REGISTRY/task-management-frontend:$VERSION"
    echo "Backend: Python FastAPI (port 8000)"
    echo "Size: $(docker images $REGISTRY/task-management-frontend:$VERSION --format "table {{.Size}}" | tail -n 1)"
    echo "Created: $(docker images $REGISTRY/task-management-frontend:$VERSION --format "table {{.CreatedAt}}" | tail -n 1)"
    echo ""
    echo "🚀 Next Steps:"
    echo "1. Test locally: docker run -p 3001:80 $REGISTRY/task-management-frontend:$VERSION"
    echo "2. Deploy to K8s: kubectl apply -f frontend-deployment-python-$VERSION.yaml"
    echo "3. Access frontend: http://localhost:3001"
    echo "4. API docs via frontend: http://localhost:3001/docs"
}

# Main execution
main() {
    case "${1:-build}" in
        "build")
            update_nginx_config
            validate_files
            build_image
            test_image
            generate_manifest
            show_info
            ;;
        "push")
            update_nginx_config
            validate_files
            build_image
            test_image
            push_image
            generate_manifest
            show_info
            ;;
        "test")
            test_image
            ;;
        *)
            echo "Usage: $0 [build|push|test]"
            echo ""
            echo "Environment Variables:"
            echo "  REGISTRY - Docker registry (default: your-registry)"
            echo "  VERSION  - Image version (default: latest)"
            echo "  BUILD_ENV - Build environment (default: production)"
            echo ""
            echo "Examples:"
            echo "  $0 build"
            echo "  REGISTRY=myregistry.com VERSION=v1.2.3 $0 push"
            exit 1
            ;;
    esac
}

main "$@"
