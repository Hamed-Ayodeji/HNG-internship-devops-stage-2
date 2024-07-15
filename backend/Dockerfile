# Use Python 3.10 image from Docker Hub as the base image
FROM python:3.10-slim-bullseye

# Set the working directory inside the container to /app
WORKDIR /app

# Install poetry for dependency management, disable virtualenv creation
RUN pip install poetry && \
    poetry config virtualenvs.create false

# Copy the project's dependency files to the container
COPY ./pyproject.toml ./poetry.lock* ./

# Copy the rest of the application's code to the container
COPY . .

# Install the project dependencies
RUN poetry install

# Inform Docker that the container listens on port 8000 at runtime
EXPOSE 8000

# Define the command to run the application using poetry, uvicorn, and prestart script
CMD ["sh", "-c", "poetry run bash ./prestart.sh && poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"]