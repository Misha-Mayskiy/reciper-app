from sqlalchemy import Column, String, Integer, ForeignKey, Date
from sqlalchemy.orm import relationship
from infrastructure.database import Base


class UserOrm(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    name = Column(String)
    daily_calories_target = Column(Integer)
    target_protein = Column(Integer)
    target_fat = Column(Integer)
    target_carbs = Column(Integer)

    daily_stats = relationship("DailyStatOrm", back_populates="user")


class RecipeOrm(Base):
    __tablename__ = "recipes"

    id = Column(String, primary_key=True, index=True)
    title = Column(String)
    description = Column(String)
    image_url = Column(String, nullable=True)
    prep_time_minutes = Column(Integer)
    calories = Column(Integer)
    protein = Column(Integer)
    fat = Column(Integer)
    carbs = Column(Integer)

    steps = relationship(
        "RecipeStepOrm", back_populates="recipe", cascade="all, delete-orphan")


class RecipeStepOrm(Base):
    __tablename__ = "recipe_steps"

    id = Column(String, primary_key=True, index=True)
    recipe_id = Column(String, ForeignKey("recipes.id"))
    step_number = Column(Integer)
    instruction = Column(String)
    timer_seconds = Column(Integer, nullable=True)

    recipe = relationship("RecipeOrm", back_populates="steps")


class DailyStatOrm(Base):
    __tablename__ = "daily_stats"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("users.id"))
    date = Column(Date, index=True)
    total_calories = Column(Integer, default=0)
    total_protein = Column(Integer, default=0)
    total_fat = Column(Integer, default=0)
    total_carbs = Column(Integer, default=0)

    user = relationship("UserOrm", back_populates="daily_stats")
