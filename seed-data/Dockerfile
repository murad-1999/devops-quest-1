FROM python:3.9-slim

# Install apache2-utils for the 'ab' (Apache Bench) command
RUN apt-get update && \
    apt-get install -y --no-install-recommends apache2-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the generation script and run it to create vote data files
COPY make-data.py .
RUN python make-data.py

# Copy the execution script
COPY generate-votes.sh .
RUN chmod +x generate-votes.sh

# Start the vote generation process
CMD ["./generate-votes.sh"]