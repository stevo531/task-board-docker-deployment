# ---------- Build Stage ----------
FROM maven:3.9.11-eclipse-temurin-17 AS builder

WORKDIR /workspace

# Copy the entire project because notification-service depends on the parent POM
COPY . .

# Build only notification-service and anything it depends on
RUN mvn -pl services/notification-service -am clean package -DskipTests


# ---------- Runtime Stage ----------
FROM eclipse-temurin:17-jre

RUN apt-get update && \
    apt-get-install -y curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /workspace/services/notification-service/target/*.jar app.jar

# Create non-root user
RUN useradd -r -u 1001 spring \
    && mkdir -p /tmp \
    && chown -R spring:spring /app /tmp

USER spring

EXPOSE 8083

ENV JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=/tmp"
ENV SERVER_PORT=8083

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
CMD curl -fsS http://localhost:8083/actuator/health || exit 1

ENTRYPOINT ["java","-jar","app.jar"]