# First Stage: Build the application
FROM maven:3.8.5-openjdk-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml and install dependencies
COPY pom.xml ./
RUN mvn dependency:go-offline

# Copy the rest of the project and build the application
COPY src ./src
RUN mvn package

# Second Stage: Create a minimal image for running the JAR
FROM openjdk:17-jdk-slim AS runtime

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/imagegenerator-0.0.1-SNAPSHOT.jar /app/imagegenerator.jar

# Set the entrypoint to run the application
ENTRYPOINT ["java", "-jar", "/app/imagegenerator.jar"]
