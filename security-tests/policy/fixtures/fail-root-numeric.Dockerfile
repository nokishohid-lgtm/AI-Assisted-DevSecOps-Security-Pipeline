FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

USER 0

ENTRYPOINT ["java", "-version"]