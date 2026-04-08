#!/bin/bash
set -e

echo "Waiting for PostgreSQL to start..."
# Мы можем использовать python скрипт для ожидания, но для простоты просто подождем пару секунд
sleep 5

echo "Running Alembic migrations..."
python -m alembic upgrade head

echo "Starting FastAPI server..."
exec uvicorn main:app --host 0.0.0.0 --port 8000
