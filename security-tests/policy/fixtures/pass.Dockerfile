FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY app.jar /app/app.jar

USER appuser

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
