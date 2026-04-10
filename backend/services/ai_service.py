"""
AI-сервис: анализ изображений и генерация рецептов.
Использует Ollama/llama.cpp (OpenAI-совместимый API) или mock-данные.
"""

import json
import logging
from typing import Optional

import base64
import httpx

from core.config import settings
from infrastructure.database import SessionLocal
from infrastructure.external_api.unsplash import fetch_recipe_image
from infrastructure.repositories import RecipeRepository
from services.task_service import TaskService

logger = logging.getLogger("reciper.ai_service")

# Промпт для Vision-модели
SYSTEM_PROMPT = """Ты профессиональный шеф-повар ИИ-ассистент. Анализируешь фото содержимого холодильника.

Получив изображение, ты должен:
1. Определить все видимые продукты и ингредиенты
2. Предложить 3-5 рецептов БЕЗ дополнительных покупок, используя ТОЛЬКО эти ингредиенты

Отвечай ТОЛЬКО валидным JSON в ЭТОМ точном формате:
{
  "ingredients": ["ингредиент1", "ингредиент2"],
  "recipes": [
    {
      "title": "Название рецепта",
      "description": "Краткое описание",
      "search_query": "ключевые слова для поиска фото блюда",
      "prep_time_minutes": 15,
      "calories": 350,
      "protein": 20,
      "fat": 25,
      "carbs": 5,
      "steps": [
        {"step_number": 1, "instruction": "Описание шага", "timer_seconds": 120},
        {"step_number": 2, "instruction": "Описание шага", "timer_seconds": null}
      ]
    }
  ]
}
"""


