# Best Practices - Python FastAPI

## 🐍 Python FastAPI Best Practices

Comprehensive best practices guide for developing, deploying, and maintaining the Python FastAPI Task Management System.

## 🏗️ Code Structure & Architecture

### Project Organization
```
2-source-code/
├── app/
│   ├── __init__.py
│   ├── main.py              # Application entry point
│   ├── models/              # SQLAlchemy models
│   ├── schemas/             # Pydantic schemas
│   ├── routers/             # API route handlers
│   ├── services/            # Business logic
│   ├── database/            # Database configuration
│   └── config/              # Application settings
├── tests/                   # Test modules
├── requirements.txt         # Production dependencies
└── requirements-dev.txt     # Development dependencies
```

### Dependency Injection
```python
# app/dependencies.py
from fastapi import Depends
from sqlalchemy.orm import Session
from app.database.connection import get_db

def get_current_user(db: Session = Depends(get_db)):
    # User authentication logic
    pass

# Usage in routes
@router.get("/tasks")
async def get_tasks(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    return TaskService.get_user_tasks(db, current_user.id)
```

## 📊 Database Best Practices

### Model Design
```python
# app/models/task.py
from sqlalchemy import Column, Integer, String, DateTime, Index
from sqlalchemy.sql import func

class Task(Base):
    __tablename__ = "tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False, index=True)
    description = Column(Text)
    status = Column(Enum(TaskStatus), default=TaskStatus.PENDING, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Add indexes for common queries
    __table_args__ = (
        Index('idx_status_created', 'status', 'created_at'),
    )
```

### Query Optimization
```python
# app/services/task_service.py
from sqlalchemy.orm import joinedload, selectinload

class TaskService:
    @staticmethod
    def get_tasks_with_relations(db: Session):
        # Use eager loading to avoid N+1 queries
        return db.query(Task).options(
            joinedload(Task.user),
            selectinload(Task.tags)
        ).all()
    
    @staticmethod
    def get_tasks_paginated(db: Session, skip: int = 0, limit: int = 100):
        # Always implement pagination
        return db.query(Task).offset(skip).limit(limit).all()
```

### Connection Management
```python
# app/database/connection.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Production-ready connection pool
engine = create_engine(
    DATABASE_URL,
    pool_size=20,           # Number of connections to maintain
    max_overflow=30,        # Additional connections when needed
    pool_pre_ping=True,     # Validate connections before use
    pool_recycle=3600,      # Recycle connections every hour
    echo=False              # Set to True for SQL debugging
)
```

## 🔒 Security Best Practices

### Input Validation
```python
# app/schemas/task.py
from pydantic import BaseModel, validator, Field
from typing import Optional

class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=2000)
    
    @validator('title')
    def validate_title(cls, v):
        if not v.strip():
            raise ValueError('Title cannot be empty')
        return v.strip()
    
    @validator('description')
    def validate_description(cls, v):
        if v:
            return v.strip()
        return v
```

### Authentication & Authorization
```python
# app/auth/security.py
from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer
import jwt

security = HTTPBearer()

def verify_token(token: str = Depends(security)):
    try:
        payload = jwt.decode(token.credentials, SECRET_KEY, algorithms=["HS256"])
        return payload
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials"
        )
```

### CORS Configuration
```python
# app/main.py
from fastapi.middleware.cors import CORSMiddleware

# Production CORS settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Specific origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)
```

## 🧪 Testing Best Practices

### Test Structure
```python
# tests/test_tasks.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.database.connection import get_db

# Test database setup
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)

@pytest.fixture
def sample_task():
    return {
        "title": "Test Task",
        "description": "Test Description",
        "status": "PENDING"
    }

def test_create_task(sample_task):
    response = client.post("/api/tasks/", json=sample_task)
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == sample_task["title"]
```

### Test Coverage
```bash
# Run tests with coverage
pytest --cov=app --cov-report=html --cov-report=term

# Aim for 90%+ coverage
pytest --cov=app --cov-fail-under=90
```

## 🚀 Performance Best Practices

### Async Operations
```python
# app/routers/tasks.py
from fastapi import BackgroundTasks

@router.post("/tasks/")
async def create_task(
    task: TaskCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    # Create task synchronously
    new_task = TaskService.create_task(db, task)
    
    # Send notification asynchronously
    background_tasks.add_task(send_notification, new_task.id)
    
    return new_task

async def send_notification(task_id: int):
    # Async notification logic
    pass
```

