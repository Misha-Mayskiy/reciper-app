"""
Сервис бизнес-логики пользователя.
Управляет профилем, статистикой КБЖУ и логированием приёмов пищи.
"""
import logging
from datetime import date

from sqlalchemy.orm import Session

from infrastructure.repositories import (
    UserRepository,
    DailyStatRepository,
    RecipeRepository,
)

logger = logging.getLogger("reciper.user_service")


class UserService:
    """Бизнес-логика, связанная с пользователем и его статистикой."""

    def __init__(self, db: Session):
        self.user_repo = UserRepository(db)
        self.stat_repo = DailyStatRepository(db)
        self.recipe_repo = RecipeRepository(db)

    def create_user(self, user_data: dict) -> dict:
        """Создаёт нового пользователя и возвращает его данные."""
        user = self.user_repo.create_user(user_data)
        return {
            "id": user.id,
            "name": user.name,
            "daily_calories_target": user.daily_calories_target,
            "target_protein": user.target_protein,
            "target_fat": user.target_fat,
            "target_carbs": user.target_carbs,
        }

    def get_or_create_daily_stat(self, user_id: str, target_date: date):
        """Получает или создаёт запись статистики на указанную дату."""
        stat = self.stat_repo.get_stat_by_date(user_id, target_date)
        if not stat:
            stat = self.stat_repo.create_stat(user_id, target_date)
        return stat

    def consume_meal(self, user_id: str, recipe_id: str) -> dict:
        """
        Логирует приём пищи: добавляет КБЖУ рецепта в дневную статистику.
        """
        recipe = self.recipe_repo.get_recipe(recipe_id)
        if not recipe:
            raise ValueError(f"Рецепт с id={recipe_id} не найден")

        today = date.today()
        stat = self.get_or_create_daily_stat(user_id, today)

        stat.total_calories = (stat.total_calories or 0) + recipe.calories
        stat.total_protein = (stat.total_protein or 0) + recipe.protein
        stat.total_fat = (stat.total_fat or 0) + recipe.fat
        stat.total_carbs = (stat.total_carbs or 0) + recipe.carbs

        self.stat_repo.update_stat(stat)
        logger.info(
            f"Meal logged: user={user_id}, recipe=«{recipe.title}», "
            f"+{recipe.calories} kcal"
        )

        return {
            "total_calories": stat.total_calories,
            "total_protein": stat.total_protein,
            "total_fat": stat.total_fat,
            "total_carbs": stat.total_carbs,
        }

    def get_user_dashboard_stats(self, user_id: str, period: str = "week") -> dict:
        """
        Возвращает агрегированные данные для дашборда.

        Args:
            period: 'week' (7 дней) или 'month' (30 дней).
        """
        user = self.user_repo.get_user(user_id)
        if not user:
            raise ValueError(f"Пользователь с id={user_id} не найден")

        limit = 7 if period == "week" else 30
        stats = self.stat_repo.get_stats_for_user(user_id, limit=limit)
        today = date.today()
        today_stat = next((s for s in stats if s.date == today), None)

        return {
            "user_id": user_id,
            "user_name": user.name,
            "period": period,
            "daily_target": {
                "calories": user.daily_calories_target,
                "protein": user.target_protein,
                "fat": user.target_fat,
                "carbs": user.target_carbs,
            },
            "today": {
                "calories": today_stat.total_calories if today_stat else 0,
                "protein": today_stat.total_protein if today_stat else 0,
                "fat": today_stat.total_fat if today_stat else 0,
                "carbs": today_stat.total_carbs if today_stat else 0,
            },
            "history": [
                {
                    "date": s.date.isoformat(),
                    "calories": s.total_calories or 0,
                    "protein": s.total_protein or 0,
                    "fat": s.total_fat or 0,
                    "carbs": s.total_carbs or 0,
                }
                for s in reversed(stats)
            ],
        }
