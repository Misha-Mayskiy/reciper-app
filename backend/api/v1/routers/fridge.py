"""
Роутер сканирования холодильника.
POST /api/v1/fridge/scan — загрузка фото и запуск AI-анализа.
"""
import logging
import uuid

from fastapi import APIRouter, UploadFile, File, BackgroundTasks, Depends, HTTPException

from api.dependencies import get_task_service, get_ai_service
from services.task_service import TaskService
from services.ai_service import AIService

logger = logging.getLogger("reciper.api.fridge")

router = APIRouter()


@router.post("/scan")
async def scan_fridge(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    task_service: TaskService = Depends(get_task_service),
    ai_service: AIService = Depends(get_ai_service),
):
    """
    Принимает фотографию холодильника, ставит фоновую задачу AI-анализа.

    - Использует Redlock для предотвращения дублирования запросов.
    - Возвращает task_id для последующего polling.
    """
    # Redlock: проверяем, нет ли уже активного запроса от пользователя
    user_id = "user_1"  # TODO: получать из auth token
    if not task_service.acquire_user_lock(user_id):
        raise HTTPException(
            status_code=429,
            detail="У вас уже есть активный запрос. Пожалуйста, подождите.",
        )

    task_id = str(uuid.uuid4())

    # Читаем байты изображения
    image_bytes = await file.read()
    logger.info(
        f"Получено изображение: {file.filename} "
        f"({len(image_bytes)} bytes) → task {task_id}"
    )

    # Ставим статус processing
    task_service.set_task_status(task_id, "processing")

    # Запускаем фоновую задачу
    async def _process_and_unlock():
        try:
            await ai_service.process_fridge_image(task_id, image_bytes)
        finally:
            task_service.release_user_lock(user_id)

    background_tasks.add_task(_process_and_unlock)

    return {"task_id": task_id, "status": "processing"}
