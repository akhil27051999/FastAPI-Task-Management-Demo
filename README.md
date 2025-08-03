# Task Management API - Python Version

## 🐍 Updated Project Structure

```
task-management-api-python/
├── 1-project-overview/
│   └── README.md
├── 2-source-code/                          # Python Backend (FastAPI/Flask)
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                         # FastAPI application entry
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   └── task.py                     # SQLAlchemy models
│   │   ├── routers/
│   │   │   ├── __init__.py
│   │   │   └── tasks.py                    # API routes
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   └── task_service.py             # Business logic
│   │   ├── database/
│   │   │   ├── __init__.py
│   │   │   ├── connection.py               # Database connection
│   │   │   └── migrations/                 # Alembic migrations
│   │   ├── schemas/
│   │   │   ├── __init__.py
│   │   │   └── task.py                     # Pydantic schemas
│   │   └── config/
│   │       ├── __init__.py
│   │       └── settings.py                 # Configuration
│   ├── tests/
│   │   ├── __init__.py
│   │   ├── test_tasks.py                   # API tests
│   │   └── test_models.py                  # Model tests
│   ├── requirements.txt                    # Python dependencies
│   ├── requirements-dev.txt                # Development dependencies
│   ├── Dockerfile                          # Python container
│   ├── .env.example                        # Environment variables
│   ├── alembic.ini                         # Database migrations
│   └── README.md
├── 3-frontend/                             # Same as Java version
│   ├── src/
│   │   ├── index.html
│   │   ├── css/style.css
│   │   └── js/script.js
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── 4-cloudformation-setup/                 # Same infrastructure
│   ├── 01-vpc-stack.yaml
│   ├── 02-ec2-stack.yaml
│   └── 03-eks-stack.yaml
├── 5-containerization/
│   ├── docker-compose.yml                  # Updated for Python
│   ├── prometheus.yml
│   └── README.md
├── 6-local-build-test/
│   ├── scripts/
│   │   ├── build.sh                        # Updated for Python
│   │   ├── test.sh                         # Python testing
│   │   └── run-local.sh                    # Python dev server
│   └── README.md
├── 7-kubernetes/
│   ├── task-api-deployment.yaml            # Updated Python image
│   ├── task-api-service.yaml               # Same service config
│   ├── frontend-deployment.yaml            # Same frontend
│   ├── mysql-deployment.yaml               # Same database
│   └── ingress.yaml
├── 8-cicd/
│   ├── github-actions/
│   │   └── ci-cd-pipeline.yml              # Updated for Python
│   └── jenkins/
│       └── Jenkinsfile                     # Updated for Python
├── 9-monitoring/
│   ├── prometheus/
│   │   └── prometheus-config.yaml          # Updated Python metrics
│   ├── grafana/
│   └── load-testing/
│       └── locust/
│           └── locustfile.py               # Python load testing
├── 10-documentation/
│   ├── python-api-guide.md                 # Python-specific docs
│   ├── fastapi-documentation.md            # FastAPI guide
│   └── deployment-guide.md
└── README.md
```

## 🔄 Key Changes from Java to Python

### 1. Backend Framework Options

#### Option A: FastAPI (Recommended)
```python
# app/main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.routers import tasks
from app.database.connection import engine
from app.models import task

app = FastAPI(title="Task Management API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tasks.router, prefix="/api")

@app.get("/health")
async def health_check():
    return {"status": "UP"}
```

#### Option B: Flask
```python
# app/main.py
from flask import Flask
from flask_cors import CORS
from app.routers.tasks import tasks_bp

app = Flask(__name__)
CORS(app)

app.register_blueprint(tasks_bp, url_prefix='/api')

@app.route('/health')
def health_check():
    return {"status": "UP"}
```

### 2. Dependencies File

#### requirements.txt
```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
alembic==1.12.1
pymysql==1.1.0
pydantic==2.5.0
python-multipart==0.0.6
prometheus-client==0.19.0
python-dotenv==1.0.0
```

#### requirements-dev.txt
```txt
pytest==7.4.3
pytest-asyncio==0.21.1
httpx==0.25.2
black==23.11.0
flake8==6.1.0
mypy==1.7.1
```

### 3. Database Models (SQLAlchemy)

```python
# app/models/task.py
from sqlalchemy import Column, Integer, String, Text, DateTime, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
import enum

Base = declarative_base()

class TaskStatus(enum.Enum):
    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"

class Task(Base):
    __tablename__ = "tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    status = Column(Enum(TaskStatus), default=TaskStatus.PENDING)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
```

### 4. API Routes (FastAPI)

