from infrastructure.repositories import UserRepository, DailyStatRepository, RecipeRepository
from sqlalchemy.orm import Session
from datetime import date

class UserService:
    def __init__(self, db: Session):
        self.user_repo = UserRepository(db)
        self.stat_repo = DailyStatRepository(db)
        self.recipe_repo = RecipeRepository(db)

    def get_or_create_daily_stat(self, user_id: str, target_date: date):
        stat = self.stat_repo.get_stat_by_date(user_id, target_date)
        if not stat:
            stat = self.stat_repo.create_stat(user_id, target_date)
        return stat

    def consume_meal(self, user_id: str, recipe_id: str):
        recipe = self.recipe_repo.get_recipe(recipe_id)
        if not recipe:
            raise ValueError("Recipe not found")
        
        today = date.today()
        stat = self.get_or_create_daily_stat(user_id, today)

        # Добавляем макронутриенты из рецепта в статистику за день
        stat.total_calories += recipe.calories
        stat.total_protein += recipe.protein
        stat.total_fat += recipe.fat
        stat.total_carbs += recipe.carbs

        return self.stat_repo.update_stat(stat)

    def get_user_dashboard_stats(self, user_id: str):
        user = self.user_repo.get_user(user_id)
        if not user:
            raise ValueError("User not found")
            
        stats = self.stat_repo.get_stats_for_user(user_id, limit=7)
        today = date.today()
        today_stat = next((s for s in stats if s.date == today), None)
        
        return {
            "user_id": user_id,
            "daily_target": {
                "calories": user.daily_calories_target,
                "protein": user.target_protein,
                "fat": user.target_fat,
                "carbs": user.target_carbs
            },
            "today": {
                "calories": today_stat.total_calories if today_stat else 0,
                "protein": today_stat.total_protein if today_stat else 0,
                "fat": today_stat.total_fat if today_stat else 0,
                "carbs": today_stat.total_carbs if today_stat else 0
            },
            "history": [
                {
                    "date": s.date.isoformat(),
                    "calories": s.total_calories
                } for s in stats
            ]
        }
