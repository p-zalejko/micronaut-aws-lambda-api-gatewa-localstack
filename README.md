# Micronaut application launched as an AWS Lambda

- Micronaut
- Java 17
- Native image
- Maven
- AWS Lambda
- AWS API Gateway
- Docker

# Resources

Localstack https://localstack.cloud/

Micronaut https://guides.micronaut.io/latest/mn-application-aws-lambda-graalvm-maven-java.html

# How to

## Build a lambda function

``` 
./mvnw package -Dpackaging=docker-native -Dmicronaut.runtime=lambda -Pgraalvm
```

## Launch Localstack (docker)

```
docker-compose up
```

## Configure a function

```
./setup.sh
```

As a result, all AWS artifacts will be created (a lambda function, API resources and so on). At the end of the script a
GET and POST requests are executed.