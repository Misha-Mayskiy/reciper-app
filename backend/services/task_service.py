"""
Сервис управления задачами через Redis.
Хранит статусы фоновых AI-задач (processing, done, error).
"""
import json
import logging
from typing import Optional

import redis
from core.config import settings

logger = logging.getLogger("reciper.task_service")


class TaskService:
    """
    Управляет жизненным циклом асинхронных задач в Redis.

    Задачи хранятся с TTL 1 час и имеют статусы:
    - 'processing' — задача в обработке
    - 'done' — готова, результат доступен
    - 'error' — произошла ошибка
    """

    def __init__(self):
        self.redis_client = redis.from_url(
            settings.REDIS_URL, decode_responses=True
        )

    def set_task_status(
        self,
        task_id: str,
        status: str,
        result: Optional[dict] = None,
    ) -> None:
        """Устанавливает статус задачи в Redis с TTL 1 час."""
        data = {"status": status, "result": result}
        self.redis_client.setex(
            f"task:{task_id}", 3600, json.dumps(data, ensure_ascii=False)
        )
        logger.info(f"Task {task_id}: статус → {status}")

    def get_task_status(self, task_id: str) -> Optional[dict]:
        """Возвращает текущий статус задачи (и результат, если готова)."""
        data = self.redis_client.get(f"task:{task_id}")
        if data:
            return json.loads(data)
        return None

    # ──────────── Redlock для AI-запросов ────────────

    def acquire_user_lock(self, user_id: str) -> bool:
        """
        Пытается захватить блокировку для пользователя.
        Предотвращает дублирование ресурсоёмких AI-запросов.

        Returns:
            True если блокировка получена, False если уже заблокировано.
        """
        lock_key = f"lock:ai:{user_id}"
        acquired = self.redis_client.set(
            lock_key, "1", nx=True, ex=settings.REDLOCK_TTL
        )
        if acquired:
            logger.info(f"🔒 Lock acquired for user {user_id}")
        else:
            logger.warning(f"⚠️ Lock already held for user {user_id}")
        return bool(acquired)

    def release_user_lock(self, user_id: str) -> None:
        """Освобождает блокировку пользователя."""
        lock_key = f"lock:ai:{user_id}"
        self.redis_client.delete(lock_key)
        logger.info(f"🔓 Lock released for user {user_id}")
