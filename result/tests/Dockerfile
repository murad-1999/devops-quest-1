# Stage 1: Build stage
FROM node:18-slim AS builder

RUN apt-get update -qq && apt-get install -qy \ 
    ca-certificates \
    bzip2 \
    curl \
    libfontconfig \
    --no-install-recommends

RUN npm install -g phantomjs-prebuilt

# Stage 2: Final runtime stage
FROM node:18-slim

# Install runtime dependencies
RUN apt-get update -qq && apt-get install -qy \ 
    ca-certificates \
    libfontconfig \
    curl \
    bash \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Copy phantomjs from the builder
COPY --from=builder /usr/local/bin/phantomjs /usr/local/bin/phantomjs

WORKDIR /app
COPY . .

# Ensure the script is executable
RUN chmod +x /app/tests.sh

CMD ["/app/tests.sh"]

