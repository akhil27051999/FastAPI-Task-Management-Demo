# Deployment Guide - Python FastAPI

## 🐍 Complete Deployment Guide

Comprehensive deployment guide for the Python FastAPI Task Management System with frontend integration.

## 🏗️ Architecture Overview

```
Internet → Load Balancer → Ingress → Frontend (Nginx) → Python FastAPI → MySQL
                                   ↓
                              Monitoring Stack
```

## 🚀 Quick Deployment

### Local Development
```bash
# Start with Docker Compose
cd 5-containerization
docker-compose -f docker-compose-python.yml up -d

# Access services
# Frontend: http://localhost:3001
# API: http://localhost:8000
# Docs: http://localhost:8000/docs
```

### Production Kubernetes
```bash
# Deploy to Kubernetes
kubectl apply -f 7-kubernetes-python/

# Check status
kubectl get pods -n task-management-python
```

## 🐳 Docker Deployment

### Build Images
```bash
# Build Python API
cd 2-source-code
docker build -t task-management-api-python:latest .

# Build Frontend
cd ../3-frontend
docker build -t task-management-frontend:latest .
```

### Docker Compose Configuration
```yaml
# docker-compose-python.yml
services:
  app:
    image: task-management-api-python:latest
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: mysql+pymysql://taskuser:taskpass@mysql:3306/taskdb
      PYTHONPATH: /app
    
  frontend:
    image: task-management-frontend:latest
    ports:
      - "3001:80"
    depends_on:
      - app
```

## ☸️ Kubernetes Deployment

### Prerequisites
```bash
# Create namespace
kubectl create namespace task-management-python

# Create secrets
kubectl create secret generic mysql-secret \
  --from-literal=username=taskuser \
  --from-literal=password=taskpass \
  -n task-management-python
```

### Deployment Steps
```bash
# 1. Deploy database
kubectl apply -f 7-kubernetes-python/mysql-deployment.yaml
kubectl apply -f 7-kubernetes-python/mysql-service.yaml

# 2. Deploy Python API
kubectl apply -f 7-kubernetes-python/task-api-deployment.yaml
kubectl apply -f 7-kubernetes-python/task-api-service.yaml

# 3. Deploy frontend
kubectl apply -f 7-kubernetes-python/frontend-deployment.yaml
kubectl apply -f 7-kubernetes-python/frontend-service.yaml

# 4. Configure ingress
kubectl apply -f 7-kubernetes-python/ingress.yaml

# 5. Setup monitoring
kubectl apply -f 9-monitoring/prometheus/
kubectl apply -f 9-monitoring/grafana/
```

### Resource Configuration
```yaml
# Python API resources (optimized)
resources:
  requests:
    memory: "128Mi"  # 50% less than Java
    cpu: "100m"      # 60% less than Java
  limits:
    memory: "256Mi"
    cpu: "200m"
```

## 🌐 Environment Configuration

### Development
```bash
# .env
DATABASE_URL=mysql+pymysql://taskuser:taskpass@localhost:3306/taskdb
DEBUG=True
CORS_ORIGINS=["http://localhost:3001"]
```

### Staging
```bash
# ConfigMap
DATABASE_URL=mysql+pymysql://taskuser:taskpass@mysql-service:3306/taskdb
DEBUG=False
CORS_ORIGINS=["https://staging.yourdomain.com"]
```

### Production
```bash
# ConfigMap
DATABASE_URL=mysql+pymysql://taskuser:taskpass@mysql-service:3306/taskdb
DEBUG=False
CORS_ORIGINS=["https://yourdomain.com"]
```

## 📊 Scaling Configuration

### Horizontal Pod Autoscaler
```yaml
# HPA for Python API
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Manual Scaling
```bash
# Scale Python API
kubectl scale deployment task-api-python --replicas=5 -n task-management-python

# Scale frontend
kubectl scale deployment task-frontend --replicas=3 -n task-management-python
```

## 🔍 Health Checks

### Application Health
```bash
# Python API health
curl http://localhost:8000/health

# Frontend health
curl http://localhost:3001/

