from fastapi import FastAPI
from api.v1.routers import fridge, tasks, meals, users

app = FastAPI(
    title="Reciper API",
    description="Backend API for Reciper mobile application",
    version="1.0.0",
)

app.include_router(fridge.router, prefix="/api/v1/fridge", tags=["Fridge"])
app.include_router(tasks.router, prefix="/api/v1/tasks", tags=["Tasks"])
app.include_router(meals.router, prefix="/api/v1/meals", tags=["Meals"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])

@app.get("/health")
async def health_check():
    return {"status": "ok"}
