# Troubleshooting Guide - Python FastAPI

## 🐍 Python FastAPI Troubleshooting

Common issues and solutions for the Python FastAPI Task Management System.

## 🚨 Common Issues

### 1. Python Import Errors

#### Issue: ModuleNotFoundError
```bash
ModuleNotFoundError: No module named 'app'
```

**Solutions:**
```bash
# Set PYTHONPATH
export PYTHONPATH=/path/to/project/2-source-code

# Or in Docker
ENV PYTHONPATH=/app

# Check current path
python -c "import sys; print(sys.path)"
```

#### Issue: Relative Import Errors
```bash
ImportError: attempted relative import with no known parent package
```

**Solution:**
```bash
# Run from project root
cd 2-source-code
python -m app.main

# Or use uvicorn
uvicorn app.main:app --reload
```

### 2. Database Connection Issues

#### Issue: Connection Refused
```bash
sqlalchemy.exc.OperationalError: (pymysql.err.OperationalError) (2003, "Can't connect to MySQL server")
```

**Solutions:**
```bash
# Check MySQL status
docker ps | grep mysql
kubectl get pods -l app=mysql

# Test connection
mysql -h localhost -u taskuser -ptaskpass taskdb

# Verify environment variables
echo $DATABASE_URL
```

#### Issue: Authentication Failed
```bash
sqlalchemy.exc.OperationalError: (pymysql.err.OperationalError) (1045, "Access denied for user")
```

**Solutions:**
```bash
# Check credentials in secret
kubectl get secret mysql-secret -o yaml

# Reset MySQL password
kubectl exec -it deployment/mysql -- mysql -u root -prootpassword -e "ALTER USER 'taskuser'@'%' IDENTIFIED BY 'taskpass';"
```

### 3. FastAPI Server Issues

#### Issue: Port Already in Use
```bash
OSError: [Errno 48] Address already in use
```

**Solutions:**
```bash
# Find process using port
lsof -i :8000
netstat -tulpn | grep :8000

# Kill process
kill -9 <PID>

# Use different port
uvicorn app.main:app --port 8001
```

#### Issue: CORS Errors
```bash
Access to fetch at 'http://localhost:8000/api/tasks' from origin 'http://localhost:3001' has been blocked by CORS policy
```

**Solution:**
```python
# app/main.py
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 4. Docker Issues

#### Issue: Build Failures
```bash
ERROR: Could not find a version that satisfies the requirement
```

**Solutions:**
```bash
# Update pip in Dockerfile
RUN pip install --upgrade pip

# Use specific Python version
FROM python:3.11-slim

# Clear Docker cache
docker system prune -f
docker build --no-cache -t api .
```

#### Issue: Container Exits Immediately
```bash
# Check container logs
docker logs task-app-python

# Run interactively
docker run -it task-management-api-python bash

# Check health
docker exec task-app-python curl http://localhost:8000/health
```

### 5. Kubernetes Issues

#### Issue: Pod CrashLoopBackOff
```bash
kubectl describe pod <pod-name> -n task-management-python
kubectl logs <pod-name> -n task-management-python --previous
```

**Common Causes:**
- Missing environment variables
- Database connection failures
- Import errors
- Resource limits too low

**Solutions:**
```bash
# Check environment
kubectl exec -it <pod-name> -n task-management-python -- env

# Increase resources
kubectl patch deployment task-api-python -p '{"spec":{"template":{"spec":{"containers":[{"name":"task-api","resources":{"limits":{"memory":"512Mi"}}}]}}}}'

# Check database connectivity
kubectl exec -it <pod-name> -n task-management-python -- python -c "from app.database.connection import engine; print(engine.execute('SELECT 1').scalar())"
```

#### Issue: Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints -n task-management-python

# Port forward for testing
kubectl port-forward svc/task-api-service 8000:8000 -n task-management-python

# Test connectivity
curl http://localhost:8000/health
```

### 6. Performance Issues

#### Issue: Slow Response Times
```bash
# Check resource usage
kubectl top pods -n task-management-python

# Check database queries
# Add logging to app/services/task_service.py
import logging
logging.basicConfig(level=logging.DEBUG)
```

