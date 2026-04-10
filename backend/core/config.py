"""
Конфигурация приложения Reciper.
Все параметры берутся из переменных окружения или .env файла.
"""
import logging
import openai
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Основные настройки приложения."""

    PROJECT_NAME: str = "Reciper MVP"

    # Database
    DATABASE_URL: str = "sqlite:///./reciper.db"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    REDLOCK_TTL: int = 60  # Время блокировки AI-запроса (секунды)

    # Unsplash API
    UNSPLASH_ACCESS_KEY: str = ""

    # Ollama / llama.cpp (OpenAI-compatible API)
    OLLAMA_BASE_URL: str = "http://localhost:11434"
    OLLAMA_MODEL: str = "llava:7b"

    # Логирование
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        client = openai.OpenAI(
            api_key="sk",#TODO: убрать хард-код
            base_url="https://api.vsellm.ru/v1"
        )


settings = Settings()

# Настройка логирования
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO),
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

logger = logging.getLogger("reciper")
