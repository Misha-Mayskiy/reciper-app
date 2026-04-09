import asyncio
from infrastructure.external_api.unsplash import fetch_recipe_image
from services.task_service import TaskService


class AIService:
    def __init__(self, task_service: TaskService):
        self.task_service = task_service

    async def process_fridge_image(self, task_id: str):
        """
        Фоновая задача. Эмулирует анализ картинки холодильника и генерацию рецептов VLM-моделью.
        """
        try:
            # 1. Меняем статус на processing (хотя он уже установлен роутером, но подтверждаем)
            self.task_service.set_task_status(task_id, "processing")

            # 2. Эмуляция долгой работы AI (3-5 секунд поллинга)
            await asyncio.sleep(4)

            # 3. Фейковый ответ AI (как если бы LLaVA уже ответила)
            detected_ingredients = ["tomato", "cheese", "egg", "onion"]
            recipes_data = [
                {
                    "title": "Tomato Cheese Omelet",
                    "description": "A quick and easy omelet with fresh tomatoes and cheese.",
                    "search_query": "tomato cheese omelet",
                    "prep_time_minutes": 15,
                    "calories": 350,
                    "protein": 20,
                    "fat": 25,
                    "carbs": 5,
                    "steps": [
                        {"step_number": 1, "instruction": "Chop tomatoes and onions.",
                            "timer_seconds": 120},
                        {"step_number": 2, "instruction": "Whisk eggs and fry.",
                            "timer_seconds": 300}
                    ]
                },
                {
                    "title": "Fresh Salad",
                    "description": "Healthy salad using remaining tomatoes and onions.",
                    "search_query": "fresh tomato salad",
                    "prep_time_minutes": 10,
                    "calories": 150,
                    "protein": 5,
                    "fat": 10,
                    "carbs": 15,
                    "steps": [
                        {"step_number": 1, "instruction": "Mix everything.",
                            "timer_seconds": None}
                    ]
                }
            ]

            # 4. Получаем картинки из Unsplash для каждого рецепта
            from infrastructure.database import SessionLocal
            from infrastructure.repositories import RecipeRepository
            with SessionLocal() as db:
                recipe_repo = RecipeRepository(db)
                for recipe in recipes_data:
                    image_url = await fetch_recipe_image(recipe["search_query"])
                    recipe["image_url"] = image_url
                    del recipe["search_query"]

                    # Создаем запись в БД без явного ID (он сгенерируется внутри)
                    new_recipe_orm = recipe_repo.create_recipe({
                        "title": recipe["title"],
                        "description": recipe["description"],
                        "prep_time_minutes": recipe["prep_time_minutes"],
                        "calories": recipe["calories"],
                        "protein": recipe["protein"],
                        "fat": recipe["fat"],
                        "carbs": recipe["carbs"],
                        "image_url": recipe["image_url"]
                    })

                    # Теперь присваиваем сгенерированный ID в ответ клиенту
                    recipe["id"] = new_recipe_orm.id

            # 5. Сохраняем финальный результат
            result = {
                "ingredients": detected_ingredients,
                "recipes": recipes_data
            }
            self.task_service.set_task_status(task_id, "done", result)

        except Exception as e:
            print(f"Error in AI task {task_id}: {e}")
            self.task_service.set_task_status(
                task_id, "error", {"detail": str(e)})
