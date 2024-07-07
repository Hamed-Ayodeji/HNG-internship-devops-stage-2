# Full-Stack FastAPI and React Template

Welcome to the Full-Stack FastAPI and React template repository. This repository serves as a demo application for interns, showcasing how to set up and run a full-stack application with a FastAPI backend and a ReactJS frontend using ChakraUI.

## Project Structure

The repository is organized into two main directories:

- **frontend**: Contains the ReactJS application.
- **backend**: Contains the FastAPI application and PostgreSQL database integration.

Each directory has its own README file with detailed instructions specific to that part of the application.

## Getting Started

To get started with this template, please follow the instructions in the respective directories:

- [Frontend README](./frontend/README.md)
- [Backend README](./backend/README.md)

## Docker Compose Setup

The `docker-compose.yml` file orchestrates the setup and deployment of the entire stack, ensuring all components work seamlessly together. Below is a breakdown of the configuration, explained in detailed snippets.

### Services

#### Postgres Service

```yaml
version: "3.8"

services:
  postgres:
    image: postgres:17beta1-alpine
    container_name: postgresDb
    env_file:
      - .env
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - mynetwork
```

- **Image**: Specifies the Docker image `postgres:17beta1-alpine` for a lightweight and efficient PostgreSQL database.
- **Container Name**: Names the container `postgresDb` for easy identification.
- **Environment Variables**: Loads environment variables from the `.env` file for database configuration.
- **Volumes**: Maps the host volume `postgres_data` to persist data in the container directory `/var/lib/postgresql/data`.
- **Ports**: Exposes port `5432` for database connections.
- **Networks**: Connects to a custom Docker network named `mynetwork`.

#### Adminer Service

```yaml
  adminer:
    image: adminer:latest
    container_name: postgresDbAdminer
    env_file:
      - .env
    labels:
      - "traefik.http.routers.adminer.rule=Host(`db.${DOMAIN}`) && PathPrefix(`/adminer`)"
      - "traefik.http.services.adminer.loadbalancer.server.port=8080"
      - "traefik.http.routers.adminer.entrypoints=websecure"
      - "traefik.http.routers.adminer.tls.certresolver=myresolver"
    depends_on:
      - postgres
    ports:
      - "8080:8080"
    networks:
      - mynetwork
```

- **Image**: Uses `adminer:latest` for a database management UI.
- **Container Name**: Names the container `postgresDbAdminer`.
- **Labels**: Configures Traefik rules for routing and securing access to Adminer.
  - **Host Rule**: Routes traffic based on the host `db.${DOMAIN}` and path prefix `/adminer`.
  - **Service Port**: Specifies the internal service port `8080`.
  - **Entry Points**: Uses the `websecure` entry point for HTTPS traffic.
  - **TLS Cert Resolver**: Uses the `myresolver` for TLS certificate management.
- **Depends On**: Ensures the `postgres` service starts before Adminer.
- **Ports**: Exposes port `8080` for Adminer.
- **Networks**: Connects to `mynetwork`.

#### Traefik Service

```yaml
  traefik:
    image: traefik:v2.5
    container_name: traefikProxyManager
    env_file:
      - .env
    command:
      - "--log.level=DEBUG"
      - "--providers.docker=true"
      - "--api.insecure=true"
      - "--api.dashboard=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.dashboard.address=:8090"
      - "--certificatesresolvers.myresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.myresolver.acme.email=${FIRST_SUPERUSER}"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
      - "8090:8090"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./letsencrypt:/letsencrypt
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`proxy.${DOMAIN}`) && PathPrefix(`/dashboard`)"
    networks:
      - mynetwork
```

- **Image**: Uses `traefik:v2.5` as a reverse proxy and load balancer.
- **Container Name**: Names the container `traefikProxyManager`.
- **Environment Variables**: Loads environment variables from the `.env` file.
- **Command**: Configures Traefik with various options:
  - **Log Level**: Sets the log level to `DEBUG`.
  - **Providers**: Enables Docker provider.
  - **API**: Enables the API and dashboard.
  - **Entry Points**: Defines HTTP (`:80`), HTTPS (`:443`), and dashboard (`:8090`) entry points.
  - **Certificate Resolvers**: Configures ACME HTTP challenge for automatic Let's Encrypt certificate management.