### Caching
```python
# app/services/cache.py
from functools import lru_cache
import redis

redis_client = redis.Redis(host='redis', port=6379, db=0)

@lru_cache(maxsize=128)
def get_task_stats():
    # Cache expensive calculations
    return calculate_task_statistics()

def get_cached_tasks(user_id: int):
    cache_key = f"user_tasks:{user_id}"
    cached_data = redis_client.get(cache_key)
    
    if cached_data:
        return json.loads(cached_data)
    
    # Fetch from database and cache
    tasks = TaskService.get_user_tasks(user_id)
    redis_client.setex(cache_key, 300, json.dumps(tasks))  # 5 min cache
    return tasks
```

### Response Optimization
```python
# app/schemas/task.py
from pydantic import BaseModel
from typing import List, Optional

class TaskSummary(BaseModel):
    """Lightweight task representation for list views"""
    id: int
    title: str
    status: str
    created_at: datetime

class TaskDetail(TaskSummary):
    """Full task representation for detail views"""
    description: Optional[str]
    updated_at: Optional[datetime]

# Use appropriate schema for each endpoint
@router.get("/tasks/", response_model=List[TaskSummary])
async def get_tasks():
    # Return lightweight data for lists
    pass

@router.get("/tasks/{id}", response_model=TaskDetail)
async def get_task(id: int):
    # Return full data for details
    pass
```

## 🐳 Docker Best Practices

### Multi-stage Dockerfile
```dockerfile
# Build stage
FROM python:3.11-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder
COPY --from=builder /root/.local /root/.local

# Create non-root user
RUN useradd --create-home --shell /bin/bash app

WORKDIR /app
COPY . .
RUN chown -R app:app /app

USER app

# Make sure scripts in .local are usable
ENV PATH=/root/.local/bin:$PATH

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Environment Configuration
```python
# app/config/settings.py
from pydantic import BaseSettings
from typing import List

class Settings(BaseSettings):
    # Database
    database_url: str = "mysql+pymysql://user:pass@localhost/db"
    
    # Security
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # CORS
    cors_origins: List[str] = ["*"]
    
    # Performance
    workers: int = 1
    
    # Monitoring
    enable_metrics: bool = True
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
```

## ☸️ Kubernetes Best Practices

### Resource Management
```yaml
# 7-kubernetes-python/task-api-deployment.yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"

# Horizontal Pod Autoscaler
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

### Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

## 📊 Monitoring Best Practices

### Structured Logging
```python
# app/utils/logging.py
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno
        }
        return json.dumps(log_entry)

# Configure logging
logging.basicConfig(level=logging.INFO)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger = logging.getLogger(__name__)
logger.addHandler(handler)
```

### Metrics Collection
```python
# app/middleware/metrics.py
from prometheus_client import Counter, Histogram, generate_latest
import time

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start_time = time.time()
    
    response = await call_next(request)
    
    duration = time.time() - start_time
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    REQUEST_DURATION.observe(duration)
    
    return response

@app.get("/metrics")
async def get_metrics():
    return Response(generate_latest(), media_type="text/plain")
```

## 🔄 CI/CD Best Practices

### GitHub Actions
```yaml
# .github/workflows/ci-cd-python.yml
name: CI/CD Python FastAPI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.11]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Cache dependencies
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
    
    - name: Run tests
      run: |
        pytest --cov=app --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

### Code Quality Gates
```yaml
# Pre-commit hooks (.pre-commit-config.yaml)
repos:
  - repo: https://github.com/psf/black
    rev: 23.1.0
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        args: [--max-line-length=88]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.0.1
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
```

## 📈 Performance Monitoring

### Key Metrics to Track
- **Response Time**: < 200ms for 95th percentile
- **Throughput**: Requests per second
- **Error Rate**: < 0.1% for production
- **Memory Usage**: < 80% of allocated
- **CPU Usage**: < 70% average
- **Database Connections**: Monitor pool usage

### Alerting Rules
```yaml
# prometheus-alerts.yml
groups:
  - name: fastapi-alerts
    rules:
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
      
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.01
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
```

**🐍 Following these best practices ensures a robust, scalable, and maintainable Python FastAPI application!**
