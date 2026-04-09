"""
Главный модуль FastAPI-приложения Reciper.
Настраивает CORS, роутеры и startup-события.
"""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.v1.routers import fridge, tasks, meals, users
from infrastructure.database import SessionLocal
from infrastructure.repositories import UserRepository

logger = logging.getLogger("reciper.main")


@asynccontextmanager
async def lifespan(application: FastAPI):
    """
    Startup/shutdown lifecycle.
    При старте создаём дефолтного пользователя если его нет.
    """
    logger.info("🚀 Reciper API — запуск")

    # Seed: создаём дефолтного пользователя
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
