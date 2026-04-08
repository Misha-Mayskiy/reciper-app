from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from infrastructure.database import get_db
from services.user_service import UserService

router = APIRouter()

@router.get("/{user_id}/stats")
async def get_user_stats(user_id: str, db: Session = Depends(get_db)):
    """
    Возвращает агрегированные данные по КБЖУ для отрисовки графиков.
    """
    service = UserService(db)
    try:
        stats = service.get_user_dashboard_stats(user_id)
        return stats
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
