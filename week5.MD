### Task 1
- Creating AWS RDS PostgreSQL

- Creating Dockerfile
```
# Используем официальный образ Python
FROM python:3.8

# Установка зависимостей
RUN apt-get update
RUN apt-get install -y git
RUN pip install pipenv

# Создание рабочей директории
WORKDIR /app

# Клонирование Git-репозитория
RUN git clone https://github.com/digitalocean/sample-django.git

# Переход в директорию проекта
WORKDIR /app/sample-django

# Установка зависимостей проекта
RUN pip install -r requirements.txt

# Экспорт переменных окружения
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
ENV DJANGO_SECRET_KEY=mysecretkey
ENV DJANGO_DEBUG=True
ENV DATABASE_URL=postgres://postgres:password@db-for-test.c3soc84u4kds.us-east-1.rds.amazonaws.com:5432/db_for_test


# Применение миграций базы данных
RUN python manage.py migrate

# Запуск Django сервера
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

```
