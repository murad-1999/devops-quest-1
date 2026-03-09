# Stage 1: Build dependencies
FROM python:3.9-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev libffi-dev

COPY requirements.txt .
# Install dependencies
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Final runtime image
FROM python:3.9-alpine

WORKDIR /app

# Copy only the installed dependencies from the builder stage
COPY --from=builder /install /usr/local

# Copy the rest of the application source code
COPY . .

# Set environment variables to optimize Python performance
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install curl for health checks in the final image
RUN apk add --no-cache curl

# Explicitly declare that the container listens on port 80
EXPOSE 80

# Run the application using gunicorn
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]