#!/bin/bash

echo "🚀 Lambda Request Tests (HTTP API v2 format)"
echo "=============================================="

LOCAL_PORT=9000
BASE_URL="http://localhost:${LOCAL_PORT}/2015-03-31/functions/function/invocations"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo "📡 Envoi de requêtes au conteneur Lambda local..."
echo "   URL: ${BASE_URL}"
echo ""

# Test 1: GET /hello
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Test 1: GET /hello${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "2.0",
    "routeKey": "$default",
    "rawPath": "/hello",
    "rawQueryString": "",
    "headers": {
      "accept": "text/plain"
    },
    "requestContext": {
      "accountId": "123456789012",
      "apiId": "api-id",
      "domainName": "test.execute-api.eu-west-3.amazonaws.com",
      "domainPrefix": "test",
      "http": {
        "method": "GET",
        "path": "/hello",
        "protocol": "HTTP/1.1",
        "sourceIp": "127.0.0.1",
        "userAgent": "curl"
      },
      "requestId": "test-id-1",
      "routeKey": "$default",
      "stage": "$default",
      "time": "08/Oct/2025:00:00:00 +0000",
      "timeEpoch": 1728432000000
    },
    "isBase64Encoded": false
  }')

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')
if [ "$STATUS" = "200" ]; then
  echo -e "${GREEN}✅ Status: $STATUS${NC}"
else
  echo -e "${RED}❌ Status: $STATUS${NC}"
fi
echo "Réponse:"
echo "$RESPONSE" | jq '.'

echo ""
echo ""

# Test 2: GET /q/health
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Test 2: GET /q/health${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "2.0",
    "routeKey": "$default",
    "rawPath": "/q/health",
    "rawQueryString": "",
    "headers": {
      "accept": "application/json"
    },
    "requestContext": {
      "accountId": "123456789012",
      "apiId": "api-id",
      "domainName": "test.execute-api.eu-west-3.amazonaws.com",
      "domainPrefix": "test",
      "http": {
        "method": "GET",
        "path": "/q/health",
        "protocol": "HTTP/1.1",
        "sourceIp": "127.0.0.1",
        "userAgent": "curl"
      },
      "requestId": "test-id-2",
      "routeKey": "$default",
      "stage": "$default",
      "time": "08/Oct/2025:00:00:00 +0000",
      "timeEpoch": 1728432000000
    },
    "isBase64Encoded": false
  }')

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')
if [ "$STATUS" = "200" ]; then
  echo -e "${GREEN}✅ Status: $STATUS${NC}"
else
  echo -e "${RED}❌ Status: $STATUS${NC}"
fi
echo "Réponse:"
echo "$RESPONSE" | jq '.'

echo ""
echo ""

# Test 3: GET /q/health/live (liveness check)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Test 3: GET /q/health/live (liveness check)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "2.0",
    "routeKey": "$default",
    "rawPath": "/q/health/live",
    "rawQueryString": "",
    "headers": {
      "accept": "application/json"
    },
    "requestContext": {
      "accountId": "123456789012",
      "apiId": "api-id",
      "domainName": "test.execute-api.eu-west-3.amazonaws.com",
      "domainPrefix": "test",
      "http": {
        "method": "GET",
        "path": "/q/health/live",
        "protocol": "HTTP/1.1",
        "sourceIp": "127.0.0.1",
        "userAgent": "curl"
      },
      "requestId": "test-id-3",
      "routeKey": "$default",
      "stage": "$default",
      "time": "08/Oct/2025:00:00:00 +0000",
      "timeEpoch": 1728432000000
    },
    "isBase64Encoded": false
  }')

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')
if [ "$STATUS" = "200" ]; then
  echo -e "${GREEN}✅ Status: $STATUS${NC}"
else
  echo -e "${RED}❌ Status: $STATUS${NC}"
fi
echo "Réponse:"
echo "$RESPONSE" | jq '.'

echo ""
echo ""

# Test 4: GET /q/health/ready (readiness check)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Test 4: GET /q/health/ready (readiness check)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "2.0",
    "routeKey": "$default",
    "rawPath": "/q/health/ready",
    "rawQueryString": "",
    "headers": {
      "accept": "application/json"
    },
    "requestContext": {
      "accountId": "123456789012",
      "apiId": "api-id",
      "domainName": "test.execute-api.eu-west-3.amazonaws.com",
      "domainPrefix": "test",
      "http": {
        "method": "GET",
        "path": "/q/health/ready",
        "protocol": "HTTP/1.1",
        "sourceIp": "127.0.0.1",
        "userAgent": "curl"
      },
      "requestId": "test-id-4",
      "routeKey": "$default",
      "stage": "$default",
      "time": "08/Oct/2025:00:00:00 +0000",
      "timeEpoch": 1728432000000
    },
    "isBase64Encoded": false
  }')

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')
if [ "$STATUS" = "200" ]; then
  echo -e "${GREEN}✅ Status: $STATUS${NC}"
else
  echo -e "${RED}❌ Status: $STATUS${NC}"
fi
echo "Réponse:"
echo "$RESPONSE" | jq '.'

echo ""
echo ""

# Test 5: Route inexistante (404)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Test 5: Route inexistante (404)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "2.0",
    "routeKey": "$default",
    "rawPath": "/notfound",
    "rawQueryString": "",
    "headers": {
      "accept": "application/json"
    },
    "requestContext": {
      "accountId": "123456789012",
      "apiId": "api-id",
      "domainName": "test.execute-api.eu-west-3.amazonaws.com",
      "domainPrefix": "test",
      "http": {
        "method": "GET",
        "path": "/notfound",
        "protocol": "HTTP/1.1",
        "sourceIp": "127.0.0.1",
        "userAgent": "curl"
      },
      "requestId": "test-id-5",
      "routeKey": "$default",
      "stage": "$default",
      "time": "08/Oct/2025:00:00:00 +0000",
      "timeEpoch": 1728432000000
    },
    "isBase64Encoded": false
  }')

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')
if [ "$STATUS" = "404" ]; then
  echo -e "${GREEN}✅ Status: $STATUS (Not Found)${NC}"
else
  echo -e "${YELLOW}⚠️  Status: $STATUS (attendu: 404)${NC}"
fi
echo "Réponse:"
echo "$RESPONSE" | jq '.'

echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Tests terminés${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}💡 Routes testées:${NC}"
echo "   ✅ GET /hello - Endpoint principal"
echo "   ✅ GET /q/health - Health check global"
echo "   ✅ GET /q/health/live - Liveness probe"
echo "   ✅ GET /q/health/ready - Readiness probe"
echo "   ✅ GET /notfound - Test d'erreur 404"
echo ""
echo -e "${YELLOW}💡 Format utilisé: AWS Lambda HTTP API v2${NC}"
echo "   Ce format est compatible avec:"
echo "   - API Gateway HTTP API (v2)"
echo "   - Lambda Function URLs"
echo ""
echo "Pour tester avec une vraie Lambda AWS, remplacez BASE_URL par votre URL de fonction Lambda."
echo "Exemple: BASE_URL=\"https://xyz.lambda-url.eu-west-3.on.aws/\""