```python
# app/routers/tasks.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database.connection import get_db
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse
from app.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["tasks"])

@router.get("/", response_model=List[TaskResponse])
async def get_tasks(db: Session = Depends(get_db)):
    return TaskService.get_all_tasks(db)

@router.post("/", response_model=TaskResponse)
async def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    return TaskService.create_task(db, task)

@router.get("/{task_id}", response_model=TaskResponse)
async def get_task(task_id: int, db: Session = Depends(get_db)):
    task = TaskService.get_task(db, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.put("/{task_id}", response_model=TaskResponse)
async def update_task(task_id: int, task: TaskUpdate, db: Session = Depends(get_db)):
    updated_task = TaskService.update_task(db, task_id, task)
    if not updated_task:
        raise HTTPException(status_code=404, detail="Task not found")
    return updated_task

@router.delete("/{task_id}")
async def delete_task(task_id: int, db: Session = Depends(get_db)):
    if not TaskService.delete_task(db, task_id):
        raise HTTPException(status_code=404, detail="Task not found")
    return {"message": "Task deleted successfully"}
```

### 5. Pydantic Schemas

```python
# app/schemas/task.py
from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from app.models.task import TaskStatus

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    status: TaskStatus = TaskStatus.PENDING

class TaskCreate(TaskBase):
    pass

class TaskUpdate(TaskBase):
    pass

class TaskResponse(TaskBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True
```

### 6. Updated Dockerfile

```dockerfile
# 2-source-code/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
RUN chown -R app:app /app
USER app

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 7. Updated Docker Compose

```yaml
# 5-containerization/docker-compose.yml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: task-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: taskdb
      MYSQL_USER: taskuser
      MYSQL_PASSWORD: taskpass
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - task-network

  app:
    build: ../2-source-code
    container_name: task-app
    depends_on:
      - mysql
    environment:
      DATABASE_URL: mysql+pymysql://taskuser:taskpass@mysql:3306/taskdb
      PYTHONPATH: /app
    ports:
      - "8000:8000"  # Changed from 8080 to 8000
    networks:
      - task-network

  frontend:
    build: ../3-frontend
    container_name: task-frontend
    depends_on:
      - app
    ports:
      - "3001:80"
    networks:
      - task-network

  prometheus:
    image: prom/prometheus:latest
    container_name: task-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - task-network

  grafana:
    image: grafana/grafana:latest
    container_name: task-grafana
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin123
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - task-network

volumes:
  mysql_data:
  grafana_data:

networks:
  task-network:
    driver: bridge
```

### 8. Updated Frontend JavaScript

```javascript
// 3-frontend/src/js/script.js - Update API base URL
const API_BASE_URL = '/api';  // Same, but backend now runs on port 8000

// All other frontend code remains the same
```

### 9. Updated Nginx Configuration

```nginx
# 3-frontend/nginx.conf
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://app:8000/api/;  # Changed port from 8080 to 8000
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 10. Updated CI/CD Pipeline

```yaml
# 8-cicd/github-actions/ci-cd-pipeline.yml
name: CI/CD Pipeline - Python

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python 3.11
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        cd 2-source-code
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
    
    - name: Run tests
      run: |
        cd 2-source-code
        pytest

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push backend
      uses: docker/build-push-action@v4
      with:
        context: ./2-source-code
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/task-management-api-python:${{ github.sha }}
    
    - name: Build and push frontend
      uses: docker/build-push-action@v4
      with:
        context: ./3-frontend
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/task-management-frontend:${{ github.sha }}
```

### 11. Updated Prometheus Configuration

```yaml
# 9-monitoring/prometheus/prometheus-config.yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'task-management-api-python'
    static_configs:
      - targets: ['app:8000']  # Changed port
    metrics_path: '/metrics'   # FastAPI metrics endpoint
    scrape_interval: 30s

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

## 🚀 Migration Steps

### 1. Setup Python Environment
```bash
# Create new Python project
mkdir task-management-api-python
cd task-management-api-python

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt
```

### 2. Database Migration
```bash
# Initialize Alembic
alembic init alembic

# Create migration
alembic revision --autogenerate -m "Create tasks table"

# Apply migration
alembic upgrade head
```

### 3. Run Development Server
```bash
# FastAPI development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Or Flask development server
flask run --host 0.0.0.0 --port 8000
```

### 4. Testing
```bash
# Run tests
pytest

# Run with coverage
pytest --cov=app

# API testing
curl http://localhost:8000/api/tasks
curl http://localhost:8000/health
```

## 📊 Comparison: Java vs Python

| Aspect | Java (Spring Boot) | Python (FastAPI) |
|--------|-------------------|------------------|
| **Performance** | Higher throughput | Good performance, async support |
| **Development Speed** | Moderate | Faster development |
| **Type Safety** | Strong typing | Optional typing with Pydantic |
| **Ecosystem** | Mature enterprise | Rich data science ecosystem |
| **Memory Usage** | Higher | Lower |
| **Learning Curve** | Steeper | Gentler |
| **Deployment** | JAR files | Python packages |
| **Monitoring** | Actuator | Custom metrics |

## 🎯 Benefits of Python Version

- **Faster Development**: Less boilerplate code
- **Better Documentation**: Auto-generated OpenAPI docs
- **Async Support**: Built-in async/await
- **Data Science Integration**: Easy ML/AI integration
- **Simpler Deployment**: Lighter containers
- **Modern Features**: Latest Python language features

**🐍 The Python version maintains all the same functionality while offering faster development and modern async capabilities!**
