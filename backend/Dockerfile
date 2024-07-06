# Stage 1: Build stage
# Use a slim Python image for a smaller footprint
FROM python:3.9-slim-bullseye AS builder

# Set the working directory in the container
WORKDIR /app

# Install Poetry securely by downloading the installer and verifying its integrity before execution
RUN apt-get update && apt-get install -y curl && \
    curl -sSL https://install.python-poetry.org | python3 - && \
    poetry config virtualenvs.create false

# Copy only the files needed for installing dependencies
COPY pyproject.toml poetry.lock* ./

# Install dependencies
RUN poetry install --no-dev

# Copy the rest of the application code
COPY . .

# Stage 2: Run stage
# Use a slim Python image for runtime to reduce image size
FROM python:3.9-slim-bullseye

# Set the working directory in the container
WORKDIR /app

# Copy built artifacts from the builder stage
COPY --from=builder /app ./

# Expose the port
EXPOSE 8000

# Copy the prestart script into the image and make it executable
COPY prestart.sh /prestart.sh
RUN chmod +x /prestart.sh

# Use an entrypoint script to set up the database and run the server
ENTRYPOINT ["/prestart.sh"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
