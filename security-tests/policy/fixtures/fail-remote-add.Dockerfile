FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

ADD https://example.com/example.jar /app/example.jar

USER appuser
