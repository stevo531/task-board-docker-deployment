# ---------- Build Stage ----------
FROM maven:3.9.11-eclipse-temurin-21 AS builder

WORKDIR /build

COPY ../../pom.xml .
COPY ../../services ./services

WORKDIR /build/services/notification-service

RUN mvn clean package -DskipTests


# ---------- Runtime Stage ----------
FROM eclipse-temurin:21-jre

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/
    
RUN useradd --system --uid 1001 spring    

WORKDIR /app

COPY --from=builder /build/services/notification-service/target/*.jar app.jar

RUN mkdir -p /app/tmp && \
    chown -R spring:spring /app /tmp

USER spring    

EXPOSE 8083

ENV SERVER_PORT=8083
ENV JAVA_OPTS="Djava.io.tmpdir=/tmp"


HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
CMD curl -fsS http://localhost:8083/actuator/health || exit 1

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]