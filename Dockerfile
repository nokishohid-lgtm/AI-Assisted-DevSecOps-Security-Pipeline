
FROM maven:3.9-eclipse-temurin-25-alpine AS build

WORKDIR /workspace

COPY pom.xml .
RUN mvn --batch-mode dependency:go-offline

COPY src ./src
RUN mvn --batch-mode clean test compile

FROM eclipse-temurin:25-jre-alpine

# Remediate the Alpine Expat vulnerability during image build.
RUN apk add --no-cache 'expat>=2.9.0-r0' 'libexpat>=2.9.0-r0'

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=build --chown=appuser:appgroup \
    /workspace/target/classes ./classes

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-cp", "classes", "com.nokishohid.devsecops.SecurityApplication"]
