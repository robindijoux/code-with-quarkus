#!/bin/bash#!/bin/bash



echo "🚀 Lambda Request Tests (HTTP API v2 format)"echo "🚀 Lambda Request Tests (HTTP API v2 format)"

echo "=============================================="echo "=============================================="



LOCAL_PORT=9000LOCAL_PORT=9000

BASE_URL="http://localhost:${LOCAL_PORT}/2015-03-31/functions/function/invocations"BASE_URL="http://localhost:${LOCAL_PORT}/2015-03-31/functions/function/invocations"



# Colors for output# Colors for output

GREEN='\033[0;32m'GREEN='\033[0;32m'

BLUE='\033[0;34m'BLUE='\033[0;34m'

YELLOW='\033[1;33m'YELLOW='\033[1;33m'

RED='\033[0;31m'RED='\033[0;31m'

NC='\033[0m' # No ColorNC='\033[0m' # No Color



echo ""echo ""

echo "📡 Sending requests to local Lambda container..."echo "📡 Sending requests to local Lambda container..."

echo "   URL: ${BASE_URL}"echo "   URL: ${BASE_URL}"

echo ""echo ""



# Test 1: GET /api/hello

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}Test 1: GET /api/hello${NC}"# Test 1: GET /api/hello

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""echo -e "${BLUE}Test 1: GET /api/hello${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \echo ""

  -H "Content-Type: application/json" \

  -d '{

    "version": "2.0",

    "routeKey": "$default",RESPONSE=$(curl -s -XPOST "${BASE_URL}" \NC='\033[0m' # No ColorNC='\033[0m' # No Color

    "rawPath": "/api/hello",

    "rawQueryString": "",  -H "Content-Type: application/json" \

    "headers": {

      "accept": "text/plain"  -d '{

    },

    "requestContext": {    "version": "2.0",

      "accountId": "123456789012",

      "apiId": "api-id",    "routeKey": "$default",echo ""echo ""

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",

      "domainPrefix": "test",    "rawPath": "/api/hello",

      "http": {

        "method": "GET",    "rawQueryString": "",echo "📡 Envoi de requêtes au conteneur Lambda local..."echo "📡 Envoi de requêtes au conteneur Lambda local..."

        "path": "/api/hello",

        "protocol": "HTTP/1.1",    "headers": {

        "sourceIp": "127.0.0.1",

        "userAgent": "curl"      "accept": "text/plain"echo "   URL: ${BASE_URL}"echo "   URL: ${BASE_URL}"

      },

      "requestId": "test-id-1",    },

      "routeKey": "$default",

      "stage": "$default",    "requestContext": {echo ""echo ""

      "time": "08/Oct/2025:00:00:00 +0000",

      "timeEpoch": 1728432000000      "accountId": "123456789012",

    },

    "isBase64Encoded": false      "apiId": "api-id",

  }')

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')

if [ "$STATUS" = "200" ]; then      "domainPrefix": "test",# Test 1: GET /hello# Test 1: GET /hello

  echo -e "${GREEN}✅ Status: $STATUS${NC}"

else      "http": {

  echo -e "${RED}❌ Status: $STATUS${NC}"

fi        "method": "GET",echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Response:"

echo "$RESPONSE" | jq '.'        "path": "/api/hello",



echo ""        "protocol": "HTTP/1.1",echo -e "${BLUE}Test 1: GET /hello${NC}"echo -e "${BLUE}Test 1: GET /hello${NC}"

echo ""

        "sourceIp": "127.0.0.1",

# Test 2: GET /template/count

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"        "userAgent": "curl"echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}Test 2: GET /template/count${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"      },

echo ""

      "requestId": "test-id-1",echo ""echo ""

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \

  -H "Content-Type: application/json" \      "routeKey": "$default",

  -d '{

    "version": "2.0",      "stage": "$default",

    "routeKey": "$default",

    "rawPath": "/template/count",      "time": "08/Oct/2025:00:00:00 +0000",

    "rawQueryString": "",

    "headers": {      "timeEpoch": 1728432000000RESPONSE=$(curl -s -XPOST "${BASE_URL}" \RESPONSE=$(curl -s -XPOST "${BASE_URL}" \

      "accept": "application/json"

    },    },

    "requestContext": {

      "accountId": "123456789012",    "isBase64Encoded": false  -H "Content-Type: application/json" \  -H "Content-Type: application/json" \

      "apiId": "api-id",

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",  }')

      "domainPrefix": "test",

      "http": {  -w "\nHTTP_STATUS:%{http_code}" \  -w "\nHTTP_STATUS:%{http_code}" \

        "method": "GET",

        "path": "/template/count",STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')

        "protocol": "HTTP/1.1",

        "sourceIp": "127.0.0.1",if [ "$STATUS" = "200" ]; then  -d '{  -d '{

        "userAgent": "curl"

      },  echo -e "${GREEN}✅ Status: $STATUS${NC}"

      "requestId": "test-id-2",

      "routeKey": "$default",else    "version": "2.0",    "version": "2.0",

      "stage": "$default",

      "time": "08/Oct/2025:00:00:00 +0000",  echo -e "${RED}❌ Status: $STATUS${NC}"

      "timeEpoch": 1728432000000

    },fi    "routeKey": "$default",    "routeKey": "$default",

    "isBase64Encoded": false

  }')echo "Réponse:"



STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')echo "$RESPONSE" | jq '.'    "rawPath": "/api/hello",    "rawPath": "/api/hello",

if [ "$STATUS" = "200" ]; then

  echo -e "${GREEN}✅ Status: $STATUS${NC}"

else

  echo -e "${RED}❌ Status: $STATUS${NC}"echo ""    "rawQueryString": "",    "rawQueryString": "",

fi

echo "Response:"echo ""

echo "$RESPONSE" | jq '.'

    "headers": {    "headers": {

echo ""

echo ""# Test 2: GET /q/health



# Test 3: GET /car/1 (specific car)echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"      "accept": "text/plain"      "accept": "text/plain"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}Test 3: GET /car/1 (specific car)${NC}"echo -e "${BLUE}Test 2: GET /q/health${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"    },    },



RESPONSE=$(curl -s -XPOST "${BASE_URL}" \echo ""

  -H "Content-Type: application/json" \

  -d '{    "requestContext": {    "requestContext": {

    "version": "2.0",

    "routeKey": "$default",RESPONSE=$(curl -s -XPOST "${BASE_URL}" \

    "rawPath": "/car/1",

    "rawQueryString": "",  -H "Content-Type: application/json" \      "accountId": "123456789012",      "accountId": "123456789012",

    "headers": {

      "accept": "application/json"  -d '{

    },

    "requestContext": {    "version": "2.0",      "apiId": "api-id",      "apiId": "api-id",

      "accountId": "123456789012",

      "apiId": "api-id",    "routeKey": "$default",

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",

      "domainPrefix": "test",    "rawPath": "/q/health",      "domainName": "test.execute-api.eu-west-3.amazonaws.com",      "domainName": "test.execute-api.eu-west-3.amazonaws.com",

      "http": {

        "method": "GET",    "rawQueryString": "",

        "path": "/car/1",

        "protocol": "HTTP/1.1",    "headers": {      "domainPrefix": "test",      "domainPrefix": "test",

        "sourceIp": "127.0.0.1",

        "userAgent": "curl"      "accept": "application/json"

      },

      "requestId": "test-id-3",    },      "http": {      "http": {

      "routeKey": "$default",

      "stage": "$default",    "requestContext": {

      "time": "08/Oct/2025:00:00:00 +0000",

      "timeEpoch": 1728432000000      "accountId": "123456789012",        "method": "GET",        "method": "GET",

    },

    "isBase64Encoded": false      "apiId": "api-id",

  }')

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",        "path": "/api/hello",        "path": "/api/hello",

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')

if [ "$STATUS" = "200" ]; then      "domainPrefix": "test",

  echo -e "${GREEN}✅ Status: $STATUS${NC}"

else      "http": {        "protocol": "HTTP/1.1",        "protocol": "HTTP/1.1",

  echo -e "${RED}❌ Status: $STATUS${NC}"

fi        "method": "GET",

echo "Response:"

echo "$RESPONSE" | jq '.'        "path": "/q/health",        "sourceIp": "127.0.0.1",        "sourceIp": "127.0.0.1",



echo ""        "protocol": "HTTP/1.1",

echo ""

        "sourceIp": "127.0.0.1",        "userAgent": "curl"        "userAgent": "curl"

# Test 4: POST /car (create a car)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"        "userAgent": "curl"

echo -e "${BLUE}Test 4: POST /car (create a car)${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"      },      },      },

echo ""

      "requestId": "test-id-2",

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \

  -H "Content-Type: application/json" \      "routeKey": "$default",      "requestId": "test-id-1",      "requestId": "test-id-1",

  -d '{

    "version": "2.0",      "stage": "$default",

    "routeKey": "$default",

    "rawPath": "/car",      "time": "08/Oct/2025:00:00:00 +0000",      "routeKey": "$default",      "routeKey": "$default",

    "rawQueryString": "",

    "headers": {      "timeEpoch": 1728432000000

      "accept": "application/json",

      "content-type": "application/json"    },      "stage": "$default",      "stage": "$default",

    },

    "requestContext": {    "isBase64Encoded": false

      "accountId": "123456789012",

      "apiId": "api-id",  }')      "time": "08/Oct/2025:00:00:00 +0000",      "time": "08/Oct/2025:00:00:00 +0000",

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",

      "domainPrefix": "test",

      "http": {

        "method": "POST",STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')      "timeEpoch": 1728432000000      "timeEpoch": 1728432000000

        "path": "/car",

        "protocol": "HTTP/1.1",if [ "$STATUS" = "200" ]; then

        "sourceIp": "127.0.0.1",

        "userAgent": "curl"  echo -e "${GREEN}✅ Status: $STATUS${NC}"    },    },

      },

      "requestId": "test-id-4",else

      "routeKey": "$default",

      "stage": "$default",  echo -e "${RED}❌ Status: $STATUS${NC}"    "isBase64Encoded": false    "isBase64Encoded": false

      "time": "08/Oct/2025:00:00:00 +0000",

      "timeEpoch": 1728432000000fi

    },

    "body": "{\"brand\":\"Audi\",\"model\":\"e-tron\"}",echo "Réponse:"  }')  }')

    "isBase64Encoded": false

  }')echo "$RESPONSE" | jq '.'



STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')

if [ "$STATUS" = "201" ]; then

  echo -e "${GREEN}✅ Status: $STATUS (Created)${NC}"echo ""

else

  echo -e "${RED}❌ Status: $STATUS (expected: 201)${NC}"echo ""STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')

fi

echo "Response:"echo -e "${YELLOW}✨ Tests terminés !${NC}"

echo "$RESPONSE" | jq '.'

echo ""if [ "$STATUS" = "200" ]; thenif [ "$STATUS" = "200" ]; then

echo ""

echo ""echo "Pour tester avec une vraie Lambda AWS, remplacez BASE_URL par votre URL de fonction Lambda."



# Test 5: PUT /car/1 (update a car)echo "Exemple: BASE_URL=\"https://xyz.lambda-url.eu-west-3.on.aws/\""  echo -e "${GREEN}✅ Status: $STATUS${NC}"  echo -e "${GREEN}✅ Status: $STATUS${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}Test 5: PUT /car/1 (update)${NC}"elseelse

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""  echo -e "${RED}❌ Status: $STATUS${NC}"  echo -e "${RED}❌ Status: $STATUS${NC}"



RESPONSE=$(curl -s -XPOST "${BASE_URL}" \fifi

  -H "Content-Type: application/json" \

  -d '{echo "Réponse:"echo "Réponse:"

    "version": "2.0",

    "routeKey": "$default",echo "$RESPONSE" | jq '.'echo "$RESPONSE" | jq '.'

    "rawPath": "/car/1",

    "rawQueryString": "",

    "headers": {

      "accept": "application/json",echo ""echo ""

      "content-type": "application/json"

    },echo ""echo ""

    "requestContext": {

      "accountId": "123456789012",

      "apiId": "api-id",

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",# Test 2: GET /template/count# Test 2: GET /template/count

      "domainPrefix": "test",

      "http": {echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        "method": "PUT",

        "path": "/car/1",echo -e "${BLUE}Test 2: GET /template/count${NC}"# Test 3: GET /car/1 (une voiture spécifique)

        "protocol": "HTTP/1.1",

        "sourceIp": "127.0.0.1",echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        "userAgent": "curl"

      },echo ""echo -e "${BLUE}Test 3: GET /car/1 (voiture spécifique)${NC}"

      "requestId": "test-id-5",

      "routeKey": "$default",echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

      "stage": "$default",

      "time": "08/Oct/2025:00:00:00 +0000",RESPONSE=$(curl -s -XPOST "${BASE_URL}" \echo ""

      "timeEpoch": 1728432000000

    },  -H "Content-Type: application/json" \

    "body": "{\"brand\":\"Tesla\",\"model\":\"Model S\"}",

    "isBase64Encoded": false  -d '{RESPONSE=$(curl -s -XPOST "${BASE_URL}" \

  }')

    "version": "2.0",  -H "Content-Type: application/json" \

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')

if [ "$STATUS" = "200" ]; then    "routeKey": "$default",  -d '{

  echo -e "${GREEN}✅ Status: $STATUS${NC}"

else    "rawPath": "/template/count",    "version": "2.0",

  echo -e "${RED}❌ Status: $STATUS${NC}"

fi    "rawQueryString": "",    "routeKey": "$default",

echo "Response:"

echo "$RESPONSE" | jq '.'    "headers": {    "rawPath": "/car/1",



echo ""      "accept": "application/json"    "rawQueryString": "",

echo ""

    },    "headers": {

# Test 6: DELETE /car/2

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"    "requestContext": {      "accept": "application/json"

echo -e "${BLUE}Test 6: DELETE /car/2${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"      "accountId": "123456789012",    },

echo ""

      "apiId": "api-id",    "requestContext": {

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \

  -H "Content-Type: application/json" \      "domainName": "test.execute-api.eu-west-3.amazonaws.com",      "accountId": "123456789012",

  -d '{

    "version": "2.0",      "domainPrefix": "test",      "apiId": "api-id",

    "routeKey": "$default",

    "rawPath": "/car/2",      "http": {      "domainName": "test.execute-api.eu-west-3.amazonaws.com",

    "rawQueryString": "",

    "headers": {        "method": "GET",      "domainPrefix": "test",

      "accept": "application/json"

    },        "path": "/template/count",      "http": {

    "requestContext": {

      "accountId": "123456789012",        "protocol": "HTTP/1.1",        "method": "GET",

      "apiId": "api-id",

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",        "sourceIp": "127.0.0.1",        "path": "/car/1",

      "domainPrefix": "test",

      "http": {        "userAgent": "curl"        "protocol": "HTTP/1.1",

        "method": "DELETE",

        "path": "/car/2",      },        "sourceIp": "127.0.0.1",

        "protocol": "HTTP/1.1",

        "sourceIp": "127.0.0.1",      "requestId": "test-id-2",        "userAgent": "curl"

        "userAgent": "curl"

      },      "routeKey": "$default",      },

      "requestId": "test-id-6",

      "routeKey": "$default",      "stage": "$default",      "requestId": "test-id-3",

      "stage": "$default",

      "time": "08/Oct/2025:00:00:00 +0000",      "time": "08/Oct/2025:00:00:00 +0000",      "routeKey": "$default",

      "timeEpoch": 1728432000000

    },      "timeEpoch": 1728432000000      "stage": "$default",

    "isBase64Encoded": false

  }')    },      "time": "08/Oct/2025:00:00:00 +0000",



STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')    "isBase64Encoded": false      "timeEpoch": 1728432000000

if [ "$STATUS" = "204" ]; then

  echo -e "${GREEN}✅ Status: $STATUS (No Content)${NC}"  }')    },

