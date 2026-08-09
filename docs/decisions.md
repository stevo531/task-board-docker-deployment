# Architecture Decisions (ADR)

## ADR 1: Local Startup Script Design (Challenge 1)

### Status:
Accepted
### Context:
Need a single-command mechanism to validate prerequisites, prepare databases, and launch all platform services in sequential dependency order.

### Alternatives Considered
1. **Docker Compose:** Handled in Challenge 3.
2. **Native Bash Process Orchestration:** Selected for `start-local.sh` to meet bare-metal execution constraints.

### Decision
Utilized a native Bash script (`infrastructure/scripts/start-local.sh`) that reads standard `.env` variables, initializes MySQL schemas, checks service readiness using `curl` against HTTp ports, and manages background PIDs with an explicit `SIGINT` `SIGTERM` and `EXIT` signals to clean up background PIDs.