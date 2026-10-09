FROM eclipse-temurin

WORKDIR /app

USER appuser

ENTRYPOINT ["java", "-version"]