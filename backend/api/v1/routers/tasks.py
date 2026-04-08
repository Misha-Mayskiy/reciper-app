from fastapi import APIRouter, HTTPException
from services.task_service import TaskService

router = APIRouter()

@router.get("/{task_id}")
async def get_task_status(task_id: str):
    """
    Возвращает статус задачи из Redis. Если status == 'done', также возвращает результат.
    """
    task_service = TaskService()
    task_data = task_service.get_task_status(task_id)
    
    if not task_data:
        raise HTTPException(status_code=404, detail="Task not found")
        
    return {
        "task_id": task_id,
        "status": task_data["status"],
        "result": task_data.get("result")
    }
