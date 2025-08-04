from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import tasks
from app.database.connection import engine
from app.models import task

# Create database tables
task.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Task Management API",
    description="A modern task management REST API built with FastAPI",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tasks.router, prefix="/api")

@app.get("/health")
async def health_check():
    return {"status": "UP"}

@app.get("/")
async def root():
    return {"message": "Task Management API", "docs": "/docs"}
