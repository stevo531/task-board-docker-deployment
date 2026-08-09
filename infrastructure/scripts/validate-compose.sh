#!/usr/bin/env bash
set -e

echo "=== Starting Challenge 3 Validation ==="

GATEWAY_URL="http://localhost:8080"

# List of routes to test through the Gateway
ENDPOINTS=(
  "/api/tasks"
  "/api/teams"
  "/api/notifications"
)

echo "Testing Gateway routing to backend microservices..."

for endpoint in "${ENDPOINTS[@]}"; do
  echo -n "Checking ${GATEWAY_URL}${endpoint} ... "
  HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "${GATEWAY_URL}${endpoint}" || true)
  
  # Fail if status is 502 Bad Gateway, 503 Service Unavailable, or 000 (unreachable)
  if [[ "$HTTP_STATUS" == "200" || "$HTTP_STATUS" == "201" || "$HTTP_STATUS" == "404" ]]; then
    echo "OK (HTTP $HTTP_STATUS)"
  else
    echo "FAILED (HTTP $HTTP_STATUS)"
    exit 1
  fi
done

echo "=== Validation Successful! All checks passed. ==="
exit 0