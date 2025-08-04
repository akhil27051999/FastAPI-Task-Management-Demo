# Task Management API - Python Backend

## 🐍 FastAPI Backend

Modern, high-performance task management REST API built with FastAPI, SQLAlchemy, and MySQL.

## 🚀 Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Access API documentation
http://localhost:8000/docs
```

## 📊 API Endpoints

- `GET /api/tasks` - Get all tasks
- `POST /api/tasks` - Create new task
- `GET /api/tasks/{id}` - Get task by ID
- `PUT /api/tasks/{id}` - Update task
- `DELETE /api/tasks/{id}` - Delete task
- `GET /health` - Health check
- `GET /docs` - Interactive API documentation

## 🧪 Testing

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run tests
pytest

# Run with coverage
pytest --cov=app
```

## 🐳 Docker

```bash
# Build image
docker build -t task-management-api-python .

# Run container
docker run -p 8000:8000 task-management-api-python
```
