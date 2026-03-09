# Use a lightweight Node.js LTS image
FROM node:18-slim

# Set working directory
WORKDIR /app

# Set environment to production
ENV NODE_ENV=production

# Copy package files first for caching
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev && npm cache clean --force

# Copy application source
COPY . .

# Expose the service port
EXPOSE 4000

# Start the application
CMD ["node", "server.js"]