# Task Management System - Python Containerization

## 🐳 Docker Setup for Python Backend

Complete containerization setup for the Python FastAPI version of the Task Management System.

## 🚀 Quick Start

```bash
# Start all services
docker compose -f docker-compose.yml up -d

# Check status
docker compose -f docker-compose.yml ps

# View logs
docker compose -f docker-compose.yml logs -f app
```

## 📊 Services

| Service | Port | Description |
|---------|------|-------------|
| **Python API** | 8000 | FastAPI backend |
| **Frontend** | 3001 | Nginx + HTML/CSS/JS |
| **MySQL** | 3306 | Database |
| **Prometheus** | 9090 | Metrics collection |
| **Grafana** | 3000 | Monitoring dashboard |

## 🔧 Configuration Changes

### Backend Changes
- **Port**: 8080 → 8000 (FastAPI default)
- **Image**: Java → Python 3.11-slim
- **Health Check**: `/actuator/health` → `/health`
- **Metrics**: `/actuator/prometheus` → `/metrics`

### Environment Variables
```bash
DATABASE_URL=mysql+pymysql://taskuser:taskpass@mysql:3306/taskdb
PYTHONPATH=/app
```

## 🧪 Testing

```bash
# Test Python API
curl http://localhost:8000/health
curl http://localhost:8000/api/tasks

# Test Frontend
curl http://localhost:3001

# Test API Documentation
curl http://localhost:8000/docs
```

## 📈 Monitoring

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin123)
- **API Docs**: http://localhost:8000/docs

## 🛠️ Development

```bash
# Build only backend
docker compose -f docker-compose.yml build app

# Restart backend
docker compose -f docker-compose.yml restart app

# View backend logs
docker compose -f docker-compose.yml logs -f app
```

## 🎯 Benefits

- **Faster startup**: 2-3 seconds vs 10-15 seconds (Java)
- **Lower memory**: 100-200MB vs 512MB+ (Java)
- **Auto docs**: Interactive API documentation at `/docs`
- **Modern async**: Built-in async/await support
