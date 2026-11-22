FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

WORKDIR /build

COPY pom.xml ./pom.xml
COPY services/task-service/pom.xml ./services/task-service/pom.xml

RUN mvn dependency:go-offline -B -f services/task-service/pom.xml

COPY services/task-service/src ./services/task-service/src
RUN mvn clean package spring-boot:repackage -DskipTests -f services/task-service/pom.xml -Dproject.build.outputTimestamp=2026-01-01T00:00:00Z

WORKDIR /build/extracted
# Updated to use layertools extract for compatible Spring Boot layer extraction
RUN java -Djarmode=layertools -jar /build/services/task-service/target/*.jar extract

# ADDED java.desktop TO THE --add-modules LIST BELOW:
RUN $JAVA_HOME/bin/jlink \
    --add-modules java.base,java.logging,java.net.http,java.sql,java.management,java.naming,java.security.jgss,java.instrument,java.desktop,jdk.unsupported \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /custom-jre

FROM alpine:3.19.1

RUN apk add --no-cache curl tzdata
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /custom-jre /opt/jre

COPY --from=builder /build/extracted/dependencies/ ./
COPY --from=builder /build/extracted/spring-boot-loader/ ./
COPY --from=builder /build/extracted/snapshot-dependencies/ ./
COPY --from=builder /build/extracted/application/ ./

RUN chown -R appuser:appgroup /app /tmp

ENV PATH="/opt/jre/bin:$PATH" \
    PORT=8080 \
    JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=/tmp -Duser.home=/tmp"

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=3s --start-period=20s --retries=3 \
  CMD curl -f http://localhost:${PORT}/actuator/health || exit 1

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]