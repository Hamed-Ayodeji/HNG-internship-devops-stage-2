# Frontend Setup with ReactJS and ChakraUI

This guide covers setting up and dockerizing the frontend of your application built with ReactJS and ChakraUI. By following these instructions, you ensure a smooth and consistent development and deployment process.

## Prerequisites

Before you start, make sure you have the following installed:

- **Node.js (version 14.x or higher)**
- **npm (version 6.x or higher)**
- **Docker (latest version recommended)**

## Setup Instructions

### Local Development

1. **Navigate to the frontend directory**:

    ```sh
    cd frontend
    ```

2. **Install dependencies**:

    ```sh
    npm install
    ```

3. **Run the development server**:

    ```sh
    npm run dev
    ```

4. **Configure API URL**:

    Ensure the API URL is correctly set in the `.env` file for the frontend to communicate with the backend services.

### Using Docker

To build and run the application using Docker, follow these steps:

1. **Build the Docker image**:

    ```sh
    docker build -t frontend-app .
    ```

2. **Run the Docker container**:

    ```sh
    docker run -p 5173:5173 frontend-app
    ```

## Dockerfile Breakdown

The Dockerfile for this application uses a multi-stage build process to create a lean and efficient Docker image.

### Stage 1: Build Stage

```dockerfile
FROM node:current-slim AS builder
WORKDIR /app
COPY ./package.json ./package-lock.json ./
RUN npm install
COPY . .
```

- **Base Image**: Uses `node:current-slim` for a lightweight Node.js environment.
- **Working Directory**: Sets `/app` as the working directory.
- **Dependencies**: Copies `package.json` and `package-lock.json`, then runs `npm install` to install dependencies.
- **Application Code**: Copies the application source code into the container.

### Stage 2: Run Stage

```dockerfile
FROM node:current-slim
WORKDIR /app
COPY --from=builder /app ./
EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host"]
```

- **Base Image**: Uses `node:current-slim` again for runtime.
- **Working Directory**: Sets `/app` as the working directory.
- **Copy Artifacts**: Copies the built application and installed dependencies from the build stage.
- **Expose Port**: Indicates that the container listens on port 5173.
- **Start Command**: Specifies the command to start the application in development mode, making it accessible on port 5173.

## Conclusion

This guide provides a comprehensive walkthrough for setting up and running the frontend of your application both locally and using Docker. By following these instructions, you can ensure a consistent environment for development and deployment, leveraging the benefits of containerization with Docker. Enjoy building your responsive and robust frontend application!
