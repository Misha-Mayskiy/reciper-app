from pydantic import BaseModel
from typing import List, Optional
from datetime import date


class UserBase(BaseModel):
    name: str
    daily_calories_target: int
    target_protein: int
    target_fat: int
    target_carbs: int


class User(UserBase):
    id: str


class RecipeStep(BaseModel):
    id: str
    recipe_id: str
    step_number: int
    instruction: str
    timer_seconds: Optional[int] = None


class RecipeBase(BaseModel):
    title: str
    description: str
    image_url: Optional[str] = None
    prep_time_minutes: int
    calories: int
    protein: int
    fat: int
    carbs: int


class Recipe(RecipeBase):
    id: str
    steps: List[RecipeStep] = []


class DailyStatBase(BaseModel):
    user_id: str
    date: date
    total_calories: int = 0
    total_protein: int = 0
    total_fat: int = 0
    total_carbs: int = 0


class DailyStat(DailyStatBase):
    id: str
