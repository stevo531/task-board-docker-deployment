FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn -N install -B

COPY services/team-service/pom.xml services/team-service/pom.xml
COPY services/team-service/src services/team-service/src

RUN mvn -f services/team-service/pom.xml clean package -DskipTests -B

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

RUN apk add --no-cache wget && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    mkdir -p /app/tmp && \
    chown -R appuser:appgroup /app

USER appuser

COPY --from=builder /app/services/team-service/target/team-service-1.0.0.jar app.jar

EXPOSE 8082

HEALTHCHECK --interval=30s \
            --timeout=5s \
            --start-period=20s \
            --retries=3 \
CMD wget -q --spider http://localhost:8082/api/teams || exit 1

ENTRYPOINT ["java","-Djava.io.tmpdir=/app/tmp","-jar","app.jar"]