"""
Роутер пользователей и статистики.
GET  /api/v1/users/{user_id}/stats — дашборд КБЖУ.
POST /api/v1/users — создание пользователя.
"""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from api.dependencies import get_user_service
from services.user_service import UserService


class CreateUserRequest(BaseModel):
    """Запрос на создание пользователя."""
    name: str
    daily_calories_target: int = 2200
    target_protein: int = 120
    target_fat: int = 70
    target_carbs: int = 280


router = APIRouter()


@router.get("/{user_id}/stats")
async def get_user_stats(
    user_id: str,
    service: UserService = Depends(get_user_service),
):
    """Возвращает агрегированные данные по КБЖУ для дашборда."""
    try:
        stats = service.get_user_dashboard_stats(user_id)
        return stats
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/")
async def create_user(
    request: CreateUserRequest,
    service: UserService = Depends(get_user_service),
):
    """Создаёт нового пользователя с целевыми значениями КБЖУ."""
    user = service.create_user(request.model_dump())
    return {"status": "created", "user": user}
