"""
Интеграция с Unsplash API для получения фотографий блюд.
Бэкенд скачивает картинку и отдает локальный URL, чтобы обойти блокировки на клиенте.
"""

import logging
import os
import uuid
import httpx

from core.config import settings

logger = logging.getLogger("reciper.unsplash")

MEDIA_DIR = "media"
os.makedirs(MEDIA_DIR, exist_ok=True)

# Дефолтная картинка (если API не нашло)
DEFAULT_FOOD_IMAGE_URL = (
    "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"
    "?w=600&h=400&fit=crop&q=80"
)


async def _download_and_save_image(
    client: httpx.AsyncClient, url: str, query: str
) -> str:
    """Скачивает картинку по URL и сохраняет в папку media."""
    try:
        response = await client.get(url, follow_redirects=True)
        response.raise_for_status()

        # Генерируем уникальное имя файла
        filename = f"{uuid.uuid4().hex}.jpg"
        filepath = os.path.join(MEDIA_DIR, filename)

        # Сохраняем на диск
        with open(filepath, "wb") as f:
            f.write(response.content)

        logger.info(f"Unsplash: Картинка для «{query}» успешно скачана ({filename})")

        # Возвращаем URL нашего бэкенда
        return f"{settings.APP_DOMAIN}/media/{filename}"

    except Exception as e:
        logger.error(f"Unsplash: Ошибка скачивания картинки для «{query}»: {e}")
        return ""


async def fetch_recipe_image(query: str) -> str:
    """
    Выполняет поиск в Unsplash, скачивает результат и возвращает локальный URL.
    """
    image_url = DEFAULT_FOOD_IMAGE_URL

    # Если твой сервер в РФ и Unsplash заблокирован даже для бэкенда,
    # раскомментируй proxy_mounts и добавь их в httpx.AsyncClient(mounts=proxies)
    # proxies = {
    #     "http://": httpx.HTTPTransport(proxy="http://ТВОЙ_ПРОКСИ"),
    #     "https://": httpx.HTTPTransport(proxy="http://ТВОЙ_ПРОКСИ"),
    # }

    async with httpx.AsyncClient(timeout=15.0) as client:
        # 1. Пытаемся найти картинку через API
        if settings.UNSPLASH_ACCESS_KEY:
            api_url = "https://api.unsplash.com/search/photos"
            params = {
                "query": f"{query} food dish",
                "per_page": 1,
                "orientation": "landscape",
            }
            headers = {"Authorization": f"Client-ID {settings.UNSPLASH_ACCESS_KEY}"}

            try:
                api_resp = await client.get(api_url, params=params, headers=headers)
                api_resp.raise_for_status()
                data = api_resp.json()
                if data.get("results"):
                    image_url = data["results"][0]["urls"]["regular"]
            except Exception as e:
                logger.error(f"Unsplash: Ошибка поиска API для «{query}»: {e}")

        # 2. Скачиваем найденную (или дефолтную) картинку на наш сервер
        local_backend_url = await _download_and_save_image(client, image_url, query)

        if local_backend_url:
            return local_backend_url

        # 3. Если скачивание упало, возвращаем хотя бы оригинальный URL как последний шанс
        return image_url
