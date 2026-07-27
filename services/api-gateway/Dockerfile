# --- Stage 1: Build Stage ---
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy the parent pom and the service pom/source
COPY pom.xml ./
COPY services/api-gateway/pom.xml ./services/api-gateway/
COPY services/api-gateway/src ./services/api-gateway/src

# Build from the service directory
WORKDIR /app/services/api-gateway
RUN mvn clean package -DskipTests

# --- Stage 2: Runtime Stage (Lean Alpine + Headless JRE) ---
FROM eclipse-temurin:17-jre-alpine

# Install wget for health checks cleanly without bloating
RUN apk add --no-cache wget

# Create a non-root system user and group for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy the compiled jar from the builder stage
COPY --from=builder /app/services/api-gateway/target/*.jar app.jar

# Change ownership of the app directory to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Expose port 8080
EXPOSE 8080

# Add a native HEALTHCHECK instruction
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]