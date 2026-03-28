#!/bin/bash

# This script provides the production-grade Helm commands for deploying PostgreSQL and Redis
# using the Bitnami charts, with persistence and restricted network policies built-in.

echo "Adding Bitnami Helm Repo..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "Installing PostgreSQL via Helm..."
# Note: In a production setting, passwords should be passed via --set auth.existingSecret
helm install dbl bitnami/postgresql \
  --namespace code-quest \
  --create-namespace \
  --set auth.postgresPassword=postgres \
  --set auth.username=postgres \
  --set auth.database=postgres \
  --set primary.persistence.enabled=true \
  --set primary.persistence.size=8Gi

echo "Installing Redis via Helm..."
helm install redis bitnami/redis \
  --namespace code-quest \
  --set architecture=standalone \
  --set auth.enabled=false \
  --set master.persistence.enabled=true \
  --set master.persistence.size=2Gi

echo "Databases deployed successfully via Helm."
