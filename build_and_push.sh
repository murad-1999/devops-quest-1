#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

PROJECT_ID=$(gcloud config get-value project)

# Safety check
if [ -z "$PROJECT_ID" ]; then
    echo "Error: No GCP Project ID found. Run 'gcloud config set project [ID]'"
    exit 1
fi

REGION="us-west1"
REPO_NAME="code-quest-vote"
REGISTRY="${REGION}-docker.pkg.dev"
IMAGE_PREFIX="${REGISTRY}/${PROJECT_ID}/${REPO_NAME}"

echo "Configuring Docker authentication for GCP Artifact Registry..."
gcloud auth configure-docker ${REGISTRY} --quiet

SERVICES=("vote" "worker" "result" "seed-data")

for SERVICE in "${SERVICES[@]}"; do
    IMAGE_TAG="${IMAGE_PREFIX}/${SERVICE}:latest"
    echo "======================================"
    echo "Building ${SERVICE} -> ${IMAGE_TAG}"
    echo "======================================"
    docker build -t ${IMAGE_TAG} ./${SERVICE}
    
    echo "======================================"
    echo "Pushing ${IMAGE_TAG}"
    echo "======================================"
    docker push ${IMAGE_TAG}
done

echo "======================================"
echo "All images built and pushed successfully!"
echo "======================================"
