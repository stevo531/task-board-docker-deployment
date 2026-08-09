#!/usr/bin/env bash
set -uo pipefail

NAMESPACE="taskboard"
INGRESS_NAMESPACE="ingress-nginx"
PROBE_IMAGE="curlimages/curl:8.5.0"
TEST_RUN_ID="$(date +%s)"

FAILED=0
TOTAL=0
ACTIVE_PODS=""

log() { printf '%s\n' "$*"; }

cleanup() {
  for pod in $ACTIVE_PODS; do
    kubectl delete pod "$pod" -n "$NAMESPACE" --ignore-not-found --grace-period=0 --force >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT

kubectl delete pod -n "$NAMESPACE" -l test-runner=true --ignore-not-found --grace-period=0 --force >/dev/null 2>&1 || true
kubectl delete pod -n "$INGRESS_NAMESPACE" -l test-runner=true --ignore-not-found --grace-period=0 --force >/dev/null 2>&1 || true

wait_pod_ready() {
  local pod="$1" ns="$2" i
  for i in $(seq 1 30); do
    local phase
    phase="$(kubectl get pod "$pod" -n "$ns" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
    if [ "$phase" = "Running" ]; then
      return 0
    fi
    if [ "$phase" = "Succeeded" ] || [ "$phase" = "Failed" ]; then
      return 1
    fi
    sleep 1
  done
  return 1
}

run_probe() {
  local desc="$1"
  local ns="$2"
  local src_labels="$3"
  local target="$4"
  local port="$5"
  local expected="$6"

  TOTAL=$((TOTAL + 1))
  local pod_name="net-test-${TEST_RUN_ID}-${TOTAL}"

  kubectl run "$pod_name" -n "$ns" \
    --image="$PROBE_IMAGE" \
    --labels="test-runner=true,${src_labels}" \
    --restart=Never \
    --command -- sleep 30 >/dev/null 2>&1 || { echo "[FAIL] $desc (could not create probe pod)"; FAILED=$((FAILED + 1)); return; }

  ACTIVE_PODS="$ACTIVE_PODS $pod_name"

  if ! wait_pod_ready "$pod_name" "$ns"; then
    echo "[FAIL] $desc (probe pod $pod_name never became ready)"
    FAILED=$((FAILED + 1))
    return
  fi

  if kubectl exec "$pod_name" -n "$ns" -- sh -c \
    "curl -sv --connect-timeout 3 --max-time 6 telnet://$target:$port </dev/null 2>&1 | grep -q 'Connected to'" >/dev/null 2>&1; then
    result="SUCCESS"
  else
    result="BLOCKED"
  fi

  if [ "$expected" = "PASS" ]; then
    if [ "$result" = "SUCCESS" ]; then
      echo "[PASS] $desc ($target:$port reachable as expected)"
    else
      echo "[FAIL] $desc ($target:$port connection failed/blocked, but expected PASS)"
      FAILED=$((FAILED + 1))
    fi
  else
    if [ "$result" = "BLOCKED" ]; then
      echo "[PASS] $desc ($target:$port blocked/refused as expected)"
    else
      echo "[FAIL] $desc ($target:$port reached successfully, but expected isolation)"
      FAILED=$((FAILED + 1))
    fi
  fi
}

echo "=== Starting Network Isolation Validation Suite ==="
echo "=== Executing Matrix Validation Checks ==="

INGRESS_LABELS="app.kubernetes.io/name=ingress-nginx"
FRONTEND_LABELS="app=frontend"
GATEWAY_LABELS="app=api-gateway"
TASK_LABELS="app=task-service"
NOTIF_LABELS="app=notification-service"

run_probe "Ingress -> Frontend" "$INGRESS_NAMESPACE" "$INGRESS_LABELS" "frontend.taskboard.svc.cluster.local" "3000" "PASS"

run_probe "Ingress -> Gateway" "$INGRESS_NAMESPACE" "$INGRESS_LABELS" "api-gateway.taskboard.svc.cluster.local" "8080" "PASS"

run_probe "Frontend -> Gateway" "$NAMESPACE" "$FRONTEND_LABELS" "api-gateway" "8080" "PASS"

run_probe "Frontend -> Task Service (Forbidden)" "$NAMESPACE" "$FRONTEND_LABELS" "task-service" "8081" "FAIL"

run_probe "Gateway -> Task Service" "$NAMESPACE" "$GATEWAY_LABELS" "task-service" "8081" "PASS"

run_probe "Gateway -> Team Service" "$NAMESPACE" "$GATEWAY_LABELS" "team-service" "8082" "PASS"

run_probe "Gateway -> Notification Service" "$NAMESPACE" "$GATEWAY_LABELS" "notification-service" "8083" "PASS"

run_probe "Task Service -> Team Service" "$NAMESPACE" "$TASK_LABELS" "team-service" "8082" "PASS"

run_probe "Task Service -> RabbitMQ" "$NAMESPACE" "$TASK_LABELS" "rabbitmq" "5672" "PASS"

run_probe "Notification Service -> RabbitMQ" "$NAMESPACE" "$NOTIF_LABELS" "rabbitmq" "5672" "PASS"

run_probe "Task Service -> MySQL" "$NAMESPACE" "$TASK_LABELS" "mysql" "3306" "PASS"

run_probe "Notification Service -> Team Service (Forbidden)" "$NAMESPACE" "$NOTIF_LABELS" "team-service" "8082" "FAIL"

run_probe "Task Service -> Kube-DNS" "$NAMESPACE" "$TASK_LABELS" "kube-dns.kube-system.svc.cluster.local" "53" "PASS"

echo "-----------------------------------"
if [ "$FAILED" -eq 0 ]; then
  echo "All $TOTAL network isolation matrix checks passed successfully!"
  exit 0
else
  echo "$FAILED out of $TOTAL network checks failed validation."
  exit 1
fi
