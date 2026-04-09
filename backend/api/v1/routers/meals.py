"""
Роутер учёта приёмов пищи.
POST /api/v1/meals/consume — логирование съеденного блюда.
"""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from api.dependencies import get_user_service
from services.user_service import UserService


class ConsumeMealRequest(BaseModel):
    """Запрос на логирование приёма пищи."""
    user_id: str
    recipe_id: str


router = APIRouter()


@router.post("/consume")
async def consume_meal(
    request: ConsumeMealRequest,
    service: UserService = Depends(get_user_service),
):
    """
    Принимает user_id и recipe_id съеденного блюда.
    Добавляет КБЖУ рецепта в DailyStat пользователя на текущую дату.
    """
    try:
        updated_stats = service.consume_meal(request.user_id, request.recipe_id)
        return {
            "status": "success",
            "message": "Приём пищи записан",
            "today_stats": updated_stats,
        }
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
