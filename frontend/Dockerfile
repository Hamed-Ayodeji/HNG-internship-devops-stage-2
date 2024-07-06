# Stage 1: Build stage
# Use a slim Node.js image for a smaller footprint
FROM node:22.4.0-slim as builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker cache
# This is efficient for rebuilding images when dependencies have not changed
COPY package*.json ./

# Use npm ci for installing dependencies to ensure a clean, consistent install
RUN npm ci

# Copy the rest of the application code
COPY . .

# Stage 2: Run stage
# Again, using a slim Node.js image for runtime to reduce image size
FROM node:22.4.0-slim

# Set the working directory in the container
WORKDIR /app

# Copy built artifacts from the builder stage
COPY --from=builder /app ./

# Inform Docker that the container listens on port 3000 at runtime
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]