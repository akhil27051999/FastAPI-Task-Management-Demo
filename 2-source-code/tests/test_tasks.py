import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "UP"}

def test_create_task():
    task_data = {
        "title": "Test Task",
        "description": "Test Description",
        "status": "PENDING"
    }
    response = client.post("/api/tasks/", json=task_data)
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == task_data["title"]
    assert data["description"] == task_data["description"]

def test_get_tasks():
    response = client.get("/api/tasks/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