class AIService:
    """
    Сервис обработки изображений холодильника и генерации плана питания.
    """

    def __init__(self, task_service: TaskService):
        self.task_service = task_service

    async def generate_personal_plan(self, user_id: str, goal: str, allergies: str, preferences: str) -> dict:
        """Генерирует персональный план питания на основе анкеты без использования фото."""
        prompt = f"""
        Ты профессиональный ИИ-диетолог. Составь план питания (3 рецепта) на день для пользователя.
        Его цель: {goal}
        Аллергии/Непереносимости: {allergies if allergies else "Нет"}
        Пожелания (вкусы): {preferences if preferences else "Нет особых пожеланий"}

        Верни ТОЛЬКО валидный JSON в формате:
        {{
          "recipes": [
            {{
              "title": "Название",
              "description": "Описание",
              "search_query": "food photography dish",
              "prep_time_minutes": 15,
              "calories": 400,
              "protein": 30,
              "fat": 15,
              "carbs": 40,
              "steps": [ {{"step_number": 1, "instruction": "Шаг 1", "timer_seconds": null}} ]
            }}
          ]
        }}
        """

        try:
            ai_result = None
            if hasattr(settings, "client") and settings.client:
                from fastapi.concurrency import run_in_threadpool
                response = await run_in_threadpool(
                    lambda: settings.client.chat.completions.create(
                        model="google/gemini-3-flash-preview",
                        messages=[
                            {"role": "system", "content": "Ты профессиональный ИИ-диетолог. Отвечай только валидным JSON."},
                            {"role": "user", "content": prompt}
                        ],
                    )
                )
                ai_result = self._parse_ai_response(
                    response.choices[0].message.content)

            if not ai_result:
                ai_result = self._get_mock_data()

            recipes_data = ai_result.get("recipes", [])

            with SessionLocal() as db:
                recipe_repo = RecipeRepository(db)
                for recipe in recipes_data:
                    search_query = recipe.pop("search_query", recipe["title"])
                    recipe["image_url"] = await fetch_recipe_image(search_query)
                    steps = recipe.pop("steps", [])
                    new_recipe = recipe_repo.create_recipe_with_steps(
                        recipe, steps)
                    recipe["id"] = new_recipe.id
                    recipe["steps"] = [
                        {
                            "id": s.id, "recipe_id": s.recipe_id, "step_number": s.step_number,
                            "instruction": s.instruction, "timer_seconds": s.timer_seconds
                        } for s in new_recipe.steps
                    ]

            return {"recipes": recipes_data}
        except Exception as e:
            logger.error(f"Ошибка генерации плана: {e}")
            return self._get_mock_data()

    async def process_fridge_image(
        self, task_id: str, image_bytes: Optional[bytes] = None
    ) -> None:
        try:
            self.task_service.set_task_status(task_id, "processing")

            ai_result = None

            if hasattr(settings, "client") and settings.client:
                logger.info("Пробуем основное API (Gemini/OpenAI)...")
                ai_result = await self._call_openai(image_bytes)

            if ai_result is None:
                logger.warning("Основное API недоступно. Fallback -> Ollama")
                ai_result = await self._call_ollama(image_bytes)

            if ai_result is None:
                logger.warning(
                    "Ollama недоступна или вернула ошибку — используем mock-данные")
                ai_result = self._get_mock_data()

            detected_ingredients = ai_result.get("ingredients", [])
            recipes_data = ai_result.get("recipes", [])

            with SessionLocal() as db:
                recipe_repo = RecipeRepository(db)

                for recipe in recipes_data:
                    search_query = recipe.pop("search_query", recipe["title"])
                    image_url = await fetch_recipe_image(search_query)
                    recipe["image_url"] = image_url
                    steps = recipe.pop("steps", [])

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
                task_id, "error", {"detail": str(e)})

    async def _call_openai(self, image_bytes: Optional[bytes] = None) -> Optional[dict]:
        logger.info("--- Попытка вызова VSELLM ---")
        if image_bytes is None:
            return None
        try:
            image_b64 = base64.b64encode(image_bytes).decode("utf-8")

            payload = {
                "model": "google/gemini-3-flash-preview",
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {
                        "role": "user",
                        "content": [
                            {"type": "text",
                                "text": "Проанализируй фото и предложи рецепты."},
                            {"type": "image_url", "image_url": {
                                "url": f"data:image/jpeg;base64,{image_b64}"}}
                        ]
                    }
                ],
            }

            from fastapi.concurrency import run_in_threadpool
            response = await run_in_threadpool(
                lambda: settings.client.chat.completions.create(**payload)
            )

            content = response.choices[0].message.content
            return self._parse_ai_response(content)

        except Exception as e:
            logger.error(f"❌ Ошибка VSELLM: {type(e).__name__}: {e}")
            return None

    async def _call_ollama(self, image_bytes: Optional[bytes] = None) -> Optional[dict]:
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

            content = data.get("message", {}).get("content", "")
            return self._parse_ai_response(content)

        except httpx.ConnectError:
            logger.warning(
                f"Ollama недоступна по адресу {settings.OLLAMA_BASE_URL}")
            return None
        except httpx.TimeoutException:
            logger.error("Ollama: таймаут запроса (120с)")
            return None
        except Exception as e:
            logger.error(f"Ollama: ошибка — {e}")
            return None

    def _parse_ai_response(self, content: str) -> Optional[dict]:
        try:
            result = json.loads(content)
            if "recipes" in result and isinstance(result["recipes"], list):
                logger.info("AI: JSON ответ успешно распарсен")
                return result
            else:
                logger.warning("AI: JSON не содержит ожидаемую структуру")
                return None
        except json.JSONDecodeError as e:
            logger.error(f"AI: невалидный JSON — {e}")
            try:
                start = content.index("{")
                end = content.rindex("}") + 1
                return json.loads(content[start:end])
            except (ValueError, json.JSONDecodeError):
                logger.error("AI: не удалось извлечь JSON из ответа")
                return None

    @staticmethod
    def _get_mock_data() -> dict:
        return {
            "ingredients": ["помидоры", "сыр", "яйца", "лук", "зелень"],
            "recipes": [
                {
                    "title": "Омлет с помидорами и сыром",
                    "description": "Быстрый и сытный омлет с нежным сыром и свежими помидорами.",
                    "search_query": "tomato cheese omelet breakfast",
                    "prep_time_minutes": 15,
                    "calories": 350,
                    "protein": 22,
                    "fat": 24,
                    "carbs": 6,
                    "steps": [
                        {"step_number": 1, "instruction": "Нарежьте помидоры кубиками и натрите сыр.",
                            "timer_seconds": None},
                        {"step_number": 2, "instruction": "Взбейте яйца с солью и перцем.",
                            "timer_seconds": None},
                        {"step_number": 3, "instruction": "Обжарьте помидоры на сковороде.",
                            "timer_seconds": 120},
                        {"step_number": 4, "instruction": "Вылейте яичную смесь. Готовьте под крышкой.",
                            "timer_seconds": 180},
                        {"step_number": 5, "instruction": "Посыпьте тёртым сыром и зеленью.",
                            "timer_seconds": None},
                    ],
                },
                {
                    "title": "Свежий овощной салат",
                    "description": "Лёгкий салат из свежих овощей с оливковым маслом.",
                    "search_query": "fresh tomato vegetable salad",
                    "prep_time_minutes": 10,
                    "calories": 150,
                    "protein": 5,
                    "fat": 10,
                    "carbs": 15,
                    "steps": [
                        {"step_number": 1, "instruction": "Нарежьте помидоры дольками, лук — полукольцами.",
                            "timer_seconds": None},
                        {"step_number": 2, "instruction": "Смешайте ингредиенты. Заправьте маслом.",
                            "timer_seconds": None},
                    ],
                },
                {
                    "title": "Яичница-глазунья",
                    "description": "Классическая яичница для быстрого перекуса.",
                    "search_query": "fried eggs",
                    "prep_time_minutes": 8,
                    "calories": 280,
                    "protein": 18,
                    "fat": 20,
                    "carbs": 4,
                    "steps": [
                        {"step_number": 1, "instruction": "Разогрейте масло на сковороде.",
                            "timer_seconds": None},
                        {"step_number": 2, "instruction": "Разбейте яйца, посолите.",
                            "timer_seconds": None},
                        {"step_number": 3, "instruction": "Готовьте до застывания белка.",
                            "timer_seconds": 150},
                    ],
                },
            ],
        }
