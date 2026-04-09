"""
AI-сервис: анализ изображений и генерация рецептов.
Использует Ollama/llama.cpp (OpenAI-совместимый API) или mock-данные.
"""
import asyncio
import json
import logging
from typing import Optional

import httpx

from core.config import settings
from infrastructure.database import SessionLocal
from infrastructure.external_api.unsplash import fetch_recipe_image
from infrastructure.repositories import RecipeRepository
from services.task_service import TaskService

logger = logging.getLogger("reciper.ai_service")

# Промпт для Vision-модели
SYSTEM_PROMPT = """You are a professional chef AI assistant. You analyze photos of fridge contents.

Given an image, you must:
1. Identify all visible food ingredients
2. Generate 3-5 recipe suggestions using those ingredients

Respond ONLY with valid JSON in this exact format:
{
  "ingredients": ["ingredient1", "ingredient2", ...],
  "recipes": [
    {
      "title": "Recipe Name",
      "description": "Brief description",
      "search_query": "search terms for food photo",
      "prep_time_minutes": 15,
      "calories": 350,
      "protein": 20,
      "fat": 25,
      "carbs": 5,
      "steps": [
        {"step_number": 1, "instruction": "Step description", "timer_seconds": 120},
        {"step_number": 2, "instruction": "Step description", "timer_seconds": null}
      ]
    }
  ]
}
"""


