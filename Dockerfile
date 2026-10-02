FROM maven:3.9-eclipse-temurin-17-alpine AS build

WORKDIR /workspace

COPY pom.xml .
RUN mvn --batch-mode dependency:go-offline

COPY src ./src
RUN mvn --batch-mode clean test compile

FROM eclipse-temurin:17-jre-alpine

RUN apk upgrade --no-cache && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup
    WORKDIR /app

COPY --from=build --chown=appuser:appgroup \
    /workspace/target/classes ./classes

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-cp", "classes", "com.nokishohid.devsecops.SecurityApplication"]