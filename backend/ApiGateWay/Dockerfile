FROM maven:3.9.9-eclipse-temurin-17-alpine AS build
WORKDIR /workspace

# Copy pom.xml first for better layer caching
COPY pom.xml .
# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build application
RUN mvn -B clean package -DskipTests && \
    rm -rf /root/.m2

# Runtime stage with alpine JRE for smaller image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Copy jar file
COPY --from=build --chown=appuser:appuser /workspace/target/apigate-0.0.1-SNAPSHOT.jar app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
