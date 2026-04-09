"""
Репозитории для работы с базой данных.
Инкапсулируют все SQL-запросы согласно Clean Architecture.
"""
import logging
import uuid
from datetime import date
from typing import Protocol

from sqlalchemy.orm import Session

from infrastructure.orm_models import UserOrm, DailyStatOrm, RecipeOrm, RecipeStepOrm

logger = logging.getLogger("reciper.repositories")


# ──────────── Абстрактные интерфейсы (Protocols) ────────────

class IUserRepository(Protocol):
    """Интерфейс репозитория пользователей."""

    def get_user(self, user_id: str) -> UserOrm | None: ...
    def create_user(self, user_data: dict, user_id: str | None = None) -> UserOrm: ...


class IDailyStatRepository(Protocol):
    """Интерфейс репозитория дневной статистики."""

    def get_stat_by_date(self, user_id: str, target_date: date) -> DailyStatOrm | None: ...
    def get_stats_for_user(self, user_id: str, limit: int = 7) -> list[DailyStatOrm]: ...
    def create_stat(self, user_id: str, target_date: date) -> DailyStatOrm: ...
    def update_stat(self, stat: DailyStatOrm) -> DailyStatOrm: ...


class IRecipeRepository(Protocol):
    """Интерфейс репозитория рецептов."""

    def get_recipe(self, recipe_id: str) -> RecipeOrm | None: ...
    def create_recipe_with_steps(self, recipe_data: dict, steps_data: list[dict]) -> RecipeOrm: ...


# ──────────── Имплементации ────────────

class UserRepository:
    """Репозиторий пользователей (PostgreSQL/SQLite)."""

    def __init__(self, db: Session):
        self.db = db

    def get_user(self, user_id: str) -> UserOrm | None:
        return self.db.query(UserOrm).filter(UserOrm.id == user_id).first()

    def create_user(self, user_data: dict, user_id: str | None = None) -> UserOrm:
        new_user = UserOrm(id=user_id or str(uuid.uuid4()), **user_data)
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        logger.info(f"Создан пользователь: {new_user.id} ({new_user.name})")
        return new_user


class DailyStatRepository:
    """Репозиторий дневной статистики КБЖУ."""

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
        new_stat = DailyStatOrm(
            id=str(uuid.uuid4()),
            user_id=user_id,
            date=target_date,
            total_calories=0,
            total_protein=0,
            total_fat=0,
            total_carbs=0,
        )
        self.db.add(new_stat)
        self.db.commit()
        self.db.refresh(new_stat)
        logger.info(f"Создана статистика: user={user_id}, date={target_date}")
        return new_stat

    def update_stat(self, stat: DailyStatOrm) -> DailyStatOrm:
        self.db.commit()
        self.db.refresh(stat)
        return stat


class RecipeRepository:
    """Репозиторий рецептов. Создаёт рецепт вместе с шагами."""

    def __init__(self, db: Session):
        self.db = db

    def get_recipe(self, recipe_id: str) -> RecipeOrm | None:
        return self.db.query(RecipeOrm).filter(RecipeOrm.id == recipe_id).first()

    def create_recipe_with_steps(
        self, recipe_data: dict, steps_data: list[dict]
    ) -> RecipeOrm:
        """
        Создаёт рецепт и все его шаги в одной транзакции.

        Args:
            recipe_data: Словарь с полями рецепта (без id и steps).
            steps_data: Список словарей с полями шагов (step_number, instruction, timer_seconds).

        Returns:
            Созданный ORM-объект рецепта.
        """
        recipe_id = str(uuid.uuid4())
        new_recipe = RecipeOrm(id=recipe_id, **recipe_data)
        self.db.add(new_recipe)

        for step in steps_data:
            step_orm = RecipeStepOrm(
                id=str(uuid.uuid4()),
                recipe_id=recipe_id,
                step_number=step.get("step_number", 1),
                instruction=step.get("instruction", ""),
                timer_seconds=step.get("timer_seconds"),
            )
            self.db.add(step_orm)

        self.db.commit()
        self.db.refresh(new_recipe)
        logger.info(
            f"Создан рецепт: {new_recipe.id} «{new_recipe.title}» "
            f"с {len(steps_data)} шагами"
        )
        return new_recipe

    # Совместимость: если где-то ещё вызывается старый метод
    def create_recipe(self, recipe_data: dict) -> RecipeOrm:
        """Создаёт рецепт без шагов (legacy)."""
        return self.create_recipe_with_steps(recipe_data, [])
