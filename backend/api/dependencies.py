"""
Централизованный модуль Dependency Injection для FastAPI.
Все зависимости (сервисы, репозитории) создаются здесь и инжектируются через Depends().
"""
from fastapi import Depends
from sqlalchemy.orm import Session

from infrastructure.database import get_db
from services.task_service import TaskService
from services.ai_service import AIService
from services.user_service import UserService
from infrastructure.repositories import (
    UserRepository,
    DailyStatRepository,
    RecipeRepository,
)


# ──────────── Инфраструктурный слой ────────────

def get_task_service() -> TaskService:
    """Провайдер TaskService (Redis)."""
    return TaskService()


# ──────────── Репозитории ────────────

def get_user_repository(db: Session = Depends(get_db)) -> UserRepository:
    """Провайдер UserRepository."""
    return UserRepository(db)


def get_daily_stat_repository(db: Session = Depends(get_db)) -> DailyStatRepository:
    """Провайдер DailyStatRepository."""
    return DailyStatRepository(db)


def get_recipe_repository(db: Session = Depends(get_db)) -> RecipeRepository:
    """Провайдер RecipeRepository."""
    return RecipeRepository(db)


# ──────────── Сервисы ────────────

def get_ai_service(
    task_service: TaskService = Depends(get_task_service),
) -> AIService:
    """Провайдер AIService."""
    return AIService(task_service)


def get_user_service(db: Session = Depends(get_db)) -> UserService:
    """Провайдер UserService."""
    return UserService(db)
