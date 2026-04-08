from sqlalchemy.orm import Session
from infrastructure.orm_models import UserOrm, DailyStatOrm, RecipeOrm
from datetime import date
import uuid

class UserRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_user(self, user_id: str) -> UserOrm | None:
        return self.db.query(UserOrm).filter(UserOrm.id == user_id).first()

    def create_user(self, user_data: dict) -> UserOrm:
        new_user = UserOrm(id=str(uuid.uuid4()), **user_data)
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        return new_user

class DailyStatRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_stat_by_date(self, user_id: str, target_date: date) -> DailyStatOrm | None:
        return self.db.query(DailyStatOrm).filter(
            DailyStatOrm.user_id == user_id, 
            DailyStatOrm.date == target_date
        ).first()

    def get_stats_for_user(self, user_id: str, limit: int = 7) -> list[DailyStatOrm]:
        return self.db.query(DailyStatOrm).filter(
            DailyStatOrm.user_id == user_id
        ).order_by(DailyStatOrm.date.desc()).limit(limit).all()

    def create_stat(self, user_id: str, target_date: date) -> DailyStatOrm:
        new_stat = DailyStatOrm(id=str(uuid.uuid4()), user_id=user_id, date=target_date)
        self.db.add(new_stat)
        self.db.commit()
        self.db.refresh(new_stat)
        return new_stat

    def update_stat(self, stat: DailyStatOrm) -> DailyStatOrm:
        self.db.commit()
        self.db.refresh(stat)
        return stat

class RecipeRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_recipe(self, recipe_id: str) -> RecipeOrm | None:
        return self.db.query(RecipeOrm).filter(RecipeOrm.id == recipe_id).first()

    def create_recipe(self, recipe_data: dict) -> RecipeOrm:
        # Упрощенное создание без шагов для примера
        new_recipe = RecipeOrm(id=str(uuid.uuid4()), **recipe_data)
        self.db.add(new_recipe)
        self.db.commit()
        self.db.refresh(new_recipe)
        return new_recipe
