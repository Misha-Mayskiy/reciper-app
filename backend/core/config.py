"""
Конфигурация приложения Reciper.
Все параметры берутся из переменных окружения или .env файла.
"""

import logging
from typing import Optional
from openai import OpenAI
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Основные настройки приложения."""

    PROJECT_NAME: str = "Reciper MVP"

    APP_DOMAIN: str = "http://localhost:8000"

    # Database
    DATABASE_URL: str = "sqlite:///./reciper.db"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    REDLOCK_TTL: int = 60  # Время блокировки AI-запроса (секунды)

    # Unsplash API
    UNSPLASH_ACCESS_KEY: str = ""

    # Основной AI (vsellm.ru или любой OpenAI-совместимый)
    OPENAI_API_KEY: Optional[str] = None
    OPENAI_BASE_URL: str = "https://api.vsellm.ru/v1"

    # Ollama / llama.cpp (Fallback)
    OLLAMA_BASE_URL: str = "http://localhost:11434"
    OLLAMA_MODEL: str = "moondream"  # Используем легкую модель

    # Логирование
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        # Позволяет добавлять атрибуты динамически (например, client)
        extra = "allow"


settings = Settings()

# Инициализируем клиента OpenAI только если есть ключ
if settings.OPENAI_API_KEY:
    settings.client = OpenAI(
        api_key=settings.OPENAI_API_KEY,
        base_url=settings.OPENAI_BASE_URL,
        # Раскомментируй, если нужен прокси:
        # http_client=httpx.Client(
        #     mounts={
        #         "http://": httpx.HTTPTransport(proxy="http://ТВОЙ_ПРОКСИ"),
        #         "https://": httpx.HTTPTransport(proxy="http://ТВОЙ_ПРОКСИ"),
        #     },
        #     timeout=60.0,
        # ),
    )
else:
    settings.client = None

# Настройка логирования
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO),
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

logger = logging.getLogger("reciper")
