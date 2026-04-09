"""
Роутер статусов задач.
GET /api/v1/tasks/{task_id} — проверка статуса AI-задачи.
"""
from fastapi import APIRouter, HTTPException, Depends

from api.dependencies import get_task_service
from services.task_service import TaskService

router = APIRouter()


@router.get("/{task_id}")
async def get_task_status(
    task_id: str,
    task_service: TaskService = Depends(get_task_service),
):
    """
    Возвращает статус задачи из Redis.
    Если status == 'done', также возвращает результат с рецептами и ингредиентами.
    """
    task_data = task_service.get_task_status(task_id)

    if not task_data:
        raise HTTPException(status_code=404, detail="Задача не найдена")

    return {
        "task_id": task_id,
        "status": task_data["status"],
        "result": task_data.get("result"),
    }
