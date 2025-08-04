# Kubernetes Deployment - Python Version

## 🐍 Python Task Management API on Kubernetes

Complete Kubernetes manifests for deploying the Python FastAPI version of the Task Management System.

## 🚀 Quick Deployment

```bash
# Create namespace and deploy all resources
kubectl apply -f 7-kubernetes-python/

# Check deployment status
kubectl get pods -n task-management-python
kubectl get svc -n task-management-python
kubectl get ingress -n task-management-python
```

## 📋 Kubernetes Resources

| Resource | File | Description |
|----------|------|-------------|
| **Namespace** | namespace.yaml | Isolated environment |
| **ConfigMap** | configmap.yaml | Python app configuration |
| **Secret** | secret.yaml | MySQL credentials |
| **MySQL** | mysql-deployment.yaml | Database deployment |
| **MySQL Service** | mysql-service.yaml | Database service |
| **Python API** | task-api-deployment.yaml | FastAPI deployment |
| **API Service** | task-api-service.yaml | API service |
| **Frontend** | frontend-deployment.yaml | Nginx frontend |
| **Frontend Service** | frontend-service.yaml | Frontend service |
| **Ingress** | ingress.yaml | Traffic routing |
| **HPA** | hpa.yaml | Auto-scaling |
| **PDB** | pdb.yaml | High availability |

## 🔧 Configuration Changes for Python

### API Deployment
- **Image**: `task-management-api-python:latest`
- **Port**: 8000 (FastAPI default)
- **Health Check**: `/health` endpoint
- **Environment**: Python-specific variables

### Resource Limits
```yaml
resources:
  requests:
    memory: "128Mi"  # Lower than Java (256Mi)
    cpu: "100m"      # Lower than Java (250m)
  limits:
    memory: "256Mi"  # Lower than Java (512Mi)
    cpu: "200m"      # Lower than Java (500m)
```

### Environment Variables
```yaml
env:
- name: DATABASE_URL
  value: "mysql+pymysql://taskuser:taskpass@mysql-service:3306/taskdb"
- name: PYTHONPATH
  value: "/app"
- name: DEBUG
  value: "False"
```

## 🌐 Access URLs

After deployment, access the application:

```bash
# Add to /etc/hosts
echo "$(kubectl get ingress -n task-management-python -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}') taskmanagement-python.local" >> /etc/hosts

# Access URLs
# Frontend: http://taskmanagement-python.local
# API: http://taskmanagement-python.local/api
# API Docs: http://taskmanagement-python.local/docs
```

## 📊 Monitoring & Scaling

### Horizontal Pod Autoscaler
```bash
# Check HPA status
kubectl get hpa -n task-management-python

# API scaling: 2-10 replicas (70% CPU, 80% memory)
# Frontend scaling: 2-5 replicas (50% CPU)
```

### Pod Disruption Budget
```bash
# Check PDB status
kubectl get pdb -n task-management-python

# Ensures minimum 1 pod always available during updates
```

## 🔍 Troubleshooting

### Check Pod Status
```bash
# View all pods
kubectl get pods -n task-management-python

# Check specific pod logs
kubectl logs -f deployment/task-api-python -n task-management-python
kubectl logs -f deployment/task-frontend -n task-management-python
```

### Database Connection
```bash
# Test MySQL connectivity
kubectl exec -it deployment/mysql -n task-management-python -- mysql -u taskuser -ptaskpass taskdb

# Check database service
kubectl get svc mysql-service -n task-management-python
```

### API Health Check
```bash
# Port forward to test API
kubectl port-forward svc/task-api-service 8000:8000 -n task-management-python

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/api/tasks
curl http://localhost:8000/docs
```

## 🔄 Updates & Rollbacks

### Rolling Updates
```bash
# Update API image
kubectl set image deployment/task-api-python task-api=task-management-api-python:v2.0 -n task-management-python

# Check rollout status
kubectl rollout status deployment/task-api-python -n task-management-python
```

### Rollback
```bash
# Rollback to previous version
kubectl rollout undo deployment/task-api-python -n task-management-python

# Check rollout history
kubectl rollout history deployment/task-api-python -n task-management-python
```

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete namespace task-management-python

# Or delete specific resources
kubectl delete -f 7-kubernetes-python/
```

## 📈 Performance Benefits

### Python vs Java on Kubernetes

| Metric | Python FastAPI | Java Spring Boot |
|--------|----------------|------------------|
| **Memory Request** | 128Mi | 256Mi |
| **Memory Limit** | 256Mi | 512Mi |
| **CPU Request** | 100m | 250m |
| **Startup Time** | 5-10s | 30-60s |
| **Pod Density** | Higher | Lower |

### Cost Optimization
- **50% less memory** usage per pod
- **60% less CPU** usage per pod
- **Higher pod density** on nodes
- **Faster scaling** due to quick startup

## 🎯 Production Considerations

### Security
- Non-root containers
- Resource limits enforced
- Secrets for sensitive data
- Network policies (optional)

### High Availability
- Multiple replicas (2+ for API, 2+ for frontend)
- Pod Disruption Budgets
- Health checks and readiness probes
- Auto-scaling based on metrics

### Monitoring
- Prometheus metrics at `/metrics`
- Health checks at `/health`
- Application logs via kubectl
- Resource usage monitoring

**🐍 Python Kubernetes deployment ready for production!**