# Database connectivity
kubectl exec -it deployment/mysql -n task-management-python -- \
  mysql -u taskuser -ptaskpass -e "SELECT 1"
```

### Kubernetes Probes
```yaml
# Liveness probe
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 10

# Readiness probe
readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
```

## 📈 Performance Optimization

### Python FastAPI Optimizations
```python
# app/main.py
import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        workers=4,  # Multi-worker for production
        loop="uvloop",  # Faster event loop
        http="httptools"  # Faster HTTP parser
    )
```

### Database Optimization
```python
# app/database/connection.py
engine = create_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

### Frontend Optimization
```nginx
# nginx.conf
gzip on;
gzip_types text/css application/javascript application/json;

location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 🔒 Security Configuration

### Container Security
```dockerfile
# Use non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

# Security scanning
RUN pip install safety
RUN safety check
```

### Network Security
```yaml
# Network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: task-api-netpol
spec:
  podSelector:
    matchLabels:
      app: task-api-python
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: task-frontend
```

## 📊 Monitoring Setup

### Prometheus Configuration
```yaml
# prometheus-config-python.yaml
scrape_configs:
  - job_name: 'task-management-api-python'
    static_configs:
      - targets: ['app:8000']
    metrics_path: '/metrics'
```

### Grafana Dashboards
```bash
# Import Python-specific dashboards
curl -X POST http://grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @frontend-dashboard.json
```

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
# .github/workflows/deploy-python.yml
- name: Deploy to Kubernetes
  run: |
    kubectl set image deployment/task-api-python \
      task-api=task-management-api-python:${{ github.sha }} \
      -n task-management-python
```

### ArgoCD
```yaml
# argocd/application-python.yaml
spec:
  source:
    repoURL: https://github.com/your-org/task-management-api-python
    path: 7-kubernetes-python
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 🧪 Testing Deployment

### Smoke Tests
```bash
# Test API endpoints
curl -f http://your-domain.com/health
curl -f http://your-domain.com/api/tasks

# Test frontend
curl -f http://your-domain.com/

# Test documentation
curl -f http://your-domain.com/docs
```

### Load Testing
```bash
# Using K6
k6 run 9-monitoring/load-testing/k6/load-test.js

# Using Locust
kubectl apply -f 9-monitoring/load-testing/locust/
```

## 🚨 Troubleshooting

### Common Issues

#### Python Import Errors
```bash
# Check PYTHONPATH
kubectl exec -it deployment/task-api-python -n task-management-python -- \
  python -c "import sys; print(sys.path)"

# Fix in deployment
env:
- name: PYTHONPATH
  value: "/app"
```

#### Database Connection Issues
```bash
# Test database connectivity
kubectl exec -it deployment/task-api-python -n task-management-python -- \
  python -c "from app.database.connection import engine; print(engine.execute('SELECT 1').scalar())"
```

#### Performance Issues
```bash
# Check resource usage
kubectl top pods -n task-management-python

# Scale if needed
kubectl scale deployment task-api-python --replicas=5
```

## 📈 Performance Comparison

### Python vs Java Deployment

| Metric | Python FastAPI | Java Spring Boot |
|--------|----------------|------------------|
| **Startup Time** | 5-10 seconds | 30-60 seconds |
| **Memory Usage** | 128-256MB | 512MB-1GB |
| **CPU Usage** | 100-200m | 250-500m |
| **Image Size** | 200-300MB | 500MB-1GB |
| **Build Time** | 2-3 minutes | 5-10 minutes |

### Cost Optimization
- **50% less memory** per pod
- **60% less CPU** per pod
- **Higher pod density** on nodes
- **Faster scaling** response

## 🎯 Production Checklist

### Pre-Deployment
- [ ] Environment variables configured
- [ ] Secrets created
- [ ] Resource limits set
- [ ] Health checks configured
- [ ] Monitoring setup

### Post-Deployment
- [ ] Health checks passing
- [ ] Metrics being collected
- [ ] Logs being aggregated
- [ ] Auto-scaling working
- [ ] Backup strategy in place

**🐍 Python FastAPI deployment ready for production with optimal performance!**
