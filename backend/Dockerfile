# Stage 1: Build stage
# Use a slim Python image for a smaller footprint and enhanced security
FROM python:3.10-slim-bullseye

# Set the working directory in the container
WORKDIR /app

# Install Poetry for dependency management and configure it to not create a virtual environment
RUN pip install poetry && \
    poetry config virtualenvs.create false

# Copy the Poetry configuration files to install Python dependencies
COPY ./pyproject.toml ./poetry.lock* ./

# Copy the application code into the container
COPY . .

# Install the Python dependencies
RUN poetry install

# Expose the port the application listens on
EXPOSE 8000

# Run prestart and start the Uvicorn server with the application
CMD ["sh", "-c", "poetry run bash ./prestart.sh && poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"]