# Stage 1: Build front-end
FROM node:22-bookworm-slim AS frontend

WORKDIR /app
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend .
RUN npm run build

# Stage 2: Build Java App
FROM eclipse-temurin:21-jdk AS build_app
WORKDIR /app
RUN rm -rf src/main/resources/static && mkdir -p src/main/resources/static
COPY --from=frontend /app/dist src/main/resources/static
COPY gradlew build.gradle.kts ./
COPY gradle ./gradle
RUN ./gradlew --no-daemon dependencies
COPY src ./src
RUN ./gradlew --no-daemon build
RUN cp build/libs/app-*-SNAPSHOT.jar app.jar

# Stage 3: Runtime
FROM eclipse-temurin:21-jre-jammy AS app
WORKDIR /app
RUN useradd -u 1001 -r -m app
USER app
COPY --from=build_app --chown=app:app /app/app.jar app.jar
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
