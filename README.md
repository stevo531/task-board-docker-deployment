# Team Task Board Platform

A microservices-based task management platform with teams, tasks, and event-driven notifications.

## Architecture

### Request flow (HTTP)

```
                  ┌─────────────────────┐
                  │      Frontend        │
                  │     (Next.js)        │
                  └──────────┬──────────┘
                             │
                           HTTP
                             ▼
                  ┌─────────────────────┐
                  │    API Gateway       │
                  │       :8080          │
                  └──┬──────┬──────┬─────┘
                     │      │      │
          ┌──────────┘      │      └────────────┐
          ▼                 ▼                   ▼
┌────────────────┐ ┌────────────────┐ ┌────────────────────┐
│  Task Service  │ │  Team Service  │ │ Notification Svc  │
│    :8081       │ │    :8082       │ │    :8083           │
│  MySQL taskdb  │ │  MySQL teamdb  │ │ MySQL notifdb      │
└───────┬────────┘ └────────────────┘ └────────────────────┘
        │ HTTP (member validation)
        └──────────────────────────────────────────────────┘
```

### Event flow (RabbitMQ)

```
Task Service ──publishes──▶ RabbitMQ ──consumes──▶ Notification Service
  (task.assigned, task.completed, task.status.changed)
```

### Services

| Service | Port | Responsibility | Datastore |
|---------|------|----------------|-----------|
| Frontend | 3000 | User interface (Next.js) | — |
| API Gateway | 8080 | Routes traffic to backend services | — |
| Task Service | 8081 | Task CRUD, assignment, status transitions | MySQL `taskdb` |
| Team Service | 8082 | Team and member management | MySQL `teamdb` |
| Notification Service | 8083 | Consumes RabbitMQ events, persists + serves notifications | MySQL `notificationdb` |

The Gateway is the single entry point — the frontend never calls backend services directly.
Task Service calls Team Service synchronously to validate member assignments.
Events (task assigned, completed, status changed) flow asynchronously through RabbitMQ.

## Quick start

```bash
# Prerequisites: Java 17+, Maven 3.8+, MySQL 8.0+, RabbitMQ 3.x+
mvn clean install -DskipTests

# Start in this order (separate terminals):
cd services/team-service       && mvn spring-boot:run   # port 8082
cd services/task-service       && mvn spring-boot:run   # port 8081
cd services/notification-service && mvn spring-boot:run # port 8083
cd services/api-gateway        && mvn spring-boot:run   # port 8080

# Verify:
curl http://localhost:8080/api/teams    # []
curl http://localhost:8080/api/tasks    # []
```

Full startup guide with database setup: `docs/requirements.md`.  
API contracts with example requests: `docs/api-contracts.md`.  
Interactive Swagger UI at `/swagger-ui.html` on each service port.

## Project structure

```
task-board-platform/
├── services/
│   ├── api-gateway/              # Spring Cloud Gateway — single entry point
│   ├── task-service/             # Task CRUD + RabbitMQ event publisher
│   ├── team-service/             # Team and member management
│   └── notification-service/     # RabbitMQ consumer + notification REST API
├── frontend/                     # Next.js application
├── infrastructure/               # Scripts, Docker, Kubernetes
├── docs/                         # Architecture, API contracts, requirements
└── CHALLENGE.md                  # Infrastructure challenges (group project)
```

## Documentation

| File | What it covers |
|------|---------------|
| `services/README.md` | Backend services: tech stack, ports, dependencies, configuration |
| `frontend/README.md` | Frontend architecture: stores, repositories, proxy, pages |
| `docs/architecture.md` | Deep dive: communication patterns, event system, database strategy |
| `docs/api-contracts.md` | Complete API reference with request/response examples |
| `docs/requirements.md` | Prerequisites, database setup, environment configuration |
| `CHALLENGE.md` | Infrastructure challenges for containerisation, K8s, observability |
