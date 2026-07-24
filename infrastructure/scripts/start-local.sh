#!/usr/bin/env bash
set -e

PIDS=()

cleanup() {
  echo -e "\n[INFO] Stopping background processes..."
  for pid in "${PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done
  echo "[INFO] Cleanup complete."
}
trap cleanup SIGINT SIGTERM EXIT

check_prereqs() {
  echo "[INFO] Checking prerequisites..."
  local tools=("java" "mvn" "mysql" "node" "pnpm" "curl")
  for tool in "${tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      echo "[ERROR] Missing required tool: $tool"
      exit 1
    fi
  done
}

load_env() {
  if [ -f "services/.env" ]; then
    export $(grep -v '^#' services/.env | xargs)
  else
    echo "[ERROR] services/.env file not found."
    exit 1
  fi
}

init_databases() {
  echo "[INFO] Initializing MySQL databases..."
  mysql -u"${SPRING_DATASOURCE_USERNAME}" -p"${SPRING_DATASOURCE_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS taskdb;
CREATE DATABASE IF NOT EXISTS teamdb;
CREATE DATABASE IF NOT EXISTS notificationdb;
EOF
}

wait_for_port() {
  local host=$1
  local port=$2
  local name=$3
  local retries=30

  echo "[INFO] Waiting for $name on port $port..."

  while true; do
    if curl -s "http://$host:$port" >/dev/null 2>&1; then
      echo "[INFO] $name is ready!"
      return 0
    fi

    retries=$((retries - 1))
    if [ "$retries" -le 0 ]; then
      echo "[ERROR] $name failed to start on port $port"
      exit 1
    fi

    sleep 2
  done
}

start_services() {
  echo "[INFO] Building Java services..."
  mvn clean package -DskipTests

  echo "[INFO] Starting Team Service..."
  (cd services/team-service && mvn spring-boot:run) &
  PIDS+=($!)
  wait_for_port localhost 8082 "Team Service"

  echo "[INFO] Starting Task Service..."
  (cd services/task-service && mvn spring-boot:run) &
  PIDS+=($!)
  wait_for_port localhost 8081 "Task Service"

  echo "[INFO] Starting Notification Service..."
  (cd services/notification-service && mvn spring-boot:run) &
  PIDS+=($!)
  wait_for_port localhost 8083 "Notification Service"

  echo "[INFO] Starting API Gateway..."
  (cd services/api-gateway && mvn spring-boot:run) &
  PIDS+=($!)
  wait_for_port localhost 8080 "API Gateway"

  echo "[INFO] Starting Frontend..."
  (cd frontend && pnpm dev) &
  PIDS+=($!)
  wait_for_port localhost 3000 "Frontend"

  echo "[SUCCESS] All services are running smoothly!"
  wait
}

check_prereqs
load_env
init_databases
start_services