- **Ports**: Exposes ports `80` (HTTP), `443` (HTTPS), and `8090` (dashboard).
- **Volumes**: Shares the Docker socket and a directory for Let's Encrypt certificates.
- **Labels**: Configures Traefik rules for the API dashboard.
  - **Enable**: Enables Traefik for this container.
  - **Router Rule**: Routes traffic based on the host `proxy.${DOMAIN}` and path prefix `/dashboard`.
- **Networks**: Connects to `mynetwork`.

#### Backend Service

```yaml
  backend:
    build: ./backend
    image: backend:fastapi
    container_name: backend
    ports:
      - "8000:8000"
    env_file:
      - .env
    labels:
      - "traefik.http.routers.backend.rule=PathPrefix(`/api`) || PathPrefix(`/docs`) || PathPrefix(`/redoc`)"
      - "traefik.http.routers.backend.entrypoints=websecure,web"
      - "traefik.http.services.backend.loadbalancer.server.port=8000"
      - "traefik.http.routers.backend.middlewares=api-stripprefix"
    depends_on:
      - postgres
      - traefik
    networks:
      - mynetwork
```

- **Build**: Specifies the build context as `./backend`.
- **Image**: Uses `backend:fastapi` image.
- **Container Name**: Names the container `backend`.
- **Ports**: Exposes port `8000` for the FastAPI application.
- **Environment Variables**: Loads environment variables from the `.env` file.
- **Labels**: Configures Traefik rules for routing:
  - **Router Rule**: Routes traffic based on path prefixes (`/api`, `/docs`, `/redoc`).
  - **Entry Points**: Uses both HTTP (`web`) and HTTPS (`websecure`) entry points.
  - **Service Port**: Specifies the internal service port `8000`.
  - **Middleware**: Uses `api-stripprefix` middleware for URL path adjustments.
- **Depends On**: Ensures `postgres` and `traefik` services start before the backend.
- **Networks**: Connects to `mynetwork`.

#### Frontend Service

```yaml
  frontend:
    build: ./frontend
    image: frontend:react
    container_name: frontend
    ports:
      - "3000:3000"
    labels:
      - "traefik.http.routers.frontend.rule=PathPrefix(`/`)"
      - "traefik.http.services.frontend.loadbalancer.server.port=3000"
      - "traefik.http.routers.frontend.entrypoints=websecure,web"
      - "traefik.http.routers.frontend.tls.certresolver=myresolver"
    depends_on:
      - backend
      - traefik
    networks:
      - mynetwork
```

- **Build**: Specifies the build context as `./frontend`.
- **Image**: Uses `frontend:react` image.
- **Container Name**: Names the container `frontend`.
- **Ports**: Exposes port `3000` for the React application.
- **Labels**: Configures Traefik rules for routing:
  - **Router Rule**: Routes all traffic with path prefix `/`.
  - **Service Port**: Specifies the internal service port `3000`.
  - **Entry Points**: Uses both HTTP (`web`) and HTTPS (`websecure`) entry points.
  - **TLS Cert Resolver**: Uses the `myresolver` for TLS certificate management.
- **Depends On**: Ensures `backend` and `traefik` services start before the frontend.
- **Networks**: Connects to `mynetwork`.

### Volumes

```yaml
volumes:
  postgres_data:
  letsencrypt:
```

- **postgres_data**: Volume for pers

isting PostgreSQL data.

- **letsencrypt**: Volume for storing Let's Encrypt certificates.

### Networks

```yaml
networks:
  mynetwork:
```

- **mynetwork**: Custom Docker network to ensure all services can communicate with each other.

## Conclusion

This documentation provides a comprehensive overview of setting up a full-stack FastAPI and React application using Docker and Traefik. By following these instructions, you can ensure a consistent and efficient development and deployment environment.
