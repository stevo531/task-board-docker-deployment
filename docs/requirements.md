# Requirements

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Java | 17+ | Run Spring Boot services |
| Maven | 3.8+ | Build Java services |
| MySQL | 8.0+ | Primary datastore |
| RabbitMQ | 3.12+ | Async event broker |
| Node.js | 20+ (LTS) | Build and run frontend |
| pnpm | 8+ | Frontend package manager |

## Database setup

Connect to MySQL and create the required databases:

```sql
CREATE DATABASE taskdb;
CREATE DATABASE teamdb;
CREATE DATABASE notificationdb;

```

## RabbitMQ setup

Start RabbitMQ on default settings (port 5672, management UI on 15672):

```bash
# Native install
rabbitmq-server

# Or via Docker
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management
```

Management UI: `http://localhost:15672` (guest/guest)

## Configuration

Default configuration in each service's `application.yml`:

| Property | Default | Description |
|----------|---------|-------------|
| `spring.datasource.url` | `jdbc:mysql://localhost:3306/{service_db}` | MySQL connection URL |
| `spring.datasource.username` | `root` | MySQL user |
| `spring.datasource.password` | `password` | MySQL password |
| `spring.rabbitmq.host` | `localhost` | RabbitMQ host |
| `spring.rabbitmq.port` | `5672` | RabbitMQ port |

Override via environment variables (Spring Boot convention):
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `SPRING_RABBITMQ_HOST`
- `SPRING_RABBITMQ_PORT`

Or create an `application-local.yml` in the service's `src/main/resources/` directory — Spring Boot loads it automatically when the `local` profile is active.

## Startup order

Services depend on each other and must start in order:

1. MySQL + RabbitMQ (prerequisites)
2. Team Service (no dependencies)
3. Task Service (depends on Team Service + RabbitMQ)
4. Notification Service (depends on RabbitMQ)
5. API Gateway (depends on all backend services)
6. Frontend (depends on Gateway)
