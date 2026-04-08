from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from infrastructure.database import get_db
from services.user_service import UserService
from pydantic import BaseModel

class ConsumeMealRequest(BaseModel):
    user_id: str
    recipe_id: str

router = APIRouter()

@router.post("/consume")
async def consume_meal(request: ConsumeMealRequest, db: Session = Depends(get_db)):
    """
    Принимает user_id и recipe_id съеденного блюда и логирует его КБЖУ в DailyStat.
    """
    service = UserService(db)
    try:
        service.consume_meal(request.user_id, request.recipe_id)
        return {"status": "success", "message": "Meal logged successfully"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
