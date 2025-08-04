# Task Management API - Python 

## 🐍 Project Overview

A modern, high-performance task management REST API built with **FastAPI**, **SQLAlchemy**, and **MySQL**. This Python version offers the same enterprise-level features as the Java Spring Boot version but with faster development cycles and modern async capabilities.

## 🚀 Key Features

- **FastAPI Framework** - Modern, fast web framework with automatic API documentation
- **Async/Await Support** - High-performance asynchronous request handling
- **SQLAlchemy ORM** - Powerful database abstraction with migration support
- **Pydantic Validation** - Automatic request/response validation with type hints
- **Auto-Generated Docs** - Interactive OpenAPI/Swagger documentation
- **Docker Containerized** - Production-ready containerization
- **Prometheus Metrics** - Built-in monitoring and observability
- **MySQL Database** - Reliable relational database storage

## 🏗️ Architecture

```
Frontend (React/HTML) → FastAPI Backend → MySQL Database
                              ↓
                        Prometheus Metrics
```

## 🛠️ Technology Stack

- **Backend**: Python 3.11, FastAPI, SQLAlchemy, Alembic
- **Database**: MySQL 8.0
- **Containerization**: Docker, Docker Compose
- **Monitoring**: Prometheus, Grafana
- **Testing**: pytest, httpx
- **Documentation**: Auto-generated OpenAPI/Swagger

## 📊 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks` | Get all tasks |
| POST | `/api/tasks` | Create new task |
| GET | `/api/tasks/{id}` | Get task by ID |
| PUT | `/api/tasks/{id}` | Update task |
| DELETE | `/api/tasks/{id}` | Delete task |
| GET | `/health` | Health check |
| GET | `/docs` | Interactive API documentation |
| GET | `/metrics` | Prometheus metrics |

## 🚀 Quick Start

```bash
# Clone repository
git clone <repository-url>
cd task-management-api-python

# Setup Python environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or venv\Scripts\activate  # Windows

# Install dependencies
cd 2-source-code
pip install -r requirements.txt

# Run development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Access API documentation
# http://localhost:8000/docs
```

## 🐳 Docker Deployment

```bash
# Build and run with Docker Compose
cd 5-containerization
docker-compose up -d

# Access services
# API: http://localhost:8000
# Frontend: http://localhost:3001
# Grafana: http://localhost:3000
```

## 📈 Performance Benefits

- **50% faster development** compared to Java Spring Boot
- **Lower memory footprint** (100-200MB vs 512MB+ for Java)
- **Faster startup time** (2-3 seconds vs 10-15 seconds)
- **Built-in async support** for better concurrency
- **Auto-generated documentation** saves development time

## 🔄 Migration from Java

This Python version maintains **100% API compatibility** with the Java Spring Boot version:
- Same REST endpoints and HTTP methods
- Same request/response JSON formats
- Same database schema and data
- Same Docker Compose configuration
- Same frontend application (no changes needed)

## 📚 Documentation

- **API Documentation**: Auto-generated at `/docs` endpoint
- **Database Schema**: SQLAlchemy models with type hints
- **Development Guide**: Complete setup and development workflow
- **Deployment Guide**: Docker and Kubernetes deployment instructions
- **Testing Guide**: Comprehensive testing with pytest

## 🎯 Use Cases

- **Microservices Architecture** - Lightweight, fast API service
- **Rapid Prototyping** - Quick development and iteration
- **Data-Heavy Applications** - Excellent Python data ecosystem integration
- **Modern Web APIs** - Built-in async support and modern features
- **DevOps Friendly** - Easy containerization and deployment

## 🏆 Why Choose Python Version?

1. **Developer Productivity** - Less boilerplate, more features
2. **Modern Language Features** - Type hints, async/await, dataclasses
3. **Rich Ecosystem** - Extensive libraries for data processing, ML, etc.
4. **Easy Testing** - Simple, powerful testing with pytest
5. **Auto Documentation** - OpenAPI docs generated automatically
6. **Performance** - Async support for high-concurrency scenarios

## 📞 Getting Started

1. **Development**: Follow the Quick Start guide above
2. **Production**: Use Docker Compose for full-stack deployment
3. **Kubernetes**: Apply manifests in `7-kubernetes/` directory
4. **Monitoring**: Access Grafana dashboards for metrics
5. **Testing**: Run `pytest` for comprehensive test coverage

**🚀 Ready to build modern, fast APIs with Python!**
