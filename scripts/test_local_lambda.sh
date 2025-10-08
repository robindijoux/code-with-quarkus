#!/bin/bash

echo "🧪 Local Lambda Image Test"
echo "=========================="

# Configuration
REGION="eu-west-3"
REPO_NAME="portfolio-rbndjx"
read -rp "Enter image tag to test (default: latest): " IMAGE_TAG
IMAGE_TAG=${IMAGE_TAG:-latest}
REGISTRY="259726931000.dkr.ecr.${REGION}.amazonaws.com"
FULL_IMAGE="${REGISTRY}/${REPO_NAME}:${IMAGE_TAG}"
LOCAL_PORT=9000

echo ""
echo "📋 Configuration:"
echo "  - Image: ${FULL_IMAGE}"
echo "  - Local port: ${LOCAL_PORT}"
echo ""

# 1. Login and pull image
echo "1️⃣  ECR login and image pull..."
aws ecr get-login-password --region ${REGION} | \
  docker login --username AWS --password-stdin ${REGISTRY}

if [ $? -ne 0 ]; then
  echo "❌ ECR login failed"
  exit 1
fi

docker pull ${FULL_IMAGE}

if [ $? -ne 0 ]; then
  echo "❌ Image pull failed"
  exit 1
fi

echo "✅ Image pulled successfully"

# 2. Stop existing container if present
echo ""
echo "2️⃣  Cleaning up existing containers..."
docker stop lambda-test 2>/dev/null || true
docker rm lambda-test 2>/dev/null || true
echo "✅ Cleanup completed"

# 3. Start container
echo ""
echo "3️⃣  Starting Lambda container..."
echo "    The container will start in interactive mode."
echo "    Press Ctrl+C to stop."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📡 Container listening on http://localhost:${LOCAL_PORT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To test, open ANOTHER terminal and run:"
echo ""
echo "  ./test_lambda_requests.sh"
echo ""
echo "Or manually:"
echo ""
echo "  # Test a GET request"
echo "  curl -XPOST \"http://localhost:${LOCAL_PORT}/2015-03-31/functions/function/invocations\" \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"httpMethod\": \"GET\", \"path\": \"/hello\", \"headers\": {}}'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Cleanup function
cleanup() {
  echo ""
  echo ""
  echo "🛑 Stopping container..."
  docker stop lambda-test 2>/dev/null || true
  docker rm lambda-test 2>/dev/null || true
  echo "✅ Container stopped"
  exit 0
}

trap cleanup SIGINT SIGTERM

# Launch container with necessary environment variables
docker run --rm --name lambda-test -p ${LOCAL_PORT}:8080 \
  -e AWS_REGION=${REGION} \
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-dummy} \
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-dummy} \
  -e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN:-} \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_NAME=portfolio \
  -e DB_USERNAME=portfolio_user \
  -e DB_PASSWORD=portfolio_password \
  -e DB_GENERATION=update \
  -e AWS_COGNITO_JWKS_URL=https://dummy.url/jwks \
  -e AWS_COGNITO_ISSUER=https://dummy.issuer \
  -e FRONTEND_URL=http://localhost:3000 \
  ${FULL_IMAGE}

# If docker run terminates, cleanup
cleanup
