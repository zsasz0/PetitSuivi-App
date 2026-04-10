# React Frontend Dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies (using legacy-peer-deps for older package compatibility)
RUN npm install --legacy-peer-deps

# Copy the rest of the application
COPY . .

# Expose port 5000
EXPOSE 5000

# Set environment variables for development server
ENV PORT=5000
ENV HOST=0.0.0.0
ENV CHOKIDAR_USEPOLLING=true
ENV WATCHPACK_POLLING=true

# Start the development server
CMD ["npm", "run", "dev"]
