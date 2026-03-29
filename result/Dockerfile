# Stage 1: Build dependencies
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev && npm cache clean --force

# Stage 2: Final runtime image
FROM node:20-alpine

WORKDIR /app

# Set environment to production
ENV NODE_ENV=production

# Upgrade system packages implicitly to patch any 0-day CVEs
RUN apk upgrade --no-cache

# Copy only the node_modules from the builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application source
COPY . .

# Expose the service port
EXPOSE 4000

# Start the application
CMD ["node", "server.js"]