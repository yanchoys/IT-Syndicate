## Task 1
```
# Use a smaller base image
FROM python:3.8-slim as builder

# Set the working directory
WORKDIR /app

# Install dependencies and Git in a single RUN instruction
RUN apt-get update && apt-get install -y git && pip install pipenv

# Copy only the Pipfile and Pipfile.lock initially
COPY Pipfile Pipfile.lock /app/

# Install Python dependencies
RUN pipenv install --deploy --ignore-pipfile

# Copy the rest of the application code
COPY . /app

# Build stage
FROM python:3.8-slim
WORKDIR /app
COPY --from=builder /app /app

# Set environment variables, migrations, and CMD as needed
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
ENV DJANGO_SECRET_KEY=mysecretkey
ENV DJANGO_DEBUG=True
ENV DATABASE_URL=postgres://postgres:password@db-for-test.c3soc84u4kds.us-east-1.rds.amazonaws.com:5432/db_for_test

# Apply database migrations
RUN python manage.py migrate

# Create a non-root user
RUN adduser --disabled-password myuser

# Set the user as the owner of the application directory
RUN chown -R myuser:myuser /app

# Switch to the non-root user
USER myuser

# Run the Django server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

```
-------------------------------------------------------------------------

### Task 2
```
version: '3'

services:
  django:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - DJANGO_SECRET_KEY=mysecretkey
      - DJANGO_DEBUG=True
      - DATABASE_URL=postgres://postgres:password@db:5432/db_for_test
    depends_on:
      - db
    command: python manage.py runserver 0.0.0.0:8000

  db:
    image: postgres:13
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
```

```
# Use the official Python image as a base
FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y git

# Install pipenv
RUN pip install pipenv

# Copy only the Pipfile and Pipfile.lock initially
COPY Pipfile Pipfile.lock /app/

# Install Python dependencies
RUN pipenv install --deploy --ignore-pipfile

# Copy the rest of the application code
COPY . /app
```
#### In this docker-compose.yml file:

- We define two services: django for the Django application and db for the Postgres database.

- For the django service, we use the same Dockerfile as before. It exposes port 8000 for the Django application and sets environment variables for the database connection.

- The db service uses the official Postgres image, and we set the database credentials as environment variables.

- The depends_on directive ensures that the django service will only start after the db service is ready.

--------------------------------------------------------------

#### Benefits of Docker Compose for Local Development:

- Isolation: Docker Compose allows you to isolate services and dependencies, ensuring consistency across development environments.

- Simplified Setup: With a single docker-compose.yml file, you can define and configure all your project's services, making it easy for your team to set up their development environments.

- Easy Testing: Docker Compose is great for testing your application in a controlled environment, especially when using different databases or external services.
