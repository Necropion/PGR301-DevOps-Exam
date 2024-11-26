FROM maven:3.8.5-openjdk-17 AS build

WORKDIR /app

COPY pom.xml ./
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package

FROM openjdk:17-jdk-slim AS runtime

WORKDIR /app

COPY --from=build /app/target/imagegenerator-0.0.1-SNAPSHOT.jar /app/imagegenerator.jar

ENTRYPOINT ["java", "-jar", "/app/imagegenerator.jar"]
