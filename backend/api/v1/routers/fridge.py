from fastapi import APIRouter, UploadFile, File, BackgroundTasks
import uuid
from services.task_service import TaskService
from services.ai_service import AIService

router = APIRouter()

@router.post("/scan")
async def scan_fridge(background_tasks: BackgroundTasks, file: UploadFile = File(...)):
    """
    Принимает фотографию холодильника, ставит фоновую задачу анализа ИИ и возвращает task_id.
    """
    task_id = str(uuid.uuid4())
    
    # Инициализируем сервисы
    task_service = TaskService()
    ai_service = AIService(task_service)
    
    # Сразу ставим статус 'processing'
    task_service.set_task_status(task_id, "processing")
    
    # Отправляем в фоновую очередь
    background_tasks.add_task(ai_service.process_fridge_image, task_id)
    
    return {"task_id": task_id, "status": "processing"}
