#!/bin/bash
set -e
export PATH=$PATH:~/.local/bin

echo "Authenticating via Kubeconfig..."
gcloud container clusters get-credentials dev-gke-cluster --region us-west1 --project project-749947f2-d37f-4dad-9f9

echo "Installing External Secrets Operator..."
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace \
  --set serviceAccount.annotations."iam\.gke\.io/gcp-service-account"="dev-eso-sa@project-749947f2-d37f-4dad-9f9.iam.gserviceaccount.com" \
  --wait || true

echo "Installing Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --wait || true

echo "Fetching LoadBalancer IP..."
INGRESS_IP=""
for i in {1..30}; do
  INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
  if [ -n "$INGRESS_IP" ] && [ "$INGRESS_IP" != "<pending>" ]; then break; fi
  echo "Waiting for IP..."
  sleep 5
done
echo "Ingress IP resolved: $INGRESS_IP"
DOMAIN="${INGRESS_IP}.nip.io"

echo "Deploying the Main Microservices Architecture (Code-Quest)..."
helm upgrade --install code-quest ./helm/code-quest \
  --namespace code-quest \
  --create-namespace \
  --set global.domain=$DOMAIN \
  --set global.imageTag=latest \
  --wait=false || true

echo "Waiting for ESO to pull the GCP Secret into the cluster..."
sleep 15

echo "Installing Baseline Databases (PostgreSQL & Redis)..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install Postgres relying on the 'code-quest-secret' that ESO just fetched from GCP
helm install dbl bitnami/postgresql \
  --namespace code-quest \
  --set auth.existingSecret=code-quest-secret \
  --set auth.secretKeys.adminPasswordKey=POSTGRES_PASSWORD \
  --set auth.database=postgres \
  --set auth.username=postgres \
  --set primary.persistence.enabled=true \
  --set primary.persistence.size=8Gi \
  --wait=false || true

helm install redis bitnami/redis \
  --namespace code-quest \
  --set architecture=standalone \
  --set auth.enabled=false \
  --set master.persistence.enabled=true \
  --set master.persistence.size=2Gi \
  --wait=false || true