**Solutions:**
```python
# Optimize database queries
from sqlalchemy.orm import joinedload

def get_all_tasks(db: Session):
    return db.query(Task).options(joinedload(Task.related_field)).all()

# Add connection pooling
engine = create_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True
)
```

#### Issue: High Memory Usage
```bash
# Monitor memory
kubectl top pods -n task-management-python

# Check for memory leaks
docker stats task-app-python
```

**Solutions:**
```python
# Use generators for large datasets
def get_tasks_generator(db: Session):
    for task in db.query(Task).yield_per(100):
        yield task

# Implement pagination
def get_tasks_paginated(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Task).offset(skip).limit(limit).all()
```

## 🔧 Debugging Tools

### 1. Python Debugging
```python
# Add debug logging
import logging
logging.basicConfig(level=logging.DEBUG)

# Use pdb for debugging
import pdb; pdb.set_trace()

# FastAPI debug mode
app = FastAPI(debug=True)
```

### 2. Database Debugging
```python
# Enable SQL logging
import logging
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# Test database connection
from app.database.connection import engine
try:
    connection = engine.connect()
    result = connection.execute("SELECT 1")
    print("Database connected successfully")
except Exception as e:
    print(f"Database connection failed: {e}")
```

### 3. Container Debugging
```bash
# Enter container
docker exec -it task-app-python bash
kubectl exec -it <pod-name> -n task-management-python -- bash

# Check Python environment
python --version
pip list
python -c "import app; print('Import successful')"

# Check network connectivity
curl http://mysql-service:3306
telnet mysql-service 3306
```

### 4. API Debugging
```bash
# Test endpoints
curl -v http://localhost:8000/health
curl -v http://localhost:8000/api/tasks

# Check FastAPI docs
curl http://localhost:8000/docs
curl http://localhost:8000/openapi.json

# Monitor requests
tail -f /var/log/nginx/access.log
```

## 📊 Monitoring & Alerts

### Health Check Script
```bash
#!/bin/bash
# health-check.sh

API_URL="http://localhost:8000"

# Test health endpoint
if curl -f $API_URL/health > /dev/null 2>&1; then
    echo "✅ API health check passed"
else
    echo "❌ API health check failed"
    exit 1
fi

# Test database connectivity
if curl -f $API_URL/api/tasks > /dev/null 2>&1; then
    echo "✅ Database connectivity check passed"
else
    echo "❌ Database connectivity check failed"
    exit 1
fi
```

### Performance Monitoring
```python
# app/middleware/monitoring.py
import time
from fastapi import Request

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response
```

## 🚨 Emergency Procedures

### 1. Service Down
```bash
# Quick restart
kubectl rollout restart deployment/task-api-python -n task-management-python

# Scale up replicas
kubectl scale deployment task-api-python --replicas=5 -n task-management-python

# Check logs
kubectl logs -f deployment/task-api-python -n task-management-python
```

### 2. Database Issues
```bash
# Restart MySQL
kubectl rollout restart deployment/mysql -n task-management-python

# Backup database
kubectl exec deployment/mysql -n task-management-python -- mysqldump -u taskuser -ptaskpass taskdb > backup.sql

# Restore database
kubectl exec -i deployment/mysql -n task-management-python -- mysql -u taskuser -ptaskpass taskdb < backup.sql
```

### 3. High Load
```bash
# Enable auto-scaling
kubectl autoscale deployment task-api-python --cpu-percent=70 --min=2 --max=10 -n task-management-python

# Manual scaling
kubectl scale deployment task-api-python --replicas=10 -n task-management-python

# Check resource usage
kubectl top nodes
kubectl top pods -n task-management-python
```

## 📞 Support Contacts

### Log Locations
- **Application Logs**: `kubectl logs -f deployment/task-api-python`
- **Nginx Logs**: `kubectl logs -f deployment/task-frontend`
- **Database Logs**: `kubectl logs -f deployment/mysql`

### Useful Commands
```bash
# Get all resources
kubectl get all -n task-management-python

# Describe problematic pod
kubectl describe pod <pod-name> -n task-management-python

# Check events
kubectl get events -n task-management-python --sort-by='.lastTimestamp'

# Port forward for debugging
kubectl port-forward svc/task-api-service 8000:8000 -n task-management-python
```

**🐍 Python FastAPI troubleshooting guide for quick issue resolution!**
