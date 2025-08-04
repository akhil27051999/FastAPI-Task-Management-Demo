# Local Build & Test - Python Version

## 🐍 Python Development Workflow

Complete local development setup for the Python FastAPI version of the Task Management API.

## 🚀 Quick Start

```bash
# 1. Build and setup environment
cd 6-local-build-test/scripts
chmod +x *.sh
./build.sh

# 2. Run tests
./test.sh

# 3. Start development server
./run-local.sh
```

## 📋 Scripts Overview

### build.sh
- Creates Python virtual environment
- Installs dependencies (production + development)
- Runs code formatting with black
- Performs linting with flake8
- Runs type checking with mypy
- Builds Docker image

### test.sh
- Runs unit tests with pytest
- Generates coverage reports
- Tests API endpoints
- Validates Docker container functionality

### run-local.sh
- Starts FastAPI development server with hot reload
- Configures database connection
- Sets up environment variables
- Provides access URLs and documentation

## 🛠️ Development Environment

### Prerequisites
- **Python 3.11+**
- **MySQL** (via Docker or local installation)
- **Docker** (for containerization)
- **Git** (for version control)

### Virtual Environment
```bash
# Created automatically by build.sh
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or venv\Scripts\activate  # Windows
```

### Dependencies
```bash
# Production dependencies
pip install -r requirements.txt

# Development dependencies
pip install -r requirements-dev.txt
```

## 🧪 Testing

### Unit Tests
```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/test_tasks.py
```

### Coverage Reports
```bash
# Generate coverage report
pytest --cov=app --cov-report=html

# View coverage in browser
open htmlcov/index.html
```

### API Testing
```bash
# Test health endpoint
curl http://localhost:8000/health

# Test tasks API
curl http://localhost:8000/api/tasks

# Interactive API docs
open http://localhost:8000/docs
```

## 🔧 Code Quality

### Formatting
```bash
# Format code with black
black app/

# Check formatting
black app/ --check
```

### Linting
```bash
# Run flake8 linting
flake8 app/ --max-line-length=88
```

### Type Checking
```bash
# Run mypy type checking
mypy app/ --ignore-missing-imports
```

## 🐳 Docker Development

### Build Image
```bash
# Build Docker image
docker build -t task-management-api-python .

# Run container
docker run -p 8000:8000 task-management-api-python
```

### Docker Compose
```bash
# Start full stack
cd ../5-containerization
docker-compose -f docker-compose-python.yml up -d

# View logs
docker-compose -f docker-compose-python.yml logs -f app
```

## 📊 Performance Comparison

| Metric | Python FastAPI | Java Spring Boot |
|--------|----------------|------------------|
| **Startup Time** | 2-3 seconds | 10-15 seconds |
| **Memory Usage** | 100-200MB | 512MB+ |
| **Build Time** | 30-60 seconds | 2-3 minutes |
| **Hot Reload** | ✅ Built-in | ⚠️ Requires tools |
| **API Docs** | ✅ Auto-generated | ⚠️ Manual setup |

## 🌟 Development Features

### Hot Reload
- **Automatic restart** on code changes
- **Fast feedback loop** for development
- **No manual server restarts** needed

### Interactive Documentation
- **Swagger UI** at `/docs`
- **ReDoc** at `/redoc`
- **OpenAPI schema** at `/openapi.json`

### Type Safety
- **Pydantic models** for request/response validation
- **Type hints** throughout codebase
- **MyPy** static type checking

## 🚀 Production Deployment

### Environment Variables
```bash
DATABASE_URL=mysql+pymysql://user:pass@host:port/db
DEBUG=False
CORS_ORIGINS=["https://yourdomain.com"]
```

### Docker Production
```bash
# Build production image
docker build -t task-api-prod .

# Run with environment file
docker run --env-file .env -p 8000:8000 task-api-prod
```

## 📞 Troubleshooting

### Common Issues

#### Virtual Environment Issues
```bash
# Recreate virtual environment
rm -rf venv
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### Database Connection Issues
```bash
# Check MySQL status
docker-compose -f ../5-containerization/docker-compose-python.yml ps mysql

# Reset database
docker-compose -f ../5-containerization/docker-compose-python.yml down -v
docker-compose -f ../5-containerization/docker-compose-python.yml up -d mysql
```

#### Import Errors
```bash
# Set PYTHONPATH
export PYTHONPATH=/path/to/project/2-source-code
```

## 🎯 Next Steps

1. **Development**: Use `run-local.sh` for active development
2. **Testing**: Run `test.sh` before committing changes
3. **Building**: Use `build.sh` for clean builds
4. **Deployment**: Use Docker Compose for full-stack testing

**🐍 Happy Python development!**