else

  echo -e "${RED}❌ Status: $STATUS (expected: 204)${NC}"    "isBase64Encoded": false

fi

echo "Response:"STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')  }')

echo "$RESPONSE" | jq '.'

if [ "$STATUS" = "200" ]; then

echo ""

echo ""  echo -e "${GREEN}✅ Status: $STATUS${NC}"STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')



# Test 7: Non-existent route (404)elseif [ "$STATUS" = "200" ]; then

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}Test 7: Non-existent route (404)${NC}"  echo -e "${RED}❌ Status: $STATUS${NC}"  echo -e "${GREEN}✅ Status: $STATUS${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""fielse



RESPONSE=$(curl -s -XPOST "${BASE_URL}" \echo "Réponse:"  echo -e "${RED}❌ Status: $STATUS${NC}"

  -H "Content-Type: application/json" \

  -d '{echo "$RESPONSE" | jq '.'fi

    "version": "2.0",

    "routeKey": "$default",echo "Réponse:"

    "rawPath": "/notfound",

    "rawQueryString": "",echo ""echo "$RESPONSE" | jq '.'

    "headers": {

      "accept": "application/json"echo ""

    },

    "requestContext": {echo ""

      "accountId": "123456789012",

      "apiId": "api-id",# Test 3: GET /examplesecho ""

      "domainName": "test.execute-api.eu-west-3.amazonaws.com",

      "domainPrefix": "test",echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

      "http": {

        "method": "GET",echo -e "${BLUE}Test 3: GET /examples${NC}"# Test 4: POST /car (créer une voiture)

        "path": "/notfound",

        "protocol": "HTTP/1.1",echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        "sourceIp": "127.0.0.1",

        "userAgent": "curl"echo ""echo -e "${BLUE}Test 4: POST /car (créer une voiture)${NC}"

      },

      "requestId": "test-id-7",echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

      "routeKey": "$default",

      "stage": "$default",RESPONSE=$(curl -s -XPOST "${BASE_URL}" \echo ""

      "time": "08/Oct/2025:00:00:00 +0000",

      "timeEpoch": 1728432000000  -H "Content-Type: application/json" \

    },

    "isBase64Encoded": false  -d '{RESPONSE=$(curl -s -XPOST "${BASE_URL}" \

  }')

    "version": "2.0",  -H "Content-Type: application/json" \

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')

if [ "$STATUS" = "404" ]; then    "routeKey": "$default",  -d '{

  echo -e "${GREEN}✅ Status: $STATUS (Not Found)${NC}"

else    "rawPath": "/examples",    "version": "2.0",

  echo -e "${YELLOW}⚠️  Status: $STATUS (expected: 404)${NC}"

fi    "rawQueryString": "",    "routeKey": "$default",

echo "Response:"

echo "$RESPONSE" | jq '.'    "headers": {    "rawPath": "/car",



echo ""      "accept": "application/json"    "rawQueryString": "",

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"    },    "headers": {

echo -e "${GREEN}✅ Tests completed${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"    "requestContext": {      "accept": "application/json",

echo ""

echo -e "${YELLOW}💡 Format used: AWS Lambda HTTP API v2${NC}"      "accountId": "123456789012",      "content-type": "application/json"

echo "   This format is compatible with:"

echo "   - API Gateway HTTP API (v2)"      "apiId": "api-id",    },

echo "   - Lambda Function URLs"

echo ""      "domainName": "test.execute-api.eu-west-3.amazonaws.com",    "requestContext": {

echo "To test with a real AWS Lambda, replace BASE_URL with your Lambda function URL."

echo "Example: BASE_URL=\"https://xyz.lambda-url.eu-west-3.on.aws/\""      "domainPrefix": "test",      "accountId": "123456789012",

      "http": {      "apiId": "api-id",

        "method": "GET",      "domainName": "test.execute-api.eu-west-3.amazonaws.com",

        "path": "/examples",      "domainPrefix": "test",

        "protocol": "HTTP/1.1",      "http": {

        "sourceIp": "127.0.0.1",        "method": "POST",

        "userAgent": "curl"        "path": "/car",

      },        "protocol": "HTTP/1.1",

      "requestId": "test-id-3",        "sourceIp": "127.0.0.1",

      "routeKey": "$default",        "userAgent": "curl"

      "stage": "$default",      },

      "time": "08/Oct/2025:00:00:00 +0000",      "requestId": "test-id-4",

      "timeEpoch": 1728432000000      "routeKey": "$default",

    },      "stage": "$default",

    "isBase64Encoded": false      "time": "08/Oct/2025:00:00:00 +0000",

  }')      "timeEpoch": 1728432000000

    },

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')    "body": "{\"brand\":\"Audi\",\"model\":\"e-tron\"}",

if [ "$STATUS" = "200" ]; then    "isBase64Encoded": false

  echo -e "${GREEN}✅ Status: $STATUS${NC}"  }')

