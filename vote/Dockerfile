# Use the official Python slim image for a smaller footprint
FROM python:3.9-slim

# Set environment variables to optimize Python performance
# PYTHONDONTWRITEBYTECODE=1: Prevents Python from writing .pyc files
# PYTHONUNBUFFERED=1: Ensures logs are sent directly to the terminal
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies (curl is useful for health checks)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file first to leverage Docker's caching mechanism
COPY requirements.txt .

# Install the application's Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application source code
COPY . .

# Explicitly declare that the container listens on port 80
EXPOSE 80

# Run the application using gunicorn for better production performance
# -b 0.0.0.0:80: Bind the server to all network interfaces on port 80
# --workers 4: Use multiple worker processes for better concurrency
# --log-file -: Send logs to stdout for easy viewing in Docker logs
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]