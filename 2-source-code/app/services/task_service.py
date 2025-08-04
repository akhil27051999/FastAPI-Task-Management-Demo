from sqlalchemy.orm import Session
from app.models.task import Task
from app.schemas.task import TaskCreate, TaskUpdate

class TaskService:
    @staticmethod
    def get_all_tasks(db: Session):
        return db.query(Task).all()
    
    @staticmethod
    def get_task(db: Session, task_id: int):
        return db.query(Task).filter(Task.id == task_id).first()
    
    @staticmethod
    def create_task(db: Session, task: TaskCreate):
        db_task = Task(**task.dict())
        db.add(db_task)
        db.commit()
        db.refresh(db_task)
        return db_task
    
    @staticmethod
    def update_task(db: Session, task_id: int, task: TaskUpdate):
        db_task = db.query(Task).filter(Task.id == task_id).first()
        if db_task:
            for key, value in task.dict(exclude_unset=True).items():
                setattr(db_task, key, value)
            db.commit()
            db.refresh(db_task)
        return db_task
    
    @staticmethod
    def delete_task(db: Session, task_id: int):
        db_task = db.query(Task).filter(Task.id == task_id).first()
        if db_task:
            db.delete(db_task)
            db.commit()
            return True
        return False
