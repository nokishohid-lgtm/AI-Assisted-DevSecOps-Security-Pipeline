FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

USER root:root

ENTRYPOINT ["java", "-version"]