else

  echo -e "${RED}❌ Status: $STATUS${NC}"STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')

fiif [ "$STATUS" = "201" ]; then

echo "Réponse:"  echo -e "${GREEN}✅ Status: $STATUS (Created)${NC}"

echo "$RESPONSE" | jq '.'else

  echo -e "${RED}❌ Status: $STATUS (attendu: 201)${NC}"

echo ""fi

echo ""echo "Réponse:"

echo -e "${YELLOW}✨ Tests terminés !${NC}"echo "$RESPONSE" | jq '.'

echo ""

echo "Pour tester avec une vraie Lambda AWS, remplacez BASE_URL par votre URL de fonction Lambda."echo ""

echo "Exemple: BASE_URL=\"https://xyz.lambda-url.eu-west-3.on.aws/\""echo ""

# Test 5: PUT /car/1 (mettre à jour une voiture)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Test 5: PUT /car/1 (mettre à jour)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "2.0",
    "routeKey": "$default",
    "rawPath": "/car/1",
    "rawQueryString": "",
    "headers": {
      "accept": "application/json",
      "content-type": "application/json"
    },
    "requestContext": {
      "accountId": "123456789012",
      "apiId": "api-id",
      "domainName": "test.execute-api.eu-west-3.amazonaws.com",
      "domainPrefix": "test",
      "http": {
        "method": "PUT",
        "path": "/car/1",
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
    "body": "{\"brand\":\"Tesla\",\"model\":\"Model S\"}",
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

# Test 6: DELETE /car/2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Test 6: DELETE /car/2${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RESPONSE=$(curl -s -XPOST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "2.0",
    "routeKey": "$default",
    "rawPath": "/car/2",
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
        "method": "DELETE",
        "path": "/car/2",
        "protocol": "HTTP/1.1",
        "sourceIp": "127.0.0.1",
        "userAgent": "curl"
      },
      "requestId": "test-id-6",
      "routeKey": "$default",
      "stage": "$default",
      "time": "08/Oct/2025:00:00:00 +0000",
      "timeEpoch": 1728432000000
    },
    "isBase64Encoded": false
  }')

STATUS=$(echo "$RESPONSE" | jq -r '.statusCode')
if [ "$STATUS" = "204" ]; then
  echo -e "${GREEN}✅ Status: $STATUS (No Content)${NC}"
else
  echo -e "${RED}❌ Status: $STATUS (attendu: 204)${NC}"
fi
echo "Réponse:"
echo "$RESPONSE" | jq '.'

echo ""
echo ""

# Test 7: Route inexistante (404)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Test 7: Route inexistante (404)${NC}"
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
      "requestId": "test-id-7",
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
echo -e "${YELLOW}💡 Format utilisé: AWS Lambda HTTP API v2${NC}"
echo "   Ce format est compatible avec:"
echo "   - API Gateway HTTP API (v2)"
echo "   - Lambda Function URLs"
echo ""
