# API Documentation - Python FastAPI

## 🐍 FastAPI REST API Reference

Complete API documentation for the Python FastAPI version of the Task Management System.

## 🚀 Base URL

```
Production: http://your-domain.com/api
Local: http://localhost:8000/api
Development: http://localhost:8000
```

## 📚 Interactive Documentation

FastAPI provides automatic interactive documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/openapi.json

## 📊 Endpoints

### Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "UP"
}
```

### Get All Tasks
```http
GET /api/tasks
```

**Response:**
```json
[
  {
    "id": 1,
    "title": "Implement user authentication API",
    "description": "Create JWT-based authentication system",
    "status": "PENDING",
    "created_at": "2025-08-03T13:11:12.529388",
    "updated_at": "2025-08-03T13:11:12.529404"
  }
]
```

### Get Task by ID
```http
GET /api/tasks/{id}
```

**Parameters:**
- `id` (integer): Task ID

**Response:**
```json
{
  "id": 1,
  "title": "Task Title",
  "description": "Task Description",
  "status": "PENDING",
  "created_at": "2025-08-03T13:11:12.529388",
  "updated_at": "2025-08-03T13:11:12.529404"
}
```

### Create Task
```http
POST /api/tasks
Content-Type: application/json

{
  "title": "New Task",
  "description": "Task description",
  "status": "PENDING"
}
```

**Response:**
```json
{
  "id": 2,
  "title": "New Task",
  "description": "Task description",
  "status": "PENDING",
  "created_at": "2025-08-03T14:00:00.000000",
  "updated_at": "2025-08-03T14:00:00.000000"
}
```

### Update Task
```http
PUT /api/tasks/{id}
Content-Type: application/json

{
  "title": "Updated Task",
  "description": "Updated description",
  "status": "COMPLETED"
}
```

### Delete Task
```http
DELETE /api/tasks/{id}
```

**Response:**
```json
{
  "message": "Task deleted successfully"
}
```

## 🔧 Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 404 | Not Found |
| 422 | Validation Error |
| 500 | Internal Server Error |

## 📝 Data Models

### Task Status Enum
```python
class TaskStatus(enum.Enum):
    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
```

### Task Schema
```python
{
  "id": integer,
  "title": string (required),
  "description": string (optional),
  "status": TaskStatus (default: PENDING),
  "created_at": datetime,
  "updated_at": datetime
}
```

## 🧪 Testing Examples

### cURL Examples
```bash
# Get all tasks
curl -X GET http://localhost:8000/api/tasks

# Create task
curl -X POST http://localhost:8000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Task", "description": "Testing API", "status": "PENDING"}'

# Update task
curl -X PUT http://localhost:8000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Task", "status": "COMPLETED"}'

# Delete task
curl -X DELETE http://localhost:8000/api/tasks/1
```

### Python Requests
```python
import requests

base_url = "http://localhost:8000/api"

# Get all tasks
response = requests.get(f"{base_url}/tasks")
tasks = response.json()

# Create task
task_data = {
    "title": "Python API Test",
    "description": "Testing with requests library",
    "status": "PENDING"
}
response = requests.post(f"{base_url}/tasks", json=task_data)
new_task = response.json()
```

## 📊 Metrics Endpoint

```http
GET /metrics
```

Prometheus-compatible metrics for monitoring:
- HTTP request counts
- Response times
- Error rates
- Active connections
