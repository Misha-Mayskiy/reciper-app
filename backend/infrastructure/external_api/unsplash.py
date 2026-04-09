"""
Интеграция с Unsplash API для получения фотографий блюд.
Используется search_query, сгенерированный нейросетью.
"""
import logging

import httpx
from core.config import settings

logger = logging.getLogger("reciper.unsplash")

# Fallback-изображение, если API недоступен или ключ не указан
DEFAULT_FOOD_IMAGE = (
    "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"
    "?w=600&h=400&fit=crop&q=80"
)


async def fetch_recipe_image(query: str) -> str:
    """
    Выполняет запрос к Unsplash API для поиска картинки по запросу.

    Args:
        query: Поисковый запрос (например, "tomato cheese omelet").

    Returns:
        URL изображения из Unsplash или fallback-URL.
    """
    if not settings.UNSPLASH_ACCESS_KEY:
        logger.warning("UNSPLASH_ACCESS_KEY не указан — используется fallback-изображение")
        return DEFAULT_FOOD_IMAGE

    url = "https://api.unsplash.com/search/photos"
    params = {
        "query": f"{query} food dish",
        "per_page": 1,
        "orientation": "landscape",
    }
    headers = {
        "Authorization": f"Client-ID {settings.UNSPLASH_ACCESS_KEY}"
    }

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(url, params=params, headers=headers)
            response.raise_for_status()
            data = response.json()
            if data.get("results"):
                image_url = data["results"][0]["urls"]["regular"]
                logger.info(f"Unsplash: найдено изображение для «{query}»")
                return image_url
            else:
                logger.warning(f"Unsplash: нет результатов для «{query}»")
    except httpx.TimeoutException:
        logger.error(f"Unsplash: таймаут запроса для «{query}»")
    except httpx.HTTPStatusError as e:
        logger.error(f"Unsplash: HTTP ошибка {e.response.status_code} для «{query}»")
    except Exception as e:
        logger.error(f"Unsplash: неизвестная ошибка для «{query}»: {e}")

    return DEFAULT_FOOD_IMAGE
