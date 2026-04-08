from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Reciper MVP"
    DATABASE_URL: str = "sqlite:///./reciper.db"
    REDIS_URL: str = "redis://localhost:6379/0"
    UNSPLASH_ACCESS_KEY: str = ""

    class Config:
        env_file = ".env"

settings = Settings()
