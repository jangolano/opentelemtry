FROM --platform=linux/amd64 eclipse-temurin:24-jdk AS build
WORKDIR /app
COPY . .
RUN ./gradlew bootJar --no-daemon

FROM --platform=linux/amd64 eclipse-temurin:24-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "--add-opens", "java.base/sun.misc=ALL-UNNAMED", "-jar", "app.jar"]
