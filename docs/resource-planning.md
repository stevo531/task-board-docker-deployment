# Resource Allocations and Sizing Justification

## 1. Resource Matrix

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|---|---|---|---|---|
| Gateway | 150m | 500m | 180Mi | 300Mi |
| Task Service | 150m | 500m | 180Mi | 300Mi |
| Team Service | 150m | 500m | 180Mi | 300Mi |
| Notification Service | 150m | 500m | 180Mi | 300Mi |
| Frontend | 50m | 150m | 64Mi | 128Mi |
| MySQL | 250m | 500m | 256Mi | 512Mi |
| RabbitMQ | 100m | 250m | 128Mi | 256Mi |

## 2. Rationale
* **JVM Services:** Heap allocation combined with metaspace overhead requires ~180Mi baseline, with limits set at 300Mi to protect against OOMKills.
* **Database & Messaging:** MySQL requires a minimum of 256Mi memory to keep standard InnoDB buffers active. RabbitMQ lightweight Alpine images run comfortably within 128Mi–256Mi.