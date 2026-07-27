# ---------- Build Stage ----------
FROM maven:3.9.11-eclipse-temurin-21 AS builder

WORKDIR /build

COPY ../../pom.xml .
COPY ../../services ./services

WORKDIR /build/services/notification-service

RUN mvn clean package -DskipTests


# ---------- Runtime Stage ----------
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=builder \
/build/services/notification-service/target/*.jar \
app.jar

EXPOSE 8083

ENV JAVA_OPTS=""
ENV SERVER_PORT=8083

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
CMD curl -f http://localhost:8083/actuator/health || exit 1

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]