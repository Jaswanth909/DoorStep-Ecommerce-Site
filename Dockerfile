# Multi-stage build for DoorStep Backend
# Stage 1: Build the application
FROM maven:3.8.1-openjdk-11 as builder

WORKDIR /app

# Copy pom.xml and source code
COPY backend/pom.xml .
COPY backend/src ./src

# Build the application
RUN mvn clean install -DskipTests

# Stage 2: Runtime image
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=builder /app/target/doorstep-*.jar app.jar

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8080

# Expose the port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD java -cp app.jar org.springframework.boot.loader.JarLauncher || exit 1

# Run the application
CMD ["java", "-Xmx512m", "-jar", "app.jar"]
