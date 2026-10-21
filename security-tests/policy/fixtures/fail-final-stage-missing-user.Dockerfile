FROM maven:3.9-eclipse-temurin-17-alpine AS build

WORKDIR /workspace

USER builder

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

ENTRYPOINT ["java", "-version"]
