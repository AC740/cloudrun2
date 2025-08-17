# Stage 1: Build the application
# Use an official Node.js runtime as a parent image
FROM node:18-slim AS builder

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy app source and binary files
COPY . .

# ---
# Stage 2: Production image
# Use a minimal base image for security and size
FROM node:18-slim

WORKDIR /usr/src/app

# Copy dependencies from the builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy the rest of the app from the builder stage
COPY --from=builder /usr/src/app .

# Make the binary scripts executable
# IMPORTANT: This step is crucial for your 'exec' commands to work.
RUN chmod +x bin/*

# Your app binds to port 3000, but Cloud Run provides its own PORT variable.
# The CMD will be updated by Cloud Run's environment settings.
EXPOSE 3000

# Define the command to run your app
CMD [ "npm", "start" ]
