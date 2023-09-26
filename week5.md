### Task 1
- Creating AWS RDS PostgreSQL
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/702c3719-89cc-4144-af49-c8891fb55c34)

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
- Creating and pushing image ECR
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/8a4b80e9-72c9-4bcf-b93c-1303f30ed65f)

- Creating ECS
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/78c4850e-1606-4137-8dce-f7291be05b3b)

- Creating task
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/1f1edc90-dca1-4c68-9b7b-8d7af5709dd7)
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/4f756ec4-39f5-47cd-9f39-466dc09dc720)

### Task 3

Instead of copying the entire project into the container, we only copy the Pipfile and Pipfile.lock to install the dependencies. This reduces the number of unnecessary files in the container.
```
# Используйте официальный образ Python
FROM python:3.8

# Установка зависимостей
RUN apt-get update && apt-get install -y git && apt-get clean
RUN pip install --no-cache-dir pipenv

# Создание рабочей директории
WORKDIR /app

# Клонирование Git-репозитория
RUN git clone https://github.com/digitalocean/sample-django.git

# Переход в директорию проекта
WORKDIR /app/sample-django

# Установка зависимостей проекта
COPY Pipfile Pipfile.lock /app/sample-django/
RUN pipenv install --deploy --ignore-pipfile

# Копирование секретов в контейнер
COPY db_user_secret /run/secrets/db_user_secret
COPY db_password_secret /run/secrets/db_password_secret
COPY django_secret_key_secret /run/secrets/django_secret_key_secret

# Экспорт переменных окружения
ENV POSTGRES_USER_FILE=/run/secrets/db_user_secret
ENV POSTGRES_PASSWORD_FILE=/run/secrets/db_password_secret
ENV DJANGO_SECRET_KEY_FILE=/run/secrets/django_secret_key_secret

# Применение миграций базы данных
RUN pipenv run python manage.py migrate

# Запуск Django сервера
CMD ["pipenv", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]
```

- additionaly creating docker-compose.yml for more secure
```
echo "my_db_user" | docker secret create db_user_secret -
echo "my_db_password" | docker secret create db_password_secret -
echo "mysecretkey" | docker secret create django_secret_key_secret -
```
