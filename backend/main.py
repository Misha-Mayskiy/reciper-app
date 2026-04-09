"""
Главный модуль FastAPI-приложения Reciper.
Настраивает CORS, роутеры и startup-события.
"""
import logging
import random
import uuid
from contextlib import asynccontextmanager
from datetime import date, timedelta

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.v1.routers import fridge, tasks, meals, users
from infrastructure.database import SessionLocal
from infrastructure.orm_models import DailyStatOrm
from infrastructure.repositories import UserRepository, DailyStatRepository

logger = logging.getLogger("reciper.main")


def _seed_history(db, user_id: str):
    """Создаёт исторические данные за 30 дней для красивого графика."""
    stat_repo = DailyStatRepository(db)
    today = date.today()

    for days_ago in range(30, 0, -1):
        target_date = today - timedelta(days=days_ago)
        existing = stat_repo.get_stat_by_date(user_id, target_date)
        if not existing:
            # Реалистичные вариации: ±30% от дневной нормы
            base_cal = random.randint(1600, 2800)
            stat = DailyStatOrm(
                id=str(uuid.uuid4()),
                user_id=user_id,
                date=target_date,
                total_calories=base_cal,
                total_protein=random.randint(60, 160),
                total_fat=random.randint(40, 100),
                total_carbs=random.randint(150, 350),
            )
            db.add(stat)

    db.commit()
    logger.info(f"📊 Seed: history for {user_id} — 30 days")


@asynccontextmanager
async def lifespan(application: FastAPI):
    """
    Startup/shutdown lifecycle.
    При старте создаём дефолтного пользователя и seed-историю.
    """
    logger.info("🚀 Reciper API — запуск")

    with SessionLocal() as db:
        user_repo = UserRepository(db)
        if not user_repo.get_user("user_1"):
            user_repo.create_user({
                "name": "Дефолтный пользователь",
                "daily_calories_target": 2200,
                "target_protein": 120,
                "target_fat": 70,
                "target_carbs": 280,
            }, user_id="user_1")
            logger.info("✅ Создан дефолтный пользователь user_1")
        else:
            logger.info("ℹ️ Дефолтный пользователь user_1 уже существует")

        # Seed historical data
        _seed_history(db, "user_1")

    yield

    logger.info("🛑 Reciper API — остановка")


app = FastAPI(
    title="Reciper API",
    description="Backend API for Reciper — AI-ассистент питания и рецептов",
    version="1.0.0",
    lifespan=lifespan,
)

# ──────────── CORS Middleware ────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ──────────── Роутеры ────────────
app.include_router(fridge.router, prefix="/api/v1/fridge", tags=["Fridge"])
app.include_router(tasks.router, prefix="/api/v1/tasks", tags=["Tasks"])
app.include_router(meals.router, prefix="/api/v1/meals", tags=["Meals"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])


@app.get("/health")
async def health_check():
    """Проверка работоспособности API."""
    return {"status": "ok", "service": "reciper-api"}
