import redis
import json
from core.config import settings

class TaskService:
    def __init__(self):
        self.redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

    def set_task_status(self, task_id: str, status: str, result: dict | None = None):
        """
        Устанавливает статус задачи в Redis.
        Доступные статусы: 'processing', 'done', 'error'.
        """
        data = {
            "status": status,
            "result": result
        }
        # Задачи живут 1 час
        self.redis_client.setex(f"task:{task_id}", 3600, json.dumps(data))

    def get_task_status(self, task_id: str) -> dict | None:
        """
        Возвращает статус задачи (и результат, если готова).
        """
        data = self.redis_client.get(f"task:{task_id}")
        if data:
            return json.loads(data)
        return None
