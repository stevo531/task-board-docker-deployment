# Health Probes Architecture and Strategy

## 1. Overview
Modifying service application code (such as adding Spring Boot Actuator dependencies) is strictly prohibited. Therefore, Kubernetes-native probe mechanisms (`tcpSocket` and `exec`) are used across all services.

## 2. Probe Selections
* **Application Microservices (Spring Boot & Frontend):**
    * Probes use `tcpSocket` checks targeting the designated container service port.
    * `startupProbe` handles slow JVM cold boots without triggering aggressive container restarts.
    * `readinessProbe` verifies port binding to ensure traffic routes only when ready.
    * `livenessProbe` runs less frequently to detect deadlocked application runtime states.
* **Stateful Databases (MySQL & RabbitMQ):**
    * `exec` probes run native diagnostic CLI utilities (`mysqladmin ping`, `rabbitmq-diagnostics ping`) directly inside the containers to confirm data plane responsiveness.

## 3. Readiness vs. Liveness Trade-offs
* **Readiness Failures:** Unready pods are immediately removed from endpoint slices. The pod is isolated from network traffic but is **never restarted**.
* **Liveness Failures:** Triggered only when a container is completely hung or unresponsive. Recreates the container instance.