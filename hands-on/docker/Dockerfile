FROM openjdk:17-alpine AS builder
WORKDIR /app
COPY . .
RUN apk update && apk add maven
RUN mvn package -DskipTests

FROM openjdk:17-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080

# ENTRYPOINT defines the executable
ENTRYPOINT ["java", "-jar"]

# CMD provides default arguments (can be overridden)
CMD ["app.jar"]

# ENTRYPOINT ["java", "-jar"]  +  CMD ["app.jar"]
# java -jar app.jar