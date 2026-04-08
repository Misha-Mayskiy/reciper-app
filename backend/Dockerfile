FROM python:3.11-slim

WORKDIR /app

# Установка зависимостей для системы (в т.ч. libpq-dev для psycopg2 если нужен)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Конвертируем переносы строк (на случай загрузки из Windows) и делаем скрипт исполняемым
RUN dos2unix /app/entrypoint.sh && chmod +x /app/entrypoint.sh

CMD ["/app/entrypoint.sh"]
