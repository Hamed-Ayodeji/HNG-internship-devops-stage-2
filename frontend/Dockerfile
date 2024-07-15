# Build Stage
# Use node:current-slim as the base image for the build stage
FROM node:current-slim AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json for npm install
COPY ./package.json ./package-lock.json ./

# Install dependencies defined in package.json
RUN npm install

# Copy the rest of the application's source code
COPY . .

# Run Stage
# Start a new stage from node:current-slim to keep the final image small
FROM node:current-slim

# Set the working directory in the container
WORKDIR /app

# Copy the built application from the previous stage
COPY --from=builder /app ./

# Inform Docker that the container listens on port 5173 at runtime
EXPOSE 5173

# Command to run the application
CMD ["npm", "run", "dev", "--", "--host"]