class AIService:
    """
    Сервис обработки изображений холодильника.
    Генерирует рецепты на основе распознанных продуктов.
    """

    def __init__(self, task_service: TaskService):
        self.task_service = task_service

    async def process_fridge_image(
        self, task_id: str, image_bytes: Optional[bytes] = None
    ) -> None:
        """
        Фоновая задача: анализ фото холодильника → генерация рецептов.

        1. Пытается отправить изображение в Ollama (VLM)
        2. Если Ollama недоступна — использует mock-данные
        3. Получает изображения из Unsplash
        4. Сохраняет рецепты в БД
        5. Обновляет статус задачи в Redis
        """
        try:
            self.task_service.set_task_status(task_id, "processing")

            # Попытка обратиться к Ollama
            ai_result = await self._call_ollama(image_bytes)

            if ai_result is None:
                logger.warning("Ollama недоступна — используем mock-данные")
                ai_result = self._get_mock_data()

            detected_ingredients = ai_result.get("ingredients", [])
            recipes_data = ai_result.get("recipes", [])

            # Получаем изображения и сохраняем в БД
            with SessionLocal() as db:
                recipe_repo = RecipeRepository(db)

                for recipe in recipes_data:
                    # Unsplash изображение
                    search_query = recipe.pop("search_query", recipe["title"])
                    image_url = await fetch_recipe_image(search_query)
                    recipe["image_url"] = image_url

                    # Извлекаем шаги
                    steps = recipe.pop("steps", [])

                    # Сохраняем рецепт + шаги в БД
                    recipe_db_data = {
                        "title": recipe["title"],
                        "description": recipe["description"],
                        "prep_time_minutes": recipe["prep_time_minutes"],
                        "calories": recipe["calories"],
                        "protein": recipe["protein"],
                        "fat": recipe["fat"],
                        "carbs": recipe["carbs"],
                        "image_url": recipe["image_url"],
                    }
                    new_recipe = recipe_repo.create_recipe_with_steps(
                        recipe_db_data, steps
                    )

                    # Записываем ID и шаги в ответ клиенту
                    recipe["id"] = new_recipe.id
                    recipe["steps"] = [
                        {
                            "id": step.id,
                            "recipe_id": step.recipe_id,
                            "step_number": step.step_number,
                            "instruction": step.instruction,
                            "timer_seconds": step.timer_seconds,
                        }
                        for step in new_recipe.steps
                    ]

            # Сохраняем результат
            result = {
                "ingredients": detected_ingredients,
                "recipes": recipes_data,
            }
            self.task_service.set_task_status(task_id, "done", result)
            logger.info(
                f"✅ Task {task_id}: готово — "
                f"{len(detected_ingredients)} ингредиентов, "
                f"{len(recipes_data)} рецептов"
            )

        except Exception as e:
            logger.error(f"❌ Task {task_id}: ошибка — {e}", exc_info=True)
            self.task_service.set_task_status(
                task_id, "error", {"detail": str(e)}
            )

    async def _call_ollama(
        self, image_bytes: Optional[bytes] = None
    ) -> Optional[dict]:
        """
        Отправляет изображение в Ollama VLM и парсит JSON-ответ.
        Возвращает None если Ollama недоступна или ответ невалидный.
        """
        if image_bytes is None:
            logger.info("Нет изображения — пропускаем вызов Ollama")
            return None

        try:
            import base64

            image_b64 = base64.b64encode(image_bytes).decode("utf-8")

            payload = {
                "model": settings.OLLAMA_MODEL,
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {
                        "role": "user",
                        "content": "Analyze this fridge photo and suggest recipes.",
                        "images": [image_b64],
                    },
                ],
                "stream": False,
                "format": "json",
            }

            async with httpx.AsyncClient(timeout=120.0) as client:
                response = await client.post(
                    f"{settings.OLLAMA_BASE_URL}/api/chat",
                    json=payload,
                )
                response.raise_for_status()
                data = response.json()

            # Извлекаем текст ответа
            content = data.get("message", {}).get("content", "")

            # Парсим JSON из ответа
            return self._parse_ai_response(content)

        except httpx.ConnectError:
            logger.warning(
                f"Ollama недоступна по адресу {settings.OLLAMA_BASE_URL}"
            )
            return None
        except httpx.TimeoutException:
            logger.error("Ollama: таймаут запроса (120с)")
            return None
        except Exception as e:
            logger.error(f"Ollama: ошибка — {e}")
            return None

    def _parse_ai_response(self, content: str) -> Optional[dict]:
        """
        Безопасный парсинг JSON из ответа нейросети.
        Обрабатывает случаи невалидного JSON с fallback.
        """
        try:
            result = json.loads(content)
            # Валидация минимальной структуры
            if "recipes" in result and isinstance(result["recipes"], list):
                logger.info("AI: JSON ответ успешно распарсен")
                return result
            else:
                logger.warning("AI: JSON не содержит ожидаемую структуру")
                return None
        except json.JSONDecodeError as e:
            logger.error(f"AI: невалидный JSON — {e}")
            # Попытка извлечь JSON из текста
            try:
                start = content.index("{")
                end = content.rindex("}") + 1
                return json.loads(content[start:end])
            except (ValueError, json.JSONDecodeError):
                logger.error("AI: не удалось извлечь JSON из ответа")
                return None

    @staticmethod
    def _get_mock_data() -> dict:
        """Mock-данные для разработки без Ollama."""
        return {
            "ingredients": [
                "помидоры", "сыр", "яйца", "лук", "зелень",
            ],
            "recipes": [
                {
                    "title": "Омлет с помидорами и сыром",
                    "description": "Быстрый и сытный омлет с нежным сыром и свежими помидорами. Идеальный завтрак за 15 минут!",
                    "search_query": "tomato cheese omelet breakfast",
                    "prep_time_minutes": 15,
                    "calories": 350,
                    "protein": 22,
                    "fat": 24,
                    "carbs": 6,
                    "steps": [
                        {
                            "step_number": 1,
                            "instruction": "Нарежьте помидоры кубиками, мелко нашинкуйте лук и натрите сыр на крупной тёрке.",
                            "timer_seconds": None,
                        },
                        {
                            "step_number": 2,
                            "instruction": "Взбейте 3 яйца с щепоткой соли и перца до однородной массы.",
                            "timer_seconds": None,
                        },
                        {
                            "step_number": 3,
                            "instruction": "Разогрейте сковороду с маслом на среднем огне. Обжарьте лук до золотистого цвета.",
                            "timer_seconds": 120,
                        },
                        {
                            "step_number": 4,
                            "instruction": "Вылейте яичную смесь, добавьте помидоры. Готовьте под крышкой на слабом огне.",
                            "timer_seconds": 180,
                        },
                        {
                            "step_number": 5,
                            "instruction": "Посыпьте тёртым сыром и зеленью. Подавайте горячим!",
                            "timer_seconds": None,
                        },
                    ],
                },
                {
                    "title": "Свежий овощной салат",
                    "description": "Лёгкий и полезный салат из свежих овощей с оливковым маслом. Отличный гарнир или самостоятельное блюдо.",
                    "search_query": "fresh tomato vegetable salad",
                    "prep_time_minutes": 10,
                    "calories": 150,
                    "protein": 5,
                    "fat": 10,
                    "carbs": 15,
                    "steps": [
                        {
                            "step_number": 1,
                            "instruction": "Вымойте все овощи. Нарежьте помидоры дольками, лук — полукольцами.",
                            "timer_seconds": None,
                        },
                        {
                            "step_number": 2,
                            "instruction": "Смешайте все ингредиенты в большой миске. Заправьте оливковым маслом, посолите.",
                            "timer_seconds": None,
                        },
                        {
                            "step_number": 3,
                            "instruction": "Украсьте зеленью и подавайте сразу. Приятного аппетита!",
                            "timer_seconds": None,
                        },
                    ],
                },
                {
                    "title": "Яичница-глазунья с луком",
                    "description": "Классическая яичница с хрустящим луком. Быстрый перекус на каждый день.",
                    "search_query": "fried eggs with onions",
                    "prep_time_minutes": 8,
                    "calories": 280,
                    "protein": 18,
                    "fat": 20,
                    "carbs": 4,
                    "steps": [
                        {
                            "step_number": 1,
                            "instruction": "Нарежьте лук тонкими полукольцами.",
                            "timer_seconds": None,
                        },
                        {
                            "step_number": 2,
                            "instruction": "Разогрейте масло на сковороде. Обжарьте лук до золотистой корочки.",
                            "timer_seconds": 90,
                        },
                        {
                            "step_number": 3,
                            "instruction": "Аккуратно разбейте 2-3 яйца на сковороду. Посолите, поперчите.",
                            "timer_seconds": None,
                        },
                        {
                            "step_number": 4,
                            "instruction": "Накройте крышкой и готовьте на среднем огне до застывания белка.",
                            "timer_seconds": 150,
                        },
                    ],
                },
            ],
        }
