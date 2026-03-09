# Stage 1: Generate data
FROM python:3.9-slim AS builder

WORKDIR /app

# Copy the generation script and run it to create vote data files
COPY make-data.py .
RUN python make-data.py

# Stage 2: Final runtime image
FROM alpine:3.18

# Install apache2-utils for the 'ab' (Apache Bench) command
RUN apk add --no-cache apache2-utils

WORKDIR /app

# Copy the generated data from the builder stage
COPY --from=builder /app/posta /app/postb ./

# Copy the execution script
COPY generate-votes.sh .
RUN chmod +x generate-votes.sh

# Start the vote generation process
CMD ["./generate-votes.sh"]