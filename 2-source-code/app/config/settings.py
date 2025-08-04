from pydantic import BaseSettings
import os

class Settings(BaseSettings):
    database_url: str = "mysql+pymysql://taskuser:taskpass@localhost:3306/taskdb"
    debug: bool = False
    cors_origins: list = ["*"]
    
    class Config:
        env_file = ".env"

settings = Settings()
