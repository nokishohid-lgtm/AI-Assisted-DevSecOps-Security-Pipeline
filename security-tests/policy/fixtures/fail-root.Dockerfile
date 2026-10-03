FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

USER root

ENTRYPOINT ["java", "-version"]
