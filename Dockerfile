# Use an official lightweight Alpine Linux image as the base
FROM node:20-alpine

# Set environment variables for unRAID UID and GID
ENV PUID=99
ENV PGID=100

# Set the working directory
WORKDIR /app

# Install dependencies as root
RUN apk add --no-cache git bash curl

# Create a non-root user matching unRAID standards
RUN addgroup -g ${PGID} thorium && \
    adduser -u ${PUID} -G thorium -D thorium

# Temporarily switch to the non-root user to clone the repository
USER thorium
RUN git clone https://github.com/Thorium-Sim/thorium-nova.git /app

# Switch back to root to install dependencies
USER root
WORKDIR /app
RUN npm install && npm run init:plugin

# Set ownership of the app directory to the unRAID-compatible user
RUN chown -R thorium:thorium /app

# Switch back to the non-root user
USER thorium

# Expose the port the application runs on
EXPOSE 3000

# Default command to run the development server
CMD ["npm", "run", "dev"]
